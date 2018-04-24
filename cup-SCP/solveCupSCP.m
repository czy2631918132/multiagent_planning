function [p,v,a] = solveCupSCP(po,pf,h,K,N,pmin,pmax,rmin,alim,A_p, A_v)

prev_p = initAllSolutions(po,pf,h,K);
ub = alim*ones(3*N*K,1);
lb = -ub;
H = eye(3*K*N);
A = getPosMat(h,K);
Atot = kron(eye(N),A);
Aeq = getPosVelMat(h,K);
Aeqtot = kron(eye(N),Aeq);
criteria = 2;
epsilon = 0.1;

options = optimset('Display', 'off');

for i = 1:N
    p_constr_h(:,i) = repmat((pmax-po(:,:,i))',K,1);
    p_constr_l(:,i) = repmat(-(pmin-po(:,:,i))',K,1);
    beq_i(:,i) = [(pf(:,:,i)-po(:,:,i))' ; zeros(3,1); zeros(3,1); zeros(3,1)];
end

bound_h = reshape(p_constr_h,[],1);
bound_l = reshape(p_constr_l,[],1);
beqtot = reshape(beq_i,[],1);
k = 1;
prev_f0 = 2;
while criteria > epsilon
    % Inequality Constraints
    [Ain, bin] = AddCollConstr(prev_p,po,K,rmin,Atot);
    Ain_total = [Ain; Atot; -Atot];
    bin_total = [bin; bound_h; bound_l];
    
    % Solve the QP
    [atot,f0] = quadprog(sparse(H),[],sparse(Ain_total),bin_total,sparse(Aeqtot),beqtot,lb,ub,[],options);   
    [p,v,a] = getStates(po,atot,A_p,A_v,K,N);
    prev_p = p;
    criteria = abs(prev_f0 - f0);
    prev_f0 = f0;
    k = k+1;
end
