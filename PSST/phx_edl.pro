pro phx_edl
  dlm_register,'C:\Users\jeppesen\Documents\LocalApps\spice\icy64_7\lib\icy.dlm'
  device,decompose=0
  loadct,39

  ;Set up time ranges and other spacecraft-specific things
  Phoenix=0
  MSL=1
  downsample=1
  if keyword_set(Phoenix) then begin
    et0=265030323.10503286d
    dt=0.005d
    n=90572
    et1=et0+dt*n
    et=et0+dindgen(n)*dt
    cspice_furnsh,'Phoenix.tm'
    target='PHX'
    edl_oufn='phx_edl.inc'
  end
  if keyword_set(MSL) then begin
    cd,'Data/spice/MSL'
    cspice_furnsh,'msl.tm'
    cd,'../../..'
    et=msl_edl_t()
    et0=et[0]
    n=n_elements(et)
    et1=et[n-1]
    target='MSL'
    edl_oufn='Data/spice/msl_edl.inc'
    RoverMass=850
    DryDescent=829
    DescentProp=390
    HeatShield=382
    EntryBalance=6*29
    Backshell=349
    CruiseBalance=2*75
    CruiseWet=600
    EntryMass=RoverMass+DryDescent+DescentProp+HeatShield+EntryBalance+Backshell
    D=4.5
    A=!dpi*D^2/4d
    
  end
  fps=24
  et_fps=et0+dindgen((et1-et0)*fps)/fps
  n_frames=n_elements(et_fps)
  if keyword_set(downsample) then begin
    et=et_fps
    n=n_frames
  end

  ;Calculate state vectors
  state_iau_mars=dblarr(n,6)
  state_j2000=dblarr(n,6)
  state_mme=dblarr(n,6)
  sun_mme=dblarr(n,3)
  earth_mme=dblarr(n,3)
  utcc=strarr(n)
  utcd=strarr(n)
  for i=0,n-1 do begin
    cspice_timout,et[i],'YYYY-MM-DDTHR:MN:SC.### ::UTC',30,tutc & utcc[i]=tutc
    cspice_timout,et[i],'YYYY-DOYTHR:MN:SC.### ::UTC',30,tutc & utcd[i]=tutc
    cspice_spkezr,target,et[i],'PHX_MME_2000','NONE','MARS',state,ltime & state_mme[i,*]=state
    cspice_spkezr,target,et[i],'J2000','NONE','MARS',state,ltime & state_j2000[i,*]=state
    cspice_spkezr,target,et[i],'IAU_MARS','NONE','MARS',state,ltime & state_iau_mars[i,*]=state
    cspice_spkezr,'SUN',et[i],'PHX_MME_2000','NONE','MARS',state,ltime & sun_mme[i,*]=state[0:2]*1000
    cspice_spkezr,'399',et[i],'PHX_MME_2000','NONE','MARS',state,ltime & earth_mme[i,*]=state[0:2]*1000
  end
  dt=et-shift(et,1)
  dt[0]=dt[1]
  
  ;Ensure correct units and array dimensions
  if (size(state_iau_mars,/dim))[0] eq 6 then state_iau_mars=transpose(state_iau_mars)
  if vlength(state_iau_mars[0,0:2]) lt 1d6 then state_iau_mars*=1d3
  if (size(state_j2000,/dim))[0] eq 6 then state_j2000=transpose(state_j2000)
  if vlength(state_j2000[0,0:2]) lt 1d6 then state_j2000*=1d3
  if (size(state_mme,/dim))[0] eq 6 then state_mme=transpose(state_mme)
  if vlength(state_mme[0,0:2]) lt 1d6 then state_mme*=1d3

  ;Select the inertial and relative frames to use from here down  
  r_rel=state_iau_mars[*,0:2]
  v_rel=state_iau_mars[*,3:5]
  r_i=state_mme[*,0:2]
  v_i=state_mme[*,3:5]
  tau=2*!dpi ;tau manifesto
  wind=crossp_grid([0,0,350.89198226/86400d/360d*tau],r_i)
  v_rel_mme=v_i-wind

  if keyword_set(Phoenix) then begin
    ;This part is Phoenix specific
    ;The spice kernel data is a blend of a top-down solution from the final
    ;orbit-determined entry state vector and a bottom-up soltion from the final 
    ;determination of the landing site. Unfortunately, that means that the position
    ;has imposed on it a change of ~700m in ~420s, so about 1m/s, which is not
    ;physical or accounted for in the velocity. In the upper atmosphere when we are
    ;traveling at 5500m/s, 1m/s doesn't matter, but at landing it does, so we do the following:
    ;1) From entry to peak deceleration, use the official numbers
    ;2) From parachute firing to landing, use bottom-up integration
    ;3) In between, do a linear blend 
    r_rel_from_v=r_rel
    r_rel_blend=r_rel
    r_i_from_v=r_i
    r_i_blend=r_i
    w1=max(where(et-et[0] lt 122.955)) ;time of peak deceleration, 82.962m/s^2
    w2=max(where(et-et[0] lt 227.825)) ;time of parachute firing
    w3=max(where(et-et[0] lt 404.940)) ;time of lander separation
    ww=[w1,w2]
    ;Step through things backwards, so that we get the integration from the ground up
    for i=n_elements(et)-2,0,-1 do begin
      ;Euler integration of velocity to get position, using final state vector as initial (final?) condition.
      r_rel_from_v[i,*]=r_rel_from_v[i+1,*]-v_rel[i,*]*dt[i]
      r_i_from_v[i,*]=r_i_from_v[i+1,*]-v_i[i,*]*dt[i]
      if i lt w1 then begin
        ;Before peak heating, use official r_rel
        r_rel_blend[i,*]=r_rel[i,*]
      end else if i gt w2 then begin
        ;After parachute firing, use ground-up integration
        r_rel_blend[i,*]=r_rel_from_v[i,*]
      end else begin
        ;In between, linear blend
        r_rel_blend[i,*]=linterp(double(w1),r_rel[i,*],double(w2),r_rel_from_v[i,*],double(i))
      end
    end
    
    ;Draw some plots showing the difference between official, from_v, and blend
    window,0
    plot, et-et[0],r_rel[*,0]-r_rel_from_v[*,0],/ynoz,charsize=2,yrange=[-1000,1000],/ys, $
         title='Difference between kernel and integrated position', ytitle='Difference/m',xtitle='Time from start of kernel/s',/nodata
    oplot,et-et[0],r_rel[*,0]-r_rel_from_v[*,0],color=254
    oplot,et-et[0],r_rel[*,1]-r_rel_from_v[*,1],color=140
    oplot,et-et[0],r_rel[*,2]-r_rel_from_v[*,2],color= 64
    oplot,et-et[0],vlength(r_rel[*,*]-r_rel_from_v[*,*]),color=255
    oplot,et[ww]-et[0],r_rel[ww,0]-r_rel_from_v[ww,0],color=254,psym=1
    oplot,et[ww]-et[0],r_rel[ww,1]-r_rel_from_v[ww,1],color=140,psym=1
    oplot,et[ww]-et[0],r_rel[ww,2]-r_rel_from_v[ww,2],color= 64,psym=1
    oplot,et[ww]-et[0],vlength(r_rel[ww,*]-r_rel_from_v[ww,*]),color=255,psym=1
    xyouts,et[ww]-et[0],vlength(r_rel[ww,*]-r_rel_from_v[ww,*]),['Start of blend','End of blend']
    
    window,1
    plot, et-et[0],r_rel_from_v[*,0]-r_rel_blend[*,0],/ynoz,charsize=2,yrange=[-1000,1000],/ys,/nodata, $
         title='Difference between blended and integrated position', ytitle='Difference/m',xtitle='Time from start of kernel/s'
    oplot,et-et[0],r_rel_from_v[*,0]-r_rel_blend[*,0],color=254
    oplot,et-et[0],r_rel_from_v[*,1]-r_rel_blend[*,1],color=140
    oplot,et-et[0],r_rel_from_v[*,2]-r_rel_blend[*,2],color= 64
    oplot,et-et[0],vlength(r_rel_from_v[*,*]-r_rel_blend[*,*]),color=255
    oplot,et[ww]-et[0],r_rel_from_v[ww,0]-r_rel_blend[ww,0],color=254,psym=1
    oplot,et[ww]-et[0],r_rel_from_v[ww,1]-r_rel_blend[ww,1],color=140,psym=1
    oplot,et[ww]-et[0],r_rel_from_v[ww,2]-r_rel_blend[ww,2],color= 64,psym=1
    oplot,et[ww]-et[0],vlength(r_rel_from_v[ww,*]-r_rel_blend[ww,*]),color=255,psym=1
    xyouts,et[ww]-et[0],vlength(r_rel_from_v[ww,*]-r_rel_blend[ww,*]),['Start of blend','End of blend']

    window,2
    plot, et-et[0],r_rel[*,0]-r_rel_blend[*,0],/ynoz,charsize=2,yrange=[-1000,1000],/ys,/nodata, $
         title='Difference between kernel and blended position', ytitle='Difference/m',xtitle='Time from start of kernel/s'
    oplot,et-et[0],r_rel[*,0]-r_rel_blend[*,0],color=254
    oplot,et-et[0],r_rel[*,1]-r_rel_blend[*,1],color=140
    oplot,et-et[0],r_rel[*,2]-r_rel_blend[*,2],color= 64
    oplot,et-et[0],vlength(r_rel[*,*]-r_rel_blend[*,*]),color=255
    oplot,et[ww]-et[0],r_rel[ww,0]-r_rel_blend[ww,0],color=254,psym=1
    oplot,et[ww]-et[0],r_rel[ww,1]-r_rel_blend[ww,1],color=140,psym=1
    oplot,et[ww]-et[0],r_rel[ww,2]-r_rel_blend[ww,2],color= 64,psym=1
    oplot,et[ww]-et[0],vlength(r_rel[ww,*]-r_rel_blend[ww,*]),color=255,psym=1
    xyouts,et[ww]-et[0],vlength(r_rel[ww,*]-r_rel_blend[ww,*]),['Start of blend','End of blend']

    ;Use the blends officially from now on
    r_i=r_i_blend
    r_rel=r_rel_blend
    junk=temporary(r_i_blend)
    junk=temporary(r_rel_blend)
    junk=0
  end

  ;Run the Mars model to figure atmosphere, altitude, and gravity
  mars_model,r_rel,adlat=lat,lon_rel=lon,lon_i=lon_i,h=h,alt=alt,rho=rho,agl=agl,csound=csound,r_i,g=g,mars_a=mars_a,mars_b=mars_b
  cspice_kclear ; Don't need spice anymore.
  lat2=lat[n_elements(et)-1]
  lon2=lon[n_elements(et)-1]
  dist=ell_dist(lat,lon,lat2,lon2,a=mars_a,b=mars_b,/rad,ell_az=az)
  plot,et-et[0],dist

  dr_rel=r_rel[1:n_elements(et)-1,*]-r_rel[0:n_elements(et)-2,*]

  zh=llr_to_xyz([[lat],[lon_i],[lat*0d +1d]])
  eh=normalize_grid(crossp_grid([0,0,1],zh))
  nh=crossp_grid(zh,eh)
  ve=comp(v_rel_mme,eh)
  vn=comp(v_rel_mme,nh)
  vz=comp(v_rel_mme,zh)
  vh=sqrt(ve^2+vn^2)
  vaz=atan(ve,vn)
  w=where(vaz lt 0,count)
  if count gt 0 then vaz[w]+=2d*!dpi

  airspd=vlength(v_rel_mme)
  spd_i=vlength(v_i)
  dv_i=v_i[1:n_elements(et)-1,*]-v_i[0:n_elements(et)-2,*]
  dr_i=r_i[1:n_elements(et)-1,*]-r_i[0:n_elements(et)-2,*]
  a_i=dv_i/[[dt],[dt],[dt]]
  dr_dt_rel=dr_rel/[[dt],[dt],[dt]]
  a_ng=a_i-g
  

