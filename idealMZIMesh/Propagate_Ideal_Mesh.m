function [Output, top_matrix, left_matrix, right_matrix, bottom_matrix] = Propagate_Ideal_Mesh(PIC, Input)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

Output = zeros([PIC.N, 1]);

top_matrix = zeros(PIC.N);
left_matrix = zeros(PIC.N);
right_matrix = zeros(PIC.N);
bottom_matrix = zeros(PIC.N);

top_matrix(1,:) = Input;
for row = 1:PIC.N
    for col = PIC.N:-1:1
        top = top_matrix(row, col);
        left = left_matrix(row, col);
        
        tav = PIC.theta_av(row, col);
        dt = PIC.dtheta(row, col);

        right = 1j*exp(1j*tav)*(sin(0.5*dt)*top + cos(0.5*dt)*left);
        bottom = 1j*exp(1j*tav)*(cos(0.5*dt)*top - sin(0.5*dt)*left);

        right_matrix(row, col) = right;
        bottom_matrix(row, col) = bottom;

        if row < PIC.N
            top_matrix(row+1, col) = bottom;
        end
        if col > 1
            left_matrix(row, col-1) = right;
        else
            Output(row) = right;
        end
    end
end

end