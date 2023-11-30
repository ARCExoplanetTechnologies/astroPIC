% Generates an ideal coronagraph and computes an off-axis response

clear all;
addpath('\\exoplanetshare\LabData\Software\Rus_libraries\Zernike');
addpath('\\exoplanetshare\LabData\Software\Rus_libraries\misc_utilities');
addpath('\\exoplanetshare\LabData\Software\Rus_libraries\Optical Propagation\v3\zoomFFT2D');

N2 = 10; %order of the optimal coronagraph

% Define pupil plane and telescope aperture
pupil = pupil_generate('LUVOIR_A_1024.fits', 1, 'circumscribed', 'vertex-centered'); % second argument is pupil diameter

% define science plane
sci = make2Dgrid(512, 8, 'vertex-centred');
sci.f = 1;
sci.lambda = 1;
sci.flD = sci.f*sci.lambda/pupil.D;

disp('Generating coronagraph...');  %tic;
ideal_coronagraph = ideal_coronagraph_generate(N2, pupil, sci); %toc;
ideal_coronagraph_draw_modes(ideal_coronagraph, 1, 2); %toc; % second and third arguments are figure numbers

%% Compute off-axis PSF
theta_sky = [0.5 0.5]; % angle of off-axis point source

% create tip/tilt
pupil.E = pupil.A.*exp(2*pi*1i*(pupil.xx * theta_sky(1) + pupil.yy * theta_sky(2))/pupil.D)/sqrt(pupil.Area); % energy normalized
% pupil.E = pupil.A.*exp(2*pi*1i*(pupil.xx * theta_sky(1) + pupil.yy * theta_sky(2))/pupil.D)/pupil.Area; % contrast units
    
Elyot = ideal_coronagraph_pupil_to_lyot(N2, ideal_coronagraph, pupil);
sci.E = 1i*zoomFFT_realunits(pupil.x, pupil.y, Elyot, sci.x, sci.y, sci.f, sci.lambda);

figure(3)
imagesc(sci.x, sci.y, abs(sci.E).^2); 
xlabel('\theta_{sci}'); ylabel('\theta_{sci}'); axis image; colorbar;
title(sprintf('Off-axis PSF for \\theta_{sky}=(%0.1f,%0.1f)', theta_sky(1), theta_sky(2))); 