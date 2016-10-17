function [place_recognized, I] = filtering(k, results, filtering_method, matches_local)

place_recognized = zeros(size(results,1));

switch filtering_method
    case 'spatial'
        spatial_filter()
    case 'threshold'
        normal_threshold()
    case 'sequential'
        sequential_filter()
end


end
