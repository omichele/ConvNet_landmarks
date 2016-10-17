% This code run online and make use of the vocabulary to compute the
% nearest neighborhooring word for every landmark
clear all
close all

%% WARMUP

a = gpuArray(1); clear a       % ensure to avoid problems with CUDA

global ds

run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'startup'));

% edit get_defaults_bow
get_defaults_bow();

% useful to avoid problems with EdgeBoxes
bbs = edgeBoxes(ones(100,100,3), ds.eb.model, ds.eb.opts);

% Paths of the datasets
ds.data.memory.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images2';
ds.data.live.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images2';

% Indices of the datasets
ds.data.memory.idx_mem_begin = 1940;
ds.data.memory.idx_mem_end = 4610;
% ds.data.memory.idx_mem_end = 3350;
ds.data.live.idx_live_begin = 2250;
ds.data.live.idx_live_end = 4630;
% ds.data.live.idx_live_end = 3530;

% if(~ds.conf.use_mem)
% % loadimgset_bow_imageSkip();
%     loadimgset_bow_odom();
% end

%% LOAD FILES ###################################################

% Loading the matrix G for the Gaussian dimensionaly reduction
load G_64896_1024
ds.data.G = G;  clear G

load(ds.conf.vocab_name)


if(ds.conf.use_mem && ds.conf.build_mem)
    error('Error: flags use_mem and build_mem cannot be active at the same time');
end

if(~ds.conf.use_mem && ds.conf.build_mem)
    error('Error: cannot build_mem and do online matching at the same time');
end

if(ds.conf.build_mem)
    loadimgset_bow_odom();

    load(ds.conf.imgInd_name)
    testImageIndex = invertedImageIndex_mine(bag, 'SaveFeatureLocations', true);
    [wordFreq, ImgLoc, numImPerWord, idf] = get_idf_on_bag(imageIndex);
    set_idf_on_bag(testImageIndex, wordFreq, ImgLoc, numImPerWord, idf);
    
end


if(ds.conf.use_mem)
    load testImagesIndex_1_870_cloudy_200_patches_Eb_dft_no_reRank
    loadimgset_bow_on_mem();
else
    % loadimgset_bow_imageSkip();
%     loadimgset_bow_odom();
    loadimgset_mine();
    
    load(ds.conf.imgInd_name)
    testImagesIndex = invertedImageIndex_mine(bag, 'SaveFeatureLocations', true);
    [wordFreq, ImgLoc, numImPerWord, idf] = get_idf_on_bag(imageIndex);
    set_idf_on_bag(testImagesIndex, wordFreq, ImgLoc, numImPerWord, idf);
end

%% INITIALIZATIONS ###########################################
caffe.set_mode_gpu();
caffe.set_device(ds.conf.gpu_id);

% Build the confusion matrix
ds.results.confusionMat = zeros(imgSet.Count, memorySet.Count);

if size(testImagesIndex.WordHistograms, 1) ~= 0
    count = size(testImagesIndex.WordHistograms,1);
else
    count = 1;
end

flag_match = 0;
prev_match_id = 0;


%% MAIN CODE ##############################################
if(ds.conf.build_mem)
    for ii = 1:imgSet.Count
        I = read(imgSet,ii);
        display(['Image number' ': ' num2str(ii)])
        addImages_online(testImagesIndex, I);
    end
    save_results_bow_mem();
else
    do_convNet_bow();
    make_ground_truth();
    save_results();
end

%% ground truth creation
% make_ground_truth();
% 
%% Print results ###########################################
% save_results_bow();
