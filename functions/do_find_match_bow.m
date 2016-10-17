% If the figures are enabled this script show the best match found
% according to the selected filtering method.
if(ds.conf.enable_figures)
    % code for the ratio test (ratio of the distances of the best over the second best match found in the nearest neighbor search)
    if ii > 3
        ratio = resorted_scores(1)/resorted_scores(2);
    else
        ratio = 0;
    end
    
    if(strcmp(ds.results.filtering_method, 'threshold'))
        if resorted_scores(1) >= ds.conf.params.th_recognition && ii > 3 && imageIDs(reRanked_ind(1)) <= count-ds.conf.params.frame_tolerance
            disp('Recognized place');
            disp('Matching with image number:');
            disp(imageIDs(reRanked_ind(1)));
            disp('Score');
            disp(resorted_scores(1));
            disp('Ratio:');
            disp(ratio);
            subplot_tight(2,2,3, [0.01, 0.01])
            imshow(read(memorySet, imageIDs(reRanked_ind(1))));
            subplot_tight(2,2,4, [0.01, 0.01])
            imshow(read(memorySet, imageIDs(reRanked_ind(2))));
        end
    end
    if(strcmp(ds.results.filtering_method, 'sequential'))
        if count > ds.conf.params.matching.ds/2+1
            DD = ds.results.confusionMat';
            match = findSingleMatch(DD, count, ds.conf.params);
            match(isnan(match)) = 0;
            if match(2) >= ds.conf.params.th_recognition && ii > 3 && match(1) <= count-ds.conf.params.frame_tolerance
                disp('Recognized place!!');
                disp('Matching with image number:');
                disp(match(1))
                disp('Matching score:');
                disp(match(2));
                subplot_tight(2,2,3, [0.01, 0.01])
                imshow(read(imgSet, match(1)));
            end
        end
    end
    
end