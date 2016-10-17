% This code run online and make use of the vocabulary to compute the
% nearest neighborhooring word for every landmark
clear all
close all
clc

%% WARMUP

a = gpuArray(1); clear a       % ensure to avoid problems with CUDA

global ds

run(fullfile(fileparts(fileparts(mfilename('fullpath'))), 'startup'));

% get_defaults_online();
get_defaults_convNet();

% useful to avoid problems with Edge Boxes
bbs = edgeBoxes(ones(100,100,3), ds.eb.model, ds.eb.opts);

% loadimgset_online();

%% LOAD FILES ###################################################
load G_64896_1024
ds.data.G = G;  clear G

ds.data.memory.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images2';
ds.data.live.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images2';

ds.data.memory.idx_mem_begin = 1940;
ds.data.memory.idx_mem_end = 4610;
% ds.data.memory.idx_mem_end = 3350;
ds.data.live.idx_live_begin = 2250;
ds.data.live.idx_live_end = 4630;
% ds.data.live.idx_live_end = 3530;

loadimgset_mine();

% ds.data.memory.path = '/home/michele/Documents/master thesis/datasets/alderley/FRAMESA/FRAMESA';
% ds.data.live.path = '/home/michele/Documents/master thesis/datasets/alderley/FRAMESB/FRAMESB';
% addpath('/home/michele/Documents/master thesis/datasets/alderley');
% load fm.mat
% make_gt_matrix();
% 
% ds.data.memory.idx_mem_begin = 1;
% ds.data.memory.idx_mem_end = 5000;
% ds.data.live.idx_live_begin = 1;
% ds.data.live.idx_live_end = 5000;

% loadimgset_imageSkip();


%% INITIALIZATIONS ###########################################
caffe.set_mode_gpu();
caffe.set_device(ds.conf.gpu_id);

ds.results.confusionMat = zeros(imgSet.Count, memorySet.Count);
confusionMat_diag_cut = zeros(imgSet.Count, memorySet.Count);

memory = {};

count = 1;

flag_match = 0;
prev_match_id = 0;


%% MAIN CODE ###########################################
do_convNet_postRank_online();

%% ground truth creation
make_ground_truth();

%% Print results ###########################################
% save_results_online();
save_results();
