% This version implements polar modes rather than cartesian
% It also uses circumscribed lambda/D units (see line 79-80 to change this
% to effective lambda/D units)

clear all;

N2_max = 10; % maximum coronagraph order

% Define pupil plane and telescope aperture
A = fitsread('pupil_offaxis_1024.fits');
Areapix = trapz(trapz(A));
Rpix = sqrt(Areapix/pi); % this sets pupil.Deff to the radius of unobstructed aperture of the same diameter
Deff = 1; % value of 1 here normalizes pupil plane units, so that raw image plane units are in f*lambda/Deff

pupil = make2Dgrid(size(A,1), Deff/(2*Rpix) * size(A,1),'vertex-centered'); % second number refers to full diameter of grid, usually slightly larger than Deff

pupil.As(:,:,1) = A;
pupil.As(:,:,2) = pupil.rr < Deff/2; % unobstructed aperture with the same area
Dc = 2*max(max(pupil.rr.*pupil.As(:,:,1))); % circumscribed diameter
pupil.As(:,:,3) = pupil.rr <= Dc/2; % circumscribed pupil aperture

pupil.D = Dc; % This specifies what diameter to use for l/D units in the focal plane (D_effective or D_circumscribed). Use effective for more elegant math, circumscribed for generating Chris plots

% define science plane
sci = make2Dgrid(128,8,'pixel-centered');
sci.f = 1;
sci.lambda = 1;
sci.flD = sci.f*sci.lambda/pupil.D; % uses effective pupil l/D units

for A_index = 1:3
   
    pupil.A = pupil.As(:,:,A_index);
    
    disp('Generating coronagraph...');  %tic;
    ideal_coronagraph = ideal_coronagraph_generate(N2_max, pupil, sci); %toc;
    
    disp('Displaying coronagraph modes...');                %tic;
    ideal_coronagraph_draw_modes(ideal_coronagraph, 1, 2);  %toc;
    
    disp('Computing Tc / flat field...');                   %tic;
    ideal_coronagraph.Tc = ideal_coronagraph_Tc(ideal_coronagraph); %toc;
    ideal_coronagraph_Tc_display(ideal_coronagraph, sci, 3, 4, A_index); 

end