d = cell(size(memory, 1), 1);
d_ind = cell(size(memory, 1), 1);
S = cell(size(memory, 1), 1);
crosscheck_mask = cell(size(memory, 1), 1);
score = zeros(1, size(memory, 1));

% do this loop for every image kk in the memory
for kk = 1:size(memory, 1)
    
    % cosine distance computation --- it gives the index of the
    % corresponding landmarks in the memory
    % every d{kk, 1} is
    % every d_ind{kk, 1} is
    [tmp_d, tmp_d_ind] = pdist2_mine(memory{kk, 1}, X, 'cosine', 'Smallest', 1);
    % crosschecking
    [~, d_ind1] = pdist2_mine(X, memory{kk, 1}, 'cosine', 'Smallest', 1);
    
    crosscheck_mask{kk, 1} = d_ind1(tmp_d_ind) == 1:size(tmp_d, 2);
    %                 tmp_d( ~crosscheck_mask ) = 0;
    dimensions = dimensions_to_save( crosscheck_mask{kk, 1}, : );
    %                 centers = centers_to_save( crosscheck_mask{kk, 1}, : );
    
    d{kk,1} = tmp_d( crosscheck_mask{kk, 1} );
    d_ind{kk,1} = tmp_d_ind( crosscheck_mask{kk, 1} );
    
    
    % normalization
    d{kk,1} = d{kk,1}./2;
    
    % extraction of width and height and centers from the memory for every
    % image
    wh = memory{kk, 2};
    
    % extraction of the dimension corresponding to the matched
    % landmarks. wh it will contain for every landmark in the
    % current image the dimensions of the matched landmarks.
    % myx2
    wh = wh(d_ind{kk,1}', :);
    
    shape_sim = zeros(1,size(d{kk,1},2));
    % shape similarity for every matched landmark
    for a = 1:size(d{kk,1},2)
        % computation of the shape similarity
        shape_sim(a) = exp(1/2 * ( abs(wh(a,1) - dimensions(a,1))/max(wh(a,1), dimensions(a,1)) + abs(wh(a,2) - dimensions(a,2))/max(wh(a,2), dimensions(a,2)) ));
        % normalization
        shape_sim(a) = shape_sim(a) - 1/(exp(1) - 1);
    end
    
    S{kk,1} = shape_sim;
    
    % computation of the overall score
    % TO BE MODIFIED
    score(kk) = 1/((size(memory{kk,1}, 1) * size(X,1))^(1/2)) * sum ( ones(1, size(d{kk,1},2)) - d{kk,1} .* S{kk,1});
    
end

% simple maximum search
[sorted_scores, img_match_ind] = sort(score,'descend');
% it does not consider the images to close to the current one
% tmp3 = min(ds.conf.params.frame_tolerance, size(memory,1));
% [sorted_scores, img_match_ind] = sort(score(1:kk-tmp3),'descend');



inlier_ind = cell(ds.conf.params.reRank_num, 1);
new_score = zeros(1, min(ds.conf.params.reRank_num, size(sorted_scores ,2)));
% re-rank of the first n matches
for ll = 1:min(ds.conf.params.reRank_num, size(sorted_scores ,2))
    % at first it retrieve the all the centers of the memory
    % image
    pointsOriginal = memory{img_match_ind(ll), 3};
    % then I have to sort the points according to the matching
    % landmarks of the current image
    pointsOriginal = pointsOriginal(d_ind{img_match_ind(ll), 1}', :);
    % inlier_ind
    [ tform{ll}, ~, ~, inlier_ind{ll}] = estimateGeometricTransform_mine( centers_to_save(crosscheck_mask{img_match_ind(ll), 1}, :), pointsOriginal, 'similarity', 'Confidence', ds.conf.params.Confidence, 'MaxDistance', ds.conf.params.MaxDistance);
    
    num_inlier = sum(inlier_ind{ll});
    
    d_inlier = d{img_match_ind(ll), 1};
    d_inlier = d_inlier(inlier_ind{ll}');
    S_inlier = S{img_match_ind(ll), 1};
    S_inlier = S_inlier(inlier_ind{ll}');
    
    % the order here is still the one after the sort on the
    % previous score. Now I compute the new score
    new_score(ll) = 1/((size(memory{img_match_ind(ll),1},1) * size(X,1))^(1/2)) * sum ( ones(1, sum(inlier_ind{ll})) - d_inlier .* S_inlier);
    
end

if exist('new_score', 'var') && ~isempty(new_score) % with reRanking
    [resorted_scores, reRanked_ind] = sort(new_score, 'descend');
    
    transfo{count} = tform{reRanked_ind(1)}.T;
    transfo{count}
    
    if img_match_ind(reRanked_ind(1)) <= count - ds.conf.params.frame_tolerance
        
        
        pointsOriginal = memory{img_match_ind(reRanked_ind(1)), 3};
        pointsOriginal = pointsOriginal(d_ind{img_match_ind(reRanked_ind(1)), 1}', :);
        inlierMemory = pointsOriginal(inlier_ind{reRanked_ind(1)}, :);
        tmp1 = centers_to_save(crosscheck_mask{img_match_ind(reRanked_ind(1)), 1}, :);
        inlierCurrent = tmp1(inlier_ind{reRanked_ind(1)}, :);
        if(ds.conf.enable_figures)
            figure(2)
            showMatchedFeatures(I, read(imgSet, img_match_ind(reRanked_ind(1))), inlierCurrent, inlierMemory, 'montage')
            figure(1)
        end
    end
    
    % add a row to the confusion matrix
    ds.results.confusionMat(ii, img_match_ind(reRanked_ind)) = resorted_scores;
    
else % without reRanking
    resorted_scores = sorted_scores;
    reRanked_ind = 1:numel(img_match_ind);
    if numel(img_match_ind) ~= 0
        %         resorted_scores = sorted_scores;
        %         reRanked_ind = 1:numel(img_match_ind);
        
        if img_match_ind(1) <= count - ds.conf.params.frame_tolerance
            
            pointsOriginal = memory{img_match_ind(1), 3};
            pointsOriginal = pointsOriginal(d_ind{img_match_ind(1), 1}', :);
            tmp2 = centers_to_save(crosscheck_mask{img_match_ind(reRanked_ind(1)), 1}, :);
            if(ds.conf.enable_figures)
                figure(2)
                showMatchedFeatures(I, read(imgSet, img_match_ind(1)), tmp2, pointsOriginal, 'montage')
                figure(1)
            end
        end
    end
    
    % add a row to the confusion matrix
    ds.results.confusionMat(ii, 1:size(score,2)) = score;
    
end