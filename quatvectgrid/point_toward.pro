;Given a body frame defined by a "point" vector and "toward" vector expressed in that frame, and
;a corresponding reference frame such that the body point vector must be pointed at the reference point vector
;and the body toward vector must be pointed toward the reference toward vector as closely as possible,
;figure the rotation matrix which transforms a vector in the body frame to the corresponding one in the reference frame
;Input
;  p_b= - "point"  vector in body      frame, must be a column [1,3] vector but doesn't have to be unit length
;  p_r= - "point"  vector in reference frame, must be a column [1,3] vector but doesn't have to be unit length
;  p_b= - "toward" vector in body      frame, must be a column [1,3] vector but doesn't have to be unit length
;  p_b= - "toward" vector in reference frame, must be a column [1,3] vector but doesn't have to be unit length
;return
;  A 3x3 matrix M_BR which when used as r=M_BR ## B, transforms a vector from the body frame to the reference frame 
function point_toward,p_r=p_r,t_r=t_r,p_b=p_b,t_b=t_b
  ;calculation
  s_b=transpose(normalize_grid(crossp_grid(p_b,t_b)))
  u_b=transpose(normalize_grid(crossp_grid(p_b,s_b)))
  s_r=transpose(normalize_grid(crossp_grid(p_r,t_r)))
  u_r=transpose(normalize_grid(crossp_grid(p_r,s_r)))
  if size(s_b,/n_dim) lt 2 then s_b=transpose(s_b)
  if size(s_r,/n_dim) lt 2 then s_r=transpose(s_r)
  if size(u_b,/n_dim) lt 2 then u_b=transpose(u_b)
  if size(u_r,/n_dim) lt 2 then u_r=transpose(u_r)
  R=[p_r,s_r,u_r]
  B=[p_b,s_b,u_b]
  M_BR=R ## transpose(B)
  return,M_BR
end