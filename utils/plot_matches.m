function plot_matches(index)

global ds

% ds.data = yaml.ReadYaml('data.yaml');
idx = dlmread('idx.txt');

% useful to avoid problems with Edge Boxes
bbs = edgeBoxes(ones(100,100,3), ds.eb.model, ds.eb.opts);

imgFolders = { ds.data.memory.path, ...
               ds.data.live.path
              };
          
memorySet = imageSet(ds.data.memory.path);
          
% creation of a unique dataset
imgSet = imageSet_mine(imgFolders);

% idx = [cell2mat(ds.data.memory.idx), memorySet.Count+cell2mat(ds.data.live.idx)];
imgSet = select(imgSet, idx);
memorySet = imgSet;

clear memorySet

rows = find(index);

for ii = 1:numel(rows)
    if rows(ii) < size(index,1)
        matches_ind(ii,:) = [rows(ii), index(rows(ii),1)];
    end
end

% for ii = 1:numel(rows)
%     matches(ii,:) = [rows(ii), index(rows(ii),1)];
% end

figure
for ii = 1:size(matches_ind,1)
    display(ii);
    imshow([read(imgSet, matches_ind(ii,1)), read(imgSet, matches_ind(ii,2))])
    drawnow
    waitforbuttonpress;
end


%% replay all the dataset highlighting the matches

for ii = 1:imgSet.Count
    I = read(imgSet,ii);
    
    figure(1)
    subplot_tight(1,2,1, [0.01, 0.01])
%     subplot(1,2,1)
    title(['Image Number: ', sprintf('%d', ii)]);
    imshow(I)
    
    if index(ii,1) ~= 0
        subplot_tight(1,2,2, [0.01, 0.01])
%         subplot(1,2,2)
        title(['Image Number: ', sprintf('%d', index(ii,1))]);
        imshow(read(imgSet, index(ii,1)));
%         waitforbuttonpress;
        pause(1);
    end
    
    drawnow
    
    if ii == 1
        waitforbuttonpress;
    end
        
end


%%
get_defaults_bow();
load G_64896_1024
ds.data.G = G;  clear G
ds.conf.vocab_name = 'bag2_50_words';
ds.conf.imgInd_name = 'imageIndex_50_words';
load(ds.conf.vocab_name)
load(ds.conf.imgInd_name)
match_num = 5;
testImagesIndex = invertedImageIndex_mine(bag, 'SaveFeatureLocations', true);
[wordFreq, ImgLoc, numImPerWord, idf] = get_idf_on_bag(imageIndex);
set_idf_on_bag(testImagesIndex, wordFreq, ImgLoc, numImPerWord, idf);

I = read(imgSet, matches_ind(match_num, 1));
addImages_online(testImagesIndex, I);

ds.conf.enable_figures = 0;
I = read(imgSet, matches_ind(match_num, 2));
[imageIDs, scores, queryWords, dimensions, dist] = retrieveImages_mine(I, testImagesIndex, 'NumResults', ds.conf.params.NumResults);
do_crosschk_reRank_bow();
showMatchedFeatures(read(imgSet, matches_ind(match_num, 1)), I, inlierPoints1, inlierPoints2, 'montage')

clear testImagesIndex

%%
get_defaults_convNet();
load G_64896_1024
ds.data.G = G;  clear G

match_num = 55;

I = read(imgSet, matches_ind(match_num, 1));
[X, ~, centers, dimensions] = ConvNet_eb_feature_extractor_warp(I);

dimensions_to_save = dimensions;
centers_to_save = centers;

memory{1,1} = X;
memory{1,2} = dimensions_to_save;
memory{1,3} = centers_to_save;

I = read(imgSet, matches_ind(match_num, 2));
[X, ~, centers, dimensions] = ConvNet_eb_feature_extractor_warp(I);
do_crosschk_reRank();
showMatchedFeatures(read(imgSet, matches_ind(match_num, 1)), I, inlierPoints1, inlierPoints2, 'montage')