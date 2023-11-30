function pupil = pupil_generate_unobstructed(N, Dgrid, D, centering); 

pupil = make2Dgrid(N, Dgrid, centering);

pupil.A = pupil.rr <= D/2;
pupil.D = D;
pupil.Dc = D;
pupil.Deff = D;
pupil.Area = pi * (D/2)^2;