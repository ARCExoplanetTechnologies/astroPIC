function noisecube = create_Zernike_noise(pupil, noise, nsamps);

addpath('\\exoplanetshare\LabData\Software\Rus_libraries\oneoverf');

% time series 1/f noise # of samples
oversamp = 1;

%initializing noise cube
noisecube = zeros(pupil.N, pupil.N, nsamps);

for i = 1:length(noise.Noll_modes)
    [n m] = Noll(noise.Noll_modes(i));
    i
    
    % compute Zernike mode, normalized such that Z(1) = 1;
    Z_xy = Zernike2D(n, m, pupil.rr/pupil.D*2, pupil.ttheta);
    
    % create random time variation of that mode
    A = noise.amplitudes(i)*oneoverf_noise(nsamps, oversamp, noise.alphas(i));
    
    for t = 1:nsamps
        noisecube(:,:,t) = noisecube(:,:,t) + A(t)*Z_xy;
    end
  
end

hold off;
xlabel('time (minutes)');
ylabel('Zernike coefficient (nm rms)')
legend('defocus', 'asigmatism x', 'astigmatism y', 'coma x', 'coma y');

% %% see the noise movie
% noise_min = min(min(min(noisecube)));
% noise_max = max(max(max(noisecube)));
% for t = 1:nsamps
%     imagesc(pupil.x, pupil.y, noisecube(:,:,t).*pupil.A, [noise_min/2 noise_max/2]); axis image; colorbar; pause(0.1);
% end

% % write to file sequence
% for t = 1:nsamps
%     filename = sprintf('noise_image%05d.fits', t);
%     fits_write(sprintf('noise_image%05d.fits', t), noisecube(:,:,t));
% end