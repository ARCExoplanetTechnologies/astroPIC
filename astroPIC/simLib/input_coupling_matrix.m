%% computes matrix M for direct computation of input couplign \int Ea^* Eb dA / sqrt(|\int Ea dA|^2 + |\int Eb dA|^2) 
% assumes Ea and Eb are provided over the same grid

function inputCoupling_matrixOut = input_coupling_matrix(inputCoupling)

[a b] = size(inputCoupling.array);
lensInd = 1;
for ia = 1:a
    for ib = 1:b
        Eb = inputCoupling.array{ia,ib};
        inputCoupling_matrix(lensInd,:) = Eb(:)./norm(Eb(:),2);
        lensInd = lensInd + 1;
    end
end

inputCoupling_matrixOut = inputCoupling_matrix;%transpose(inputCoupling_matrix);

