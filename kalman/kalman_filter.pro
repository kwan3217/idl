;Run the discrete linear Kalman filter.
;
;Input
;  z  - m-element measurement vector
;  A  - nxn state transition matrix
;  H  - mxn Observation matrix
;  Q  - nxn Process noise covariance
;  R  - mxm Measurement covariance
;Input for startup (ignored if state= is defined)
;  xh0=   - n-element 'a priori' state vector estimate
;  P0=    - nxn matrix 'a priori' estimate covariance
;  state= - an undefined named variable. On return, this will contain the smoother
;           state (not to be confused with the process state) to be passed back
;           to subsequent smoohter runs
;Input for steady state
;  state= - a structure created by a previous run of kalman_filter
;Returns a structure with the following members:
;  filter_xh - result of the Kalman filter for this measurement
;  smooth_xh - Another copy of filter_xh, for compatiblity with Kalman_smooth
;  filter_P  - covariance from the Kalman filter at this measurement
;  smooth_P  - Another copy of filter_P, for compatiblity with Kalman_smooth
;
;Notes
;  A, H, Q, and R can be different each time the filter is called. The process 
;  state vector has a constant size n which cannot vary, and the A and Q 
;  matrices must always be compatible with it, but the values of the A and Q 
;  matrices may be changed each time the filter is called. The size of the 
;  measurement vector m may change from measurement to measurement, but the R 
;  matrix needs to be compatible (mxm) each time and the H matrix needs to be
;  compatible with both the state and this measurment (mxn) each time.
;
;  Matrices are multiplied using the ## operator, so when you print out the matrices in
;  IDL normally, it appears like conventional math. In other words, matrix multiplication
;  of matrix A by matrix B is represented as C = A ## B, where each cell c with row i and
;  column j is the dot product of the row i vector from A and the column j vector from B.
;  The only unusual bit about this is that in IDL, the column index is first, so we get
;  c[j,i]=dot(a[*,i],b[j,*]).
;
;  This function is designed to be drop-in replaced by kalman_smooth, so it is
;  a bit more complicated of an interface than it needs. You don't need to know
;  what's in the filter state, but the important bits are just the last estimate
;  and covariance. In fact, if you wanted, you could use the results of the 
;  last xh and P as inputs to xh0 and P0, and never use the state= parameter.
;
;Usage:
;  This is designed to be inside of a loop for filtering each of your measurements
;  one-by-one. You can call it like this:
;
;  z[*,*]=measurements   ;each measurement vector in its own column so z[*,i] represents
;                        ;the ith measurement vector 
;  xh0=initial guess     ;state vector of n elements
;  P0=initial covariance ;must be a square matrix of n by n elements
;  s=(size(z,/dim))[0]   ;number of measurmenets 
;  for i=0L,s-1 do begin
;    ;calculate A, H, Q, and R matrices for your process. If these are constant,
;    ;you can do it outside the loop
;
;    ;Note that on the first time through this loop, state is undefined. When this is so, 
;    ;kalman_filt knows it is doing the startup step. On other loops, it knows that it is
;    ;doing a steady-state step.
;    ;Note also that xh0 and P0 are passed in every time, but ignored after the first time
;    result=kalman_filt(z[*,i],A,H,Q,R,xh0=xh0,P0=P0,state=state)
;
;    ;Do something with result
;  end
;
;Or you can ignore the state variable altogether and go like this:
;  z[*,*]=measurements   ;each measurement vector in its own column so z[*,i] represents
;                        ;the ith measurement vector 
;  xh=initial guess     ;state vector of n elements
;  P=initial covariance ;must be a square matrix of n by n elements
;  s=(size(z,/dim))[0]   ;number of measurmenets 
;  for i=0L,s-1 do begin
;    ;calculate A, H, Q, and R matrices for your process. If these are constant,
;    ;you can do it outside the loop
;
;    result=kalman_filt(z[*,i],A,H,Q,R,xh0=xh,P0=P)
;
;    ;Do something with result
;    xh=result.filter_xh
;    P=result.filter_P
;  end
;
;The second way will break if you decide to go with kalman_smooth at some point.
function kalman_filter,z,A,H,Q,R,xh0=xh0,P0=P0,state=state
  if n_elements(state) eq 0 then begin
    ;Initialize the filter state if needed

    n=n_elements(xh0) ;Use initial condition to size the state vector
    state=kf_blank_state(n=n,P=P0,xh=xh0)
  end

  if state.P[0,0] eq 0 then begin
    state.xh=xh0
    state.P=P0
  end

  ;extract the filter state
  n=state.n
  P=state.P
  xh=state.xh

  ;Time update
  xhm=A ## xh                    ;Projected old state estimate
  Pm=A ## P ## kf_t(A) + Q       ;Projected old estimate covariance

  ;compare measurement to estimate
  yh=z - H ## xhm                ;Measurement Residual
  S=H ## Pm ## kf_t(H) + R       ;Residual covariance

  ;calculate gain
  K=Pm ## kf_t(H) ## kf_inv(S)   ;Kalman gain

  ;Measurement update
  xh=xhm + K ## yh               ;New estimate of state
  P=(identity(n) - K ## H) ## Pm ;new estimate covariance

  state.P=P
  state.xh=xh

  return,{                $
    filter_P:   P,        $
    filter_xh:  xh        $
  }
end

