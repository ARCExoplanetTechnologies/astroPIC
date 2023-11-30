pupil = pupil_generate('LUVOIR_A_1024.fits', 16, 'circumscribed', 'vertex-centered');

figure(5); 
imagesc(pupil.x, pupil.y, pupil.A); axis image; grid on; hold on;

theta = 0:0.001:(2*pi);
[x y] = pol2cart(theta, pupil.Dc*ones(size(theta))/2); plot(x,y, 'r');
[x y] = pol2cart(theta, pupil.Deff*ones(size(theta))/2); plot(x,y, 'g');
[x y] = pol2cart(theta, pupil.D*ones(size(theta))/2); plot(x,y, 'k');
legend('Circuscribed', 'Effective', 'Nominal');

hold off;