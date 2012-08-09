function tableterp,table,table_x,table_y,xout,yout
  i=min(where(table_x) lt xout)<(n_elements(table_x)-2)
  col=linterp(table_x[i],table[i,*],table_x[i+1],table[i+1,*],xout)
  return,interpol(col,table_y,yout)
  
end