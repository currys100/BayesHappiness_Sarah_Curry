function G = ComputeStageCosts(stateSpace, stateSpaceSize, controlSpace )
%% compute stageCost

% stateCost is the cost associated with being in a given state, independent
% of how we arrived in this state.
stateCost = zeros(length(stateSpace), 1) ;
for i = 1 : length(stateSpace)
    k = stateSpace(i,:) ;
    mood = k(2) ;
    stateCost(i) = (stateSpaceSize(2) - mood + 1) ; 
end 

% stageCost is the cost of being in a given state and applying a given
% action. Since the result of the action is probabilistic, stageCost will
% be an expected value. 
stageCost = zeros(length(stateSpace), length(controlSpace)) ; 
pij = ComputeTransitionProbabilities(stateSpace, stateSpaceSize, controlSpace) ;


time_cost_work = 10 ; 
time_cost_not_work = 10 ; 


for state = 1 : length(stageCost)
        
    [increase_mood_valid, increase_mood_ind] = GetNewState(state, 'mood_increase', stateSpace) ; 
    if increase_mood_valid
        stageCost(state,2) = time_cost_not_work + pij(state, increase_mood_ind, 2)*stateCost(increase_mood_ind)...
            + pij(state, state, 2)*stateCost(state) ;
    else
        % if we can't transition to the desired state, then applying that control input has an infinite cost. 
        stageCost(state, 2) = inf; 
    end
    
    [increase_goal_valid, increase_goal_ind] = GetNewState(state, 'goal_increase', stateSpace) ; 
    if increase_goal_valid
        stageCost(state,1) = time_cost_work + pij(state, increase_goal_ind, 1)*stateCost(increase_goal_ind)...
            + pij(state, state, 1)*stateCost(state) ;
    else
        stageCost(state, 1) = 0;
    end
    
end

G = stageCost ; 
