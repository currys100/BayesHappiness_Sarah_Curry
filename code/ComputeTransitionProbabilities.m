function P = ComputeTransitionProbabilities(stateSpace, stateSpaceSize, controlSpace)

%{ 
Notes:

-- Pij depends on state x and control input u. 
-- Probabilities are static (for any given state i, the transitions to 
other squares or to the terminal state have the same probabilities); thus
this only needs to be calculated once. 
-- P(i,j,u) represents the probability of transitioning from state i to j,
given u as an input. 


%}

%% initialize (K x K x L) matrix with zeros for transition probabilities
pij = zeros( length(stateSpace), length(stateSpace), length(controlSpace) );



%% starting over on pij

% mood state transition probabilities: 
mood_increase_if_work = 0.01 ; 
% mood_decrease_if_work is a significant factor in determining the percentage of time that we
% should spend working vs. taking a break. 
mood_decrease_if_work = 0.7 ; 
mood_same_if_work = 1 - mood_increase_if_work - mood_decrease_if_work ; 

mood_increase_if_not_work = 0.95 ; 
mood_decrease_if_not_work = 0.01 ; 
mood_same_if_not_work = 1 - mood_increase_if_not_work - mood_decrease_if_not_work ;

% for u = not work = 2
for state = 1 : length(stateSpace) 

    % if the mood is not yet at its max, then not working has the following
    % probability of increasing the mood:
    [increase_mood_valid, increase_mood_ind] = GetNewState(state, 'mood_increase', stateSpace) ; 
    if increase_mood_valid
        pij(state, increase_mood_ind, 2) = mood_increase_if_not_work ;
        pij(state, state, 2) = mood_same_if_not_work ;
    else
        % if mood state is already at its max, then we stay at the same
        % state with the combined probability of mood_increase and
        % mood_same: 
        pij(state, state, 2) = mood_increase_if_not_work + mood_same_if_not_work ;
    end
        
    [decrease_mood_valid, decrease_mood_ind] = GetNewState(state, 'mood_decrease', stateSpace) ; 
    if decrease_mood_valid
        pij(state, decrease_mood_ind, 2) = mood_decrease_if_not_work ;
        pij(state, state, 2) = mood_same_if_not_work ;
    else
        pij(state, state, 2) = mood_decrease_if_not_work + mood_same_if_not_work ;
    end
    
    % the probability of staying at the same mood state (even if we can
    % increase or decrease it given a control input of not working): 
    if pij(state, state, 2) == 0 % if we're not at the edge of the map then we haven't set this value yet. 
        pij(state, state, 2) = mood_same_if_not_work ;
    end    
    
end

%% set transition probabilities for control input = 1 = work

% get the mood factor to determine the influence of the mood on the
% probability of accomplishing work:
mood_factor = ComputeMoodFactor(stateSpaceSize, 'piecewise') ; 

max_goal_inds = stateSpace(:,1) == stateSpaceSize(1) ;
p_completed_goal = zeros(length(stateSpace),1); 
p_completed_goal(max_goal_inds) = 1 ; 

% for u = work = 1
for state = 1 : length(stateSpace)
    
    % the probability of getting work done is dependent on the mood_factor.
    goal_increase_if_work = mood_factor(state) ; 
    goal_decrease_if_work = 0 ;
    goal_same_if_work = 1 - goal_increase_if_work - goal_decrease_if_work ;
    
    [increase_goal_valid, increase_goal_ind] = GetNewState(state, 'goal_increase', stateSpace) ; 
    if increase_goal_valid
        pij(state, increase_goal_ind, 1) = goal_increase_if_work*(1 - p_completed_goal(state))*mood_same_if_work ;
        pij(state, state, 1) = goal_same_if_work*(1 - p_completed_goal(state))*mood_same_if_work ;
    else
        pij(state, state, 1) = (goal_increase_if_work + goal_same_if_work)*(1 - p_completed_goal(state))*mood_same_if_work ;
    end
    
    % if the mood is not yet at its max, then working has the following
    % probability of increasing the mood:
    [increase_mood_valid, increase_mood_ind] = GetNewState(state, 'mood_increase', stateSpace) ; 
    if increase_mood_valid
        pij(state, increase_mood_ind, 1) = mood_increase_if_work*goal_same_if_work*(1 - p_completed_goal(state)) ;
%         pij(state, state, 1) = mood_same_if_work*goal_same_if_work*(1 - p_completed_goal(state)) ; 
    else
        % if mood state is already at its max, then we stay at the same
        % state with the combined probability of mood_increase and
        % mood_same: 
        pij(state, state, 1) = (mood_increase_if_work + mood_same_if_work)*goal_same_if_work*(1 - p_completed_goal(state)) ;
    end
        
    [decrease_mood_valid, decrease_mood_ind] = GetNewState(state, 'mood_decrease', stateSpace) ; 
    if decrease_mood_valid
        pij(state, decrease_mood_ind, 1) = mood_decrease_if_work*goal_same_if_work*(1 - p_completed_goal(state)) ;
