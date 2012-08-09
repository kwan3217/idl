;This script demonstrates how to use kalman_velocity in your problem
;It simulates a cart oscillating back and forth past a spot on the rail,
;creates measurements, adds noise, then runs kalman_velocity to filter
;the measurements and try to reconstruct the motion of the cart.
;
;Two models are included - one of a sine wave, and one similar to a solar
;flare as observed by EVE.
;
;This is simpler than it looks - most of this file is comments, and it is
;broken down into many short lines for maximum readability. The actual
;filter is one line, and the most complicated part is breaking out the 
;filter and smoother results.
;
;Output is a set of plots. On each, the red curve is the (unknown) true
;state, the white dots are the measurements, the blue line is the state estimate,
;and the green line is the 3-sigma error bounds on the estimate. The red true
;state line should be between the green error bounds more than 99% of the time.
;We plot the filter position, filter velocity, smoother position, and smoother
;velocity.
;
;To show how well or poorly the filter works, we compare it against
;the true result available from the simulation. In any real system,
;the true result will not be available (if it was, you wouldn't need
;the filter). Notice that the filter does not use the true state, only
;the measurements
;
;The actual dynamics of this system are oscillatory (or flare-like), while the model
;is just the cart on rails, pure inertia with process noise. This 
;demonstrates how well or poorly the system works even when the model 
;does not match the actual dynamics. It is possible to model the sine
;wave dynamics directly, but this script does not attempt it.
;
;Things to try:
;* Play with the filter tuning by varying the measurement noise (sigmaz) 
;  and process noise (sigmav)
;* Play with the smoother lag, and notice its effect on both the result, 
;  and the time it takes to calculate the result
;* Try a longer time series to get a feel for the amount of time and memory
;  it takes to compute the result
;* Change the timestamps from perfectly regular to some other distribution
;* Put in your own model for simulating the true position (xp= below)
;* Comment out the plotting of the true result and try tuning the filter
;  as you would with real data
;* See if the correlation coefficient (off-diagonal part of covariance)
;  does anything interesting


;This function simulates a flare
;input
;  a - time constant a, used to control the shape of the flare. Should be scalar.
;  b - time constant b, likewise. Should be scalar.
;  t - array of timestamps to calculate the flare for. Flare is always zero before t=0
;  /normalize - if set, flare has a maximum magnitude of 1.0. 
;               If not, maximum magnitude depends on a and b
;output
;  ddt= - derivative of flare magnitude with respect to time, same array size as t
;return
;  flare magnitude, same array size as t
function flare,a,b,t,ddt=ddt,normalize=normalize
  result=t*0d
  ddt=result
  w=where(t>0,count)
  if count gt 0 then begin
    e1=exp(-t[w]/a)
    e2=1-exp(-t[w]/b)
    result[w]=e1*e2
    ea=-e1/a
    eb=e2
    ec=e1
    ed=exp(-t[w]/b)/b
    ddt[w]=ea*eb+ec*ed
  end
  m=max(result)
  if m gt 0 and keyword_set(normalize) then begin
    result/=m
    ddt/=m
  end
  return,result
end

