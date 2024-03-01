PIC.Sidelength = 10; 
if mod(PIC.Sidelength, 2) > 0
    PIC.Sidelength = PIC.Sidelength + 1;
end

PIC.N = PIC.Sidelength^2;
[PIC.Basis_Mode_Images, PIC.Basis_Modes] = Test_Pupil_Complex_Basis(PIC.Sidelength);
[PIC.theta_av, PIC.dtheta] = Compute_Ideal_Input_Coupler(PIC, 1e1*sqrt(eps));

% Demonstrate orthogonal modes
for j = 1:PIC.N
    for k = 1:PIC.N
        if j == k
            continue
        end
        inner = sum(conj(PIC.Basis_Modes(:,j)).*PIC.Basis_Modes(:,k));
        if abs(inner) > 1e-15
            fprintf('Abs Inner Product of %i and %i = %e.\n', j, k, abs(inner));
        end
    end
end

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