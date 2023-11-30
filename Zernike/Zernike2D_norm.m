function Z = Zernike2D_norm(n,m,rho,phi);
%
% Return the Zernike mode Z_n^m(rho, phi)
% normalized to unity rms on the unit circle (?)
% rho and phi can be 2D arrays
%
if m >= 0
    Z = Zernike_norm(n,m,rho).*cos(m*phi);
else
    Z = Zernike_norm(n,-m,rho).*sin(-m*phi);
end