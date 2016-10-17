% load just ds.data.memory subsampling the dataset taking odometry into
% account
global ds

ds.data.memory.path = '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images2';
memorySet = imageSet(ds.data.memory.path);

idx_mem_end = ds.data.memory.idx_mem_end;
if(memorySet.Count < idx_mem_end)
    idx_mem_end = memorySet.Count;
end

idx_mem_begin = ds.data.memory.idx_mem_begin;
if(memorySet.Count > idx_mem_begin)
    error('idx_live_begin is bigger than the size of the live dataset');
end


%% load odometry

positions_mem = load(fullfile(fileparts(ds.data.memory.path), 'positions.txt'));
velocity_mem = load(fullfile(fileparts(ds.data.memory.path), 'velocity.txt'));
orientations_mem = load(fullfile(fileparts(ds.data.memory.path), 'orientations.txt'));
latitude_mem = load(fullfile(fileparts(ds.data.memory.path), 'gt_latitude.txt'));
longitude_mem = load(fullfile(fileparts(ds.data.memory.path), 'gt_longitude.txt'));


%% make a unique vars for mem and live data
% if(~ds.conf.build_mem)
%     positions = [positions_mem; positions_live];
%     velocity = [velocity_mem; velocity_live];
%     orientations = [orientations_mem; orientations_live];
%     latitude = [latitude_mem; latitude_live];
%     longitude = [longitude_mem; longitude_live];
%     
%     ds.data.latitude = latitude;
%     ds.data.longitude = longitude;
% end
    


%% subsample the dataset with velocity normalization
ds.data.frame_to_frame_diff.position = 1.5;
ds.data.frame_to_frame_diff.orientation = 10;

idx_mem = [];

% creation of the indices to subsample the datasets
prev_acquisition = positions_mem(idx_mem_begin, 3:4);
prev_orientation = rad2deg(quat2eul(orientations_mem(idx_mem_begin,3:6)));

for ii = idx_mem_begin+1:idx_mem_end
%     if velocity(ii,2) ~= 0
%         
%     end
    
    current_acquisition = positions_mem(ii, 3:4);
    current_orientation = rad2deg(quat2eul(orientations_mem(ii, 3:6)));
    
    if norm(current_acquisition - prev_acquisition) >= ds.data.frame_to_frame_diff.position || ...
            sum(abs(current_orientation - prev_orientation) >= ds.data.frame_to_frame_diff.orientation)
        idx_mem = [idx_mem, ii];
        
        prev_acquisition = current_acquisition;
        prev_orientation = current_orientation;
    end
end

%%

ds.data.memory.idx = idx_mem;
% memorySet = select(memorySet, idx_mem);

ds.data.memory.positions = positions_mem(idx_mem,:);
ds.data.memory.odometry =  velocity_mem(idx_mem,:);
ds.data.memory.orientations =  orientations_mem(idx_mem,:);
ds.data.memory.latitude =  latitude_mem(idx_mem,:);
ds.data.memory.longitude =  longitude_mem(idx_mem,:);

% if(~ds.conf.build_mem)
%     ds.data.live.idx = idx_live;
%     idx = [idx_mem, memorySet.Count+idx_live];
%     imgSet = select(imgSet, idx_live);
%     
%     ds.data.live.positions = positions_live(idx_live,:);
%     ds.data.live.odometry =  velocity_live(idx_live,:);
%     ds.data.live.orientations =  orientations_live(idx_live,:);
%     ds.data.live.latitude =  latitude_live(idx_live,:);
%     ds.data.live.longitude =  longitude_live(idx_live,:);
%     
%     positions = positions(idx, :);
%     velocity = velocity(idx, :);
%     orientations = orientations(idx, :);
%     latitude = latitude(idx, :);
%     longitude = longitude(idx, :);
%     
% end




%% cleaning

clear imgFolders
clear idx_mem idx_live idx
clear positions_mem velocity_mem orientations_mem latitude_mem longitude_mem
clear positions_live velocity_live orientations_live latitude_live longitude_live