;for i=0,440,5 do begin
;  plot,et-et[0],agl,xrange=[i,i+20],xtitle="Seconds from "+utc_start+"UTC",ytitle="Nongravitational acceleration, m/s^2", title="Phoenix Parachute opening",charsize=2,background=255,color=0,/xs
;  wait,0.5
;end

w=where(et-et[0] gt 0)
lon0=lon[n_elements(lon)-1]
lat0=lat[n_elements(lat)-1]
;plot,(lon[w]-lon0)*sin(lat[w])*a,(lat[w]-lat0)*a,/ynoz,/isotropic

dr_dt_e=comp(v_rel,eh)
dr_dt_n=comp(v_rel,nh)
dr_dt_z=comp(v_rel,zh)

q=airspd^2*rho/2.0d
mach=airspd/csound

  a_drag=a_ng*0
  tt=normalize_grid(v_rel_mme) ;tangential vector, unit vector parallel to local relative speed in IAU_MME
  ww=normalize_grid(crossp_grid(zh,tt)) ;Out of plane vector, perpendicular to t and in horizontal plane, positive is north of plane
  nn=normalize_grid(crossp_grid(tt,ww)) ;Normal vector, perpendicular to t and towards local vertical
  a_drag[*,0]=comp(a_ng,tt[0:n-2,*])
  a_drag[*,1]=comp(a_ng,ww[0:n-2,*])
  a_drag[*,2]=comp(a_ng,nn[0:n-2,*])
  
  c_d=-a_drag[*,0]*EntryMass/(q*A)
  c_y=a_drag[*,1]*EntryMass/(q*A)
  c_l=a_drag[*,2]*EntryMass/(q*A)
  plot,et-et[0],c_d,yrange=[-2,2],background=255,color=0,xtitle='Seconds from kernel start',ytitle='Drag Coefficient (red), Side Coefficient (green), Lift Coefficient (blue)'
  oplot,et-et[0],c_d,color=254
  oplot,et-et[0],c_l,color=60
  oplot,et-et[0],c_y,color=140
  
