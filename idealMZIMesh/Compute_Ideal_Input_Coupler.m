function [theta_av, dtheta] = Compute_Ideal_Input_Coupler(PIC, Precision_Cutoff)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Populate an array of phase shifts for each MZ node.
% For each row k, knly the first N - k + 1 columns are populated.
theta_av = zeros(PIC.N);
dtheta = zeros(PIC.N);

% Create the array of intermediate propagation matrices (corresponding to
% the C^(j) matrices in Miller eq. A11)
Intermediate_Prop = zeros([PIC.N, PIC.N, PIC.N]);

for row = 1:PIC.N
    % Compute the phases for the row
    v = PIC.Basis_Modes(:,row);
    for intermediate_row = 1:row-1
        v = Intermediate_Prop(:,:,intermediate_row)*v;
    end
    v = v/sqrt(sum(abs(v).^2));
    %disp(sqrt(sum(abs(v).^2)));

    dtheta(row,1) = real(2*asin(abs(v(1))));
    theta_av(row,1) = angle(conj(v(1))) - pi/2;
    for col = 2:PIC.N-row+1
        RHS = 1;
        for next_col = 1:col-1
            RHS = RHS*1j*exp(1j*theta_av(row,next_col))*cos(0.5*dtheta(row,next_col));
        end

        %Handle the corner case where 0 energy is propagating along the path
        if abs(RHS) < Precision_Cutoff && abs(v(col)) < Precision_Cutoff
            RHS = 1;
        else
            RHS = conj(v(col))/RHS;
%             if abs(RHS) > 1
%                 RHS = 1;
%             end
        end

        dtheta(row,col) = real(2*asin(abs(RHS)));
        theta_av(row,col) = angle(RHS) - pi/2;

    end

    %Compute the jth intermediate propagation matrix
    for start_col = 1:PIC.N-row+1
        for end_col = 1:start_col-1 %Handle start_col == end_col after the loop
            prod = 1j*exp(1j*theta_av(row,end_col))*(-sin(0.5*dtheta(row,end_col)))*1j*exp(1j*theta_av(row,start_col))*sin(0.5*dtheta(row,start_col));
            for next_col = end_col+1:start_col-1
                prod = prod*1j*exp(1j*theta_av(row,next_col))*cos(0.5*dtheta(row,next_col));
            end
            Intermediate_Prop(end_col,start_col,row) = prod;
        end

        if start_col <= PIC.N-row
            Intermediate_Prop(start_col,start_col,row) = 1j*exp(1j*theta_av(row,start_col))*cos(0.5*dtheta(row,start_col));
        end
    end

end

end