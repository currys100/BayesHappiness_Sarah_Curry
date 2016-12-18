function [ J_opt, u_opt_ind ] = ValueIteration( P, G )

iteration = 1;
% m = number of states
% n = number of actions 
[m,n] = size(G); 
J_old = zeros(m); % initialize the cost-to-go

while iteration < 1000
    % choose initial J = infinity. This will take longer to converge to an
    % optimal value, but it's certain to do so.
    J = ones(m,1)*inf; 
    for i = 1:m % for each possible current state i
        for u = 1:n % and for each possible action
            sum = 0; 
            for j = 1:m % for each possible next state j
                % calculate future costs: This is an expected value, since
                % we only know the probability of transitioning to a new
                % state. future cost = expected value of the probability of
                % transitioning to a new state j, multiplied by the cost of
                % being in that new state.
                % this is only summing the future cost of all the next
                % states; however, since the next state j includes the cost
                % to go to all of its next states, this accounts for all
                % remaining stages in the shortest path problem. 
                sum = sum + P(i,j,u)*J_old(j); 
            end
            J(i) = min(J(i), G(i,u) + sum);
        end
    end
    J_old = J;
    iteration = iteration+1 ;
    J(1) ;
end

u_opt_ind = zeros(m,1);
J = ones(m,1)*inf;
for i = 1:m
    for u = 1:n
        sum = 0;
        for j = 1:m
            sum = sum + P(i,j,u)*J_old(j);
        end
        if ( G(i,u) + sum) < J(i)
           u_opt_ind(i) = u;
        end
        J(i) = min(J(i), G(i,u) + sum);
    end
end

J_opt = J;

end