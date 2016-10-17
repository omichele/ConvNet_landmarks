matches_local( matches_local(:,2) < k, : ) = 0;
I = matches_local;

for aa = 1:size(results,1)
    if(matches_local(aa,2) ~= 0)
%         place_recognized(aa, I(aa)) = results(aa, I(aa));
        place_recognized(aa, matches_local(aa,1)) = 1;
    end
end