function constrain, a, q  ;constrain a value to the range of +-q/2.
b = a mod q
neg = where(b lt -q/2, count)
if count gt 0 then b[neg] = b[neg]+q
neg = where(b gt q/2, count)
if count gt 0 then b[neg] = b[neg]-q
return, b
end
