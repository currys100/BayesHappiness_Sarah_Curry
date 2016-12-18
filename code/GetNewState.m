function [new_state_valid, new_state_ind] = GetNewState(state, control_input, stateSpace)
% Move determines if a move is valid.
% Move returns the index of the index of the new_state. 
k = stateSpace(state, :) ; 

if strcmp(control_input, 'mood_increase')
    new_state = [k(1), k(2)+1] ;
elseif strcmp(control_input, 'mood_decrease')
    new_state = [k(1), k(2)-1] ;
elseif strcmp(control_input, 'goal_increase')
    new_state = [k(1)+1, k(2)] ;
elseif strcmp(control_input, 'goal_and_mood_increase')
    new_state = [k(1)+1, k(2)+1] ;
elseif strcmp(control_input, 'goal_increase_mood_decrease')
    new_state = [k(1)+1, k(2)-1] ;
else 
    error('control_input not recognized')
end


% determine if the move is valid: 
[new_state_valid, new_state_ind] = ismember(new_state, stateSpace, 'rows');
if ~new_state_valid
    new_state_ind = state ; 
end



end