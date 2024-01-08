function pupil = pupil_generate(filename, D, D_type, centering); 

A = fitsread(filename);

switch D_type
    case 'full-grid'
        pupil = make2Dgrid(size(A,1), D, centering);
        Area = trapz(trapz(A))*pupil.dx*pupil.dy;
        Deff = 2*sqrt(Area/pi);
        Dc = 2*max(max(pupil.rr.*A));
        
    case 'effective-area'
        Areapix = trapz(trapz(A));
        Dpix = 2*sqrt(Areapix/pi); % radius in pixels of an unobstructed aperture of the same area
        pupil = make2Dgrid(size(A,1), D/Dpix * size(A,1),centering); % second number refers to full diameter of grid, usually slightly larger than Deff
        Area = trapz(trapz(A))*pupil.dx*pupil.dy;
        Deff = D;
        Dc = 2*max(max(pupil.rr.*A));
        
    case 'circumscribed'
        pupilpix = make2Dgrid(size(A,1), size(A,1), centering);
        Dpix = 2*max(max(pupilpix.rr.*A)); % diameter in pixels of an unobstructed aperture of the same area 
        pupil = make2Dgrid(size(A,1), D/Dpix * size(A,1),centering); 
        Area = trapz(trapz(A))*pupil.dx*pupil.dy;
        Deff = 2*sqrt(Area/pi);
        Dc = D;
end

pupil.A = A;
pupil.D = D;
pupil.D_type = D_type;
pupil.Dc = Dc;
pupil.Deff = Deff;
pupil.Area = Area;