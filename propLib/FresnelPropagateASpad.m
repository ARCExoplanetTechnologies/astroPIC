function out = FresnelPropagateASpad(Ein, lambda, a, z, padfactor);

% This function performs a Fresnel propagation by multiplication of the
% angular spectrum by the transfer function given in eq. 4-20 or 4-21 on p.
% 72 of Goodman

% This routine suffers gives a "better" answer than direct Fresnel integration for the case of insufficient samples. 
% ASF effectively gives a low-passed-filtered version of the true result for the case that there are insufficient samples. 

% Ein   :   input field, with the (1,1) element being on-axis. Use fftshift
%           if nesessary. Size of the array must be even, and helps if it's
%           a power of 2. In order to avoid circular-convolution effects,
%           make sure the field is zeropadded by a factor of 2.
% lambda:   wavelength
% a     :   radius of the aperture
% z     :   distance to be propagated
% padfactor: factor by which to pad pupil for Fresnel propagation. 
% out   :   propagated field, with the (1,1) element being on-axis. Use
%           fftshift if necessary. Sampling is the same as for Ein.

k = 2*pi/lambda;
N = length(Ein);
Npad = length(Ein)*padfactor;
Epad = zeropadimage(Ein,padfactor);
a = a*padfactor;
F = a^2/lambda/z; % Fresnel number

% Computation of the transfer function spectrum frequency squared f2 = fx^2 + fy^2
H = [-Npad/2:(Npad/2-1)]'*ones(1,Npad);    % frequency fx
H = H.^2 + H'.^2;                 % f2 = fx^2 + fy^2
H = fftshift(H);
% H = exp(i*k*z) * exp(-i * pi/4 * H/F );    % Goodman 4-21. Can also do 4-20 for more precision
H = exp(i*k*z * (sqrt( 1 - 1/4 * (lambda/a)^2 * H )-0)); % Goodman 4-20

outpad = ifft2( fft2(Epad) .* H);

out = outpad((1:N) + N/2*(padfactor-1), (1:N) + N/2*(padfactor-1));