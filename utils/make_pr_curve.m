resultFolder = pwd;
results = dlmread(fullfile(resultFolder, 'confusionMat.txt'));

ds = yaml.ReadYaml('config.yaml');

%% confusionMatrix preparation
% clean the diagonal
ds.conf.params.frame_tolerance = 40;  % user defined
frame_tolerance = ds.conf.params.frame_tolerance;
for ii = 1:size(results,1)
    for jj = 1:size(results,1)
        if ii == jj
            if jj ~= 1
                if jj < frame_tolerance +1
                    ind = jj-1;
                    results(ii,jj-ind:jj) = zeros(1,ind+1);
                else
                    ind = frame_tolerance;
                    results(ii,jj-ind:jj) = zeros(1,ind+1);
                end
            end
        end
    end
end

%%
% truth_enlarged = dlmread(fullfile(resultFolder, 'gt.txt'));
truth_enlarged = dlmread(fullfile(resultFolder, 'gt_enlarged.txt'));
truth_unique = dlmread(fullfile(resultFolder, 'gt_unique.txt'));

% make_ground_truth();

% figure
% imshow(truth_enlarged)
% 
% figure
% imshow(truth_unique)

%%
% filtering_method = ds.conf.filtering_method;
filtering_method = 'threshold';
% filtering_method = 'spatial';
% filtering_method = 'sequential';

if strcmp(filtering_method, 'sequential')
    
    params.matching.ds = 30;    % 30 is good
    params.matching.vmin = 0.8;
    params.matching.vmax = 1.2;
    params.matching.Rwindow = 30;
    params.matching.save = 0;
    
    tic
    matches = doFindMatches(results', params);
    toc
    
    matches(isnan(matches)) = 0;
    
    stats.maxScore = max(max(matches(:,2)));
    stats.minScore = min(min(matches(:,2)));
    stats.medianScore = median(median(matches(:,2)));
    stats.modeScore = mode(mode(matches(:,2)));
    stats.meanScore = mean(mean(matches(:,2)));
    stats.varScore = var(var(matches(:,2)));
else
    matches = 0;
    
    % Gathering some useful statistics
    stats.maxScore = max(max(results));
    stats.minScore = min(min(results));
    stats.medianScore = median(median(results));
    stats.modeScore = mode(mode(results));
    stats.meanScore = mean(mean(results));
    stats.varScore = var(var(results));
end

%% Sweeping the recognition threshold to obtain the pr curve.
j = 1;

% th1 = 0.999:-0.0001:0.99;
% th2 = 0.99:-0.001:0.8;
% th3 = 0.8:-0.1:0.1;
% th3 = 0.1:-0.0001:0.0001;
th1 = stats.maxScore:-0.01:stats.minScore;
% th1 = stats.maxScore:-0.1:stats.minScore;
% th = [th1, th2, th3];
th = th1;
for k = th
    
    [place_recognized{j}, indices{j}] = filtering(k, results, filtering_method, matches);
    
    % With this operation we enlarge the matrix of the recognized places
    % taking into account some frames of tolerance for the matchings.
    place_recognized_enlarged = zeros(size(results,1));
    for aa = 1:size(place_recognized{j},1)
        for bb = 1:size(place_recognized{j},2)
            if(place_recognized{j}(aa,bb))
                if bb > ds.conf.params.frame_tolerance_enlarged
                    place_recognized_enlarged(aa, bb-ds.conf.params.frame_tolerance_enlarged:min(bb+ds.conf.params.frame_tolerance_enlarged-1, size(results,2))) = ones(1, numel(bb-ds.conf.params.frame_tolerance_enlarged:min(bb+ds.conf.params.frame_tolerance_enlarged-1, size(results,2))));
                    %ones(1, ds.conf.params.frame_tolerance_enlarged*2);
                else
                    place_recognized_enlarged(aa, [1:bb, bb:bb+ds.conf.params.frame_tolerance_enlarged-1]) = ones(1, size([1:bb, bb:bb+ds.conf.params.frame_tolerance_enlarged-1], 2));
                end
            end
        end
    end
    
    tp(j) = 0;
    % tn(j) = 0;
    fp(j) = 0;
    fn(j) = 0;
    
    fp(j) = sum( sum( (place_recognized{j} - truth_enlarged) == 1 ));      % false positives
    
%     fn(j) = sum( sum( (truth_enlarged - place_recognized{j}) == 1 ));      % false negatives

    % this one is a little to exagerated
%     fn(j) = sum( sum( (truth_enlarged - place_recognized_enlarged) == 1 ));      % false negatives

    fn(j) = sum( sum( (truth_unique - place_recognized_enlarged) == 1 ));
    
    tp(j) = sum( sum( (place_recognized{j} & truth_enlarged )));      % true positives
    
    precision(j) = tp(j) / (tp(j)+fp(j));
    
    recall(j) = tp(j) / (tp(j)+fn(j));
    
    j = j + 1;
end


% stats(:,:,1) = [th; tp; fp; fn; precision; recall];

stats.threshold = th;
stats.truePositivesNum = tp;
stats.falsePositivesNum = fp;
stats.falseNegativesNum = fn;
stats.precision = precision;
stats.recall = recall;

T = table;
T.threshold = th';
T.truePositivesNum = tp';
T.falsePositivesNum = fp';
T.falseNegativesNum = fn';
T.precision = precision';
T.recall = recall';
% T

h1 = figure;
plot(recall,precision,'o-'), axis([0 1 0 1]), xlabel('Recall'), ylabel('Precision')

h2 = figure;
plot(recall,precision,'o-'), xlabel('Recall'), ylabel('Precision')

% Select one threshold instance to be used in the plot_matches script
index = indices{236};

if strcmp(filtering_method, 'sequential')
    writetable(T, 'stats_seq.csv');
    saveas(h1, 'pr_curve_seq_1.eps');
    saveas(h2, 'pr_curve_seq_2.eps');
else
    writetable(T, 'stats_th.csv');
    saveas(h1, 'pr_curve_th_1.eps');
    saveas(h2, 'pr_curve_th_2.eps');
end

clear th tp fp fn place_recognized precision recall T

%% other visualization stuff
% figure
% imshow(ans)

% figure
% imshow(place_recognized_enlarged)

% figure
% imagesc(results), colormap default
% 
% figure
% imshow(results)
% 
% %
% figure
% imshow(full(spones(results)))