%         pij(state, state, 1) = mood_same_if_work*goal_same_if_work*(1 - p_completed_goal(state)) ; 
    else
        pij(state, state, 1) = (mood_decrease_if_work + mood_same_if_work)*goal_same_if_work*(1 - p_completed_goal(state)) ;
    end
        
    [increase_goal_and_mood_valid, increase_goal_and_mood_ind] = GetNewState(state, 'goal_and_mood_increase', stateSpace) ; 
    if increase_goal_and_mood_valid
        pij(state, increase_goal_and_mood_ind, 1) = goal_increase_if_work*mood_increase_if_work*(1 - p_completed_goal(state)) ;
%         pij(state, state, 1) = mood_same_if_work*goal_same_if_work*(1 - p_completed_goal(state)) ;     
    end
        
    [increase_goal_decrease_mood_valid, increase_goal_decrease_mood_ind] = GetNewState(state, 'goal_increase_mood_decrease', stateSpace) ; 
    if increase_goal_decrease_mood_valid
        pij(state, increase_goal_decrease_mood_ind, 1) = mood_decrease_if_work*goal_increase_if_work*(1 - p_completed_goal(state)) ;
%         pij(state, state, 1) = mood_same_if_work*goal_same_if_work*(1 - p_completed_goal(state)) ; 
    end
    
    if pij(state, state, 1) == 0 % if we're not at the edge of the map then we haven't set this value yet. 
        pij(state, state, 1) = mood_same_if_work*goal_same_if_work*(1 - p_completed_goal(state)) ;
    end 
    
end 

P = pij ;


%% take 1
% 
% % without considering mood_factor, the probability of progress given
% % control input is:
% p_progress_w = 0.99 ;  % P(progress | work) 
% p_progress_n = 0 ; % P(progress | not work) 
% 
% % probability of improving mood given the control inputs. Note that mood
% % stays the same for remainder of cases where it is not improved nor
% % worsened. 
% p_improve_mood_w = 0.01 ; % P(improve mood | work)
% p_worsen_mood_w = 0.7 ; % P(mood worsens | work) 
% p_improve_mood_n = 0.93 ; % P(improve mood | not work)
% p_worsen_mood_n = 0.01 ; % P(worsen mood | not work)
% 
% % for any given state, determine the transition probabilities to all other states.  
% for i = 1 : length(stateSpace)
%     % for each row in stateSpace, determine coordinates of 4 possible moves.
%     k = stateSpace(i,:) ; % get n,m map values for a given state
%     
%     % if input is to work, then probability of moving forward along
%     % the study axis is high, while moving forward along the mood axis is
%     % low:
% 
%     % TO DO: add pij for staying in current state so that SUM(all
%     % transitions) = 1
%     
%     % determine whether we make progress: 
%     delta_goal_w = p_progress_w * mood_factor(i);
%     delta_goal_n = p_progress_n * mood_factor(i);
%     
%     % find the index value in stateSpace for j, where j is a neighbor of i.
%     % goal_increase returns T/F if [k(1), k(2)+1)] is a row in stateSpace
%     % g_ind returns the index of stateSpace([k(1), k(2)+1)]) 
%     [goal_increase, g_ind] = ismember([k(1), k(2)+1], stateSpace, 'rows');
%     if goal_increase  
%         pij(i, g_ind, 1) = delta_goal_w ;
%     else
%         % if there is no movement to an adjacent square, then the
%         % probability of staying at the same state is 1, regardless of the
%         % input. 
%         % if we can't increase the goal axis then we're in the terminal
%         % state. 
%         % TO DO: how do we account for being in the terminal state? 
%    
%         pij(i, i, :) = 1 ;
%     end
%     
%     % determine if adjacent squares are in the stateSpace. 
%     % control input work = sheet 1 in pij matrix
%     % control input not work = sheet 2 
%     [mood_increase, m_ind] = ismember([k(1)+1, k(2)], stateSpace, 'rows');
%     if mood_increase 
%         pij(i, m_ind, 1) = p_improve_mood_w ;
%         pij(i, m_ind, 2) = p_improve_mood_n ;
%         pij(i, i, 1) = 1-p_improve_mood_w ;
%         pij(i, i, 2) = 1-p_improve_mood_n ;
%     else
%         % if we're already at max mood possible, then we stay at the same
%         % state if u=not work
%         pij(i, i, 2) = 1 ; 
%     end 
%     
%     [worsen_mood, w_ind] = ismember([k(1)-1, k(2)], stateSpace, 'rows');
%     if worsen_mood  
%         pij(i, w_ind, 1) = p_worsen_mood_w ;
%         pij(i, w_ind, 2) = p_worsen_mood_n ;
%     else
%         % if we're already at the minimum mood, then we stay at the same
%         % state if u=work. 
%         pij(i, i, 1) = 1 ;
%     end
%     
%     
% end 
% 
% P = pij ;

end




