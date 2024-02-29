function ideal_coronagraph = ideal_coronagraph_Tc_all(ideal_coronagraph, sci);

Tc = ideal_coronagraph_Tc(ideal_coronagraph);

for n = 1:ideal_coronagraph.N_max
    Tc2D(:,:,n) = reshape(Tc(:,n), sqrt(ideal_coronagraph.N_dims_sci), sqrt(ideal_coronagraph.N_dims_sci));
    Tcx(:,n) = Tc2D(:,floor(end/2)+1, n);
    Tcy(:,n) = Tc2D(floor(end/2)+1,:, n);
    Tcr(:,n) = azimuthal_average(Tc2D(:,:,n), sci.rr, sci.r);
end

ideal_coronagraph.Tc = Tc;
ideal_coronagraph.Tc2D = Tc2D;
ideal_coronagraph.Tcx = Tcx;
ideal_coronagraph.Tcy = Tcy;
ideal_coronagraph.Tcr = Tcr;