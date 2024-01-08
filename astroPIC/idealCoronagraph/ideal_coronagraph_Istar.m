function Iout = ideal_coronagraph_Istar(N2, ideal_coronagraph, pupil, sci, Dstar, method);
% Generate E_theta, the coronagraphic off-axis point source response
% N2: order of the coronagraph (must be even)
% ideal_coronagraph: run ideal_coronagraph_generate to generate this
% pupil and sci: entrance pupil and exit science planee grids; run make2Dgrid to generate this
% theta = [theta_x theta_y], the x and y values of the off-axis source, in
% lambda/d units
% normalization is assumed to be energy-normalized to 1 with respect to
% grid (not counts)
% Dstar is in units of l/D

switch method
    case 'BruteForce'
        % Brute force method
        sky = make2Dgrid(32, Dstar, 'vertex-cetnered');
        sky.Istar = sky.rr <= Dstar/2;
        sky.Istar = sky.Istar / sum(sum(sky.Istar.^2)); % normalized to unity energy
        
        figure(5)
        % imagesc(sky.x, sky.y, sky.star);

        sci.I = 0*sci.rr;
        for n = 1:sky.N
            n
            for m = 1:sky.N
                if sky.Istar(n,m) > 0
                
                    sci.E = ideal_coronagraph_Eoffaxis(N2, ideal_coronagraph, pupil, sci, [sky.x(n) sky.y(m)], 'Energy');
                    sci.I = sci.I + sky.Istar(n,m) * abs(sci.E).^2;
                end
            end
        end

    case 'BruteForceRand'
        % Brute force method, randomly sampled star
       sci.I = 0*sci.rr;
       
       n_max = 1000;
       for n = 1:n_max
            sky.phi = 2*pi*rand; 
            sky.r = sqrt(rand)*(Dstar/2); 
            [sky.x sky.y] = pol2cart(sky.phi, sky.r);
            
            sci.E = ideal_coronagraph_Eoffaxis(N2, ideal_coronagraph, pupil, sci, [sky.x sky.y], 'Energy');
            sci.I = sci.I + abs(sci.E).^2/n_max;
       end

        
    case 'SmallStar'
        % efficient small star method
        U = ideal_coronagraph.U;
        sci.I = zeros(sci.N^2,1);
        N = N2/2 + 1;
        for m = 1:N
            k = N*(N-1)/2 + m;
            sci.I = sci.I + abs(ideal_coronagraph.U(:,k)).^2 / N; % note: the weighting here depends slightly on aperture       
        end
        N = N2/2;

        Dstar_eff = Dstar / pupil.Dc *pupil.Deff; % converts Dstar from lambda/Dc units to lambda/Deff units
        suppression = 1/(factorial(N)^2 * (N+1)) * (pi * Dstar_eff / 4 )^(2*N); % theoretical value, valid for circular apertures of radius Deff

        sci.I = suppression * reshape(sci.I, sci.N, sci.N);
        sci.I = sci.I / sci.dx / sci.dy;

    case 'LargeStar'
        % efficient large star regime method
        U = ideal_coronagraph.U;
        sci.Istar_sky = sci.rr < Dstar/2 * sci.flD;
        sci.Istar_sky = sci.Istar_sky / (trapz(trapz(sci.Istar_sky))*sci.dx*sci.dy);
        sci.I_PSF = reshape(abs(U(:,1)).^2, sci.N, sci.N)/sci.dx/sci.dy;
        sci.Istar_telescope = conv_fft2(sci.Istar_sky, sci.I_PSF, 'wrap')*sci.dx*sci.dy; % use 'same' for full convolution, 'wrap' for faster version that uses circular convolution (possible wrapping errors on the edge of field)
        if N2 > 0
            sci.I = sci.Istar_telescope.*reshape(ideal_coronagraph.Tc(:,N2/2), sci.N, sci.N);
        else
            sci.I = sci.Istar_telescope;
        end
end

Iout = sci.I;

