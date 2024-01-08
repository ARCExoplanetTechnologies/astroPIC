function ideal_coronagraph = ideal_coronagraph_generate(N2_max, pupil, sci);

% N2_max: order of the coronagraph (2nd, 4th, etc.)
% N: number of samples in the pupil plane
% pupil: contains the pupil grid and aperture

N_modes = N2_max*(N2_max/2+1)/4;

for k = 1:N_modes
    [n m] = Noll(k);
    
    % initial polynomial Zernike basis, not necessarily orthonormal
    v = 1/(pupil.D/2) * pupil.A.*Zernike2D_complex_norm(n,m, pupil.rr/(pupil.D/2), pupil.ttheta); % normalized Zernike mode, times the aperture
    v1D = v(:); %reshape(v, prod(size(v)),1);
    
    % Orthogonalize
    if k > 1
        v1D = v1D - V*(V'*v1D);
    end
    
    % Normalize, append to V matrix
    V(:,k) = v1D/norm(v1D);

    % Create linearization factors
    % C(k) = (pi*1i)^n / factorial(n) * V(:,k)' * ( V(:,1).* (pupil.rr(:)/pupil.D/2).^n);
end

% create sci plane modes
for k = 1:N_modes
    [n m] = Noll(k);
    v = reshape(V(:,k), size(v))/sqrt(pupil.dx*pupil.dy);
    u = 1i*zoomFFT_realunits(pupil.x, pupil.y, v, sci.x, sci.y, sci.f, sci.lambda);
    U(:,k) = reshape(u, prod(size(u)), 1)*sqrt(sci.dx*sci.dy);
end

ideal_coronagraph.V = V;
ideal_coronagraph.U = U;
ideal_coronagraph.N_modes = N_modes;
ideal_coronagraph.N_max = N2_max/2;
ideal_coronagraph.N_dims_pupil = prod(size(v));
ideal_coronagraph.N_dims_sci = prod(size(u));
% ideal_coronagraph.C = C;

ideal_coronagraph = ideal_coronagraph_Tc_all(ideal_coronagraph, sci);