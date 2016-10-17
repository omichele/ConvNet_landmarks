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