clear all;

addpath(genpath('YAMLMatlab_0.4.3'));

%coronagraph_name = 'optimal_coronagraph_matlab';
coronagraph_name = 'astroPIC';
addpath(genpath(coronagraph_name))


    % # Load the coronagraph module.
    % coronagraph = importlib.import_module(module_name, '.')

% Load the design config file.
coronagraph_name_fname = 'astroPIC_usort_offax'
config_fname = strcat(coronagraph_name_fname, '.yml');

config = ReadYaml(config_fname);

% Preprocess the config.
config = preprocess_config(config);

wavelength = config.design_info.center_wavelength;
iwa = config.design_info.inner_working_angle;

% Build zero system parameters (note: this version of the code assumes no system parameters)
system_parameters = []; %{key: np.zeros(value['shape']) for key, value in config['system_parameters'].items()}

% Call the coronagraph operator functions for an on- and off-axis case.
setup_result = setup(config);

tt_offset=[0, 0];
input_field = prepare_input_field(config, tt_offset);
onaxis_img = propagate(input_field, wavelength, config, setup_result, system_parameters);

tt_offset=[2 * iwa, 0];
input_field = prepare_input_field(config, tt_offset);
offaxis_img = propagate(input_field, wavelength, config, setup_result, system_parameters);

% Plot the results.
plane_names = fieldnames(config.coronagraph_output_planes);
num_planes = length(plane_names);

    % for n = 1:num_planes
    %     plane_name = plane_names{n};
    %     delta = config.coronagraph_output_planes.(plane_name).sampling.delta;
    %     weight = prod(delta);
    % 
    %     intensity_onaxis = abs(onaxis_img.(plane_name)).^2;
    %     intensity_offaxis = abs(offaxis_img.(plane_name)).^2;
    % 
    %     power_onaxis = sum(sum(intensity_onaxis * weight));
    %     power_offaxis = sum(sum(intensity_offaxis * weight));
    % 
    %     subplot(2, num_planes, 2 * n - 1);
    %     imagesc(log10(intensity_onaxis + 1e-20), [-12 0]); axis equal; axis tight;
    %     title(sprintf('On-axis %s: %.2f', plane_name, power_onaxis), 'Interpreter', 'none');
    % 
    %     subplot(2, num_planes, 2 * n);
    %     imagesc(log10(intensity_offaxis + 1e-20), [-12 0]);
    %     title(sprintf('Off-axis %s: %.2f', plane_name, power_offaxis), 'Interpreter', 'none'); axis equal; axis tight;
    % end