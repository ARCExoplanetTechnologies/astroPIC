function ideal_coronagraph_Tc_display(ideal_coronagraph, sci, fig2D_index, fig1D_index, A_index);

% for n = 1:ideal_coronagraph.N_max
%     Tc(:,:,n) = reshape(ideal_coronagraph.Tc(:,n), sqrt(ideal_coronagraph.N_dims_sci), sqrt(ideal_coronagraph.N_dims_sci));
% end

colors = {'b', 'g', 'r', 'c', 'k'; 
          'b:', 'g:', 'r:', 'c:', 'k:'
          'b--', 'g--', 'r--', 'c--', 'k--'};

figure(fig2D_index);
for n = 1:ideal_coronagraph.N_max
    subplot(1,ideal_coronagraph.N_max,n)
    imagesc(sci.x/sci.flD,sci.y/sci.flD, ideal_coronagraph.Tc2D(:,:,n)); axis image; grid on; hold on;
    xlabel('\theta (\lambda/D)'); title(sprintf('order = %d', 2*n));
end
hold off;

figure(fig1D_index);
for n = 1:ideal_coronagraph.N_max
    subplot(1,3,2);
%     Tx(:,n) = Tc(:,floor(end/2)+1, n);
%     Ty(:,n) = Tc(floor(end/2)+1,:, n);
%     Tr(:,n) = azimuthal_average(Tc(:,:,n), sci.rr, sci.r);
    plot(sci.r/sci.flD, ideal_coronagraph.Tcr(:, n), colors{A_index,n}); hold on;
end

xlim([0 sci.Dgrid/2]); grid on;
xlabel('amount of off-axis tip (\lambda/D)');
ylabel('Total coronagraphic throughput (or leak)');
legend('2nd order', '4th order', '6th order', '8th order', '10th order');

subplot(1,3,3);
for n = 1:ideal_coronagraph.N_max
    %loglog(sci.x, sci.Tx(:,N), colors{2,N}); hold on;
    %loglog(sci.y, sci.Ty(:,N), colors{3,N}); hold on;
    loglog(sci.r/sci.flD, ideal_coronagraph.Tcr(:,n), colors{A_index,n}); hold on;
end

xlim([0.01 sci.Dgrid/2]); 
ylim([1e-10 1]);
grid on;
xlabel('amount of off-axis tip (lambda/D)'); 