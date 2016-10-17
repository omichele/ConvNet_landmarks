% This script is used to check 

clear all
close all

a = gpuArray(1); clear a       % ensure to avoid problems with CUDA

global ds

run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'startup'));

get_defaults_bow();

edgeBoxes(ones(100,100,3), ds.eb.model, ds.eb.opts);

ds.data.memory.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images2';
ds.data.live.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images2';

ds.data.memory.idx_mem_begin = 1940;
% ds.data.memory.idx_mem_end = 4610;
ds.data.memory.idx_mem_end = 3350;
ds.data.live.idx_live_begin = 2250;
% ds.data.live.idx_live_end = 4630;
ds.data.live.idx_live_end = 3530;

loadimgset_mine();

% LOAD FILES ###################################################
load G_64896_1024
ds.data.G = G;  clear G

ds.conf.update_statistics = 0;

% load first_bag
% load first_inverted_index
load bag2_50_words
load imageIndex_50_words
testImagesIndex = invertedImageIndex_mine(bag, 'SaveFeatureLocations', true);
[wordFreq, ImgLoc, numImPerWord, idf] = get_idf_on_bag(imageIndex);
set_idf_on_bag(testImagesIndex, wordFreq, ImgLoc, numImPerWord, idf);

% INITIALIZATIONS ##############################################
caffe.set_mode_gpu();
caffe.set_device(ds.conf.gpu_id);

ds.conf.save_patches = 1;
ds.conf.save_features = 1;
ds.conf.enable_figures = 0;

ds.results.saved_patches = {};
ds.results.saved_features = {};
% 
% figure(1)
% hold on

%%

for ii = 1:imgSet.Count
    I = read(imgSet,ii);
    
    %     subplot(2,1,1)
    %     imshow(I)
    
    display(['Image number' ': ' num2str(ii)])
    
    
    addImages_online(testImagesIndex, I);
    
end


%%

for jj = 1:size(testImagesIndex.ImageWords,1)
    
    if jj == 1
            features_map = {testImagesIndex.ImageWords(jj,1).WordIndex};
    else
            features_map = [features_map, {testImagesIndex.ImageWords(jj,1).WordIndex}]; % 50 x # images
    end
    
end


%% visualize the patches corresponding to a same codeword

% imageIndex = testImagesIndex;

h = sum(full(testImagesIndex.WordHistograms), 1);

% reorder the histogram in descending order. Most common features should be at
% the top.
[B, ind1] = sort(h, 'descend');

% cut the zero elements
B = nonzeros(B);

num_codewords = 50;
for kk = 1:num_codewords
    for mm = 1:size(features_map, 2)
        ind_features{1, mm, kk} = find(features_map{1, mm} == ind1(kk));
    end
end

% visualize chosen cluster. Cluster cannot be greater than num_words
% obviously
% the variable patches_to_show contain all the patches belonging to a
% particular cluster

% a = 1:10;
% clusters = 1:10:100;
% clusters = 1:48;
clusters = 23;
for c_num = clusters
    patches_to_show = {};
    for mm = 1:size(features_map, 2)
        tmp = ds.results.saved_patches{1, mm};
        if ~isempty(ind_features{1, mm, c_num})
            patches_to_show = [patches_to_show, tmp(ind_features{1, mm, c_num}, 1)'];
        end
        
    end
    
    % % visualize not resized patches
    % for oo = 1:10
    %     figure
    %     imshow(patches_to_show{oo});
    % end
    
    % visualize the selected number of pathces belonging to the same cluster
    % It also resize them to fit the montage
%     num_patches_to_show = 72;
    num_patches_to_show = 200;
    if num_patches_to_show > size(patches_to_show, 2)
        num_patches_to_show = size(patches_to_show, 2);
    end
    for oo = 1:num_patches_to_show
        images(:,:,:,oo) = imresize(patches_to_show{oo}, [227 227], 'bilinear');
    end
    
    h = figure;
    montage(images);
    clear images patches_to_show
%     saveas(h,sprintf('codewords_cluster_%d.jpg',c_num))
    % montage(images, 'Size', [2 5])
end