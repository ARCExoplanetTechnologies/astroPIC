function [system] = setup(config)

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



% Define pupil plane and telescope aperture
pupil = pupil_generate('pupil_offaxis_1024.fits', 1, 'circumscribed', 'vertex-centered'); % second argument is pupil diameter

% Define input coupling
params.N2 = 6; %order of the optimal coronagraph
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
ideal_coronagraph = ideal_coronagraph_subaperture_generate(params.N2, pupil, inputCoupling, sci);
ideal_coronagraph_draw_modes(ideal_coronagraph, 3, 4); % second and third arguments are figure numbers

system.params = params;
system.pupil = pupil;
system.inputCoupling = inputCoupling;
system.ideal_coronagraph = ideal_coronagraph;

end


