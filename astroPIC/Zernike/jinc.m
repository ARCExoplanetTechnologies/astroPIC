% kth order jinc function
function out = jinc(k,theta);

out = 2*(k+1)*besselj((k+1),pi*theta)./(pi*theta);

out(isnan(out)) = k == 0;