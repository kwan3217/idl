;state vector
;[r{3},v{3},a{3},q{4},w{3},m{1}]
;r=x[0:2]
;v=x[3:5]
;a=x[6:8]
;q_r2b=x[9:12]
;w=x[13:15]
;m=x[16]

pro blackbrant_sim
  tic
  t0=-1.d
  dt=0.003d   ;match the sample rate of the sensors
  t1=1000d;
  n=floor((t1-t0)/dt)
  t=dindgen(n)*dt+t0

  x0=blackbrant_x0(el=86.6d*!dtor,az=9d*!dtor,spd=0d,alt=1200d,lat=32.41785d*!dtor,lon=-106.31994d*!dtor,t0=t0)
  
  x=dblarr(n,n_elements(x0))
  xd=x
  x[0,*]=x0
  z0=g_rocketometer(t0,x0) ;measurement vector, for size only
  z=dblarr(n,n_elements(z0))
  z[0,*]=z0
  i=1L
  while vlength(x[i-1,0:2]) gt vlength(x[0,0:2])-1 and i lt n_elements(t) do begin
    xd[i,*]=call_function('fd_blackbrant',t[i],x[i-1,*])
    x[i,*]=x[i-1,*]+dt*xd[i,*]
    x[i,6:8]=xd[i,3:5] ;stick acceleration into state vector
    x[i,9:12]=x[i,9:12]/sqrt(total(x[i,9:12]^2)) ;renormalize quaternion
    z[i,*]=call_function('g_rocketometer',t[i],x[i,*])
    i++
  end 
  n=i
  t=t[0:n-1]
  t1=t[n-1]
  xd=xd[0:n-1,*]
  x=x[0:n-1,*]
  z=z[0:n-1,*]
  toc,'Done with simulation'
  save,filename='BlackBrantClean.sav',/compress
  toc,'Done saving simulation'
end