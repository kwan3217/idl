function quat_to_mtx,input,inverse=inverse

; See pg 13 "Spacecraft Dynamics" Kane, Likins, Levinson

if n_params() lt 1 then begin
  message,/info,'USAGE: result=quat_to_mtx(input,inverse=inverse)
  print,'Inverse keyword set will convert matrix to euaternion'
  return,[0.0]
endif

if not(keyword_set(inverse)) then begin

  e1=input(0)
  e2=input(1)
  e3=input(2)
  e4=input(3)

  C11=1-2*e2^2-2*e3^2
  C12=2*(e1*e2-e3*e4)
  C13=2*(e3*e1+e2*e4)
  C21=2*(e1*e2+e3*e4)
  C22=1-2*e3^2-2*e1^2
  C23=2*(e2*e3-e1*e4)
  C31=2*(e3*e1-e2*e4)
  C32=2*(e2*e3+e1*e4)
  C33=1-2*e1^2-2*e2^2

  return,[[C11,C21,C31],[C12,C22,C32],[C13,C23,C33]]

endif else begin
  C=input
  e4=.5*sqrt(1 + C(0,0) + C(1,1) + C(2,2))
  e1=-(C(1,2)-C(2,1))/(4*e4)
  e2=-(C(2,0)-C(0,2))/(4*e4)
  e3=-(C(0,1)-C(1,0))/(4*e4)
  return,[e1,e2,e3,e4]
endelse

end
