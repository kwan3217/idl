;Output
;  m=   - mass of vehicle in kg
;  CoM= - center of mass of vehicle in station coordinates
;  I=   - Moment of inertia about center of mass, parallel to station frame
;For Phoenix, X axis is along spin axis pointing down, y is towards lander leg nearest 
;      arm shoulder, and z is perpendicular, right handed. Each pair of RCS/TCM windows 
;      straddles the +Z or -Z axis.Origin is at center of heatshield face  
pro phoenix_mass_prop,m=m,i=i,com=com
  CGx=-1.07d
  CGy=0d
  CGz=0d
  Ixx=293.15d
  Iyy=184.00d
  Izz=208.02d
  Ixy= 0.451d & Iyx=Ixy
  Ixz=-4.424d & Izx=Ixz
  Iyz= 0.372d & Izy=Iyz
  m=572.743d
  CoM=transpose([CGx,CGy,CGz])
  I=[[Ixx,Ixy,Ixz], $
     [Iyx,Iyy,Iyz], $
     [Izx,Izy,Izz]]
end