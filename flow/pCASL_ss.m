M0 = 1

[alpha phi]= meshgrid(0:0.2:pi , 0:0.2:4*pi);
Mz = (M0 * sin(alpha) .* sin( phi/2)) ./ sqrt( (1-cos(alpha)).^2  + (sin(alpha) .* sin(phi/2)) .^2 );

surf(alpha, phi, Mz) ; xlabel('\alpha'); ylabel( '\phi'); zlabel( '\Mz')