;Input
;  M - mach number
;  alpha - vertical angle of attack, radians
;  beta  - horizontal angle of attack, radians
;  D= aeroshell diameter, m. Defaults to 2.65m, Phoenix/MPF/MER
;Output
;  CfA= Force coefficients times reference area, m^2. Components are [drag, lift, side] in that order
;  CmAD= Moment coefficients times reference area times reference length, m^3. Components are [pitch, yaw, roll] in that order
;  CmwAD= Moment damping coefficient times blah, m^3. 
;Coordinate frames
;  Each airfoil has a center of force, forward vector, and normal vector. From these two latter vectors, we cross-multiply and come up with a side vector
;  and therefore sufficient basis vectors to form an airfoil coordinate frame, centered on the center of force. The coefficients are with respect to this frame.
;Angles of attack
;  vrel=[u,v,w]=velocity of airfoil with respect to local air (not velocity of air with respect to airfoil, which is the negative of this vector) in airfoil frame
;  beta=atan2(v/u)
;  alpha=atan2(w*cos(beta)/u)
;  alpha_t=acos(cos(alpha)*cos(beta)) 
;Coefficients
;  The force coefficients are drag, lift, and side. They are all used in a similar manner:
;  q=rho*V^2/2 ; dynamic pressure in Pa. V is the velocity of the center of pressure relative
;                to the air (m/s) and rho is the density of the air (kg/m^3).
;  F=Cf*A*q    ; {L,D,Y} is the aerodynamic force in in newtons, 
;              ; C{l,d,y} is the dimensionless force coefficient
;              ; q is dynamic pressure from above, in Pa
;              ; A is the reference area of the airfoil in m^2. This is usually
;              ;   the projected front cross section for things like cars and entry capsules,
;              ;   wing area for airfoils, but doesn't have to match any physically measurable
;              ;   area, just match the reference area used when generating the tables.
;              ;   For capsules, this is usually the circular area described by the maximum 
;              ;   diameter of the heatshield.
;  In the vector pre-multiplied form (Cf*A) that this function returns, you can just multiply by the dynamic pressure
;  scalar to get the aerodynamic force vector in the airfoil frame. If the forward vector is really pointing roughly in the direction of motion,
;  conventional drag will be backwards, so the drag component should be negative.
;  M=Cm*A*D*q+Cmw*A*D*w*q  ; M is the moment (torque) in newton-meters
;                          ; D is the reference length in meters. For entry capsules, this is usually
;                          ;   the diameter of the heatshield
;                          ; Cm is the dimensionless moment coefficient around each axis 
;                          ; Cmw is the moment damping coefficient around each axis in 1/seconds
;                          ; w is the angular rotation rate in the airfoil frame
;  This function returns vector pre-multiplied (Cm*A*D) and (Cmw*A*D)
;Phoenix aeroshell details
;  Aerodynamics are totally dominated by the heatshield. Therefore, I believe that any 70deg entry capsule entering at Mars 
;  (All of them, so far) will have similar aerodynamics. The only real difference is the center of moment point.
;  These coefficients are from Phoenix, and have a center at Xcg/D=-0.253, or on Phoenix, 0.67045m behind the forward point on the heatshield.
;  Always put the airfoil at this point in station coordinates, regardless of where the real center of gravity is.
pro aeroshell_70deg,M,alpha_t,CdA=CdA,ClA=ClA,CmAD=CmAD,CmwAD=CmwAD,D=D
  if n_elements(D) eq 0 then begin
    D=2.65
  end
  A=!dpi*D^2/4
  aero_alpha=[0,  2,  4,  6,  11, 16]*!dtor;

  aero_mach=[ $
   0.4, 0.6, 0.8, 0.9, 1.0, $
   1.2, 1.5, 2.0, 3.0, 4.0, $
   5.0, 6.3, 8.8, 9.8,10.8, $
  11.8,12.8,13.9,15.0,16.0, $
  17.0,18.1,19.2,20.3,21.3, $
  22.4,23.4,24.5,25.5,26.4, $
  27.2,28.0,30.0];

  aero_cl=[ $
[0, -0.0362,  -0.0729,  -0.1051,  -0.1894,  -0.2672], $
[0, -0.0382,  -0.0764,  -0.1096,  -0.1955,  -0.2758], $
[0, -0.0407,  -0.0785,  -0.1172,  -0.2071,  -0.2904], $
[0, -0.0428,  -0.0850,  -0.1237,  -0.2182,  -0.3066], $
[0, -0.0519,  -0.0976,  -0.1394,  -0.2389,  -0.3439], $
[0, -0.0594,  -0.1057,  -0.1480,  -0.2596,  -0.3732], $
[0, -0.0579,  -0.1062,  -0.1495,  -0.2712,  -0.3955], $
[0, -0.0503,  -0.1017,  -0.1495,  -0.2692,  -0.3793], $
[0, -0.0498,  -0.1017,  -0.1500,  -0.2687,  -0.3773], $
[0, -0.0503,  -0.1027,  -0.1510,  -0.2702,  -0.3732], $
[0, -0.0503,  -0.1017,  -0.1515,  -0.2712,  -0.3707], $
[0, -0.0508,  -0.1042,  -0.1535,  -0.2717,  -0.3682], $
[0, -0.0529,  -0.1062,  -0.1571,  -0.2717,  -0.3621], $
[0, -0.0524,  -0.1077,  -0.1581,  -0.2717,  -0.3626], $
[0, -0.0534,  -0.1077,  -0.1586,  -0.2722,  -0.3631], $
[0, -0.0529,  -0.1093,  -0.1596,  -0.2727,  -0.3621], $
[0, -0.0539,  -0.1103,  -0.1601,  -0.2722,  -0.3636], $
[0, -0.0544,  -0.1093,  -0.1611,  -0.2722,  -0.3636], $
[0, -0.0554,  -0.1113,  -0.1606,  -0.2727,  -0.3641], $
[0, -0.0569,  -0.1123,  -0.1611,  -0.2717,  -0.3641], $
[0, -0.0564,  -0.1123,  -0.1611,  -0.2722,  -0.3641], $
[0, -0.0579,  -0.1118,  -0.1596,  -0.2712,  -0.3636], $
[0, -0.0569,  -0.1113,  -0.1596,  -0.2717,  -0.3631], $
[0, -0.0564,  -0.1118,  -0.1586,  -0.2712,  -0.3631], $
[0, -0.0554,  -0.1093,  -0.1591,  -0.2702,  -0.3626], $
[0, -0.0544,  -0.1088,  -0.1581,  -0.2717,  -0.3631], $
[0, -0.0544,  -0.1082,  -0.1586,  -0.2707,  -0.3631], $
[0, -0.0544,  -0.1082,  -0.1571,  -0.2702,  -0.3621], $
[0, -0.0534,  -0.1077,  -0.1571,  -0.2702,  -0.3621], $
[0, -0.0534,  -0.1082,  -0.1566,  -0.2692,  -0.3606], $
[0, -0.0534,  -0.1082,  -0.1566,  -0.2687,  -0.3616], $
[0, -0.0544,  -0.1072,  -0.1561,  -0.2692,  -0.3601], $
[0, -0.0529,  -0.1047,  -0.1530,  -0.2646,  -0.3601]  $
];

  aero_cd=[ $
[1.0441,  1.0464, 1.0453, 1.0398, 1.0311, 1.0112], $
[1.0943,  1.0949, 1.0903, 1.0926, 1.0779, 1.0562], $ 
[1.1618,  1.1633, 1.1569, 1.1601, 1.1532, 1.1237], $
[1.2146,  1.2152, 1.2261, 1.2241, 1.2129, 1.1834], $
[1.3020,  1.3069, 1.3248, 1.3236, 1.3124, 1.3046], $
[1.4136,  1.4263, 1.4260, 1.4248, 1.4214, 1.4041], $
[1.5356,  1.5457, 1.5454, 1.5408, 1.5313, 1.5114], $
[1.5702,  1.5691, 1.5662, 1.5546, 1.5183, 1.4621], $
[1.5763,  1.5751, 1.5714, 1.5616, 1.5174, 1.4499], $
[1.5849,  1.5838, 1.5774, 1.5685, 1.5218, 1.4439], $
[1.5962,  1.5950, 1.5869, 1.5771, 1.5261, 1.4404], $
[1.6074,  1.6045, 1.5982, 1.5875, 1.5330, 1.4352], $
[1.6273,  1.6253, 1.6155, 1.6040, 1.5373, 1.4335], $
[1.6351,  1.6331, 1.6259, 1.6143, 1.5391, 1.4378], $
[1.6420,  1.6409, 1.6321, 1.6187, 1.5443, 1.4387], $
[1.6481,  1.6469, 1.6397, 1.6247, 1.5477, 1.4413], $
[1.6541,  1.6521, 1.6458, 1.6299, 1.5486, 1.4430], $
[1.6619,  1.6582, 1.6518, 1.6342, 1.5520, 1.4456], $
[1.6732,  1.6712, 1.6587, 1.6420, 1.5555, 1.4499], $
[1.6853,  1.6824, 1.6717, 1.6472, 1.5590, 1.4534], $
[1.6965,  1.6937, 1.6769, 1.6515, 1.5624, 1.4551], $
[1.7078,  1.7015, 1.6830, 1.6533, 1.5633, 1.4586], $
[1.7182,  1.7092, 1.6856, 1.6567, 1.5667, 1.4603], $
[1.7260,  1.7136, 1.6890, 1.6602, 1.5693, 1.4595], $
[1.7277,  1.7153, 1.6908, 1.6611, 1.5702, 1.4612], $
[1.7277,  1.7170, 1.6916, 1.6645, 1.5719, 1.4612], $
[1.7268,  1.7179, 1.6942, 1.6645, 1.5702, 1.4629], $
[1.7260,  1.7170, 1.6951, 1.6654, 1.5719, 1.4612], $
[1.7268,  1.7179, 1.6960, 1.6663, 1.5711, 1.4612], $
[1.7260,  1.7170, 1.6934, 1.6645, 1.5711, 1.4612], $
[1.7260,  1.7170, 1.6925, 1.6645, 1.5711, 1.4603], $
[1.7242,  1.7136, 1.6925, 1.6628, 1.5711, 1.4585], $
[1.7026,  1.6954, 1.7011, 1.6619, 1.5702, 1.4500] $
]; 

 aero_cm=[ $
[0, -0.00489, -0.00989, -0.01512, -0.02609, -0.03603], $
[0, -0.00575, -0.01032, -0.01529, -0.02618, -0.03594], $
[0, -0.00532, -0.01006, -0.01495, -0.02479, -0.03387], $
[0, -0.00584, -0.00997, -0.01434, -0.02384, -0.03214], $
[0, -0.00731, -0.01161, -0.01564, -0.02333, -0.03084], $
[0, -0.00791, -0.01049, -0.01313, -0.01918, -0.02583], $
[0, -0.00644, -0.00876, -0.01054, -0.01849, -0.02600], $
[0, -0.00342, -0.00652, -0.00994, -0.01814, -0.02618], $
[0, -0.00325, -0.00669, -0.00985, -0.01797, -0.02644], $
[0, -0.00333, -0.00626, -0.00959, -0.01745, -0.02652], $
[0, -0.00325, -0.00608, -0.00916, -0.01676, -0.02713], $
[0, -0.00316, -0.00557, -0.00838, -0.01641, -0.02834], $
[0, -0.00247, -0.00462, -0.00717, -0.01693, -0.03041], $
[0, -0.00247, -0.00410, -0.00665, -0.01711, -0.03093], $
[0, -0.00212, -0.00410, -0.00631, -0.01745, -0.03136], $
[0, -0.00204, -0.00349, -0.00587, -0.01754, -0.03171], $
[0, -0.00204, -0.00323, -0.00570, -0.01762, -0.03188], $
[0, -0.00186, -0.00289, -0.00536, -0.01797, -0.03222], $
[0, -0.00126, -0.00246, -0.00527, -0.01823, -0.03257], $
[0, -0.00057, -0.00176, -0.00562, -0.01857, -0.03309], $
[0, -0.00005, -0.00168, -0.00613, -0.01944, -0.03343], $
[0,  0.00021, -0.00237, -0.00665, -0.01987, -0.03404], $
[0, -0.00022, -0.00297, -0.00717, -0.02030, -0.03464], $
[0, -0.00100, -0.00358, -0.00778, -0.02082, -0.03490], $
[0, -0.00178, -0.00418, -0.00821, -0.02108, -0.03525], $
[0, -0.00256, -0.00479, -0.00855, -0.02134, -0.03551], $
[0, -0.00307, -0.00531, -0.00881, -0.02134, -0.03568], $
[0, -0.00342, -0.00557, -0.00907, -0.02134, -0.03577], $
[0, -0.00359, -0.00548, -0.00907, -0.02143, -0.03585], $
[0, -0.00351, -0.00565, -0.00890, -0.02117, -0.03577], $
[0, -0.00316, -0.00531, -0.00847, -0.02099, -0.03568], $
[0, -0.00247, -0.00453, -0.00786, -0.02039, -0.03525], $
[0,  0.00004, -0.00194, -0.00536, -0.01780, -0.03292] $
];
  clA=tableterp(aero_cl,aero_alpha,aero_mach,alpha_t,M)*A
  cdA=tableterp(aero_cd,aero_alpha,aero_mach,alpha_t,M)*A
  cmAD=tableterp(aero_cm,aero_alpha,aero_mach,alpha_t,M)*A*D
end