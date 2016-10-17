% ds.data.memory = [];

global ds

[dir, filename] = fileparts(mfilename('fullpath'));

ds.data.memory_path = fullfile(fileparts(dir), 'data');
ds.data.memory_name = datestr(now);
memory.fullname = fullfile(ds.data.memory_path, ds.data.memory_name);

% t = datetime('now')
% t = datestr(now);

if ~exist(memory.fullname, 'dir')
    mkdir(memory.fullname)
end

ds.data.G = [];

yaml.WriteYaml(fullfile(memory.fullname, 'data.yaml'), ds.data, 0, 0);

ds.data = [];
ds.caffe.mean_data = [];
ds.caffe.net = [];
ds.eb.model = [];
ds.results = [];

yaml.WriteYaml(fullfile(memory.fullname, 'config.yaml'), ds, 0, 0);

% yaml_file = 'test.yaml';
% yaml_file = 'test_non_pretty.yaml';
% ds = yaml.ReadYaml(yaml_file);