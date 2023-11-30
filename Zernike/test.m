% test of Zernike2D_complex_norm and FTZernike2D_complex_norm

clear all;
addpath('\\exoplanetshare\LabData\FundedProjects\PIAACMC_TDEM\Rus\fundamental_limits\zoomFFT2D');

pupil.N = 128;
pupil.D = 2;
pupil.dx = pupil.D/pupil.N;
pupil.dy = pupil.D/pupil.N;
pupil.x = linspace(-(pupil.D - pupil.dx)/2, (pupil.D - pupil.dy)/2, pupil.N);
pupil.y = pupil.x';
[pupil.xx pupil.yy]= meshgrid(pupil.x,pupil.y);
[pupil.ttheta pupil.rr]=cart2pol(pupil.xx, pupil.yy);
pupil.A = pupil.rr < pupil.D/2;

image.N = 128;
image.D = 5;
image.dx = image.D/image.N;
image.dy = image.D/image.N;
image.x = linspace(-(image.D - image.dx)/2, (image.D - image.dy)/2, image.N);
image.y = image.x';
[image.xx image.yy]= meshgrid(image.x,image.y);
[image.ttheta image.rr]=cart2pol(image.xx, image.yy);

for n = 0:4
    for m = -n:2:n
        v = pupil.A.*Zernike2D_complex_norm(n,m,pupil.rr, pupil.ttheta);
        v_hat = FTZernike2D_complex_norm(n,m,image.rr,image.ttheta);
        v_hatn = 1i*zoomFFT_realunits(pupil.x, pupil.y, v, image.x, image.y', 1,1); %multiplication by i to convert Fraunhofer to straight FT
        
        figure(1); subplot(5,5, n*5 + (m+n)/2 + 1);
        imagesc(real(1i^(m>0)*v)); axis image; axis off;
        
        figure(2); subplot(5,5, n*5 + (m+n)/2 + 1);
        imagesc(real(1i^(m>0)*v_hat)); axis image; axis off;
        
        figure(3); subplot(5,5, n*5 + (m+n)/2 + 1);
        imagesc(real(1i^(m>0)*v_hatn)); axis image; axis off;
        
        figure(4); subplot(5,5, n*5 + (m+n)/2 + 1);
        imagesc(abs(v_hat - v_hatn).^2, [0 1e-4]); axis image; axis off;
    end
end
    
% plot_lookup = [1 6 7 11 12 13 16 17 18 19 21 22 23 24 25];