[M, I] = max(results, [], 2);  % extract the max for every image in the mem. excluded the most recent ones
I(M < k) = 0;
place_recognized = zeros(size(results,1));
for aa = 1:size(results,1)
    if(I(aa) ~= 0)
        %         place_recognized(aa, I(aa)) = results(aa, I(aa));
        place_recognized(aa, I(aa)) = 1;
    end
end
% place_recognized = place_recognized > k;     % remove the weakest matches

%% spatial filter
d_s = 3;
max_frame_passed = 20;
flag_match = 0;
last_detection = 0;
for ii = 1:size(place_recognized, 1)
    ind = find(place_recognized(ii,:));
    if( ~isempty(ind))
        if(~flag_match)
            prev_ind = ind;
            last_detection = ii;
            flag_match = 1;
            %         place_recognized(ii, ind) = 1;
            
        else
            frame_passed = ii-last_detection;
            if(frame_passed <= max_frame_passed)
                if(ind-prev_ind+frame_passed <= d_s)
                    %                 place_recognized(ii, ind) = 1;
                    prev_ind = ind;
                    last_detection = ii;
                else
                    place_recognized(ii, ind) = 0;
                    prev_ind = ind;
                    last_detection = ii;
                end
            else
                flag_match = 0;
            end
        end
    end
    
    
end