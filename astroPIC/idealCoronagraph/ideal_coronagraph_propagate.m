function Eout = ideal_coronagraph_propagate(N2, ideal_coronagraph, pupil, sci);

N_modes = N2*(N2/2+1)/4;
V = ideal_coronagraph.V(:,1:N_modes); 
N_dims_pupil = ideal_coronagraph.N_dims_pupil;
N_pupil = sqrt(N_dims_pupil);

E1D = reshape(pupil.E, N_dims_pupil, 1); 

E1D = E1D - V*(V'*E1D); 

E2D = reshape(E1D, N_pupil, N_pupil);

Eout = 1i*zoomFFT_realunits(pupil.x, pupil.y, E2D, sci.x, sci.y, sci.f, sci.lambda); % Note: multiplying by i to make this into an actual FT rather than Fraunhofer, for certain mathematical conveniences. In effect, the optimal coronagraph has an extra pi/2 phase delay compared to pure Fraunhofer