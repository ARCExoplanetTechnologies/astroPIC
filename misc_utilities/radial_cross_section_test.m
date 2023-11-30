clear all;

im.x = -1:0.001:1;
im.y = im.x;
[im.xx im.yy] = meshgrid(im.x,im.y);
[im.tth im.rr] = cart2pol(im.xx, im.yy);

im.I = double(im.rr < (im.tth + pi) / (2*pi));

rs_slice = 0:0.001:1;
theta_slice = 2*pi*0.1;
thetas_slice = theta_slice * ones(size(rs_slice));
[xs_slice ys_slice] = pol2cart(thetas_slice, rs_slice);


figure(1); 
imagesc(im.x, im.y, im.I); axis image; colorbar; hold on;
plot(xs_slice, ys_slice, 'r');
hold off;

figure(2)

slice = radial_cross_section(im, rs_slice, theta_slice);

plot(rs_slice, slice);