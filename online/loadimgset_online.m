global ds

% '/home/michele/Documents/master thesis/datasets/alderley/FRAMESB/FRAMESB'
ds.data.imageSkip = 100;
ds.data.live.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images2';
% '/home/michele/Documents/master thesis/datasets/city_centre/Images/Images'
% '/media/michele/SAMSUNG/miche/files/stlucia/101215_153851_MultiCamera0_deb'
% '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/Images'
% '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/Images2'
% '/home/michele/Documents/master thesis/datasets/alderley/FRAMESA/FRAMESA'
% '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images'

imgSet = imageSet(ds.data.live.path);
% idx_live = 1:ds.data.imageSkip:imgSet.Count;
idx_live = 1:ds.data.imageSkip:2000;
% idx_live = 2700:10:3800;     % sunny  second visit of the first loop
% idx_live = 2250:10:3750;     % cloudy  second visit of the first loop
imgSet = select(imgSet,idx_live);
ds.data.live.idx = [idx_live(1), idx_live(end)];

clear idx

%% load odometry
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

%% cleaning

clear idx_mem idx_live 
clear positions_mem velocity_mem orientations_mem latitude_mem longitude_mem
clear positions_live velocity_live orientations_live latitude_live longitude_live
