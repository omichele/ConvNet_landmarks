% startup() - It prepares the environment for the execution of the algorithm by including the necessary folders to the search path.
global ds

ds.curdir = fileparts(mfilename('fullpath'));
addpath(ds.curdir);
addpath(genpath(fullfile(ds.curdir, 'online')));
addpath(genpath(fullfile(ds.curdir, 'utils')));
addpath(genpath(fullfile(ds.curdir, 'data')));
addpath(genpath(fullfile(ds.curdir, 'functions')));
addpath(genpath(fullfile(ds.curdir, 'BoW')));

% Locations of the submodules Caffe and EdgeBoxes
ds.caffe.caffe_path = '/media/michele/Data/miche/file temporanei/DOCUMENTI MIEI/lavori università/robotics/master thesis/softwares/caffe-master';
ds.eb.EBdir = '/media/michele/Data/miche/file temporanei/DOCUMENTI MIEI/lavori università/robotics/master thesis/softwares/edges-master';
ds.eb.toolbox_path = '/media/michele/Data/miche/file temporanei/DOCUMENTI MIEI/lavori università/robotics/master thesis/softwares/toolbox-master';

addpath(genpath(ds.caffe.caffe_path));
addpath(genpath(ds.eb.EBdir));
addpath(genpath(ds.eb.toolbox_path));

% Include other useful packages
addpath('/media/michele/Data/miche/file temporanei/MATLAB/subplot_tight');
addpath('/media/michele/Data/miche/file temporanei/MATLAB/GPS2Cart');
addpath('/media/michele/Data/miche/file temporanei/MATLAB/yamlmatlab');
