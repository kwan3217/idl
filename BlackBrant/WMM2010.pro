;  /**
;   * The heart of the WMM model
;   * @param alt Altitude above WGS-84 ellipsoid in m
;   * @param rlat Geodetic latitude using WGS-84 ellipsoid and frame in radians
;   * @param rlon Longitude using WGS-84 frame in radians
;   * @param time time to compute model in decimal years (IE 1 Jul 2008~=2008.5)
;   * @return an array of [bx, by, bz]
;   *   <ul>
;   * <li>bx - north component of field in local WGS-84 horizon frame in nanoTeslas
;   * <li>by - east component of field in local WGS-84 horizon frame in nanoTeslas
;   * <li>bz - down component of field in local WGS-84 horizon frame in nanoTeslas
;   * </ul>
;   * <p>
;   * All interesting field data is encoded in the bx, by, and bz components. You can get
;   * <ul>
;   * <li>Compass horizontal declination in radians, poisitive east =atan2(by/bx)</li>
;   * <li>Vertical inclination in radians, positive down=atan2(bz/bh)</li>
;   * <li>horizontal field intensity =sqrt(bx^2+by^2)</li>
;   * <li>Total field intensity =sqrt(bh^2+bz^2)</li>
;   * </li>
;   */
function wmm2010,lla,time,ti=ti,bh=bh,dec=dec,dip=dip
  rlat=lla[0]
  rlon=lla[1]
  alt=lla[2]
 a=6378137d;
 f=1d/298.257223563d;
 ;b=6356.7523142d;
 b=a*(1d -f)
 re=6371200d;
 a2=a*a;
 b2=b*b;
 c2=a2-b2;
 a4=a2*a2;
 b4=b2*b2;
 c4=a4-b4;
 epoch=2010d
  if n_elements(time) eq 0 then time=epoch
 maxord=12
 WMM2010Cof= [ $
[        0.0d,      0.0  ,      0.0 ,       0.0], $;  0  0 
[  -29496.6 ,      0.0  ,     11.6 ,       0.0], $;  1  0
[   -1586.3 ,   4944.4  ,     16.5 ,     -25.9], $;  1  1
[   -2396.6 ,      0.0  ,    -12.1 ,       0.0], $;  2  0
[    3026.1 ,  -2707.7  ,     -4.4 ,     -22.5], $;  2  1
[    1668.6 ,   -576.1  ,      1.9 ,     -11.8], $;  2  2
[    1340.1 ,      0.0  ,      0.4 ,       0.0], $;  3  0
[   -2326.2 ,   -160.2  ,     -4.1 ,       7.3], $;  3  1
[    1231.9 ,    251.9  ,     -2.9 ,      -3.9], $;  3  2
[     634.0 ,   -536.6  ,     -7.7 ,      -2.6], $;  3  3
[     912.6 ,      0.0  ,     -1.8 ,       0.0], $;  4  0
[     808.9 ,    286.4  ,      2.3 ,       1.1], $;  4  1
[     166.7 ,   -211.2  ,     -8.7 ,       2.7], $;  4  2
[    -357.1 ,    164.3  ,      4.6 ,       3.9], $;  4  3
[      89.4 ,   -309.1  ,     -2.1 ,      -0.8], $;  4  4
[    -230.9 ,      0.0  ,     -1.0 ,       0.0], $;  5  0
[     357.2 ,     44.6  ,      0.6 ,       0.4], $;  5  1
[     200.3 ,    188.9  ,     -1.8 ,       1.8], $;  5  2
[    -141.1 ,   -118.2  ,     -1.0 ,       1.2], $;  5  3
[    -163.0 ,      0.0  ,      0.9 ,       4.0], $;  5  4
[      -7.8 ,    100.9  ,      1.0 ,      -0.6], $;  5  5
[      72.8 ,      0.0  ,     -0.2 ,       0.0], $;  6  0
[      68.6 ,    -20.8  ,     -0.2 ,      -0.2], $;  6  1
[      76.0 ,     44.1  ,     -0.1 ,      -2.1], $;  6  2
[    -141.4 ,     61.5  ,      2.0 ,      -0.4], $;  6  3
[     -22.8 ,    -66.3  ,     -1.7 ,      -0.6], $;  6  4
[      13.2 ,      3.1  ,     -0.3 ,       0.5], $;  6  5
[     -77.9 ,     55.0  ,      1.7 ,       0.9], $;  6  6
[      80.5 ,      0.0  ,      0.1 ,       0.0], $;  7  0
[     -75.1 ,    -57.9  ,     -0.1 ,       0.7], $;  7  1
[      -4.7 ,    -21.1  ,     -0.6 ,       0.3], $;  7  2
[      45.3 ,      6.5  ,      1.3 ,      -0.1], $;  7  3
[      13.9 ,     24.9  ,      0.4 ,      -0.1], $;  7  4
[      10.4 ,      7.0  ,      0.3 ,      -0.8], $;  7  5
[       1.7 ,    -27.7  ,     -0.7 ,      -0.3], $;  7  6
[       4.9 ,     -3.3  ,      0.6 ,       0.3], $;  7  7
[      24.4 ,      0.0  ,     -0.1 ,       0.0], $;  8  0
[       8.1 ,     11.0  ,      0.1 ,      -0.1], $;  8  1
[     -14.5 ,    -20.0  ,     -0.6 ,       0.2], $;  8  2
[      -5.6 ,     11.9  ,      0.2 ,       0.4], $;  8  3
[     -19.3 ,    -17.4  ,     -0.2 ,       0.4], $;  8  4
[      11.5 ,     16.7  ,      0.3 ,       0.1], $;  8  5
[      10.9 ,      7.0  ,      0.3 ,      -0.1], $;  8  6
[     -14.1 ,    -10.8  ,     -0.6 ,       0.4], $;  8  7
[      -3.7 ,      1.7  ,      0.2 ,       0.3], $;  8  8
[       5.4 ,      0.0  ,      0.0 ,       0.0], $;  9  0
[       9.4 ,    -20.5  ,     -0.1 ,       0.0], $;  9  1
[       3.4 ,     11.5  ,      0.0 ,      -0.2], $;  9  2
[      -5.2 ,     12.8  ,      0.3 ,       0.0], $;  9  3
[       3.1 ,     -7.2  ,     -0.4 ,      -0.1], $;  9  4
[     -12.4 ,     -7.4  ,     -0.3 ,       0.1], $;  9  5
[      -0.7 ,      8.0  ,      0.1 ,       0.0], $;  9  6
[       8.4 ,      2.1  ,     -0.1 ,      -0.2], $;  9  7
[      -8.5 ,     -6.1  ,     -0.4 ,       0.3], $;  9  8
[     -10.1 ,      7.0  ,     -0.2 ,       0.2], $;  9  9
[      -2.0 ,      0.0  ,      0.0 ,       0.0], $; 10  0
[      -6.3 ,      2.8  ,      0.0 ,       0.1], $; 10  1
[       0.9 ,     -0.1  ,     -0.1 ,      -0.1], $; 10  2
[      -1.1 ,      4.7  ,      0.2 ,       0.0], $; 10  3
[      -0.2 ,      4.4  ,      0.0 ,      -0.1], $; 10  4
[       2.5 ,     -7.2  ,     -0.1 ,      -0.1], $; 10  5
[      -0.3 ,     -1.0  ,     -0.2 ,       0.0], $; 10  6
[       2.2 ,     -3.9  ,      0.0 ,      -0.1], $; 10  7
[       3.1 ,     -2.0  ,     -0.1 ,      -0.2], $; 10  8
[      -1.0 ,     -2.0  ,     -0.2 ,       0.0], $; 10  9
[      -2.8 ,     -8.3  ,     -0.2 ,      -0.1], $; 10 10
[       3.0 ,      0.0  ,      0.0 ,       0.0], $; 11  0
[      -1.5 ,      0.2  ,      0.0 ,       0.0], $; 11  1
[      -2.1 ,      1.7  ,      0.0 ,       0.1], $; 11  2
[       1.7 ,     -0.6  ,      0.1 ,       0.0], $; 11  3
[      -0.5 ,     -1.8  ,      0.0 ,       0.1], $; 11  4
[       0.5 ,      0.9  ,      0.0 ,       0.0], $; 11  5
[      -0.8 ,     -0.4  ,      0.0 ,       0.1], $; 11  6
[       0.4 ,     -2.5  ,      0.0 ,       0.0], $; 11  7
[       1.8 ,     -1.3  ,      0.0 ,      -0.1], $; 11  8
[       0.1 ,     -2.1  ,      0.0 ,      -0.1], $; 11  9
[       0.7 ,     -1.9  ,     -0.1 ,       0.0], $; 11 10
[       3.8 ,     -1.8  ,      0.0 ,      -0.1], $; 11 11
[      -2.2 ,      0.0  ,      0.0 ,       0.0], $; 12  0
[      -0.2 ,     -0.9  ,      0.0 ,       0.0], $; 12  1
[       0.3 ,      0.3  ,      0.1 ,       0.0], $; 12  2
[       1.0 ,      2.1  ,      0.1 ,       0.0], $; 12  3
[      -0.6 ,     -2.5  ,     -0.1 ,       0.0], $; 12  4
[       0.9 ,      0.5  ,      0.0 ,       0.0], $; 12  5
[      -0.1 ,      0.6  ,      0.0 ,       0.1], $; 12  6
[       0.5 ,      0.0  ,      0.0 ,       0.0], $; 12  7
[      -0.4 ,      0.1  ,      0.0 ,       0.0], $; 12  8
[      -0.4 ,      0.3  ,      0.0 ,       0.0], $; 12  9
[       0.2 ,     -0.9  ,      0.0 ,       0.0], $; 12 10
[      -0.8 ,     -0.2  ,     -0.1 ,       0.0], $; 12 11
[       0.0 ,      0.9  ,      0.1 ,       0.0]]  ; 12 12
 
 WMM2005Cof= [ $
[      0.0d,       0.0,        0.0,        0.0], $ ;/*  0  0 */
[ -29556.8,       0.0,        8.0,        0.0], $ ;/*  1  0 */
[  -1671.7,    5079.8,       10.6,      -20.9], $ ;/*  1  1 */
[  -2340.6,       0.0,      -15.1,        0.0], $ ;/*  2  0 */
[   3046.9,   -2594.7,       -7.8,      -23.2], $ ;/*  2  1 */
[   1657.0,    -516.7,       -0.8,      -14.6], $ ;/*  2  2 */
[   1335.4,       0.0,        0.4,        0.0], $ ;/*  3  0 */
[  -2305.1,    -199.9,       -2.6,        5.0], $ ;/*  3  1 */
[   1246.7,     269.3,       -1.2,       -7.0], $ ;/*  3  2 */
[    674.0,    -524.2,       -6.5,       -0.6], $ ;/*  3  3 */
[    919.8,       0.0,       -2.5,        0.0], $ ;/*  4  0 */
[    798.1,     281.5,        2.8,        2.2], $ ;/*  4  1 */
[    211.3,    -226.0,       -7.0,        1.6], $ ;/*  4  2 */
[   -379.4,     145.8,        6.2,        5.8], $ ;/*  4  3 */
[    100.0,    -304.7,       -3.8,        0.1], $ ;/*  4  4 */
[   -227.4,       0.0,       -2.8,        0.0], $ ;/*  5  0 */
[    354.6,      42.4,        0.7,        0.0], $ ;/*  5  1 */
[    208.7,     179.8,       -3.2,        1.7], $ ;/*  5  2 */
[   -136.5,    -123.0,       -1.1,        2.1], $ ;/*  5  3 */
[   -168.3,     -19.5,        0.1,        4.8], $ ;/*  5  4 */
[    -14.1,     103.6,       -0.8,       -1.1], $ ;/*  5  5 */
[     73.2,       0.0,       -0.7,        0.0], $ ;/*  6  0 */
[     69.7,     -20.3,        0.4,       -0.6], $ ;/*  6  1 */
[     76.7,      54.7,       -0.3,       -1.9], $ ;/*  6  2 */
[   -151.2,      63.6,        2.3,       -0.4], $ ;/*  6  3 */
[    -14.9,     -63.4,       -2.1,       -0.5], $ ;/*  6  4 */
[     14.6,      -0.1,       -0.6,       -0.3], $ ;/*  6  5 */
[    -86.3,      50.4,        1.4,        0.7], $ ;/*  6  6 */
[     80.1,       0.0,        0.2,        0.0], $ ;/*  7  0 */
[    -74.5,     -61.5,       -0.1,        0.6], $ ;/*  7  1 */
[     -1.4,     -22.4,       -0.3,        0.4], $ ;/*  7  2 */
[     38.5,       7.2,        1.1,        0.2], $ ;/*  7  3 */
[     12.4,      25.4,        0.6,        0.3], $ ;/*  7  4 */
[      9.5,      11.0,        0.5,       -0.8], $ ;/*  7  5 */
[      5.7,     -26.4,       -0.4,       -0.2], $ ;/*  7  6 */
[      1.8,      -5.1,        0.6,        0.1], $ ;/*  7  7 */
[     24.9,       0.0,        0.1,        0.0], $ ;/*  8  0 */
[      7.7,      11.2,        0.3,       -0.2], $ ;/*  8  1 */
[    -11.6,     -21.0,       -0.4,        0.1], $ ;/*  8  2 */
[     -6.9,       9.6,        0.3,        0.3], $ ;/*  8  3 */
[    -18.2,     -19.8,       -0.3,        0.4], $ ;/*  8  4 */
[     10.0,      16.1,        0.2,        0.1], $ ;/*  8  5 */
[      9.2,       7.7,        0.4,       -0.2], $ ;/*  8  6 */
[    -11.6,     -12.9,       -0.7,        0.4], $ ;/*  8  7 */
[     -5.2,      -0.2,        0.4,        0.4], $ ;/*  8  8 */
[      5.6,       0.0,        0.0,        0.0], $ ;/*  9  0 */
[      9.9,     -20.1,        0.0,        0.0], $ ;/*  9  1 */
[      3.5,      12.9,        0.0,        0.0], $ ;/*  9  2 */
[     -7.0,      12.6,        0.0,        0.0], $ ;/*  9  3 */
[      5.1,      -6.7,        0.0,        0.0], $ ;/*  9  4 */
[    -10.8,      -8.1,        0.0,        0.0], $ ;/*  9  5 */
[     -1.3,       8.0,        0.0,        0.0], $ ;/*  9  6 */
[      8.8,       2.9,        0.0,        0.0], $ ;/*  9  7 */
[     -6.7,      -7.9,        0.0,        0.0], $ ;/*  9  8 */
[     -9.1,       6.0,        0.0,        0.0], $ ;/*  9  9 */
[     -2.3,       0.0,        0.0,        0.0], $ ;/* 10  0 */
[     -6.3,       2.4,        0.0,        0.0], $ ;/* 10  1 */
[      1.6,       0.2,        0.0,        0.0], $ ;/* 10  2 */
[     -2.6,       4.4,        0.0,        0.0], $ ;/* 10  3 */
[      0.0,       4.8,        0.0,        0.0], $ ;/* 10  4 */
[      3.1,      -6.5,        0.0,        0.0], $ ;/* 10  5 */
[      0.4,      -1.1,        0.0,        0.0], $ ;/* 10  6 */
[      2.1,      -3.4,        0.0,        0.0], $ ;/* 10  7 */
[      3.9,      -0.8,        0.0,        0.0], $ ;/* 10  8 */
[     -0.1,      -2.3,        0.0,        0.0], $ ;/* 10  9 */
[     -2.3,      -7.9,        0.0,        0.0], $ ;/* 10 10 */
[      2.8,       0.0,        0.0,        0.0], $ ;/* 11  0 */
[     -1.6,       0.3,        0.0,        0.0], $ ;/* 11  1 */
[     -1.7,       1.2,        0.0,        0.0], $ ;/* 11  2 */
[      1.7,      -0.8,        0.0,        0.0], $ ;/* 11  3 */
[     -0.1,      -2.5,        0.0,        0.0], $ ;/* 11  4 */
[      0.1,       0.9,        0.0,        0.0], $ ;/* 11  5 */
[     -0.7,      -0.6,        0.0,        0.0], $ ;/* 11  6 */
[      0.7,      -2.7,        0.0,        0.0], $ ;/* 11  7 */
[      1.8,      -0.9,        0.0,        0.0], $ ;/* 11  8 */
[      0.0,      -1.3,        0.0,        0.0], $ ;/* 11  9 */
[      1.1,      -2.0,        0.0,        0.0], $ ;/* 11 10 */
[      4.1,      -1.2,        0.0,        0.0], $ ;/* 11 11 */
[     -2.4,       0.0,        0.0,        0.0], $ ;/* 12  0 */
[     -0.4,      -0.4,        0.0,        0.0], $ ;/* 12  1 */
[      0.2,       0.3,        0.0,        0.0], $ ;/* 12  2 */
[      0.8,       2.4,        0.0,        0.0], $ ;/* 12  3 */
[     -0.3,      -2.6,        0.0,        0.0], $ ;/* 12  4 */
[      1.1,       0.6,        0.0,        0.0], $ ;/* 12  5 */
[     -0.5,       0.3,        0.0,        0.0], $ ;/* 12  6 */
[      0.4,       0.0,        0.0,        0.0], $ ;/* 12  7 */
[     -0.3,       0.0,        0.0,        0.0], $ ;/* 12  8 */
[     -0.3,       0.3,        0.0,        0.0], $ ;/* 12  9 */
[     -0.1,      -0.9,        0.0,        0.0], $ ;/* 12 10 */
[     -0.3,      -0.4,        0.0,        0.0], $ ;/* 12 11 */
[     -0.1,       0.8,        0.0,        0.0]]   ; /* 12 12 */
WMMCof=WMM2010Cof                      
  common wmm2010_static,k,h,hd,g,gd,fn,fm
  if n_elements(k) eq 0 then begin
    snorm=dblarr(maxord+1,maxord+1);
    ;/* CONVERT SCHMIDT NORMALIZED GAUSS COEFFICIENTS TO UNNORMALIZED */
    snorm[0,0] = 1.0;
    g=dblarr(maxord+1,maxord+1);
    gd=dblarr(maxord+1,maxord+1);
    h=dblarr(maxord+1,maxord+1);
    hd=dblarr(maxord+1,maxord+1);
    k=dblarr(maxord+1,maxord+1);
    fn=dblarr(maxord+1,maxord+1);
    fm=dblarr(maxord+1,maxord+1);
    for n=1,maxord do begin
      snorm[n,0] = snorm[n-1,0]*double(2*n-1)/double(n);
      j = 2;
      for m=0,n do begin
        i=n*(n+1)/2+m; //Get a triangular index
        k[n,m] = double(((n-1)*(n-1))-(m*m))/double((2*n-1)*(2*n-3));
        if (m gt 0) then begin
          flnmj = double((n-m+1)*j)/double(n+m);
          snorm[n,m] = snorm[n,m-1]*sqrt(flnmj);
          j = 1;
          h[n,m] = snorm[n,m]*WMMCof[1,i];
          hd[n,m] = snorm[n,m]*WMMCof[3,i];
        end
        g[n,m] = snorm[n,m]*WMMCof[0,i];
        gd[n,m] = snorm[n,m]*WMMCof[2,i];
      end
      fn[n] = double(n+1);
      fm[n] = double(n);
    end
  end
  
  
  ;  double q,q1,q2,ct,st,r,r2,d,ca,sa,aor,ar,par,temp1,temp2,parp;
  dt = double(time - epoch);
  ;  //Some conevnience values for
  srlon = sin(rlon);
  srlat = sin(rlat);
  crlon = cos(rlon);
  crlat = cos(rlat);
  srlat2 = srlat*srlat;
  crlat2 = crlat*crlat;

  ;  //Convert from geodetic latitude and altitude to geocentric latitude and radius
  ;  //TRWMM eq 17 and 18
  q = sqrt(a2-c2*srlat2);
  q1 = alt*q;
  q2 = ((q1+a2)/(q1+b2))*((q1+a2)/(q1+b2));
  ct = srlat/sqrt(q2*crlat2+srlat2);
  st = sqrt(1.0d -(ct*ct));
  r2 = (alt*alt)+2.0d*q1+(a4-c4*srlat2)/(q*q);
  r = sqrt(r2);
  d = sqrt(a2*crlat2+b2*srlat2);
  ca = (alt+d)/r;
  sa = c2*crlat*srlat/(r*d);
  ;  //Normalize radius
  aor = re/r;
  ar = aor*aor;

  sp=dblarr(maxord+1);
  cp=dblarr(maxord+1);
  sp[0] = 0.0d;
  cp[0] = 1.0d;
  sp[1] = srlon;
  cp[1] = crlon;
  for m=2,maxord do begin
    sp[m] = sp[1]*cp[m-1]+cp[1]*sp[m-1];
    cp[m] = cp[1]*cp[m-1]-sp[1]*sp[m-1];
  end
  br=0d;
  bt=0d;
  bp=0d;
  bpp=0d;
  snorm=dblarr(maxord+1,maxord+1);
  snorm[0,0]=1.0;
  dp=dblarr(maxord+1,maxord+1)
  dp[0,0] = 0.0;
  tg=dblarr(maxord+1,maxord+1)
  th=dblarr(maxord+1,maxord+1)
  pp=dblarr(maxord+1)
  pp[0] = 1.0;
  for n=1,maxord do begin
    ar = ar*aor;
    for m=0,n do begin
