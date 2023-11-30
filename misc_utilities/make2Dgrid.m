function grid = make2Dgrid(N,Dgrid,centering); 

grid.N = N;
grid.Dgrid = Dgrid;
grid.dx = grid.Dgrid/grid.N;
grid.dy = grid.Dgrid/grid.N;
if mod(N,2) % i.e. if N is odd

     if strcmp(centering, 'pixel-centered')
        grid.x = linspace(-(grid.Dgrid - grid.dx)/2, (grid.Dgrid - grid.dx)/2, grid.N); % origin at pixel corner
     else
        grid.x = ((1:grid.N) - grid.N/2 - 1)*grid.dx; % origin at pixel center
     end
    
else
 
    if strcmp(centering, 'pixel-centered')
        grid.x = ((1:grid.N) - grid.N/2 - 1)*grid.dx; % origin at pixel center
    else
        grid.x = linspace(-(grid.Dgrid - grid.dx)/2, (grid.Dgrid - grid.dx)/2, grid.N); % origin at pixel corner
    end
end
grid.y = grid.x; % note: may need to transpose
grid.r = - grid.x(floor(end/2+1):-1:1);
if strcmp(centering, 'vertex-centered')
    if ~mod(N,2)
        grid.r = grid.r(2:end);
    end
end
[grid.xx grid.yy] = meshgrid(grid.x,grid.y);
[grid.ttheta grid.rr]=cart2pol(grid.xx, grid.yy);