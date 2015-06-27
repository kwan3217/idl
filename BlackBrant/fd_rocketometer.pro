function fd_rocketometer,t,x,vv
  r=x[0:2]
  v=x[3:5]
  a=x[6:8]
  q=x[9:12]
  w=x[13:15]
  
  wd=[0d,0,0]
  qd=quat_mult_grid(q,[w,0d])/2

  ;return results
  xd=x
  xd[*]=0
  xd[0:2]=v
  xd[3:5]=a
  xd[6:8]=0
  xd[9:12]=qd
  xd[13:15]=wd
  return,xd
end

