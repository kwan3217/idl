function dms,d,m,s
  result=(abs(double(d))+double(m)/60d +double(s)/3600d)
  if d<0 then result=-result
  return,result
end

pro test_ell_dist
  lat1=dms(-37,57,03.72030)*!dpi/180d
  lon1=dms(144,25,29.52440)*!dpi/180d
  lat2=dms(-37,39,10.15610)*!dpi/180d
  lon2=dms(143,55,35.38390)*!dpi/180d
  print,'calc dist (km) ',ell_dist(lat1,lon1,lat2,lon2,az=az,/rad)
  print,'test           ',54.972271d
  print,'calc az  (deg) ',az*180d/!dpi
  print,'test           ',dms(306,52,5.37)
end

;Geodesic length and azimuth between two points on a spheroid ("ellipsoid")
function ell_dist,lat1_,lon1_,lat2_,lon2_,a=a_,b=b_,h=h,ell_az=az,rad=rad
  if n_elements(lat1_) gt 1 then begin
    result_dist=lat1_*0;
    az=lat1_*0;
    for i=0,n_elements(lat1_)-1 do begin
      result_dist[i]=ell_dist(lat1_[i],lon1_[i],lat2_,lon2_,a=a_,b=b_,h=h,ell_az=this_az,rad=rad)
      az[i]=this_az
    end
    return,result_dist
  end
;  if n_elements(a_) eq 0 then a=get_wgs84_const(/re) else a=a_
;  if n_elements(b_) eq 0 then b=get_wgs84_const(/rp) else b=b_
a=a_
b=b_
  if n_elements(h) ne 0 then begin
    a+=h
    b+=h
  end
  f=1-b/a
  lat1=lat1_
  lon1=lon1_
  lat2=lat2_
  lon2=lon2_
  if ~keyword_set(rad) then begin
    lat1*=!dpi/180d
    lon1*=!dpi/180d
    lat2*=!dpi/180d
    lon2*=!dpi/180d
  end
  ;Radians from here on out

;  var a = 6378137, b = 6356752.3142,  f = 1/298.257223563;  // WGS-84 ellipsiod
  L = lon2-lon1;
  U1 = atan((1-f) * tan(lat1));
  U2 = atan((1-f) * tan(lat2));
  sinU1 = sin(U1);
  cosU1 = cos(U1);
  sinU2 = sin(U2);
  cosU2 = cos(U2);

  lambda = L
  lambdaP = 2*!dpi;
  iterLimit = 20;
  while (abs(lambda-lambdaP) gt 1e-12 && iterLimit gt 0) do begin
    sinLambda = sin(lambda)
    cosLambda =cos(lambda);
    sinSigma = sqrt((cosU2*sinLambda) * (cosU2*sinLambda) + (cosU1*sinU2-sinU1*cosU2*cosLambda) * (cosU1*sinU2-sinU1*cosU2*cosLambda));
    if (sinSigma eq 0) then return, 0;  // co-incident points
    cosSigma = sinU1*sinU2 + cosU1*cosU2*cosLambda;
    sigma = atan(sinSigma, cosSigma);
    sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
    cosSqAlpha = 1 - sinAlpha*sinAlpha;
    cos2SigmaM = cosSigma - 2*sinU1*sinU2/cosSqAlpha;
    if (~finite(cos2SigmaM)) then cos2SigmaM = 0;  // equatorial line: cosSqAlpha=0 (�6)
    C = f/16*cosSqAlpha*(4+f*(4-3*cosSqAlpha));
    lambdaP = lambda;
    lambda = L + (1-C) * f * sinAlpha * (sigma + C*sinSigma*(cos2SigmaM+C*cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)));
    iterlimit--;
  end
  if (iterLimit eq 0) then return,!values.d_NaN;  // formula failed to converge

  uSq = cosSqAlpha * (a*a - b*b) / (b*b);
  AA = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
  BB = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
  deltaSigma = BB*sinSigma*(cos2SigmaM+BB/4*(cosSigma*(-1+2*cos2SigmaM*cos2SigmaM)- BB/6*cos2SigmaM*(-3+4*sinSigma*sinSigma)*(-3+4*cos2SigmaM*cos2SigmaM)));
  s = b*AA*(sigma-deltaSigma);
  az=atan(cosU2*sin(Lambda), cosU1*sinU2-sinU1*cosU2*cos(lambda))
  if(az lt 0) then az+=2*!dpi
  if ~keyword_set(rad) then begin
    az*=180d/!dpi
  end
  return,s;
end