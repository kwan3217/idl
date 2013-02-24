function fix_tc,tc
  w=tc lt shift(tc,1)
  w[0]=0
  return,double(total(w,/cum))*60d +double(tc)/60d6
end
