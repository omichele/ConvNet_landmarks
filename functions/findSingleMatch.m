function match = findSingleMatch(DD, N, params)


    % We shall search for matches using velocities between
    % params.matching.vmin and params.matching.vmax.
    % However, not every vskip may be neccessary to check. So we first find
    % out, which v leads to different trajectories:
        
    move_min = params.matching.vmin * params.matching.ds;    
    move_max = params.matching.vmax * params.matching.ds;    
    
    move = move_min:move_max;
    v = move / params.matching.ds;
    
    idx_add = repmat([0:params.matching.ds], size(v,2),1);
   % idx_add  = floor(idx_add.*v);
    idx_add = floor(idx_add .* repmat(v', 1, length(idx_add)));
    
    % this is where our trajectory starts
    n_start = N - params.matching.ds/2;     % why it is not just ds?
    x = repmat([n_start : n_start + params.matching.ds], length(v), 1);    
    
    score = zeros(1, size(DD,1));    
    
    % add a line of inf costs so that we penalize running out of data
    DD = [DD; zeros(1,size(DD,2))];
            
    y_max = size(DD,1);        
    xx = (x-1) * y_max;
    
    % computing the score for every template
    for s = 1:size(DD,1)           
        y = min(idx_add+s, y_max);                
        idx = xx + y;
        score(s) = max(sum(DD(idx),2));
    end
    
    % find min score and 2nd smallest score outside of a window
    % around the minimum 
    [max_value, max_idx] = max(score);
    if(0)
        window = max(1, max_idx-params.matching.Rwindow/2):min(length(score), max_idx+params.matching.Rwindow/2);
        not_window = setxor(1:length(score), window);
        max_value_2nd = max(score(not_window));
        match = [max_idx + params.matching.ds/2; max_value_2nd / max_value ];
    else
        match = [max_idx + params.matching.ds/2; max_value ];
    end
end