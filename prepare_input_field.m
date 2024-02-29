function input_field = prepare_input_field(config, tt_offset)
% Read in telescope pupil with accompanying sampling information.
    telescope_pupil = fitsread(config.telescope.pupil_fname);

    shape = config.telescope.sampling.shape;
    delta = config.telescope.sampling.delta;
    zero = config.telescope.sampling.zero;

    pupil_diameter = config.telescope.circumscribed_diameter;

    x = (0:(shape(1)-1)) * delta(1) + zero(1);
    y = (0:(shape(2)-1)) * delta(2) + zero(2);
    y = y';

    [xx yy] = meshgrid(x,y);

% Normalize the telescope pupil.
    weight = prod(delta);
    norm = sum(sum(telescope_pupil.^2)) * weight;
    input_field = (telescope_pupil / sqrt(norm));

    magnification = config.coronagraph_input_plane.magnification_from_telescope;
    x = x * magnification / pupil_diameter;
    y = y * magnification / pupil_diameter;

% Apply a tilt to the input field.
    input_field = input_field .* exp(2j * pi * (xx * tt_offset(1) + yy * tt_offset(2)));
