%pupil = pupil_generate('\\exoplanetshare\LabData\FundedProjects\PIAACMC_TDEM\LUVOIR_reference_files\2018-10-10-LUVOIR_B_4096\LUVOIR-B_4096.fits', 4096*2.11e-3, 'full-grid', 'vertex-centered');

figure(5); 
imagesc(pupil.x, pupil.y, pupil.A); axis image; grid on; hold on;

pupil.Di = 6.718;
theta = 0:0.001:(2*pi);
[x y] = pol2cart(theta, pupil.Dc*ones(size(theta))/2); plot(x,y, 'r');
[x y] = pol2cart(theta, pupil.Deff*ones(size(theta))/2); plot(x,y, 'g');
[x y] = pol2cart(theta, pupil.Di*ones(size(theta))/2); plot(x,y, 'k');
legend(sprintf('D_{circumscribed} = %0.3fm',pupil.Dc), sprintf('D_{effective} = %0.3fm',pupil.Deff), sprintf('D_{inscribed} = %0.3fm',pupil.Di));

hold off;