pro kv_example

  ;timestamps of measurement
  max_t=100d ;Measurements cover 10 time units
  n_meas=1000 ;This many measurements
  t=dindgen(n_meas)*double(max_t)/double(n_meas) ;measurements are equally spaced

  ;Measurement noise - 1 sigma
  sigmaz=1.0

  ;Process noise - 1 sigma, in units of position/time^2
  sigmav=1.0

  ;Smoother lag - Smoother considers all measurements in the past and this many
  ;measurements in the future
  LL=20

  ; == Simulation ==
  A=20d;    Amplitude
  Ofs=20d; DC offset

  if 0 then begin ;change this to 1 to switch process models
    ;Create simulated true position, sine wave
    TT=20d; Period 5 time units
    tau=2d*!dpi; http://tauday.com/tau-manifesto.pdf
    xp=Ofs+A*sin(t*tau/TT)
    xv=A*tau/TT*cos(t*tau/TT) ;Notice that this is not used in the measurement
                            ;simulation, only in the plots to compare
                            ;against filter's velocity estimate
    p_yrange=ofs+[-2,2]*A
    v_yrange=A*tau/TT*[-2,2]                            
  end else begin
    ;Create simulated true measurement, EVE flare
    t0=50 ;Flare start time
    flare_a=10 ;Flare time constants
    flare_b=20
    xp=Ofs+A*flare(flare_a,flare_b,t-t0,ddt=xv,/norm)
    xv*=A
    p_yrange=[0,50]
    v_yrange=[-2,8]                            
  end
  
  ;Create measurement noise, normally distributed with zero mean and sigma=1.0
  ;Constant seed, so same noise each time this script is run
  v=randomn(3217,size(t,/dim),/double)*sigmaz

  ;Create measurements by adding noise to true state
  z=xp+v

  ;In real life, you will have timestamps t and measurements z, but no x or v
  ; == End simulation ==

  ; == Filter ==
  ;Run the filter and smoother
  f=kalman_velocity(z,t,sigmav,sigmaz,LL)

  ; == Break out the parts of the result ==
  xp_filt=f.xh_filt[0,*] ;filter estimated position 
  xv_filt=f.xh_filt[1,*] ;filter estimated velocity

  sigmap_filt=sqrt(f.P_filt[0,0,*]) ;filter estimated 1-sigma noise on position
  sigmav_filt=sqrt(f.P_filt[1,1,*]) ;filter estimated 1-sigma noise on velocity
  rho_pv_filt=f.P_filt[0,1,*]/sigmap_filt/sigmav_filt ;correlation between position and velocity noise
  
  xp_smoo=f.xh_smoo[0,*] ;smoother estimated position
  xv_smoo=f.xh_smoo[1,*] ;smoother estimated velocity

  sigmap_smoo=sqrt(f.P_smoo[0,0,*]) ;filter estimated 1-sigma noise on position
  sigmav_smoo=sqrt(f.P_smoo[1,1,*]) ;filter estimated 1-sigma noise on velocity
  rho_pv_smoo=f.P_smoo[0,1,*]/sigmap_smoo/sigmav_smoo ;correlation between position and velocity noise
  
  ; == Plot the results ==
  device,retain=2,decompose=0
  loadct,39
  window,0,title='Filter position'
  plot,yrange=p_yrange,t,z,xtitle='Time',ytitle='Position',psym=3 ;Measurements
  oplot,t,xp,color=254                                    ;True position
  oplot,t,xp_filt,color=64                                ;Filter result
  oplot,t,xp_filt+3*sigmap_filt,color=128                 ;Upper 3-sigma error bound on estimate
  oplot,t,xp_filt-3*sigmap_filt,color=128                 ;Lower 3-sigma error bound on estimate
  oplot,t,xp+3*sigmaz,color=192                           ;Upper 3-sigma error bound on measurements
  oplot,t,xp-3*sigmaz,color=192                           ;Lower 3-sigma error bound on measurements
  
  window,1,title='Filter velocity'
  plot,yrange=v_yrange,t,z,xtitle='Time',ytitle='Velocity',/nodata ;(No) measurements
  oplot,t,xv,color=254                                    ;True velocity
  oplot,t,xv_filt,color=64                                ;Filter result
  oplot,t,xv_filt+3*sigmav_filt,color=128                 ;Upper 3-sigma error bound
  oplot,t,xv_filt-3*sigmav_filt,color=128                 ;Lower 3-sigma error bound
  
  window,2,title='Smoother position'
  plot,yrange=p_yrange,t,z,xtitle='Time',ytitle='Position',psym=3 ;Measurements
  oplot,t,xp,color=254                                    ;True position
  oplot,t,xp_smoo,color=64                                ;Filter result
  oplot,t,xp_smoo+3*sigmap_smoo,color=128                 ;Upper 3-sigma error bound
  oplot,t,xp_smoo-3*sigmap_smoo,color=128                 ;Lower 3-sigma error bound
  oplot,t,xp+3*sigmaz,color=192                           ;Upper 3-sigma error bound on measurements
  oplot,t,xp-3*sigmaz,color=192                           ;Lower 3-sigma error bound on measurements
  
  window,3,title='Smoother velocity'
  plot,yrange=v_yrange,t,z,xtitle='Time',ytitle='Velocity',/nodata ;(No) measurements
  oplot,t,xv,color=254                                    ;True velocity
  oplot,t,xv_smoo,color=64                                ;Filter result
  oplot,t,xv_smoo+3*sigmav_smoo,color=128                 ;Upper 3-sigma error bound
  oplot,t,xv_smoo-3*sigmav_smoo,color=128                 ;Lower 3-sigma error bound
  
end