window,0
  plot,et-et[0],a_drag[*,0],yrange=[-1.2,1.2]*max(vlength(a_drag)),/ys,xtitle="Seconds from kernel start",ytitle="Non-gravitational acceleration/(m/s^2)",/nodata
  oplot,et-et[0],a_drag[*,0],color=254
;  oplot,et-et[0],(kalman_velocity(a_drag[*,0],et-et[0],10,1)).xh_filt[0,*]
  oplot,et-et[0],a_drag[*,1],color=140
;  oplot,et-et[0],(kalman_velocity(a_drag[*,1],et-et[0],10,1)).xh_filt[0,*]
  oplot,et-et[0],a_drag[*,2],color= 64
;  oplot,et-et[0],(kalman_velocity(a_drag[*,2],et-et[0],10,1)).xh_filt[0,*]

window,2
  plot,et-et[0],sqrt(a_drag[*,2]^2+a_drag[*,1]^2)/abs(a_drag[*,0]),yrange=[0,0.5],/ys,xtitle="Seconds from kernel start",ytitle="L/D ratio"
  oplot,et-et[0],vlength(a_ng)*0.005,color=254


window,1  
plot,et-et[0],agl/1000,/ys,xtitle="Seconds from kernel start",ytitle="Altitude above landing site, m",charsize=2,background=255,color=0,/xs
oplot,et-et[0],vlength(a_ng),color=254

  openw,/get_lun,ouf,edl_oufn
  printf,ouf,'//All distances in meters, all time in seconds, all angles in radians, all derived units in SI primary derived units
  printf,ouf,'//i - Zero-based frame number'
  printf,ouf,'//utc - SCET(UTC) of this frame, in ISO date format'
  printf,ouf,'//et - SCET(ET) of this frame, in seconds since J2000 ET epoch'
  printf,ouf,'//deltaet - time from frame zero, in seconds'
  printf,ouf,'//r=<rx,ry,rz> - Vector from center of Mars to spacecraft in MME frame in meters'
  printf,ouf,'//v=<vx,vy,vz> - Relative velocity vector of spacecraft in MME frame in m/s. Airspeed, discounting local wind'
  printf,ouf,'//s=<sx,sy,sz> - Vector from center of Mars to center of Sun in MME frame, in meters'
  printf,ouf,'//e=<ex,ey,ez> - Vector from center of Mars to center of Earth (not Earth-Moon Barycenter) in MME frame, in meters'
  printf,ouf,'//l=<lx,ly,lz> - Local vertical in MME, unit vector' 
  printf,ouf,'//t=<tx,ty,tz> - Tangential vector - parallel to relative velocity in MME, unit vector' 
  printf,ouf,'//w=<wx,wy,wz> - Side vector - Perpendicular to T and local vertical, therefore in local horizon plane, in MME, unit vector' 
  printf,ouf,'//n=<nx,ny,nz> - Normal vector - Perpendicular to T and W, therefore towards local vertical, in MME, unit vector' 
  printf,ouf,'//ad=<adx,ady,adz> - Non-gravitation acceleration in TWN frame, so components are (negative) drag, side lift, up lift, m/s^2'
  printf,ouf,'//rho,agl,alt,h - atmospheric density, altitude above ground level, altitude above aeroid, altitude above ellipsoid
  printf,ouf,'//csound,dist,az - speed of sound, distance along ellipsoid, and azimuth of geodesic from sub-spacecraft point to sub-landing point 
  printf,ouf,format='(%"array[%5d][33] {")',n-1
  printf,ouf,'//                                  0                     1                      2                  3                  4                  5                  6                  7                  8                  9                 10                 11                 12                 13                 14                 15                 16                 17                 18                 19                 20                 21                 22                 23                 24                 25                 26                 27                 28                 29                 30                 31                 32                33                 34                 35'
  printf,ouf,'//     i,utc,                      et,                   deltaet,               rx,                ry,                rz,                vx,                vy,                vz,                sx,                sy,                sz,                ex,                ey,                ez,                lx,                ly,                lz,                tx,                ty,                tz,                wx,                wy,                wz,                nx,                ny,                nz,                adx,               ady,               adz                rho                agl                alt                h                 csound             dist               az'
  for i=0,n-2 do begin ;-2 since we have one less drag measurement than state vector
    printf,ouf,format='(%"/*%6d,%s*/{%21.14e,%21.14e,' + $ i,utc,et,deltaet
                      '%18.10e,%18.10e,%18.10e,' + $ rx,ry,rz
                      '%18.10e,%18.10e,%18.10e,' + $ vx,vy,vz
                      '%18.10e,%18.10e,%18.10e,' + $ sx,sy,sz
                      '%18.10e,%18.10e,%18.10e,' + $ ex,ey,ez
                      '%18.10e,%18.10e,%18.10e,' + $ lx,ly,lz
                      '%18.10e,%18.10e,%18.10e,' + $ tx,ty,tz
                      '%18.10e,%18.10e,%18.10e,' + $ wx,wy,wz
                      '%18.10e,%18.10e,%18.10e,' + $ nx,ny,nz
                      '%18.10e,%18.10e,%18.10e,' + $ adx,ady,adz
                      '%18.10e,%18.10e,%18.10e,%18.10e' + $ rho,agl,alt,h
                      '%18.10e,%18.10e,%18.10e},")', $ csound,dist,az
                      i,utcc[i],et[i],et[i]-et0, $
                      r_i[i,0],r_i[i,1],r_i[i,2], $
                      v_rel_mme[i,0],v_rel_mme[i,1],v_rel_mme[i,2], $
                      sun_mme[i,0],sun_mme[i,1],sun_mme[i,2], $
                      earth_mme[i,0],earth_mme[i,1],earth_mme[i,2], $
                      zh[i,0],zh[i,1],zh[i,2], $
                      tt[i,0],tt[i,1],tt[i,2], $
                      ww[i,0],ww[i,1],ww[i,2], $
                      nn[i,0],nn[i,1],nn[i,2], $
                      a_drag[i,0],a_drag[i,1],a_drag[i,2], $
                      rho[i],agl[i],alt[i],h[i], $
                      csound[i],dist[i],az[i]
  end
  printf,ouf,'}'
  
  free_lun,ouf

  ;Resample all the relevant data to 30fps
  r_rel_fps=dblarr(n_frames,3)
  r_rel_fps[*,0]=interpol(r_rel[*,0],et-et[0],et_fps-et_fps[0])
  r_rel_fps[*,1]=interpol(r_rel[*,1],et-et[0],et_fps)
  r_rel_fps[*,2]=interpol(r_rel[*,2],et-et[0],et_fps)
  lat_fps=interpol(lat,et-et[0],et_fps)
  lon_fps=interpol(lon,et-et[0],et_fps)
  alt_fps=interpol(alt,et-et[0],et_fps)
  agl_fps=interpol(agl,et-et[0],et_fps)
  ve_fps=interpol(ve,et-et[0],et_fps)
  vn_fps=interpol(vn,et-et[0],et_fps)
  vz_fps=interpol(vz,et-et[0],et_fps)

;
;
;i_land=n_elements(et_fps)-1
;for i=0,n_elements(et_fps)-1 do begin
;  lat1=lat_fps[I]
;  lon1=lon_fps[I]
;  dist=ell_dist(lat1,lon1,lat2,lon2,a=a,b=b,h=alt2,/rad,ell_az=az)
;  vtol,ve_fps[I<I_land],vn_fps[I<I_land],vz_fps[I<I_land],agl_fps[i]-agl_fps[I_land],dist,az,string(I,format='(%"svg/VTOL%05d.svg")')
;  if i mod 100 eq 0 then print,i
; end
  print,'done'
end



