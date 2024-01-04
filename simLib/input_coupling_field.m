%% computes matrix M for direct computation of input couplign \int Ea^* Eb dA / sqrt(|\int Ea dA|^2 + |\int Eb dA|^2) 
% assumes Ea and Eb are provided over the same grid

function Eout = input_coupling_field(Ein,M)

Eout = transpose(conj(Ein(:))/norm(Ein(:),2))*M;

