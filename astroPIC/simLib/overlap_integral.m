%% uses trapz assuming E_a and E_b are over the same grid

function overlap_out = overlap_integral(E_a,E_b,pupil)

dx = pupil.x(2) - pupil.x(1);
dy = pupil.y(2) - pupil.y(1);

E_a_conj = conj(E_a);
E_prod = E_a_conj .* E_b;

overlap_out = trapz(trapz(E_prod,2)*dx,1)*dy;


