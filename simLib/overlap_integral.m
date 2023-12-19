%% uses trapz assuming E_a and E_b are over the same grid

function overlap_output = overlap_integral(E_a,E_b,pupil)

A = E_a .* E_b;
B = (trapz(pupil.x,trapz(pupil.y, A, 1)) )^2;
C = trapz(pupil.x,trapz(pupil.y, abs(E_a).^2, 1)) * trapz(pupil.x,trapz(pupil.y, abs(E_b).^2, 1 ));
overlap_output = B./C;

% function overlap_output = overlap_integral(E_a,E_b)
% 
% overlap_output = (trapz(trapz(E_a.*E_b))).^2 ./ ...
%         (trapz(trapz(abs(E_a).^2))*trapz(trapz(abs(E_b).^2)))
