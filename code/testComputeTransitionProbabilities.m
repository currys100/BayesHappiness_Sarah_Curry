% return a value according to a given probability distribution
function testComputeTransitionProbabilities( pij, stateSpace ) 

%{ 
test that transition probabilities are correct. for a given state i
 (corresponding to some row, column (n, m), the 4 adjacent squares should
 have values. so for pij(n, m, u):  
u = {1, 2} 

pij(n+1, m, u) ~= 0
pij(n-1, m, u) ~= 0
pij(n, m+1, u) ~= 0
pij(n, m-1, u) ~= 0


%}

[n, m, u] = size (pij) ;

% for a random state k, check that the pij neighbors are not zero
k = randi([2 n-1], 1) ; 

% get n, m values for state k:
n_m = stateSpace(k, :) ;


pij(n, m, 1)

% for a random state 

