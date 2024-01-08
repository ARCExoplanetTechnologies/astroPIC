function Eout = ideal_coronagraph_pupil_to_lyot(N2, ideal_coronagraph, pupil);

N_modes = N2*(N2/2+1)/4;
V = ideal_coronagraph.V(:,1:N_modes); 
N_dims_pupil = ideal_coronagraph.N_dims_pupil;
N_pupil = sqrt(N_dims_pupil);

E1D = reshape(pupil.E, N_dims_pupil, 1); 

tic; E1D = E1D - V*(V'*E1D);

Eout = reshape(E1D, N_pupil, N_pupil);