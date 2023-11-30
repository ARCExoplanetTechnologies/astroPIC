function grid = make2Dgrid_arb(N,dx,dy,x0,y0); 

grid.N = N;
grid.dx = dx;
grid.dy = dy;
grid.x = ((1:N)-x0)*dx;
grid.y = ((1:N)-y0)*dy;

grid.r = grid.x(x0:end);

[grid.xx grid.yy] = meshgrid(grid.x,grid.y);
[grid.ttheta grid.rr]=cart2pol(grid.xx, grid.yy);

grid.Dgrid = 2*max(grid.r);