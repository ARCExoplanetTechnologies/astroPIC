function Eout = ideal_coronagraph_Eoffaxis(N2, ideal_coronagraph, pupil, sci, theta, normalization);
% Generate E_theta, the coronagraphic off-axis point source response
% N2: order of the coronagraph (must be even)
% ideal_coronagraph: run ideal_coronagraph_generate to generate this
% pupil and sci: entrance pupil and exit science planee grids; run make2Dgrid to generate this
% theta = [theta_x theta_y], the x and y values of the off-axis source, in
% lambda/d units
% Normalization: Default is contrast units. For energy-normalised E_theta, use 'Energy'

if strcmp(normalization, 'Energy')
    pupil.E = pupil.A.*exp(2*pi*1i*(pupil.xx * theta(1) + pupil.yy * theta(2))/pupil.D)/sqrt(pupil.Area); % energy normalized
else
    pupil.E = pupil.A.*exp(2*pi*1i*(pupil.xx * theta(1) + pupil.yy * theta(2))/pupil.D)/pupil.Area; % contrast units
end
    
Eout = ideal_coronagraph_propagate(N2, ideal_coronagraph, pupil, sci);

