;Given a time, return the quaternion to transform from ECI to ECEF frame
function eci_to_ecef,t
  ;calculate the transformation from ECI to ECEF
  return,quatx(3,-gmst(t)*!dpi/180d)
end
