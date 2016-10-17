global ds

inlierPoints1 = [];
inlierPoints2 = [];


for ll = 1:min(ds.conf.params.reRank_num, size(imageIDs,1))
    
    matchWords = testImagesIndex.ImageWords(imageIDs(ll));
    
    queryWordsIndex     = queryWords.WordIndex;
    matchWordIndex  = matchWords.WordIndex;
    
    tentativeMatches = [];
    for i = 1:numel(queryWords.WordIndex)
        
        idx = find(queryWordsIndex(i) == matchWordIndex);
        
        matches = [repmat(i, numel(idx), 1), idx];
        
        tentativeMatches = [tentativeMatches; matches];
        
    end
    
    % Show the point locations for the tentative matches. There are many poor matches.
    points1 = queryWords.Location(tentativeMatches(:,1),:);
    points2 = matchWords.Location(tentativeMatches(:,2),:);
    
    % RANSAC
    [tform{ll}, ~, ~, inlier_ind{ll}, status] = estimateGeometricTransform_mine(points1, points2, 'similarity', 'Confidence', ds.conf.params.Confidence, 'MaxDistance', ds.conf.params.MaxDistance);
    
    if status ~= 0
        scores(ll) = 0;
    else
        if sum(tform{ll}.T(3,:) > 100) ~= 0
            percentageOfInliers = 0;
        else
            % Rerank the search results by the percentage of inliers. Do this when the geometric verificiation procedure is applied to the top N search results. Those images with a higher percetage of inliers are more likely to be relevant.
            percentageOfInliers = sum(inlier_ind{ll})./size(points1,1);
        end
        scores(ll) = scores(ll) * percentageOfInliers;
    end
    
end

% visualization code - with and without geometric re-ranking
if min(ds.conf.params.reRank_num, size(imageIDs,1)) == 0 % without geometric re-ranking
    resorted_scores = scores;
    reRanked_ind = 1:numel(imageIDs);
    
    if imageIDs(reRanked_ind(1)) <= count - ds.conf.params.frame_tolerance
        % take the best match image words
        matchWords = testImagesIndex.ImageWords(imageIDs(1));
        queryWordsIndex     = queryWords.WordIndex;
        matchWordIndex  =     matchWords.WordIndex;
        tentativeMatches = [];
        for i = 1:numel(queryWords.WordIndex)
            idx = find(queryWordsIndex(i) == matchWordIndex);
            matches = [repmat(i, numel(idx), 1), idx];
            tentativeMatches = [tentativeMatches; matches];
        end
        % Show the point locations for the tentative matches. There are many poor matches.
        points1 = queryWords.Location(tentativeMatches(:,1),:);
        points2 = matchWords.Location(tentativeMatches(:,2),:);
        
        if(ds.conf.enable_figures)
            figure(2)
            showMatchedFeatures(I, read(memorySet, imageIDs(1)), points1, points2, 'montage')
            figure(1)
        end
        
    end
    
    
else % with geometric re-ranking
    [resorted_scores, reRanked_ind] = sort(scores, 'descend');
    
    %     transfo{count} = tform{reRanked_ind(1)}.T;
    %     transfo{count}
    transfo = tform{reRanked_ind(1)}.T;
    transfo
    
    
    if imageIDs(reRanked_ind(1)) <= count - ds.conf.params.frame_tolerance
        matchWords = testImagesIndex.ImageWords(imageIDs(reRanked_ind(1)));
        queryWordsIndex     = queryWords.WordIndex;
        matchWordIndex  =     matchWords.WordIndex;
        tentativeMatches = [];
        for i = 1:numel(queryWords.WordIndex)
            idx = find(queryWordsIndex(i) == matchWordIndex);
            matches = [repmat(i, numel(idx), 1), idx];
            tentativeMatches = [tentativeMatches; matches];
        end
        % Show the point locations for the tentative matches. There are many poor matches.
        points1 = queryWords.Location(tentativeMatches(:,1),:);
        points2 = matchWords.Location(tentativeMatches(:,2),:);
        
        inlierPoints1 = points1(inlier_ind{reRanked_ind(1)},:);
        inlierPoints2 = points2(inlier_ind{reRanked_ind(1)},:);
        
        if(ds.conf.enable_figures)
            figure(3)
            showMatchedFeatures(I, read(memorySet, imageIDs(reRanked_ind(1))), inlierPoints1, inlierPoints2, 'montage')
            figure(1)
        end
    end
    
end

% Add a row to the confusion matrix
ds.results.confusionMat(ii, imageIDs(reRanked_ind)) = resorted_scores;