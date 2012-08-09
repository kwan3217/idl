sphere {                           
  <0,0,0>,1
      // texture pigment {} attribute
// create a texture that lays an image's colors onto a surface
// image maps into X-Y plane from <0,0,0> to <1,1,0>  
pigment {image_map {
  png "MarsTopoAqua_no_bathy.png" // the file to read (iff/tga/gif/png/jpeg/tiff/sys)
  map_type 1        // 0=planar, 1=spherical, 2=cylindrical, 5=torus
  interpolate 2     // 0=none, 1=linear, 2=bilinear, 4=normalized distance
  // once           // for no repetitive tiling
  // [filter N V]   // N=all or color index # (0...N), V= value (0.0...1.0)
  // [transmit N V] // N=all or color index # (0...N), V= value (0.0...1.0)
  // [use_color | use_index]
}
} // image_map   
  rotate -y*clock*360

}

light_source {
  <20,-1,-20> *10000
  color rgb 1
}
           
camera {   
  #declare V=<0,-cos(clock*2*pi)*2,-5>;
  #declare V=vnormalize(V)*5;
  location V
  look_at<0,0,0> 
  angle 35
}
             
