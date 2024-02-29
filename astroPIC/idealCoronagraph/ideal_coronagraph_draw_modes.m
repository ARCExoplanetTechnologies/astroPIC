function ideal_coronagraph_draw_modes(ideal_coronagraph, pupil_figure_number, image_figure_number);

V = ideal_coronagraph.V;
U = ideal_coronagraph.U;

[N_max m] = Noll(size(V,2));
N_pupil = sqrt(size(V,1));
N_sci = sqrt(size(U,1));
N_max = N_max + 1;

figure(pupil_figure_number)
for k1 = 1:size(V,2)
    [n m] = Noll(k1);
    subplot_row = ceil((-1+sqrt(1+8*k1))/2); subplot_column = k1 - (subplot_row-1)*subplot_row/2;
    subplot(N_max,N_max, (subplot_row-1)*N_max + subplot_column);
    v = reshape(V(:,k1), N_pupil, N_pupil);
    imagesc(real(1i^(m>0)*v)); axis image; axis off;    
end

figure(image_figure_number)
for k1 = 1:size(U,2)
    [n m] = Noll(k1);
    subplot_row = ceil((-1+sqrt(1+8*k1))/2); subplot_column = k1 - (subplot_row-1)*subplot_row/2;
    subplot(N_max,N_max, (subplot_row-1)*N_max + subplot_column);
    u = reshape(U(:,k1), N_sci, N_sci);
    imagesc(real(1i^(m>0)*u)); axis image; axis off;    
end

% pupil = ideal_coronagraph.pupil;
% image = ideal_coronagraph.image;
% 
% [N_max m] = Noll(size(pupil.v,3));
% N_max = N_max + 1;
% 
% figure(pupil_figure_number)
% for k1 = 1:size(pupil.v,3)
%     [n m] = Noll(k1);
%     subplot_row = ceil((-1+sqrt(1+8*k1))/2); subplot_column = k1 - (subplot_row-1)*subplot_row/2;
%     subplot(N_max,N_max, (subplot_row-1)*N_max + subplot_column);
%     imagesc(pupil.x, pupil.y, real(1i^(m>0)*pupil.v(:,:,k1))); axis image; axis off;    
% end
% 
% figure(image_figure_number)
% for k1 = 1:size(image.u,3)
%     [n m] = Noll(k1);
%     subplot_row = ceil((-1+sqrt(1+8*k1))/2); subplot_column = k1 - (subplot_row-1)*subplot_row/2;
%     subplot(N_max,N_max, (subplot_row-1)*N_max + subplot_column);
%     imagesc(pupil.x, pupil.y, real(1i^(m>0)*image.u(:,:,k1))); axis image; axis off;    
% end