;Run the discrete linear fixed-lag Kalman smoother.
;
;Input
;  wo - m-element measurement vector
;  A  - nxn state transition matrix
;  H  - mxn Observation matrix
;  Q  - nxn Process noise covariance
;  R  - mxm Measurement covariance
;Input for startup (ignored if state= is defined)
;  LL=    - number of steps back to do the smoothing for.
;           If zero, smoother is not run, only filter.
;  xh0=   - n-element 'a priori' state vector estimate
;  P0=    - nxn matrix 'a priori' estimate covariance
;  state= - an undefined named variable. On return, this will contain the smoother
;           state (not to be confused with the process state) to be passed back
;           to subsequent smoohter runs
;Input for steady state
;  state= - a structure created by a previous run of kalman_smooth
;Returns a structure with the following members:
;  filter_xh - result of the Kalman filter for this measurement
;  smooth_xh - result of the Kalman smoohter for the measurement LL steps in the past
;  filter_P  - covariance from the Kalman filter at this measurement
;  smooth_P  - covariance from the Kalman smoother for the measurement
;              LL steps in the past
;
;Reference: - Cohn, et al, "A fixed-lag Kalman smoother for
;             retrospective data assimilation", Monthly Weather Review
;             v112, p2838- (1994). Variable names for inputs match
;             those of the reference. Names used internally have too
;             many sub-and-superscripts to make good IDL names, so
;             they are named after the equation they appear on the
;             left side in, ie T14 is the variable on the left side of
;             equation T1.4 in Table 1. This is a straightforward
;             implementation of Table 1, with careful ordering to not
;             stomp feedback variables until after we are done using
;             them, and proper startup so that the first iteration is
;             the same as all subsequent.
;
;Notes
;  A, H, Q, and R can be different each time the filter is called. The process 
;  state vector has a constant size n which cannot vary, and the A and Q 
;  matrices must always be compatible with it, but the values of the A and Q 
;  matrices may be changed each time the filter is called. The size of the 
;  measurement vector m may change from measurement to measurement, but the R 
;  matrix needs to be compatible (mxm) each time and the H matrix needs to be
;  compatible with both the state and this measurment (mxn) each time. LL cannot
;  be changed during a smoother run, and in fact the LL= parameter is ignored
;  except on startup.
;
;  Matrices are multiplied using the ## operator, so when you print out the matrices in
;  IDL normally, it appears like conventional math. In other words, matrix multiplication
;  of matrix A by matrix B is represented as C = A ## B, where each cell c with row i and
;  column j is the dot product of the row i vector from A and the column j vector from B.
;  The only unusual bit about this is that in IDL, the column index is first, so we get
;  c[j,i]=dot(a[*,i],b[j,*]).
;
;  This has the same interface as kalman_filt, with the exception of 
;  adding the LL= parameter, so this is a drop-in replacement for 
;  kalman_filt. The first argument-by-order is called wo here and z 
;  there, but they are the same thing - the current measurement vector.
;
;  You don't need to know what's in the filter state, but it contains quite a bit more
;  information than the corresponding state variable for kalman_filt. In addition to 
;  all the same stuff as in kalman_filt, it contains the in-process estimates and 
;  covariances needed for all of the smoothed estimates which don't have enough 
;  measurements yet to be completed.
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
;    result=kalman_smooth(z[*,i],A,H,Q,R,xh0=xh0,P0=P0,state=state)
;
;    ;Do something with result
;  end
function kalman_smooth,wo,A,H,Q,R,LL=LL,xh0=xh0,P0=P0,state=state
  ;Due to a bad choice of variable names, L in the paper is hereby renamed to LL
  ;                                       \ell in the paper is hereby renamed to ell
  ;                                       No variable shall be called either l or L
  if n_elements(state) eq 0 then begin
    ;If we are not smoothing, then run the kalman filter instead
    ;Do not pass GO, do not collect $200
    if LL eq 0 then return,kalman_filter(wo,A,H,Q,R,xh0=xh0,P0=P0,state=state)
    n=(size(Q,/dim))[0] ;Use the process noise matrix to size the state vector
    if n eq 0 then n=1
    T17=dblarr(n,n,LL+1)
    for ell=1,LL do T17[*,*,ell]=P0
    T18=T17
    T1D=dblarr(n,LL+1)
    for ell=1,LL do T1D[*,ell]=xh0
    state={     $
      LL:LL,    $
      n:n,      $
      T16:P0,   $
      T17:T17,  $
      T18:T18,  $
      T1C:xh0,  $
      T1D:T1D   $
    }
  end
  ;extract the smoother state
  LL=state.LL
  ;If we are not smoothing, then run the kalman filter instead
  if LL eq 0 then return,kalman_filter(wo,A,H,Q,R,state=state)
  n=state.n
  T16=state.T16
  T17=state.T17
  T18=state.T18
  T1C=state.T1C
  T1D=state.T1D

  ;The state can't change size during the process, but the measurement can.
  m=(size(R,/dim))[0] ;Use the measurement noise covariance to size the measurement vector
  if m eq 0 then m=1

  T11=dblarr(n,n,LL+1)
  T15=dblarr(m,n,LL+1) ;An n row by m column matrix, using IDL's perverse syntax

  ;Error covariance propagation 1
                     T11[*,*,  1]=A ## T16
  for ell=2,LL do    T11[*,*,ell]=A ## T18[*,*,ell-1]

  ;Error covariance propagation 2
                     T12=A ## kf_t(T11[*,*,1]) + Q

  ;Innovation covariance
                     T13=H ## kf_t(H ## T12) + R

  ;Kalman filter gain
                     T14=kf_t(H ## T12) ## kf_inv(T13)

  ;Kalman smoother gain
  for ell=1,LL do    T15[*,*,ell]=kf_t(H ## T11[*,*,ell]) ## kf_inv(T13)

  ;Filter covariance
                     T16=(identity(n)-T14 ## H) ## T12

  ;Smoother covariance
  ;This one has to run in reverse, since it is feeding back on itself
  for ell=LL,2,-1 do T17[*,*,ell]=T17[*,*,ell-1] - T15[*,*,ell] ## H ## T11[*,*,ell]
                     T17[*,*,  1]=T16            - T15[*,*,  1] ## H ## T11[*,*,  1]

  ;Smoother cross-covariance
  for ell=1,LL-1 do  T18[*,*,ell]=(identity(n) - T14 ## H) ## T11[*,*,ell]

  ;State forecast
                   T1A=A ## T1C

  ;Innovation
                   T1B=wo - H ## T1A

  ;Smoother estimate
  ;D runs before C, since it depends on the feedback C, not the current C
  ;Also it has to run in reverse, since it is feeding back on itself
  for l=LL,2,-1 do T1D[*,l]=T1D[*,l-1] + T15[*,*,l] ## T1B
                   T1D[*,1]=T1C        + T15[*,*,1] ## T1B

  ;Filter estimate
                   T1C=T1A + T14 ## T1B


  ;Put things back into the smoother state
  state.T16=T16
  state.T17=T17
  state.T18=T18
  state.T1C=T1C
  state.T1D=T1D

  return,{                $
    filter_P:   T16,        $
    filter_xh:  T1C,        $
    smooth_P: T17[*,*,LL],$
    smooth_xh:T1D[*,LL]   $
  }
end

