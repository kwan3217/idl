;Linear interpolation along line (x1,y1) to (x2,y2) at point x.
;y1 and y2 can be any shape array, as long as they are the same.
;x1 and x2 must be scalar, or result is undefined. It will silently
;give a wrong answer. x may be an array, if y1 and y2 are scalar.
function linterp,x1,y1,x2,y2,x
  t=(x-x1)/(x2-x1)
  return,y1*(1-t)+y2*t
end