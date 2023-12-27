% Generates an optimal coronagraph, computes an off-axis response
% and uses Gaussian mode sampling for input coupling
% modification of example_3 in ideal_coronagraph library

clear all;

profilerFlag = true;
if profilerFlag; profile on; end

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
params.inputCoupling.Nlensx = 5;
params.inputCoupling.Nlensy = 5;
params.inputCoupling.sigma = 1; % Gaussian mode
params.inputCoupling.lensD = pupil.D/params.inputCoupling.Nlensx;
params.inputCoupling.lensShape = 'rectangular'; % choices are 'rectangular', 'circular', or 'none' (subaperture shape; with none there is overlap between Gaussian tails)
params.inputCoupling.efficiency = 0.98;
inputCoupling = generate_overlapArr(pupil,params.inputCoupling);

% combine input coupling and pupil
pupil.Aorig = pupil.A;
pupil.A = inputCoupling.A.*pupil.A;
inputCoupling.throughput = sum(sum(pupil.A))/sum(sum(pupil.Aorig));

figure(); imagesc(inputCoupling.A); axis image; 
title({'Input Coupler: Apodization'},{['Throughput: ', num2str(inputCoupling.throughput,'%.2f')]})

figure(); imagesc(pupil.A); axis image; 
title('Coupled Pupil')

% define science plane
sci = make2Dgrid(512, 8, 'vertex-centred');
sci.f = 1;
sci.lambda = 1;
sci.flD = sci.f*sci.lambda/pupil.D;

disp('Generating coronagraph...'); 
ideal_coronagraph = ideal_coronagraph_subaperture_generate(N2, pupil, inputCoupling, sci);
ideal_coronagraph_draw_modes(ideal_coronagraph, 3, 4); % second and third arguments are figure numbers

%% Compute off-axis PSF
theta_sky = [0.5 0.5]; % angle of off-axis point source

% create tip/tilt
pupil.E = pupil.A.*exp(2*pi*1i*(pupil.xx * theta_sky(1) + pupil.yy * theta_sky(2))/pupil.D)/pupil.Area; % contrast units

[a b] = size(inputCoupling.array);
lensInd = 1;
for ia = 1:a
    for ib = 1:b
        Eb = inputCoupling.array{ib,ia};
        inputCoupling.E(ib,ia) = input_coupling(pupil.E,Eb,pupil);
        inputCoupling.M(lensInd,:) = Eb(:)./norm(Eb(:),2);
        lensInd = lensInd + 1;
    end
end

inputCoupling.M = transpose(inputCoupling.M);

Ecoupled = transpose(conj(pupil.E(:))/norm(pupil.E(:),2))*inputCoupling.M;
Ecoupled2D = reshape(Ecoupled,[5,5]); % back to 2D

%figure(); imagesc(abs(inputCoupling.E)); axis image; title('Original')
%figure(); imagesc(abs(E2pup)); axis image; title('E2pup')
figure(); imagesc(abs(inputCoupling.E - Ecoupled2D)); title('Direct overlap integral vs. Matrix-based coupling'); colorbar;

%inputCoupling.E = inputCoupling.A.*exp(2*pi*1i*(pupil.xx * theta_sky(1) + pupil.yy * theta_sky(2))/pupil.D)/pupil.Area
    
Elyot = ideal_coronagraph_pupil_to_lyot(N2, ideal_coronagraph, inputCoupling);
Elyot_full = reshape(transpose(Elyot(:))*transpose(conj(inputCoupling.M)),[1024,1024]);
sci.E = 1i*zoomFFT_realunits(pupil.x, pupil.y, Elyot, sci.x, sci.y, sci.f, sci.lambda);

figure(7)
imagesc(sci.x, sci.y, abs(sci.E).^2); 
xlabel('\theta_{sci}'); ylabel('\theta_{sci}'); axis image; colorbar;
title(sprintf('Off-axis PSF for \\theta_{sky}=(%0.1f,%0.1f)', theta_sky(1), theta_sky(2))); 

disp('Computing Tc / flat field...');                   
ideal_coronagraph.Tc = ideal_coronagraph_Tc(ideal_coronagraph); 
ideal_coronagraph_Tc_display(ideal_coronagraph, sci, 5, 6, 1); 


%% create tip/tilt test profile
Narr = 21;
tiltArr = linspace(0,0,Narr)
tipArr = logspace(-4,log10(2.5),Narr)

for iArr = 1:Narr
    thisTilt = tiltArr(iArr);
    thisTip = tipArr(iArr);

    pupil.E = pupil.A.*exp(2*pi*1i*(pupil.xx * thisTilt + pupil.yy * thisTip)/pupil.D)/pupil.Area; % contrast units

    for ia = 1:a
        for ib = 1:b
            inputCoupling.E(ia,ib) = input_coupling(pupil.E,inputCoupling.array{ia,ib},pupil);
        end
    end

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
