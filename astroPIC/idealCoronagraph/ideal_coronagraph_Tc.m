function Tc = ideal_coronagraph_Tc(ideal_coronagraph);

U = ideal_coronagraph.U;

Tc(:,1) = abs(U(:,1)).^2;
for n = 2:ideal_coronagraph.N_max
    Tc(:,n) = Tc(:,n-1);
    for m = 1:n
        k = n*(n-1)/2 + m;
        Tc(:,n) = Tc(:,n) + abs(U(:,k)).^2;        
    end
end

for n = 1:ideal_coronagraph.N_max
    Tc(:,n) = 1 - Tc(:,n)/max(Tc(:,n));
end