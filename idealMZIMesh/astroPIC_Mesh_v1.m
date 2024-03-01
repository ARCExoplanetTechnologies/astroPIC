clear all;
close all;

profilerFlag = true;
if profilerFlag; profile on; end

% setup local library paths and load
libPath = 'astroPIC\simLib\';
propPath= 'astroPIC\propLib\';
utilPath = 'astroPIC\misc_utilities\';
zernPath= 'astroPIC\Zernike\';
idealCoroPath = 'astroPIC\idealCoronagraph\';
elementsPath = 'astroPIC\opticalElements\';
addpath(libPath);
addpath(utilPath);
addpath(propPath);
addpath(zernPath);
addpath(idealCoroPath);
addpath(elementsPath);



% Define pupil plane and telescope aperture
pupil = pupil_generate('pupil_offaxis_1024.fits', 1, 'circumscribed', 'vertex-centered'); % second argument is pupil diameter
pupil.tt = atan2(pupil.yy, pupil.xx);


PIC.inputCoupling.N = length(pupil.A); % number of samples across pupil
PIC.inputCoupling.Nlensx = 5;
PIC.inputCoupling.Nlensy = 5;
PIC.inputCoupling.sigma = 1; % Gaussian mode
PIC.inputCoupling.lensD = pupil.D/PIC.inputCoupling.Nlensx;
PIC.inputCoupling.lensShape = 'rectangular'; % choices are 'rectangular', 'circular', or 'none' (subaperture shape; with none there is overlap between Gaussian tails)
PIC.inputCoupling.efficiency = 0.98;
PIC.inputCoupling.inputCoupling = generate_overlapArr(pupil,PIC.inputCoupling); % generate lenslet array with Gaussian modes spanning each lenslet
PIC.inputCoupling.M = input_coupling_matrix(PIC.inputCoupling.inputCoupling); % compute coupling matrix M

%Compute the set of orthogonal modes
PIC.N = PIC.inputCoupling.Nlensx*PIC.inputCoupling.Nlensy; %Clean this up later
PIC.Basis_Modes = zeros(PIC.N);
PIC.Basis_Mode_Images = zeros([PIC.inputCoupling.N, PIC.inputCoupling.N, PIC.N]);
n = 0;
m = 0;
for j = 1:PIC.N

    fprintf('%i, %i.\n', n, m);

    Image = Zernike2D(n, m, 2*pupil.rr, pupil.tt).*pupil.A;
    Image = Image/sqrt(sum(sum(abs(Image).^2)));
    PIC.Basis_Mode_Images(:,:,j) = Image;
    PIC.Basis_Modes(:,j) = PIC.inputCoupling.M*reshape(Image.',[],1);

    if n == m
        n = n + 1;
        m = -n;
    else
        m = m + 2;
    end
end
%Reject modes with no power in the piston mode
Illuminated_Modes = find(abs(PIC.Basis_Modes(:,1)) > 1e1*eps);
PIC.Basis_Modes = PIC.Basis_Modes(Illuminated_Modes,:);

%Perform Gram-Schmidt over the vectors, and use the same weights over the
%images
Retained_Modes = [];
for j = 1:PIC.N
    Vector_j = PIC.Basis_Modes(:,j);
    Image_j = PIC.Basis_Mode_Images(:,:,j);
    for k = 1:j-1
        if any(Retained_Modes == k) == 0
            continue;
        end
        Vector_k = PIC.Basis_Modes(:,k);
        Image_k = PIC.Basis_Mode_Images(:,:,k);

        Coeff = sum(conj(Vector_k).*Vector_j);
        Vector_j = Vector_j - Coeff*Vector_k;
        Image_j = Image_j - Coeff*Image_k;
    end
    Norm = sqrt(sum(abs(Vector_j).^2));
    fprintf('Norm %i = %e.\n', j, Norm);
    PIC.Basis_Modes(:,j) = Vector_j/Norm;
    PIC.Basis_Mode_Images(:,:,j) = Image_j/Norm;
    if Norm > 1e-1
        Retained_Modes = [Retained_Modes, j];
    end
end
PIC.N = length(Retained_Modes);
PIC.Basis_Modes = PIC.Basis_Modes(:,Retained_Modes);
PIC.Basis_Mode_Image = PIC.Basis_Mode_Images(:,Retained_Modes);

% Demonstrate orthogonal modes
for j = 1:PIC.N
    for k = 1:PIC.N
        if j == k
            continue
        end
        inner = sum(conj(PIC.Basis_Modes(:,j)).*PIC.Basis_Modes(:,k));
        if abs(inner) > 1e-115
            fprintf('Abs Inner Product of %i and %i = %e.\n', j, k, abs(inner));
        end
    end
end

[PIC.theta_av, PIC.dtheta] = Compute_Ideal_Input_Coupler(PIC, 1e1*sqrt(eps));

% Demonstrate correct mode sorting
Sorted_Modes = zeros(PIC.N);
for j = 1:PIC.N
    [Output, ~, ~, ~, ~] = Propagate_Ideal_Mesh(PIC, PIC.Basis_Modes(:,j));
    Sorted_Modes(:,j) = Output;
end

figure(1);
subplot(1,2,1), imagesc(real(PIC.Basis_Modes));
colorbar();
axis square;
title('Real Basis Vectors');
subplot(1,2,2), imagesc(imag(PIC.Basis_Modes));
colorbar();
axis square;
title('Imag Basis Vectors');

figure(2);
subplot(1,2,1), imagesc(real(Sorted_Modes));
colorbar();
axis square;
title('Real Sorted Modes');
subplot(1,2,2), imagesc(imag(Sorted_Modes));
colorbar();
axis square;
title('Imag Sorted Modes');