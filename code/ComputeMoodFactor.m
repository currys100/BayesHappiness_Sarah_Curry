function normalized_mood_factor = ComputeMoodFactor(stateSpaceSize, distribution_type)
% mood_factor is multiplied by the probability that doing work results in
% progress. 

if strcmp(distribution_type, 'linear')
    % for n states, find the mood factor: 
    mood_factor = zeros(1, stateSpaceSize(2)) ; 
    for i = 1 : stateSpaceSize(2)
        mood_factor(i) = i/stateSpaceSize(2) ;
    end
end

if strcmp(distribution_type, 'piecewise')
    % for n states, find the mood factor: 
    mood_factor = ones(1, stateSpaceSize(2))*0.01 ; 
    for i = 2 : stateSpaceSize(2)
        if i < stateSpaceSize(2)/3
            mood_factor(i) = i^20 + mood_factor(i-1) ; 
        elseif i >= stateSpaceSize(2)/3 && i < 2*stateSpaceSize(2)/3
            mood_factor(i) = i^20 + mood_factor(i-1) ;
        else 
            mood_factor(i) = i^0.5 + mood_factor(i-1) ;
        end
    end
end 

if strcmp(distribution_type, 'piecewise1')
    % for n states, find the mood factor: 
    mood_factor = ones(1, stateSpaceSize(2))*0.01 ; 
    for i = 2 : stateSpaceSize(2)
        if i < stateSpaceSize(2)/3
            mood_factor(i) = i^3 + mood_factor(i-1) ; 
        elseif i >= stateSpaceSize(2)/3 && i < 2*stateSpaceSize(2)/3
            mood_factor(i) = i^20 + mood_factor(i-1) ;
        else 
            mood_factor(i) = i^0.5 + mood_factor(i-1) ;
        end
    end
end 

mood_factor = smooth(smooth(mood_factor)) ; 
normalized_mood_factor = (mood_factor - min(mood_factor)) / (max(mood_factor) - min(mood_factor)) ; 

% now for all states determine the mood factor: 
normalized_mood_factor = repmat(normalized_mood_factor, 1, stateSpaceSize(1)) ;

end