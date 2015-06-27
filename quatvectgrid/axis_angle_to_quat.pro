function axis_angle_to_quat,axis,angle
  ;Construct a quaternion from an axis and angle
  ;returns a 4-element array with the vector part of the quaternion first, followed by the scalar part, to correspond to the
  ;quaternion library
  return,[sin(angle/2.0)*axis,cos(angle/2.0)]
end