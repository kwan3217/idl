function b_plane,rv,vv,l_du,mu
  tau=!dpi*2d ; tau manifesto
  r=vlength(rv)
  v=vlength(vv)
  fpa=tau/4d -acos(dotp(rv,vv)/(r*v))
  b=b_from_ei(mu,r,fpa,v_ei=v)  
  if n_elements(l_du) eq 0 then begin
    b=su_to_cu(b,l_du,mu,1,0,/inv)
  end
  return,b
end