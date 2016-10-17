% ds.data.memory = [];

global ds

ds.data.G = [];

ds.caffe.mean_data = [];

ds.caffe.net = [];

ds.eb.model = [];

results = ds.results;
ds.results = [];

[dir, filename] = fileparts(mfilename('fullpath'));

ds.results.path = fullfile(fileparts(fileparts(dir)),'results');
ds.results.experiment = datestr(now);
results.fullname = fullfile(ds.results.path, ds.results.experiment);

% t = datetime('now')
% t = datestr(now);

if ~exist(results.fullname, 'dir')
    mkdir(results.fullname)
end
 
save(fullfile(results.fullname, 'confusionMat.txt'), '-struct', 'results', 'confusionMat', '-ascii','-double','-tabs');

yaml.WriteYaml(fullfile(results.fullname, 'timing.yaml'), results.time, 0, 0);

ds.data.G = [];

yaml.WriteYaml(fullfile(results.fullname, 'data.yaml'), ds.data, 0, 0);

ds.caffe.mean_data = [];

ds.caffe.net = [];

ds.eb.model = [];

ds.results = [];

yaml.WriteYaml(fullfile(results.fullname, 'config.yaml'), ds, 0, 0);

% yaml_file = 'test.yaml';
% yaml_file = 'test_non_pretty.yaml';
% ds = yaml.ReadYaml(yaml_file);