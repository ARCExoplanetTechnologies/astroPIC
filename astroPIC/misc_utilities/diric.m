% nth order diric function
function out = diric(n,phi);

out = sin((n+1)*phi)./((n+1)*sin(phi));

out(isnan(out)) = 1; % note -- this can occasionally be incorrect, sometimes the value is -1 -- need to fix later