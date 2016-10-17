% load the subsalpled version of the memory dataset and also the live
% dataset that is also subsampled following the same procedure based on the
% odometry. If we want a static memory the memorySet contains only the
% images of the first path. Otherwise it already contains all the images
% that will be in the memory at the end of the run.
global ds

%%
ds = yaml.ReadYaml(ds.conf.memory_path);

memorySet = imageSet(ds.data.memory.path);
memorySet = select(memorySet, ds.data.memory.idx);


%%

ds.data.live.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images2';
imgSet = imageSet(ds.data.live.path);

idx_live_end = ds.data.live.idx_live_end;
if(imgSet.Count < idx_live_end)
    idx_live_end = imgSet.Count;
end
idx_live_begin = ds.data.live.idx_live_begin;
if(imgSet.Count > idx_live_begin)
    error('idx_live_begin is bigger than the size of the live dataset');
end

positions_live = load(fullfile(fileparts(ds.data.live.path), 'positions.txt'));
velocity_live = load(fullfile(fileparts(ds.data.live.path), 'velocity.txt'));
orientations_live = load(fullfile(fileparts(ds.data.live.path), 'orientations.txt'));
latitude_live = load(fullfile(fileparts(ds.data.live.path), 'gt_latitude.txt'));
longitude_live = load(fullfile(fileparts(ds.data.live.path), 'gt_longitude.txt'));


prev_acquisition = positions_live(idx_live_begin, 3:4);
prev_orientation = rad2deg(quat2eul(orientations_live(idx_live_begin,3:6)));

for ii = idx_live_begin+1:idx_live_end
    %     if velocity(ii,2) ~= 0
    %
    %     end
    
    current_acquisition = positions_live(ii, 3:4);
    current_orientation = rad2deg(quat2eul(orientations_live(ii, 3:6)));
    
    if norm(current_acquisition - prev_acquisition) >= ds.data.frame_to_frame_diff.position || ...
            sum(abs(current_orientation - prev_orientation) >= ds.data.frame_to_frame_diff.orientation)
        idx_live = [idx_live, ii];
        
        prev_acquisition = current_acquisition;
        prev_orientation = current_orientation;
    end
end

ds.data.live.idx = idx_live;

ds.data.live.positions = positions_live(idx_live,:);
ds.data.live.odometry =  velocity_live(idx_live,:);
ds.data.live.orientations =  orientations_live(idx_live,:);
ds.data.live.latitude =  latitude_live(idx_live,:);
ds.data.live.longitude =  longitude_live(idx_live,:);

%% make a unique vars for mem and live data
positions = [ds.data.memory.positions; ds.data.live.positions];
odometry = [ds.data.memory.odometry; ds.data.live.odometry];
orientations = [ds.data.memory.orientations; ds.data.live.orientations];
latitude = [ds.data.memory.latitude; ds.data.live.latitude];
longitude = [ds.data.memory.longitude; ds.data.live.longitude];



%%
if(~ds.conf.static_mem)
    idx = [ds.data.memory.idx, memorySet.Count+idx_live];
    
    imgFolders = { ds.data.memory.path, ...
                   ds.data.live.path
        };
    
    memorySet = imageSet_mine(imgFolders);
    memorySet = select(memorySet, idx);
end



%% cleaning

clear imgFolders
clear idx_mem idx_live idx
clear positions_mem velocity_mem orientations_mem latitude_mem longitude_mem
clear positions_live velocity_live orientations_live latitude_live longitude_live
