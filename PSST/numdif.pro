;Calculate the numerical derivative of a 1D table of (possibly unequally-spaced) data
;using the analytical derivative of a second-order Lagrange interpolating polynomial
;independent variable x, to match the documentation
;dependent variable f(x), here called fx
function numdif,xi,fxi
  xim1=shift(xi,+1)
  xip1=shift(xi,-1)
  fxim1=shift(fxi,+1)
  fxip1=shift(fxi,-1)
  xim1[0]=xim1[1]
  xip1[n_elements(xip1)-1]=xip1[n_elements(xip1)-2]
  fxim1[0]=fxim1[1]
  fxip1[n_elements(fxip1)-1]=fxip1[n_elements(fxip1)-2]

  A=(2*xi-xi  -xip1)/((xim1-xi)*(xim1-xip1))
  B=(2*xi-xim1-xip1)/((xi-xim1)*(xi  -xip1))
  C=(2*xi-xi  -xim1)/((xip1-xi)*(xip1-xim1))
  A=A*fxim1
  B=B*fxi
  C=C*fxip1
  fpxi=A+B+C
  fpxi[0]=fpxi[1]
  fpxi[n_elements(fpxi)-1]=fpxi[n_elements(fpxi)-2]
  
  return,fpxi
end