function output_field = propagate(input_field, lambda_um, config, system, system_parameters)

    lambda = lambda_um*1e-6;
    
    pupil = system.pupil;
    params = system.params;
    ideal_coronagraph = system.ideal_coronagraph;
    inputCoupling = system.inputCoupling;

    pupil.E = input_field/pupil.Area; % contrast units
    inputCoupling.E = reshape(transpose(conj(pupil.E(:)))*inputCoupling.M, [params.inputCoupling.Nlensx,params.inputCoupling.Nlensy]); %couple to lenslet array each tip/tilt
    Elyot = ideal_coronagraph_pupil_to_lyot(params.N2, ideal_coronagraph, inputCoupling);
    
    ElyotInvCoupled = transpose(Elyot(:))*transpose(conj(inputCoupling.M)); % apply the adjoint operator to convert back to original sampling
    ElyotInvCoupled2D  = reshape(ElyotInvCoupled,[params.inputCoupling.N,params.inputCoupling.N]); % convert to 2D

    output_field = ElyotInvCoupled2D;
end


