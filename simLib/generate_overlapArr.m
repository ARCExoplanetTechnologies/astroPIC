function [inputCoupling] = generate_overlapArr(pupil,params)

Nlensx = params.Nlensx;
Nlensy = params.Nlensy;

gaussianSigma = (pupil.D/Nlensx*params.sigma);

inputCoupling = make2Dgrid(Nlensx, pupil.D, 'pixel-centered'); %assumes square grid, and pixel-centered 
inputCoupling.D = pupil.D;
inputCoupling.A = zeros(size(pupil.xx));

Cx = pupil.D/(Nlensx);
Cy = pupil.D/(Nlensy);

for qx = 1:Nlensx
    for qy = 1:Nlensy
        x_cent = qx-Nlensx/2-1/2;
        y_cent = qy-Nlensy/2-1/2;

        %couplingMode{qx,qy} = exp(-4*log(2)*((pupil.xx-pupil.D*x_cent/(Cx)).^2 + (pupil.yy-pupil.D*y_cent/(Cy)).^2)./(gaussianSigma)^2);
        switch params.lensShape
            case 'circular'
                apertureMask{qx,qy} =(sqrt((pupil.xx - x_cent*Cx).^2 + (pupil.yy - y_cent*Cy).^2) < params.lensD/2) + 0.0;
            case  'rectangular'
                apertureMask{qx,qy} = ((pupil.xx - x_cent*Cx) < params.lensD/2) & ((pupil.xx - x_cent*Cx) > -params.lensD/2) & ...
                    ((pupil.yy - y_cent*Cy) < params.lensD/2) & ((pupil.yy - y_cent*Cy) > -params.lensD/2);
            case 'none'
                apertureMask{qx,qy} = ones(size(pupil.xx))
        end
        couplingMode{qx,qy} = params.efficiency*apertureMask{qx,qy}.*exp(-((pupil.xx-x_cent*Cx).^2)/(2*gaussianSigma^2) - ((pupil.yy-y_cent*Cy).^2)./(2*gaussianSigma^2));
        inputCoupling.A = inputCoupling.A + couplingMode{qx,qy};
    end
end


inputCoupling.array = couplingMode;
inputCoupling.gaussianSigma = gaussianSigma;

end

