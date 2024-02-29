function out = radial_cross_section(im, rs_slice, theta_slice)

% im is a structure containing
% im.I = image
% im.x = 2D array representing x values
% im.y = 2D array representing y values
% rs_slice = 1D array of rs on which to compute the slice
% theta = (scalar) angle on which to compute the slice

thetas_slice = theta_slice * ones(size(rs_slice));
[xs_slice, ys_slice] = pol2cart(thetas_slice, rs_slice);

out = interp2(im.x, im.y, im.I, xs_slice, ys_slice);