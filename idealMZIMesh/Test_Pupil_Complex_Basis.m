function [Basis_Set, Basis_Vectors] = Test_Pupil_Complex_Basis(Sidelength)
%TEST_PUPIL_BASIS Summary of this function goes here
%   Detailed explanation goes here

N_Modes = Sidelength^2;
Basis_Set = zeros(Sidelength, Sidelength, N_Modes);
Basis_Vectors = zeros(N_Modes);


X_Array = - 0.5*Sidelength + 0.5 : 0.5*Sidelength - 0.5;
X_Array = X_Array/Sidelength;
[X_Mesh, Y_Mesh] = meshgrid(X_Array);

N = Sidelength / 2;
for nx = - N : N - 1
    for ny = - N : N - 1
        Mode = (nx + N)*2*N + ny + N + 1;
        Basis_Set(:,:,Mode) = exp(1j*2*pi*nx*X_Mesh).*exp(1j*2*pi*ny*Y_Mesh);
    end
end

%Gram-Schmidt orthonormalization
for j = 1:N_Modes
    Vector_j = Basis_Set(:,:,j);
    for k = 1:j-1
        Vector_k = Basis_Set(:,:,k);
        Vector_j = Vector_j - sum(sum(conj(Vector_k).*Vector_j))*Vector_k;
    end
    Vector_j = Vector_j/sqrt(sum(sum(abs(Vector_j).^2)));
    Basis_Set(:,:,j) = Vector_j;
    Basis_Vectors(:,j) = reshape(Vector_j.',1,[]);
end

end

