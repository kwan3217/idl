pro ellipsoid_fit,x_,y_,z_,center=center,radii=radii,evecs=evecs,pars=pars
;function [ center, radii, evecs, v ] = ellipsoid_fit( X, flag, equals )
;%
;% Fit an ellispoid/sphere to a set of xyz data points:
;%
;%   [center, radii, evecs, pars ] = ellipsoid_fit( X )
;%   [center, radii, evecs, pars ] = ellipsoid_fit( [x y z] );
;%   [center, radii, evecs, pars ] = ellipsoid_fit( X, 1 );
;%   [center, radii, evecs, pars ] = ellipsoid_fit( X, 2, 'xz' );
;%   [center, radii, evecs, pars ] = ellipsoid_fit( X, 3 );
;%
;% Parameters:
;% * X, [x y z]   - Cartesian data, n x 3 matrix or three n x 1 vectors
;% * flag         - 0 fits an arbitrary ellipsoid (default),
;%                - 1 fits an ellipsoid with its axes along [x y z] axes
;%                - 2 followed by, say, 'xy' fits as 1 but also x_rad = y_rad
;%                - 3 fits a sphere
;%
;% Output:
;% * center    -  ellispoid center coordinates [xc; yc; zc]
;% * ax        -  ellipsoid radii [a; b; c]
;% * evecs     -  ellipsoid radii directions as columns of the 3x3 matrix
;% * v         -  the 9 parameters describing the ellipsoid algebraically: 
;%                Ax^2 + By^2 + Cz^2 + 2Dxy + 2Exz + 2Fyz + 2Gx + 2Hy + 2Iz = 1
;%
;% Author:
;% Yury Petrov, Northeastern University, Boston, MA
;%
if n_elements(y_) eq 0 then begin
  resolve_grid,x_,x=x,y=y,z=z
end else begin
  x=x_
  y=y_
  z=z_
end
x=double(x)
y=double(y)
z=double(z)
; need nine or more data points
if n_elements( x ) lt 9 then message,'Must have at least 9 points to fit a unique ellipsoid';

; fit ellipsoid in the form Ax^2 + By^2 + Cz^2 + 2Dxy + 2Exz + 2Fyz + 2Gx + 2Hy + 2Iz = 1
D = transpose([ [x * x], $
      [y * y], $
      [z * z], $
      [2 * x * y], $
      [2 * x * z], $
      [2 * y * z], $
      [2 * x], $
      [2 * y], $ 
      [2 * z] ]);  % ndatapoints x 9 ellipsoid parameters

; solve the normal system of equations
ones=transpose(dblarr(n_elements(x),1))+1
vleft=transpose(D) ## D
vright=transpose(D) ## ones
v = invert( vleft ) ## vright;

; find the ellipsoid parameters
   ; form the algebraic form of the ellipsoid
    A = [ [v(0),v(3),v(4),v(6)],$
          [v(3),v(1),v(5),v(7)],$
          [v(4),v(5),v(2),v(8)],$
          [v(6),v(7),v(8),-1] ];
    ; find the center of the ellipsoid
    center = -invert(A[0:2,0:2]) ## transpose( [ v(6), v(7), v(8) ]);
    ; form the corresponding translation matrix
    T = identity( 4 );
    T[ 0:2,3] = transpose(center);
    ; translate to the center
    R = T ## A ## transpose(T);
    ; solve the eigenproblem
    ;[ evecs evals ] = eig( R( 1:3, 1:3 ) / -R( 4, 4 ) );
    evals=real_part(la_eigenproblem(-R[0:2,0:2]/R[3,3],eigenvectors=evecs))
    evecs=real_part(evecs)
    radii = sqrt( 1.0 /  evals  );



end