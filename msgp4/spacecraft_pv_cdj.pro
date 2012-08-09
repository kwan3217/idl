;IDL translation of spacecraft_pv from Barry Knapp's astronomy library. If you
;just have a TLE file and want a black box which converts time to position,
;this function is the one you want. It is the high-level interface to the
;IDL MSGP4 library.
;
; Chris Jeppesen, 2009-Oct-09. Draws heavily on code from Barry Knapp.
;
;input
;  satid        - NORAD satellite ID, from the second field of the first line
;                 of the two line element. The same satellite will always have
;                 the same satid.
;  jd           - scalar or N-element Array of UTC julian dates to calculate
;                 the state vector for
;  coorid=      - Selects the coordinates used for the output, either geocentric
;                 spherical (coorid=1) or rectangular (coorid=2, default)
;
;  tle_path=    - relative or absolute path to a folder with TLE files in it.
;                 If relative, it is relative to the current working directory.
;                 The TLE files should be in the specified folder and named
;                 string(format='(%"%08d.tle")',satid). For instance, AIM is
;                 satellite 31304, so its TLEs will be looked for in
;                 tle_path/00031304.tle . Default is '.', or in other words, it
;                 will look in the current directory.
;  /no_nutation - If set, the output coordinate system is true equator, mean
;                 equinox, the native coordinate system for SGP4. Default is to
;                 rotate the returned state vectors to the mean of date system.
;output
;  pv           - 6xN element array. Each row pv[*,i] is the state vector for
;                 jd[i]. Units are km and km/s, coordinate system is equatorial
;                 mean of date
;                 The coordinates used for the outputs may be either geocentric
;                 (coorid=1), rectangular (coorid=2, default). Angles are in
;                 degrees and distances in km.  Each output position is a 6-vector
;                 with elements as follows:
;
;      I   SPHERICAL                        RECTANGULAR
;
;      0   Right Ascension (deg, 0 to 360)  X (km)
;      1   Declination (deg, -90 to +90)    Y (km)
;      2   R (km)                           Z (km)
;      3   dRA/dT (deg/sec)                 dX/dT (km/sec)
;      4   dDec/dT (deg/sec)                dY/dT (km/sec)
;      5   dR/dT (km/sec)                   dZ/dT (km/sec)
;  pv_uncertainty=
;               - 6xN element array. Each element dpv[i,j] is the estimated
;                 1-sigma uncertainty in pv[i,j]. Units are km and km/s
;  interpolation_fraction=
;               - N element array, giving relative time from the epochs of the
;                 two TLEs which are closest to jd. For example, if you ask for
;                 a state vector at JD 2450001.5, and the closest TLE epochs
;                 for that spacecraft are JD 2450000 and 2450002, then the
;                 interpolation fraction is 0.75, since the date you asked for
;                 is 75% of the way from the first to the second element. If
;                 the time you ask for is not between the time of the two
;                 closest elements, f will be outside the range [0.0,1.0] but
;                 this is OK.
;  status=      - Status of propagation. N element array. If the propagation
;                 went ok for jd[i], then status[i] will equal zero. Otherwise
;                 some error occured. The program will still calculate a state
;                 vector pv[*,i] but it may not be valid.
;                   0 - no error
;                   1 - Elements invalid. ecc >= 1.0 or ecc < -0.001 or a < 0.95 er
;                   2 - Elements invalid. mean motion less than 0.0
;                   3 - Elements invalid. Perturbed ecc < 0.0  or > 1.0
;                   4 - Elements invalid. semi-latus rectum < 0.0
;                   5 - Elements are suborbital. Perigee is in atmosphere or
;                       underground. Calculated elements are valid if and only
;                       if the position doesn't pass through the earth or
;                       atmosphere at any time between the element epoch and
;                       the given time.
;                   6 - Calculated position is decayed. Position is in the
;                       atmosphere or underground.
;
;IDL Optimizations
;  The program attempts to use array operations as much as possible. If you
;  have a bunch of times, it is far more efficient to pass the whole array of
;  times as jd, rather than do a loop. If you are working with multiple
;  spacecraft, it is more efficient to do everything you want with one
;  spacecraft, and then do the next, rather than switch repeatedly between
;  spacecraft.
;  
;  In order to accomplish this, this program first figures out which times are 
;  going to be run against which elements, then calls the lower level SGP4 routine
;  with all of the times needed at once.
;  
;  This program also caches certain data, so that repeated calls with the same 
;  satellite are faster than would be otherwise.
;
;  This library does both SGP4 near-earth calculations, and SDP4 deep-space
;  calculations. In this case, any spacecraft with a period of more than
;  225min (3h45m) will be considered deep space. However, SDP4 is only valid
;  for earth-orbiting spacecraft, out to about halfway to the moon.
;  SDP4 is considerably slower than SGP4, but if that's what your spacecraft
;  is, that's what you have to use. The system automatically decides whether
;  to use SGP4 or SDP4, so this interface applies to both. You don't even
;  have to know if your spacecraft is deep space or not.
;
;Example
;  These examples all presume that the appropriate TLE files are in the current
;  working directory
;
;  To calculate the state at one time for AIM, satid=31304:
;
;  IDL> JD=yd2jd(2008278.0) ;2008/278, 2008-Oct-04 00:00:00UTC
;  IDL> spacecraft_pv,31304,JD,pv
;  IDL> help,pv
;  PV              DOUBLE    = Array[6]
;  IDL> print,pv
;      -2491.2787      -1575.6866       6313.2995      -6.7853865      -1.4207736      -3.0165613
;
;  To calculate the state for every minute of 2008-Oct-04
;
;  IDL> JD=yd2jd(2008278.0)+dindgen(1440)/1440d
;  IDL> spacecraft_pv,31304,JD,pv
;  IDL> help,pv
;PV              DOUBLE    = Array[6, 1440]
;  IDL> print,pv[*,720] ;position at 12:00UTC
;       610.04067       1147.8557      -6853.2829       7.2418177       1.9022097      0.97224672
;
;  Anti-example: This will work, but be MUCH slower than the alternative.
;
;  pv_aim =dblarr(6,n_elements(jd))
;  pv_uars=dblarr(6,n_elements(jd))
;  for i=0,n_elements(jd)-1 do
;    spacecraft_pv,31304,jd[i],this_pv & pv_aim [*,i]=this_pv ;(calculate one position for AIM)
;    spacecraft_pv,21701,jd[i],this_pv & pv_uars[*,i]=this_pv ;(calculate one position for UARS)
;  end
;
;  Instead, do this:
;
;  spacecraft_pv,31304,jd,pv_aim
;  spacecraft_pv,21701,jd,pv_uars
;
;Errors
;  The program will throw an IDL error if the TLE file it is looking for is not
;  found. Otherwise, errors are reported through the status= output parameter.
;
;Other notes
;  This function serves two purposes
;  *It is an interface to the lower-level SGP4/SDP4 code. As such, it adapts
;   code vastly different from the fortran astronomy library to the same
;   interface. This makes it a drop-in replacement for spacecraft_pv.f .
;  *It calculates the estimated uncertainty, using an alogorithm like that
;   of the old spacecraft_pv.
;
;  The underlying SGP4 code has an entirely different lineage. The old Fortran
;  version of the low level routines is basically unchanged from the original
;  Spacetrack Report #3, published in 1980. This version is from a modification
;  by David Vallado, published at http://celestrak.com/publications/AIAA/2006-6753/ .
;  The C code with that paper was translated to Java, then translated from Java
;  to IDL. Even so, it matches the results given by Vallado's C code to
;  eight or nine places after the decimal point. Therefore his extensive
;  documentation applies to this version of SGP4.
;
;  Even though the two programs are different in structure and implementation
;  language, they agree to within a few meters in most cases, and the main
;  difference between them is that the fortran version applies the nutation
;  correction calculated at the requested time, while this IDL version applies
;  it at the epoch of the first of the two TLEs being used for each time.
pro spacecraft_pv_cdj,satid,jd,pv,coorID=coorID, pv_uncertainty=dpv, interpolation_fraction=f, status=status, tle_path=tle_path, no_nutation=no_nutation, epoch=epoch
  common idl_spacecraft_pv_common,cache_satid,tle,range
  if n_elements(cache_satid) eq 0 || satid ne cache_satid then begin
    if n_elements(tle_path) eq 0 then tle_path='.'
    tle_fn=tle_path+string(format='(%"/%08d.tle")',satid)
    tle=load_tle(tle_fn)
    range=calc_voronoi2(tle[*].jdepoch)
    cache_satid=satid
  end
  status=intarr(n_elements(jd))
  f=dblarr(n_elements(jd))
  pv=dblarr(n_elements(jd),6)
  dpv=dblarr(n_elements(jd),6)
  for i=0,n_elements(range)-2 do begin
    w=where(jd ge range[i] and jd lt range[i+1],count)
    if count gt 0 then begin
      if ~keyword_set(epoch) then begin
        tmin0=(jd[w]-tle[i  ].jdepoch)*1440d
        tmin1=(jd[w]-tle[i+1].jdepoch)*1440d
        sgp4core_sgp4,tle[i  ],tmin0,r0,v0,error=error0
        sgp4core_sgp4,tle[i+1],tmin1,r1,v1,error=error1
        status[w]=error0>error1

        deltar=abs(r1-r0)
        deltav=abs(v1-v0)
        f[w]=(jd[w]-tle[i].jdepoch)/(tle[i+1].jdepoch-tle[i].jdepoch)
        ff=rebin(f[w],n_elements(w),3)
        g=(ff-0.5d)
        r=(1d -ff)*r0+ff*r1
        v=(1d -ff)*v0+ff*v1
        dy=rebin((1d -4d*g^2*(1d -2d*g^2)),n_elements(w),3)
        deltar*=dy
        deltav*=dy
        dpv[w,0:2]=deltar
        dpv[w,3:5]=deltav
      end else begin
        tmin=(jd[w]-tle[i  ].jdepoch)*1440d
        sgp4core_sgp4,tle[i  ],tmin,r,v,error=error0
        status[w]=error0

        dpv[w,0:2]=!values.d_nan
        dpv[w,3:5]=!values.d_nan
      end

      if ~keyword_set(no_nutation) then begin
        ;Make nutation correction
        ;Build nutation matrix based on epoch of first element,
        ;the Earth just doesn't nutate that much in a day
        ;Also, use UTC in place of dynamical time, the Earth
        ;REALLY doesn't nutate that much in 34s
        tn = (tle[i].jdepoch-2451545.d0)/365250.d0

        nu=Nutate_Matrix(tn)
        for ii=0,2 do begin
           PV[w,ii] = 0.d0
           PV[w,ii+3] = 0.d0
           for jj=0,2 do begin
              PV[w,jj]   = PV[w,jj]  +nu[ii,jj]*r[*,jj]
              PV[w,jj+3] = PV[w,jj+3]+nu[ii,jj]*v[*,jj]
           end
        end
        ;Don't bother to nutate the uncertainty, it's just not that big
      end else begin
        pv[w,0:2]=r
        pv[w,3:5]=v
      end
    end
  end
  pv=transpose(pv)
  dpv=transpose(dpv)
  if n_elements(coorid) eq 0 then coorid=2
  if coorid eq 1 then begin
    sphxyz,-1,sph,pv,dsph,dpv
    sph=transpose(sph)
    dsph=transpose(dsph)
    resolve_grid,sph,x=L,y=B,z=R,w=DLDT,v=DBDT,u=DRDT
    resolve_grid,dsph,x=dL,y=dB,z=dR,w=dDLDT,v=dDBDT,u=dDRDT
    sph=compose_grid(L*180d/!dpi,B*180d/!dpi,R,DLDT*180d/!dpi,DBDT*180d/!dpi,DRDT)
    dsph=compose_grid(dL*180d/!dpi,dB*180d/!dpi,dR,dDLDT*180d/!dpi,dDBDT*180d/!dpi,dDRDT)
    pv=transpose(sph)
    dpv=transpose(dsph)
  end

end