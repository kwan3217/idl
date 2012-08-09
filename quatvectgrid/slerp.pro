function slerp,q0_,q1_,t
    q0=reform(q0_)
    q1=reform(q1_)
    q0=q0/norm(q0)
    q1=q1/norm(q1)
    c_theta0=total(q0*q1) ;dot product as if quaternions were 4D vectors.
                        ;This is not necessarily related to the rotation between
                        ;the two quaternions.
    if c_theta0 lt 0 then begin ;Make sure we're going the short way around
      q1=-q1                ;Rotationally, q==-q
      c_theta0=total(q0*q1)
    end
    theta0=acos(c_theta0)
    theta=theta0*t
    q2=q1-c_theta0*q0
    q2=q2/norm(q2)
    if n_elements(theta) gt 1 then begin
      result=dblarr(n_elements(theta),4)
      for i=0,n_elements(theta)-1 do begin
        result[i,*]=q0*cos(theta[i])+q2*sin(theta[i])
      end
      return,result
    end else begin
      return,q0*cos(theta)+q2*sin(theta)
    end

end
