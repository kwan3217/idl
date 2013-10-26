pro test_ellipsoid_fit
; test ellipsoid fit

; create the test data:
; radii
a = 8;
b = 6;
c = 10;
;[ s, t ] = meshgrid( 0 : 0.3 : pi/2, 0 : 0.3 : pi );
s=range(0,delta=0.3,!pi/2)
t=range(0,delta=0.3,!pi)
s2=rebin(s,[n_elements(s),n_elements(t)])
t2=rebin(transpose(t),[n_elements(s),n_elements(t)])
s=s2
t=t2
x = a * cos(s) * cos( t );
y = b * cos(s) * sin( t );
z = c * sin(s);
; rotation
ang = !pi/6;
xt = x * cos( ang ) - y * sin( ang );
yt = x * sin( ang ) + y * cos( ang );
; translation
shiftx = 1;
shifty = 2;
shiftz = 3;
x = xt + shiftx;
y = yt + shifty;
z = z  + shiftz;

; add testing noise:
noiseIntensity = 0.;
x = x + randomn(seed, size( s,/dim ) ) * noiseIntensity;
y = y + randomn(seed, size( s,/dim ) ) * noiseIntensity;
z = z + randomn(seed, size( s,/dim ) ) * noiseIntensity;
x = x[*];
y = y[*];
z = z[*];

; do the fitting
ellipsoid_fit, [[x], [y], [z] ],center=center,radii=radii,evecs=evecs,pars=v

;figure out A and W-1 matrix from eigenvalues/eigenvectors
;eigenvalue equation is Ax=rx with unit-length x
;so given a bunch of known x and r, form X=[x0,x1,x2...] and B=[r0x0,r1x1,r2x2...]
;Now we have AX=B
;solve for A by postmultiplying both sides by X^-1
XX=normalize_grid(transpose(evecs))
BB=transpose(evecs)*rebin(radii,size(transpose(evecs),/dim))
AA=BB##invert(XX)
print,AA

;print,format='(%"Ellipsoid center: %.3g %.3g %.3g")', center ;
;print,format='(%"Ellipsoid radii : %.3g %.3g %.3g\n', radii );
;print,format='(%"Ellipsoid evecs :\n' );
;print,format='(%"%.3g %.3g %.3g\n%.3g %.3g %.3g\n%.3g %.3g %.3g\n', $
;    evecs(1), evecs(2), evecs(3), evecs(4), evecs(5), evecs(6), evecs(7), evecs(8), evecs(9) );
;fprintf( 'Algebraic form  :\n' );
;fprintf( '%.3g ', v );
;fprintf( '\n' );

; draw data
;plot3( x, y, z, '.r' );
;hold on;

;%draw fit
;maxd = max( [ a b c ] );
;step = maxd / 50;
;[ x, y, z ] = meshgrid( -maxd:step:maxd + shiftx, -maxd:step:maxd + shifty, -maxd:step:maxd + shiftz )

;Ellipsoid = v(1) *x.*x +   v(2) * y.*y + v(3) * z.*z + ...
;          2*v(4) *x.*y + 2*v(5)*x.*z + 2*v(6) * y.*z + ...
;          2*v(7) *x    + 2*v(8)*y    + 2*v(9) * z;
;p = patch( isosurface( x, y, z, Ellipsoid, 1 ) );
;set( p, 'FaceColor', 'g', 'EdgeColor', 'none' );
;view( -70, 40 );
;axis vis3d;
;camlight;
;lighting phong;
end