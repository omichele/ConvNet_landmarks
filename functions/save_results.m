% this script is charged with the task of saving all the information contained in the ds variable to a destination folder.
% ds.data.memory = [];

global ds

results = ds.results;
ds.results = [];

[dir, filename] = fileparts(mfilename('fullpath'));

% Create a folder in the results folder to contain the current experiment
% outcomes
ds.results.path = fullfile(fileparts(fileparts(dir)), 'results');
% Nme this older with the current date and time
ds.results.experiment = datestr(now);
results.fullname = fullfile(ds.results.path, ds.results.experiment);

% t = datetime('now')
% t = datestr(now);

% Create the folder if it does not exists
if ~exist(results.fullname, 'dir')
    mkdir(results.fullname)
end


% Saving stuff contained in the ds variable to the destination folder 
save(fullfile(results.fullname, 'confusionMat.txt'), '-struct', 'results', 'confusionMat', '-ascii','-double','-tabs');

data = ds.data;
save(fullfile(results.fullname, 'gt_enlarged.txt'), '-struct', 'data', 'gt_enlarged', '-ascii','-double','-tabs');
save(fullfile(results.fullname, 'gt_unique.txt'), '-struct', 'data', 'gt_unique', '-ascii','-double','-tabs');

yaml.WriteYaml(fullfile(results.fullname, 'timing.yaml'), results.time, 0, 0);

ds.data.G = [];
ds.data.gt_enlarged = [];
ds.data.gt_unique = [];

save(fullfile(results.fullname, 'idx.txt'), '-struct', 'data', 'idx', '-ascii','-double','-tabs');

yaml.WriteYaml(fullfile(results.fullname, 'data.yaml'), ds.data, 0, 0);

ds.data = [];
ds.caffe.mean_data = [];
ds.caffe.net = [];
ds.eb.model = [];

yaml.WriteYaml(fullfile(results.fullname, 'config.yaml'), ds, 0, 0);

if exist('testImagesIndex', 'var')
    save(fullfile(results.fullname, 'testImagesIndex'), 'testImagesIndex');
end

% yaml_file = 'test.yaml';
% yaml_file = 'test_non_pretty.yaml';
% ds = yaml.ReadYaml(yaml_file);