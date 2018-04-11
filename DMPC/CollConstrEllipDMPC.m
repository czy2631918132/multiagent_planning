function [Ain_total, bin_total] = CollConstrEllipDMPC(p,po,vo,n, k, l, Ain,E,A_initp)
bin = [];
diff_mat = [];
Ain_total = [];
bin_total = [];
if (~isempty(l))
    for i = 1:size(l,3) %Iterate through the number of obstacles (other agents)
        if(i~=n)
            pj = l(:,:,i); %position vector of the i-th neighbour over k iterations
            K = size(pj,2);

            dist = norm(E^(-1)*(p-pj(:,k))); %distance at time step k
            diff = (E^(-2)*(p-pj(:,k)))'; % Transpose of the difference

            % Right side of inequality constraint (bin)
            r = dist*(0.5 - dist + diff*p/dist) - diff*A_initp(3*(k-1)+1:3*k,:)*[po';vo'];
            bin = [bin; r];

            % Construct diagonal matrix with vector difference
            diff_mat = [diff_mat; zeros(1,3*(k-1)) diff zeros(1,3*(K-k))];

            % Update the ineq. constraints matrix and vector
            Ain_total =  [Ain_total; -diff_mat*Ain];
            bin_total = [bin_total; -bin];

            % Reset vectors to calculate next obstacle
            bin = [];
            diff_mat = [];  
        end
    end
end
end