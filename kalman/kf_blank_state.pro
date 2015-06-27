function kf_blank_state,n=n,P0=P0,xh0=xh0
  if n_elements(xh0) eq 0 then begin
    xh0=dblarr(1,n)
  end
  if n_elements(n) eq 0 then begin
    n=n_elements(xh0)
  end
  if n_elements(P0) eq 0 then begin
    P0=dblarr(n,n)
  end

  return,{   $
    LL:0,   $ ;needed just to tell kalman_smooth to run kalman_filt
    n:n,    $ ;number of elements in state vector
    P:P0,   $
    xh:xh0  $
  }
end
