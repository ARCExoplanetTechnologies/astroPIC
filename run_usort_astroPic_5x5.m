% Generates an optimal coronagraph, computes an off-axis response
% and uses Gaussian mode sampling for input coupling
% modification of example_3 in ideal_coronagraph library

clear all;
close all;

profilerFlag = true;
if profilerFlag; profile on; end

% setup local library paths and load
libPath = 'simLib\';
propPath= 'propLib\';
utilPath = 'misc_utilities\';
zernPath= 'Zernike\';
idealCoroPath = 'idealCoronagraph\'
elementsPath = 'opticalElements\'
addpath(libPath);
addpath(utilPath);
addpath(propPath);
addpath(zernPath);
addpath(idealCoroPath);
addpath(elementsPath);


N2 = 6; %order of the optimal coronagraph

% Define pupil plane and telescope aperture
pupil = pupil_generate('pupil_offaxis_1024.fits', 1, 'circumscribed', 'vertex-centered'); % second argument is pupil diameter

% Define input coupling
params.inputCoupling.N = length(pupil.A); % number of samples across pupil
params.inputCoupling.Nlensx = 5;
params.inputCoupling.Nlensy = 5;
params.inputCoupling.sigma = 1; % Gaussian mode
params.inputCoupling.lensD = pupil.D/params.inputCoupling.Nlensx;
params.inputCoupling.lensShape = 'rectangular'; % choices are 'rectangular', 'circular', or 'none' (subaperture shape; with none there is overlap between Gaussian tails)
params.inputCoupling.efficiency = 0.98;
inputCoupling = generate_overlapArr(pupil,params.inputCoupling); % generate lenslet array with Gaussian modes spanning each lenslet
inputCoupling.M = input_coupling_matrix(inputCoupling,pupil); % compute coupling matrix M

% combine input coupling and pupil
pupil.Aorig = pupil.A;
pupil.A = inputCoupling.A.*pupil.A;
inputCoupling.throughput = sum(sum(pupil.A))/sum(sum(pupil.Aorig));

figure(); imagesc(inputCoupling.A); axis image; 
title({'Input Coupler: Apodization'})

figure(); imagesc(pupil.A); axis image; 
title({'Coupled Pupil'}, {['Throughput: ', num2str(inputCoupling.throughput,'%.2f')]})

% define science plane
sci = make2Dgrid(512, 8, 'vertex-centred');
sci.f = 1;
sci.lambda = 1;
sci.flD = sci.f*sci.lambda/pupil.D;

disp('Generating coronagraph...'); 
ideal_coronagraph = ideal_coronagraph_subaperture_generate(N2, pupil, inputCoupling, sci);
ideal_coronagraph_draw_modes(ideal_coronagraph, 3, 4); % second and third arguments are figure numbers

%% Compute off-axis PSF
theta_sky = [0 0]; % angle of off-axis point source

% create tip/tilt
pupil.E = pupil.A.*exp(2*pi*1i*(pupil.xx * theta_sky(1) + pupil.yy * theta_sky(2))/pupil.D)/pupil.Area; % contrast units

Ecoupled = transpose(conj(pupil.E(:))/norm(pupil.E(:),2))*inputCoupling.M; %coupling to 5x5 using M
Ecoupled2D = reshape(Ecoupled,[params.inputCoupling.Nlensx,params.inputCoupling.Nlensy]); % conver to 2D
EinvCoupled = transpose(Ecoupled(:))*transpose(conj(inputCoupling.M)); % apply the adjoint operator
EinvCoupled2D = reshape(EinvCoupled,[params.inputCoupling.N,params.inputCoupling.N]); % convert to 2D

figure(); imagesc(abs(Ecoupled2D)); title('abs(Ecoupled), 5x5')
figure(); imagesc(abs(EinvCoupled2D)); title('abs(EinvCoupled), 1024x1024')

inputCoupling.E = Ecoupled2D;
Elyot = ideal_coronagraph_pupil_to_lyot(N2, ideal_coronagraph, inputCoupling);
Elyot_full = reshape(transpose(Elyot(:))*transpose(conj(inputCoupling.M)),[1024,1024]);
sci.E = 1i*zoomFFT_realunits(pupil.x, pupil.y, Elyot, sci.x, sci.y, sci.f, sci.lambda);

figure(7)
imagesc(sci.x, sci.y, abs(sci.E).^2); 
xlabel('\theta_{sci}'); ylabel('\theta_{sci}'); axis image; colorbar;
title(sprintf('Off-axis PSF for \\theta_{sky}=(%0.1f,%0.1f)', theta_sky(1), theta_sky(2))); 

%% create tip/tilt test array
Narr = 21;
tiltArr = linspace(0,0,Narr)
tipArr = logspace(-4,log10(2.5),Narr)

for iArr = 1:Narr
    thisTilt = tiltArr(iArr);
    thisTip = tipArr(iArr);

    pupil.E = pupil.A.*exp(2*pi*1i*(pupil.xx * thisTilt + pupil.yy * thisTip)/pupil.D)/pupil.Area; % contrast units

    inputCoupling.E = reshape(transpose(conj(pupil.E(:))/norm(pupil.E(:),2))*inputCoupling.M, [params.inputCoupling.Nlensx,params.inputCoupling.Nlensy]); %couple to lenslet array each tip/tilt

    Elyot = ideal_coronagraph_pupil_to_lyot(N2, ideal_coronagraph, inputCoupling);
    sci.E = 1i*zoomFFT_realunits(pupil.x, pupil.y, Elyot, sci.x, sci.y, sci.f, sci.lambda);

    IlyotArr(iArr) = sum(abs(Elyot).^2,'all');
    IsciArr(iArr) = sum(abs(sci.E).^2,'all');

    figure(10)
    imagesc(sci.x, sci.y, abs(sci.E).^2); 
    xlabel('\theta_{sci}'); ylabel('\theta_{sci}'); axis image; colorbar;
    title(sprintf('Off-axis PSF for \\theta_{sky}=(%0.1f,%0.1f)', thisTilt, thisTip)); 
    pause(0.1)
end


figure(11)
loglog(tipArr,IlyotArr./max(IlyotArr))
title('Energy in Lyot Plane as function of Tip')
xlabel('Sky L/D')
ylabel('Normalized with respect to peak off-axis energy')

figure(12)
loglog(tipArr,IsciArr./max(IsciArr))
xlabel('Sky L/D')
ylabel('Normalized with respect to peak off-axis energy')
title('Energy in Sci Plane as function of Tip')

if profilerFlag; profile viewer; end