;/*
;   COMPUTE UNNORMALIZED ASSOCIATED LEGENDRE POLYNOMIALS
;   AND DERIVATIVES VIA RECURSION RELATIONS
;*/
      if n eq m then begin
        snorm[n,m] = st*snorm[n-1,m-1];
        dp[n,m] = st*dp[n-1,m-1]+ct*snorm[n-1,m-1];
      end else if n eq 1 and m eq 0 then begin
        snorm[n,m] = ct*snorm[n-1,m];
        dp[n,m] = ct*dp[n-1,m]-st*snorm[n-1,m];
      end else if n gt 1 then begin
        snorm[n,m] = ct*snorm[n-1,m];
        dp[n,m] = ct*dp[n-1,m] - st*snorm[n-1,m];
        if m le (n-2) then begin
          snorm[n,m]-=k[n,m]*snorm[n-2,m];
          if m le (n-2) then dp[n,m]-=k[n,m]*dp[n-2,m];
        end
      end
;/*
;    TIME ADJUST THE GAUSS COEFFICIENTS
;*/
      tg[n,m] = g[n,m]+dt*gd[n,m];
      th[n,m] = h[n,m]+dt*hd[n,m];
;/*
;    ACCUMULATE TERMS OF THE SPHERICAL HARMONIC EXPANSIONS
;*/
      par = ar*snorm[n,m];
      temp1 = tg[n,m]*cp[m]+th[n,m]*sp[m];
      temp2 = tg[n,m]*sp[m]-th[n,m]*cp[m];
      bt = bt-ar*temp1*dp[n,m];
      bp += (fm[m]*temp2*par);
      br += (fn[n]*temp1*par);
;/*
;    SPECIAL CASE:  NORTH/SOUTH GEOGRAPHIC POLES
;*/
      if st eq 0.0 and  m eq 1 then begin
        if n eq 1 then begin
              pp[n] = pp[n-1];
        end else begin
            pp[n] = ct*pp[n-1]-k[n,m]*pp[n-2];
        end
        parp = ar*pp[n];
        bpp += (fm[m]*temp2*parp);
      end
    end
  end
  
  if st eq 0.0 then begin
    bp = bpp;
  end else begin
    bp /= st;
  end
;/*
;    ROTATE MAGNETIC VECTOR COMPONENTS FROM SPHERICAL TO
;    GEODETIC COORDINATES
;*/
  bx = -bt*ca-br*sa;
  by = bp;
  bz = bt*sa-br*ca;

  bh = sqrt(bx*bx+by*by);
  ti = sqrt(bh*bh+bz*bz);
  dec = atan(by,bx);
  dip = atan(bz,bh);
  return,[bx,by,bz]
end
