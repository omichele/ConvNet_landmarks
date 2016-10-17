for ii = 1:imgSet.Count
    
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
    
    [X, ~, centers, dimensions] = ConvNet_eb_feature_extractor_warp(I);
    
    dimensions_to_save = dimensions;
    centers_to_save = centers;
    
    % check the size of the memory
    if count ~= 1
        
        do_crosschk_reRank();
        
        do_find_match();
        
        memory{count,1} = X;       % every element in the memory represent an image made of a matrix of the feature that are in it
        memory{count,2} = dimensions_to_save;
        memory{count,3} = centers_to_save;
        
        
    else
        memory{1,1} = X;
        memory{1,2} = dimensions_to_save;
        memory{1,3} = centers_to_save;
    end
    
    count = count +1;
    
    ds.results.time.time_per_loop(ii,:) = toc(t1);
    ds.results.time.time_per_loop_only_processing(ii,:) = toc(t2);
    
    drawnow
    
end
