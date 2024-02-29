% generate asymptotic off-axis PSF
clear all;

addpath('\\exoplanetshare\LabData\Software\Rus_libraries\Optical Propagation\v2\zoomFFT2D');
addpath('\\exoplanetshare\LabData\Software\Rus_libraries\Zernike');
addpath('\\exoplanetshare\LabData\Software\Rus_libraries\misc_utilities');
addpath('\\exoplanetshare\LabData\Software\Rus_libraries\ideal_coronagraph');

dr = 0.001;
r = 0:dr:1;

n = 2;
ms = -n:2:n;

v0 = sqrt(1/pi)*Zernike(0,0,r);
for k = 1:length(ms)
    m = ms(k);
    vn = sqrt((n+1)/pi)*Zernike(n,m,r);
    %2*pi*trapz(vn.^2.*r*dr)
    (2*pi*trapz(v0.*r.^n.*vn.*r*dr))^2
    %c(k) = nchoosek(n,k-1)^2*(2*pi*trapz(v0.*r.^n.*vn.*r*dr))^2;
end

% c
% sum(c)