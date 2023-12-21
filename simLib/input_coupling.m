%% computes \int Ea^* Eb dA / sqrt(|\int Ea dA|^2 + |\int Eb dA|^2) 

function inputCoupling_out = input_coupling(E_a,E_b,pupil)

overlap_EaEb = overlap_integral(E_a,E_b, pupil);
overlap_EaEa = overlap_integral(abs(E_a),abs(E_a), pupil);
overlap_EbEb = overlap_integral(abs(E_b),abs(E_b), pupil);

%modematch_out = abs(overlap_EaEb).^2 / (overlap_EaEa*overlap_EbEb);
inputCoupling_out = overlap_EaEb / sqrt(overlap_EaEa*overlap_EbEb);

% below is mode matching 
% function modematch_out = input_coupling(E_a,E_b) 
% modematch_out = (trapz(trapz(conj(E_a).*E_b))).^2 ./ ...
%         (trapz(trapz(abs(E_a).^2))*trapz(trapz(abs(E_b).^2)))
