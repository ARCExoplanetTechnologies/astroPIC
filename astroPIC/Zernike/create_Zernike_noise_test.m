% Test routine for Zernike noise

clear all;

%% define pupil
pupil.D = 1; 
pupil.N = 1024; % assumes Nx = Ny
pupil.Nt = 100; % number of temporal samples
pupil.x = linspace(-pupil.D/2, pupil.D/2, pupil.N);
pupil.dx = pupil.x(2) - pupil.x(1);
pupil.y = pupil.x';
pupil.dy = pupil.dx;
[pupil.xx pupil.yy] = meshgrid(pupil.x, pupil.y);
[pupil.ttheta pupil.rr] = cart2pol(pupil.xx, pupil.yy);
pupil.A = pupil.rr < pupil.D/2;

% The following four lines define the Noise parameters: which zernikes are
% present, as well as their relative strengths and power law coefficients.
% These can be the same or different for each Zernike

noise.rms = 1/100;      % arbitrary units (the values in the noise cube will have the same units)
noise.Noll_modes = 1:8;     % 1 = piston, 2,3 tip/tilt, 4 = defocus, 5, 6 = astigmatism, 7,8 = coma
noise.amplitudes = noise.rms / sqrt(length(noise.Noll_modes)) * ones(size (noise.Noll_modes)); % relative strengths of each mode
noise.alphas     = 3 * ones(size(noise.Noll_modes));     % power laws of each mode (f^-alpha)

pupil.phase_error_vs_time = create_Zernike_noise(pupil, noise, pupil.Nt);



%% see the noise movie
noise_min = min(min(min(pupil.phase_error_vs_time)));
noise_max = max(max(max(pupil.phase_error_vs_time)));
for t = 1:pupil.Nt
    imagesc(pupil.x, pupil.y, pupil.phase_error_vs_time(:,:,t).*pupil.A, [noise_min/2 noise_max/2]); axis image; colorbar; pause(0.03);
end