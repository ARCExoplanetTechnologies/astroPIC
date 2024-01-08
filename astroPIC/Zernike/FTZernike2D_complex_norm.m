function Z_hat = FTZernike2D_complex_norm(n,m,rho,phi);
%
% Analytical 2D Fourier Transform of Zernike mode Z_n^m(rho, phi)
% Energy normalized for for Zernikes on unit circle
% For l/D units, use theta = 2*rho (i.e pass (n,m,theta/2, phi))
% rho and phi can be 2D arrays

Z_hat = sqrt((n+1)*pi)* 1i^(-n) * 2 * besselj(n+1,2*pi*rho)./(2*pi*rho).*exp(i*m*phi);