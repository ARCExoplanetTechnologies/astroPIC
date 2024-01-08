function config = preprocess_config(config)

% Process baseline pupil.
    if isfield(config.telescope, 'baseline')
        % Get all relevant values for the baseline pupil.
        fname = strcat('baseline_pupils\', config.telescope.baseline, '.fits');

        header = fitsinfo(fname);
        header = header.PrimaryData.Keywords;

        shape = [header{find(strcmp(header, 'NAXIS1')),2}, header{find(strcmp(header, 'NAXIS2')),2}];
        delta = [header{find(strcmp(header, 'CDELT1')),2}, header{find(strcmp(header, 'CDELT2')),2}];
        zero  = [header{find(strcmp(header, 'CRVAL1')),2}, header{find(strcmp(header, 'CRVAL2')),2}];

        circumscribed_diameter = header{find(strcmp(header, 'D_CIRCUM')),2};
        inscribed_diameter = header{find(strcmp(header, 'D_INSCRB')),2};

        % Rewrite the values into the config.
        config.telescope.pupil_fname                    = fname;
        config.telescope.sampling.shape                 = shape;
        config.telescope.sampling.delta                 = delta;
        config.telescope.sampling.zero                  = zero;
        config.telescope.circumscribed_diameter         = circumscribed_diameter;
        config.telescope.inscribed_diameter             = inscribed_diameter;

        config.telescope.segmentation.type              = 'hexagonal';
        config.telescope.segmentation.segment_diameter  = header{find(strcmp(header, 'SPTP')),2};
        config.telescope.segmentation.gap_size          = header{find(strcmp(header, 'GS')),2};
        config.telescope.segmentation.num_rings         = header{find(strcmp(header, 'NR')),2};
        config.telescope.segmentation.missing_segments  = [];

        config.telescope = rmfield(config.telescope, 'baseline');
    end

    % Process coronagraph input plane sampling.
    magnification = config.coronagraph_input_plane.magnification_from_telescope;

    config.coronagraph_input_plane.sampling.shape       = config.telescope.sampling.shape;
    config.coronagraph_input_plane.sampling.delta       = config.telescope.sampling.delta * magnification;
    config.coronagraph_input_plane.sampling.zero        = config.telescope.sampling.zero * magnification;

    config.coronagraph_input_plane.circumscribed_diameter = config.telescope.circumscribed_diameter * magnification;
    config.coronagraph_input_plane.inscribed_diameter     = config.telescope.inscribed_diameter;

    % Process coronagraph output plane sampling.
    plane_names = fieldnames(config.coronagraph_output_planes);
    for plane_name_index = 1:length(plane_names)
        plane_name = plane_names{plane_name_index};
        plane = config.coronagraph_output_planes.(plane_name);
        if strcmp(plane_name, 'science_path')
            if isfield(plane,'magnification_from_coronagraph_input_plane')
                magnification = plane.magnification_from_coronagraph_input_plane;
                config.coronagraph_output_planes.(plane_name).sampling.shape = config.coronagraph_input_plane.sampling.shape;
                config.coronagraph_output_planes.(plane_name).sampling.delta = config.coronagraph_input_plane.sampling.delta * magnification;
                config.coronagraph_output_planes.(plane_name).sampling.zero  = config.coronagraph_input_plane.sampling.zero * magnification;
            end
        end
    end
