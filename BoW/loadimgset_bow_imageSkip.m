global ds

ds.data.imageSkip = 10;
ds.data.memory.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images';
ds.data.live.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images';

memorySet = imageSet(ds.data.memory.path);
idx_mem = 1:ds.data.imageSkip:870;     % cloudy  second visit of the first loop
memorySet = select(memorySet, idx_mem);
ds.data.memory.idx = [idx_mem(1), idx_mem(end)];

imgSet = imageSet(ds.data.live.path);
% idx_live = 1:ds.data.imageSkip:imgSet.Count;
idx_live = 1:ds.data.imageSkip:1000;
imgSet = select(imgSet,idx_live);
ds.data.live.idx = [idx_live(1), idx_live(end)];

%% load odometry

positions_mem = load(fullfile(fileparts(ds.data.memory.path), 'positions.txt'));
velocity_mem = load(fullfile(fileparts(ds.data.memory.path), 'velocity.txt'));
orientations_mem = load(fullfile(fileparts(ds.data.memory.path), 'orientations.txt'));
latitude_mem = load(fullfile(fileparts(ds.data.memory.path), 'gt_latitude.txt'));
longitude_mem = load(fullfile(fileparts(ds.data.memory.path), 'gt_longitude.txt'));

ds.data.memory.positions = positions_mem(idx_mem,:);
ds.data.memory.odometry =  velocity_mem(idx_mem,:);
ds.data.memory.orientations =  orientations_mem(idx_mem,:);
ds.data.memory.latitude =  latitude_mem(idx_mem,:);
ds.data.memory.longitude =  longitude_mem(idx_mem,:);


positions_live = load(fullfile(fileparts(ds.data.live.path), 'positions.txt'));
velocity_live = load(fullfile(fileparts(ds.data.live.path), 'velocity.txt'));
orientations_live = load(fullfile(fileparts(ds.data.live.path), 'orientations.txt'));
latitude_live = load(fullfile(fileparts(ds.data.live.path), 'gt_latitude.txt'));
longitude_live = load(fullfile(fileparts(ds.data.live.path), 'gt_longitude.txt'));

ds.data.live.positions = positions_live(idx_live,:);
ds.data.live.odometry =  velocity_live(idx_live,:);
ds.data.live.orientations =  orientations_live(idx_live,:);
ds.data.live.latitude =  latitude_live(idx_live,:);
ds.data.live.longitude =  longitude_live(idx_live,:);


%% make a unique vars for mem and live data
positions = [positions_mem; positions_live];
velocity = [velocity_mem; velocity_live];
orientations = [orientations_mem; orientations_live];
latitude = [latitude_mem; latitude_live];
longitude = [longitude_mem; longitude_live];

idx = [idx_mem, memorySet.Count+idx_live];

positions = positions(idx, :);
velocity = velocity(idx, :);
orientations = orientations(idx, :);
latitude = latitude(idx, :);
longitude = longitude(idx, :);


%%

ds.results.confusionMat = zeros(imgSet.Count, memorySet.Count);


%% cleaning

clear idx_mem idx_live 
clear positions_mem velocity_mem orientations_mem latitude_mem longitude_mem
clear positions_live velocity_live orientations_live latitude_live longitude_live