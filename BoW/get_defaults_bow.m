global ds

% get_defaults();

ds.conf.params.num_patches = 50;
ds.conf.params.t = 1024;
ds.conf.params.th_recognition = 0.03;
ds.conf.params.reRank_num = 0;              % 20 it's good
ds.conf.params.input_caffe = 227;
ds.conf.params.NumResults = 20;
ds.conf.params.Confidence = 99;
ds.conf.params.MaxDistance = 30;
ds.conf.params.d_s = 5;                     % parameter of the sequential filter ??
% visualization config
ds.conf.gpu_id = 0;
ds.conf.bb_plotted = 20;
ds.conf.enable_figures = 0;
% modules config
ds.conf.use_dfts_eb = 0;
ds.conf.use_places_cnn = 0;
% save figure
ds.conf.save_patches = 0;
ds.conf.save_features = 0;
ds.conf.static_mem = 0;             % it says whether at test time the algorithm keeps storing images in the memory
ds.conf.update_statistics = 0;      % it says whether the statistics of the visual words should be updated online

% These params control the procedure of subsampling of the dataset
ds.data.frame_to_frame_diff.position = 1.5;
ds.data.frame_to_frame_diff.orientation = 10;

% These parameters only affects the visualization, ground truth generation
% and pr curves
ds.conf.params.tolerance_enlarged =  20;   % in meters
ds.conf.params.frame_tolerance_enlarged = ceil(ds.conf.params.tolerance_enlarged / ds.data.frame_to_frame_diff.position);
ds.conf.params.tolerance_unique = ds.data.frame_to_frame_diff.position/2;
ds.conf.params.frame_tolerance_unique = ceil(ds.conf.params.tolerance_unique / ds.data.frame_to_frame_diff.position);
% Tolerance on the most recent frames
ds.conf.params.frame_tolerance = 40;  % 30 it's ok   It affect only the plotting online. And the pr curve offline

ds.conf.use_mem = 0;
ds.conf.build_mem = 0;
ds.conf.use_odom = 0;

% Load vocabulary and imageIndex struct
ds.conf.vocab_name = 'bag2_50_words';
ds.conf.imgInd_name = 'imageIndex_50_words';
% ds.conf.vocab_name = 'first_bag';
% ds.conf.imgInd_name = 'first_inverted_index';


ds.results.filtering_method = 'threshold';

if strcmp(ds.results.filtering_method, 'sequential')
    ds.conf.params.matching.ds = 30;    % 30 is good
    ds.conf.params.matching.vmin = 0.8;
    ds.conf.params.matching.vmax = 1.2;
    ds.conf.params.matching.Rwindow = 30;
    ds.conf.params.matching.save = 0;
end

% Edge Boxes configurations ###############################################
% load edge detector model
model = load(fullfile(ds.eb.EBdir,'models/forest/modelBsds')); 
ds.eb.model = model.model;	clear model
ds.eb.model.opts.multiscale = 0; 
ds.eb.model.opts.sharpen = 2; 
ds.eb.model.opts.nThreads = 4;

ds.eb.opts = edgeBoxes;

if(ds.conf.use_dfts_eb)
    ds.eb.opts.alpha = .65;     % step size of sliding window search
    ds.eb.opts.beta  = .75;     % nms threshold for object proposals
    ds.eb.opts.minScore = .01;  % min score of boxes to detect
    ds.eb.opts.maxBoxes = 1e4;  % max number of boxes to detect
    ds.eb.opts.eta = 2;
    ds.eb.opts.edgeMinMag = .1;
    ds.eb.opts.edgeMergeThr = .5;
    ds.eb.opts.clusterMinMag = .5;
    ds.eb.opts.gamma = 2;
    ds.eb.opts.kappa = 1.5;
else
    ds.eb.opts.alpha = .38;     % step size of sliding window search
    ds.eb.opts.beta  = .38;     % nms threshold for object proposals
    ds.eb.opts.minScore = .05;  % min score of boxes to detect
    ds.eb.opts.maxBoxes = 100;  % max number of boxes to detect
    ds.eb.opts.eta = 2;
    ds.eb.opts.edgeMinMag = .1;
    ds.eb.opts.edgeMergeThr = .5;
    ds.eb.opts.clusterMinMag = .5;    % very useful to be changed -- reduce the number of proposals
    ds.eb.opts.gamma = 2;
    ds.eb.opts.kappa = 1.5;
end

% Caffe configuration #####################################################
if(ds.conf.use_places_cnn)
    ds.caffe.model_dir = [ds.caffe.caffe_path '/models/places205/'];
    ds.caffe.net_model = [ds.caffe.model_dir 'places205CNN_deploy.prototxt'];
    ds.caffe.net_weights = [ds.caffe.model_dir 'places205CNN_iter_300000.caffemodel'];
    ds.caffe.phase = 'test'; % run with phase test (so that dropout isn't applied)
    
    d = load(fullfile(caffe_path, 'models/places205/places_mean_227.mat'));
    ds.caffe.mean_data = d.image_mean;  clear d
else
    ds.caffe.model_dir = [ds.caffe.caffe_path '/models/my_model/'];
    ds.caffe.net_model = [ds.caffe.model_dir 'deploy_batch_50_227.prototxt'];
    ds.caffe.net_weights = [ds.caffe.model_dir 'my_model.caffemodel'];
    ds.caffe.phase = 'test'; % run with phase test (so that dropout isn't applied)
    
    d = load(fullfile(ds.caffe.caffe_path, 'matlab/+caffe/imagenet/ilsvrc_2012_mean_227.mat'));
    ds.caffe.mean_data = d.mean_data;   clear d
    % mean_data = uint8(mean_data);
end

% build the caffe net  #################################
ds.caffe.net = caffe.Net(ds.caffe.net_model, ds.caffe.net_weights, ds.caffe.phase);
% make sure we have the right input size at the beginning
ds.caffe.net.blobs('data').reshape([ds.conf.params.input_caffe, ds.conf.params.input_caffe, 3, ds.conf.params.num_patches]);

