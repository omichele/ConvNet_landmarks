for ii = 1:imgSet.Count
    
    % read the current image
    t1 = tic;
    I = read(imgSet,ii);
    t2 = tic;
    
    if(ds.conf.enable_figures)
        figure(1)
        subplot_tight(2,2,1, [0.01, 0.01])
        imshow(I)
    end
    
    % I = gpuArray(I);
    
    display(['Image number' ': ' num2str(ii)])
    
    
    if count ~= 1
        
        % do matching - it returns a number of matches ordered folowing their
        % score. Also it returns the queryWords computed for the current image.
        % queyWords consists in a vector of
        [imageIDs, scores, queryWords, dimensions, dist] = retrieveImages_mine(I, testImagesIndex, 'NumResults', ds.conf.params.NumResults);
        
        do_crosschk_reRank_bow();
        
        do_find_match_bow();
        
    else
        % the first time add just the image without querying the database
        addImages_online(testImagesIndex, I);
    end
    
    count = count + 1;
    
    ds.results.time.time_per_loop(ii,:) = toc(t1);
    ds.results.time.time_per_loop_only_processing(ii,:) = toc(t2);
    
    drawnow
    
end
