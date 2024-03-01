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
PIC.inputCoupling.Nlensx = 10;
PIC.inputCoupling.Nlensy = 10;
PIC.inputCoupling.sigma = 1; % Gaussian mode
PIC.inputCoupling.lensD = pupil.D/PIC.inputCoupling.Nlensx;
PIC.inputCoupling.lensShape = 'rectangular'; % choices are 'rectangular', 'circular', or 'none' (subaperture shape; with none there is overlap between Gaussian tails)
PIC.inputCoupling.efficiency = 0.98;
PIC.inputCoupling.inputCoupling = generate_overlapArr(pupil,PIC.inputCoupling); % generate lenslet array with Gaussian modes spanning each lenslet
PIC.inputCoupling.M = input_coupling_matrix(PIC.inputCoupling.inputCoupling); % compute coupling matrix M


%Compute the dimensionality of the pupil plane and find a pseudo-Zernike
%set that spans this space.
n = 0;
m = 0;
Image = pupil.A;
Image = Image/sqrt(sum(sum(abs(Image).^2)));
Vector = PIC.inputCoupling.M*reshape(Image.',[],1);

Illuminated_Modes = find(abs(Vector) > 1e1*eps);
Vector = Vector(Illuminated_Modes);

PIC.N = length(Illuminated_Modes);
PIC.Basis_Modes = zeros(PIC.N);
PIC.Basis_Mode_Images = zeros([PIC.inputCoupling.N, PIC.inputCoupling.N, PIC.N]);

Norm = sqrt(sum(abs(Vector).^2));
PIC.Basis_Modes(:,1) = Vector/Norm;
PIC.Basis_Mode_Images(:,:,1) = Image/Norm;

N_Modes = 1;
Counter = 1;
while N_Modes < PIC.N
    if n == m
        n = n + 1;
        m = -n;
    else
        m = m + 2;
    end

    Image = Zernike2D(n, m, 2*pupil.rr, pupil.tt).*pupil.A;
    Image = Image/sqrt(sum(sum(abs(Image).^2)));
    Vector = PIC.inputCoupling.M*reshape(Image.',[],1);
    Vector = Vector(Illuminated_Modes);
    for j = 1:N_Modes
        Vector_j = PIC.Basis_Modes(:,j);
        Image_j = PIC.Basis_Mode_Images(:,:,j);

        Coeff = sum(conj(Vector_j).*Vector);
        Vector = Vector - Coeff*Vector_j;
        Image = Image - Coeff*Image_j;
    end
    Norm = sqrt(sum(abs(Vector).^2));
    fprintf('Norm for modified Zernike mode %i, %i = %e.\n', n, m, Norm);
    if Norm > 1e-2
        N_Modes = N_Modes + 1;
        PIC.Basis_Modes(:,N_Modes) = Vector/Norm;
        PIC.Basis_Mode_Images(:,:,N_Modes) = Image/Norm;
    end

    Counter = Counter + 1;
    if Counter > 1e2
        print('Failed to compute basis set!');
        break;
    end
end

% Demonstrate orthogonal modes
for j = 1:PIC.N
    for k = j+1:PIC.N
        inner = sum(conj(PIC.Basis_Modes(:,j)).*PIC.Basis_Modes(:,k));
        if abs(inner) > 1e-10
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

% Throughput curves
offset_array = 0 : 1e-2 : 6; %\lambda/D
thpt_order2 = zeros(size(offset_array));
thpt_order4 = zeros(size(offset_array));
thpt_order6 = zeros(size(offset_array));
piston = zeros(size(offset_array));

for j = 1:length(offset_array)
    offset = offset_array(j);
    E_Field = pupil.A.*exp(2*pi*1i*(pupil.xx * offset)/pupil.D)/pupil.Area; % contrast units
    Energy = sum(sum(abs(E_Field).^2));

    Coupled_Vector = PIC.inputCoupling.M*reshape(E_Field.',[],1);
    Coupled_Vector = Coupled_Vector(Illuminated_Modes);

    [Output, ~, ~, ~, ~] = Propagate_Ideal_Mesh(PIC, Coupled_Vector);

    piston_term = abs(Output(1)).^2/Energy;
    order2_term = sum(abs(Output(2:end)).^2)/Energy;
    order4_term = sum(abs(Output(4:end)).^2)/Energy;
    order6_term = sum(abs(Output(7:end)).^2)/Energy;

    if mod(offset, 0.1) == 0
        fprintf('offset = %e l/D.\n', offset);
        fprintf('piston = %e. 2nd = %e. 4th = %e. 6th = %e.\n', piston_term, order2_term, order4_term, order6_term);
    end

    piston(j) = piston_term;
    thpt_order2(j) = order2_term;
    thpt_order4(j) = order4_term;
    thpt_order6(j) = order6_term;
end

small_oa = 1e-4 : 1e-3 : 1e-1;
contrast_order2 = zeros(size(small_oa));
contrast_order4 = zeros(size(small_oa));
contrast_order6 = zeros(size(small_oa));
for j = 1:length(small_oa)
    offset = small_oa(j);
    E_Field = pupil.A.*exp(2*pi*1i*(pupil.xx * offset)/pupil.D)/pupil.Area; % contrast units
    Energy = sum(sum(abs(E_Field).^2));

    Coupled_Vector = PIC.inputCoupling.M*reshape(E_Field.',[],1);
    Coupled_Vector = Coupled_Vector(Illuminated_Modes);

    [Output, ~, ~, ~, ~] = Propagate_Ideal_Mesh(PIC, Coupled_Vector);

    order2_term = mean(abs(Output(2:end)).^2)/(Energy*piston(1));
    order4_term = mean(abs(Output(4:end)).^2)/(Energy*piston(1));
    order6_term = mean(abs(Output(7:end)).^2)/(Energy*piston(1));

    if mod(j-1, 10) == 0
        fprintf('offset = %e l/D.\n', offset);
        fprintf('Contrast 2nd = %e. 4th = %e. 6th = %e.\n', order2_term, order4_term, order6_term);
    end

    contrast_order2(j) = order2_term;
    contrast_order4(j) = order4_term;
    contrast_order6(j) = order6_term;
end

figure();
plot(offset_array, piston, offset_array, thpt_order2, offset_array, thpt_order4, offset_array, thpt_order6);
figure();
loglog(small_oa, contrast_order2, small_oa, contrast_order4, small_oa, contrast_order6);