%% computes \int Ea^* Eb dA / sqrt(|\int Ea dA|^2 + |\int Eb dA|^2) 
% assumes Ea and Eb are provided over the same grid

function inputCoupling_out = input_coupling(Ea,Eb,pupil)

overlap_EaEb = sum(conj(Ea).*Eb,'all');
overlap_EaEa = sum(abs(Ea).*abs(Ea),'all');
overlap_EbEb = sum(abs(Eb).*abs(Eb),'all');

inputCoupling_out = overlap_EaEb / sqrt(overlap_EaEa*overlap_EbEb);

