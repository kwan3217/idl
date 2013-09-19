;kalman_velocity - simple driver for the Kalman fiter or smoother
;Input
; z - measurements, in any physical or engineering unit. Should be a 1D array.
; t - time stamp for each measurement, in some uniform time scale (such as TAI 
;     or hours since some epoch). Should be a 1D array with the same number of
;     elements as z
; sigmav - velocity process noise, used for tuning the filter. Scalar or array the same
;          size as z.
; sigmaz - 1-sigma measurement noise, in same units as z. Standard deviation, not variance.
;          Not to be used as a tuning parameter. A scalar or array the same size as z. 
;          R=sigmaz^2, and the squaring is performed internally, so don't worry about it.
; LL (Optional) - number of smoothing steps. Zero results in a pure Kalman filter, 
;      one or more results in a Fixed-Lag Kalman Smoother with a 
;      lag of LL measurements. Zero (pure Kalman filter) by default.
; xh0 (Optional) - Two-element array, a priori (initial guess) of process state. 
;     First element is estimate of initial position, second is of initial velocity.
;     [z[0],0d] by default.
; P0 (Optional) - Two-by-two matrix, a priori covariance of process state. 
;    [1,0]
;    [0,1] by default.
;Return
; A structure with the following fields:
;   xh_filt: 2D array of pure Kalman filter results, which you get whether you
;            ask for the filter or the smoother. xh_filt[0,*] are the position 
;            state estimates for each measurment, while xh_filt[1,*] are the 
;            velocity state estimates.
;   xh_smoo: 2D array of Kalman smoother results. Each section xh_smoo[*,i] refers to the
;            smoother result for measurement z[i-LL], or in other words, for the measurement LL
;            steps in the past. Otherwise the same structure and format as xh_filt. You
;            get xh_smoo only if LL>0.
;   p_filt:  3D array of process state covariance from pure filter. p_filt[*,*,i] is the 2D 
;            covariance matrix for estimate xh_filt[*,i].
;   p_smoo:  3D array of process state covariance from pure filter. p_smoo[*,*,i] is the 2D 
;            covariance matrix for estimate xh_smoo[*,i], which matches measurement z[i-LL].
;            Only present if LL>0
;
;Notes:
;  Kalman Filter and Smoother rely on a linear process model of the following form:
;  x[i]=A##x[i-1]+w[i] 
;  z[i]=H##x[i]+v[i]
;  A is the state transition matrix which describes the process and is used to calculate
;    the next state x from the previous. w is unknwn process noise with a covariance of Q
;  H is the observation matrix which describes how the observation is calculated from the 
;    state. v is unknown measurement noise with a covariance of R.
;  
;  This function is hard-coded to use the velocity (cart on rails) model. To supply your
;  own matrices, use kalman_filt or kalman_smooth directly. In this model, the A matrix is
;  [1,delta_T]
;  [0,      1] where delta_T is the time between measurements (If delta_T varies, so does the
;  A matrix, but this code handles all of this properly and transparently). The
;  H matrix is [1,0] which signifies that the measurement includes position but not velocity 
;  information. 
;
;  The process noise covariance Q is 
;  [dt^4/4, dt^3/2]
;  [dt^3/2, dt^2  ]*sigmav^2 where sigmav is the velocity process noise standard deviation, 
;  supplied on input. This parameter allows the model the "wiggle room" it needs to follow
;  unmodeled dynamics. The lower the sigmav, the more the filter will trust the process model,
;  and result in a smoother output (more noise filtered out) at the expense of slower reaction
;  time to unmodeled process dynamics. This is in units of the second derivative of the 
;  measurement units; for instance, if the measurement is in units of position, this parameter
;  is in units of acceleration.
;
;  The measurement noise covariance R is sigmaz^2. So, put in the 1-sigma standard deviation of
;  the measurement noise. If sigmaz is a scalar, then this is the noise for for all 
;  measurements. If an array, then each element is the noise for the corresponding measurement.
;  You should know or have a realistic idea of your measurement noise, and should apply it as 
;  best you know and not use this as a tuning parameter.
;
;  On output, you get two estimates of the state and two of the uncertainty of the state,
;  one for the filter and one for the smoother, as described above. The output uncertainty
;  in each case is expressed as a covariance matrix as follows:
;  [sigma_x0^2, sigma_x0*sigma_x1*rho_x0x1]  
;  [sigma_x0*sigma_x1*rho_x0x1, sigma_x1^2]
;  You can pull the 1-sigma uncertainty off of the diagonals, but if the correlation is too
;  high, this isn't really very meaningful any more. sigma_x0=sqrt(p[0,0]) and sigma_x1=sqrt(p[1,1])  
function kalman_velocity,z,t,sigmav,sigmaz,LL,xh0,p0

  ;Matrix constants
  H=[1d,0]

  ;A priori state estimate
  if n_elements(xh0) eq 0 then xh0=double([[z[0]],[0]])
  ;A priori estimate covariance
  if n_elements(P0)  eq 0 then P0 =[[1d,0d],[0d,1d]]
  if n_elements(LL)  eq 0 then LL=0

  ;Histories
  xh_filt=dblarr(2,n_elements(z)) ;Estimated state
  p_filt=dblarr(2,2,n_elements(z))
  xh_filt[*,0]=xh0
  p_filt[*,*,0]=p0
  if LL gt 0 then begin
    xh_smoo=dblarr(2,n_elements(z))
    p_smoo=dblarr(2,2,n_elements(z))
    xh_smoo[*,0]=xh0
    p_smoo[*,*,0]=p0
  end

  for i=1L,n_elements(z)-1 do begin
    dt=t[i]-t[i-1]
    A=[[1d,dt],[0,1]]
    if n_elements(sigmav) gt 1 then sigmav2=sigmav[i]^2d else sigmav2=sigmav^2d
    Q=[[dt^4d/4d,dt^3d/2d],[dt^3d/2d,dt^2]]*sigmav2
    if n_elements(sigmaz) gt 1 then R=sigmaz[i]^2 else R=sigmaz^2
    result=kalman_smooth(double(z[i]),A,H,Q,R,LL=LL,xh0=xh0,P0=P0,state=state)
    xh_filt[*,i]=result.filter_xh
    p_filt[*,*,i]=result.filter_p
    if i-LL ge 1 and LL gt 0 then begin
      xh_smoo[*,i]=result.filter_xh
      p_smoo[*,*,i]=result.filter_p
      xh_smoo[*,i-LL]=result.smooth_xh
      p_smoo[*,*,i-LL]=result.smooth_p
    end
  end

  if LL gt 0 then begin
    ;Correct the lag offset. After this, filtered estimate for z[i] and smoothed estimate
    ;for z[i] will both be xh_filt[*,i] and xh_smoo[*,i]. Likewise with P_smoo. Last LL 
    ;estimates will be filtered, not smoothed.
    xh_smoo=[[xh_smoo[*,0:n_elements(z)-LL-1]],[xh_filt[*,n_elements(z)-LL:n_elements(z)-1]]]
    P_smoo=[[[P_smoo[*,*,0:n_elements(z)-LL-1]]],[[P_filt[*,*,n_elements(z)-LL:n_elements(z)-1]]]]
    return,{          $
      xh_filt:xh_filt,$
      xh_smoo:xh_smoo,$
      p_filt:p_filt,  $
      p_smoo:p_smoo   $
    }
  end else begin
    return,{          $
      xh_filt:xh_filt,$
      p_filt:p_filt   $
    }
  end
end
