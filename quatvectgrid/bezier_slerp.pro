;Use the de Casteljau construction to find a point on a Bezier curve, given
;four control points and a parameter between zero and one. The curve
;passes through b0 when t=0, through b3 when t=1, but does not in general
;pass through b1 or b2.
function bez_guts,b0,b1,b2,b3,t
  c0=slerp(b0, b1, t)
  c1=slerp(b1, b2, t)
  c2=slerp(b2, b3, t)
  d0=slerp(c0, c1, t)
  d1=slerp(c1, c2, t)
  p =slerp(d0, d1, t)
  return,p
end

;Bezier interpolation between q1 and q2, using q0 and q3 to smooth the interpolation
function bezier_slerp,q0,q1,q2,q3,t,smoothing=smoothing
  if n_elements(smoothing) eq 0 then smoothing=1d/3d
  qp0=slerp(q0,q1,2d)
  a1=slerp(qp0,q2,0.5d)
  b1=slerp(q1,a1,smoothing)
  qp3=slerp(q3,q1,2d)
  a2=slerp(qp3,q1,0.5d)
  b2=slerp(q2,a2,smoothing)
  b0=q1
  b3=q2
  if n_elements(t) gt 1 then begin
    result=dblarr(n_elements(t),4)
    for i=0,n_elements(t)-1 do begin
      result[i,*]=bez_guts(b0,b1,b2,b3,t[i])
    end
    return,result
  end else begin
    return,bez_guts(b0,b1,b2,b3,t)
  end
end
