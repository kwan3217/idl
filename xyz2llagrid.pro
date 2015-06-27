;this is a standard function in FORTRAN to return a number with the same
;magnitude as a, with the sign of b.
function dsign,a,b
  result=abs(a);
  Cond1=(b lt 0)
  Where1=where(Cond1,Count)
  if(Count ne 0) then begin
    result[Where1]*=-1;
  end
  return,result
end

pro xyz2llagrid,x,y,z, a, flat,lat=lat,lon=lon,alt=alt
;XYZ2LLA   Converts position vector to navigation coordinates.
;   [lat,lon,alt]=xyz2lla(x,y,z) returns geodetic latitude and longitude in radians,
;   and altitude above ellipsoid in meters. North latitude and East longitude
;   are positive numbers. ALL LOCATIONS IN THE USA WILL HAVE NEGATIVE LONGITUDES!
;   This program uses a closed-form algorithm. By default, this uses the size
;   and shape of the WGS-84 ellipsoid, in meters.
;
;   [lat,lon,alt]=xyz2lla(x,y,z,a,f) returns geodetic coordinates and
;   altitude with a custom ellipsoid. A is the equatorial radius of the ellipsoid
;   and F is the flattening ratio (f=1-b/a, where b is the polar radius).
;   Lat and lon remain in radians, and the units of alt are the same as A.
;
;   Optional parameter sid is greenwich mean siderial time at correct moment, in radians
;
;   http://www.astro.uni.torun.pl/~kb/Papers/geod/Geod-GK.htm (in polish,
;   but contains a fortran script commented in english)
;   http://www.astro.uni.torun.pl/~kb/Papers/ASS/Geod-ASS.htm (Derivation
;   in english)
;
;   Example: The south goalpost at Folsom Field, University of Colorado
;   at Boulder is located at:
;     X (Meters)    Y (Meters)    Z (Meters)
;   ------------- ------------- -------------
;   -1288488.9373 -4720620.9617  4079778.3407
;
;   running XYZ2LLA returns the following:
;   >> [lat,lon,alt]=xyz2lla(-1288488.9373,-4720620.9617,4079778.3407)
;   lat =
;      0.69828684115439
;   lon =
;     -1.83725477406124
;   alt =
;      1612.59993154183
;
  ;Default ellipsoid if none is specified
  if n_elements(a) eq 0 then begin
    a=6378.137d;
  end

  if n_elements(flat) eq 0 then begin
    flat=1/298.257223563d;
  end

  ; Nothing special about this
  lon=atan(y,x);

  ; Set the size for the other vars
  lat=z;
  alt=z;

  ; Length of projection of vector to equatorial plane
  r=sqrt(x*x+y*y);
  ; x or y should not appear below here
  ; Ellipsoid z radius
  b=dsign(a*(1.0d - flat),z);

  ; On the rotation axis?
  Cond1=(0.0d eq r)
  NotCond1=1b - Cond1;
  Where1=where(Cond1,Count1)
  NotWhere1=where(NotCond1,NotCount1)
  ;if(0.0d eq r) then begin
  if(Count1 ne 0) then begin
    ; Yup, we are at a pole. Take the quick way out
    lat[Where1]=dsign(!dpi/2.0d,z[Where1]);
    alt[Where1]=abs(z[Where1])-abs(b[Where1]);
  ;end else begin
  end
  if(NotCount1 ne 0) then begin
    ; On the equator?
    Cond2=NotCond1 and (0.0d eq z);
    NotCond2=NotCond1 and (1b - (0.0d eq z));
    Where2=where(Cond2,Count2)
    NotWhere2=where(NotCond2,NotCount2)
    ;if(0.0d eq z) then begin
    if(Count2 ne 0) then begin
      lat[Where2]=0d;
      alt[Where2]=r[Where2]-a;
    ;end else begin
    end
    if(NotCount2 ne 0) then begin
      ; Nope, chug through the hard part
      E=z;
      F=z;
      P=z;
      Q=z;
      D=z;
      s=z;
      v=z;
      G=z;
      t=z;
      E[NotWhere2]=((z[NotWhere2]+b[NotWhere2])*b[NotWhere2]/a-a)/r[NotWhere2];
      F[NotWhere2]=((z[NotWhere2]-b[NotWhere2])*b[NotWhere2]/a+a)/r[NotWhere2];
      P[NotWhere2]=4.0d*(E[NotWhere2]*F[NotWhere2]+1.0d)/3.0d;
      Q[NotWhere2]=(E[NotWhere2]^2.0d -F[NotWhere2]^2.0d)*2.0d;
      D[NotWhere2]=P[NotWhere2]^3.0d +Q[NotWhere2]^2.0d;
      s[NotWhere2]=sqrt(D[NotWhere2])+Q[NotWhere2];
      s[NotWhere2]=dsign(abs(s[NotWhere2])^(1.0d/3.0d),s[NotWhere2]);
      v[NotWhere2]=P[NotWhere2]/s[NotWhere2]-s[NotWhere2];
      v[NotWhere2]=-(2.0d*Q[NotWhere2]+v[NotWhere2]^3.0d)/(3.0d*P[NotWhere2]);
      G[NotWhere2]=(E[NotWhere2]+sqrt(E[NotWhere2]^2.0d +v[NotWhere2]))/2.0d;
      t[NotWhere2]=sqrt(G[NotWhere2]^2.0d +(F[NotWhere2]-v[NotWhere2]*G[NotWhere2])/(2*G[NotWhere2]-E[NotWhere2]))-G[NotWhere2];
      lat[NotWhere2]=atan((1.0d -t[NotWhere2]*t[NotWhere2])*a/(2.0d*b[NotWhere2]*t[NotWhere2]));
      alt[NotWhere2]=(r[NotWhere2]-a*t[NotWhere2])*cos(lat[NotWhere2])+(z[NotWhere2]-b[NotWhere2])*sin(lat[NotWhere2]);
    end
  end
end