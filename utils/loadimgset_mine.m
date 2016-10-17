% load memory and live at the same time and subsample them according to the
% odometry

global ds

imgFolders = { ds.data.memory.path, ...
               ds.data.live.path
              };
          
% they will be used for the subsampling using odometry
memorySet = imageSet(ds.data.memory.path);
imgSet = imageSet(ds.data.live.path);

% avoid impossible indices
idx_mem_end = ds.data.memory.idx_mem_end;
if(memorySet.Count < idx_mem_end)
    idx_mem_end = memorySet.Count;
end
idx_mem_begin = ds.data.memory.idx_mem_begin;
if(memorySet.Count < idx_mem_begin)
    error('idx_mem_begin is bigger than the size of the memory dataset');
end
idx_live_end = ds.data.live.idx_live_end;
if(imgSet.Count < idx_live_end)
    idx_live_end = imgSet.Count;
end
idx_live_begin = ds.data.live.idx_live_begin;
if(imgSet.Count < idx_live_begin)
    error('idx_live_begin is bigger than the size of the live dataset');
end


%% load odometry files for memory and live datasets
positions_mem = load(fullfile(fileparts(ds.data.memory.path), 'positions.txt'));
velocity_mem = load(fullfile(fileparts(ds.data.memory.path), 'velocity.txt'));
orientations_mem = load(fullfile(fileparts(ds.data.memory.path), 'orientations.txt'));
latitude_mem = load(fullfile(fileparts(ds.data.memory.path), 'gt_latitude.txt'));
longitude_mem = load(fullfile(fileparts(ds.data.memory.path), 'gt_longitude.txt'));


positions_live = load(fullfile(fileparts(ds.data.live.path), 'positions.txt'));
velocity_live = load(fullfile(fileparts(ds.data.live.path), 'velocity.txt'));
orientations_live = load(fullfile(fileparts(ds.data.live.path), 'orientations.txt'));
latitude_live = load(fullfile(fileparts(ds.data.live.path), 'gt_latitude.txt'));
longitude_live = load(fullfile(fileparts(ds.data.live.path), 'gt_longitude.txt'));


%% make a unique vars for mem and live data
% positions = [positions_mem; positions_live];
% velocity = [velocity_mem; velocity_live];
% orientations = [orientations_mem; orientations_live];
% latitude = [latitude_mem; latitude_live];
% longitude = [longitude_mem; longitude_live];


%% subsample the dataset with velocity normalization
idx_mem = [];
idx_live = [];

% Subsample the memory dataset

% creation of the indices to subsample the datasets
prev_acquisition = positions_mem(idx_mem_begin, 3:4);
prev_orientation = rad2deg(quat2eul(orientations_mem(idx_mem_begin, 3:6)));

for ii = idx_mem_begin+1:idx_mem_end
    
    current_acquisition = positions_mem(ii, 3:4);
    current_orientation = rad2deg(quat2eul(orientations_mem(ii, 3:6)));
    
    % We check that consecutive images are sufficienlty distant one to
    % another
    if norm(current_acquisition - prev_acquisition) >= ds.data.frame_to_frame_diff.position || ...
            sum(abs(current_orientation - prev_orientation) >= ds.data.frame_to_frame_diff.orientation)
        idx_mem = [idx_mem, ii];
        
        prev_acquisition = current_acquisition;
        prev_orientation = current_orientation;
    end
end

% Subsample the memory dataset

prev_acquisition = positions_live(idx_live_begin, 3:4);
prev_orientation = rad2deg(quat2eul(orientations_live(idx_live_begin,3:6)));

for ii = idx_live_begin+1:idx_live_end
    
    current_acquisition = positions_live(ii, 3:4);
    current_orientation = rad2deg(quat2eul(orientations_live(ii, 3:6)));
    % We check that consecutive images are sufficienlty distant one to
    % another
    if norm(current_acquisition - prev_acquisition) >= ds.data.frame_to_frame_diff.position || ...
            sum(abs(current_orientation - prev_orientation) >= ds.data.frame_to_frame_diff.orientation)
        idx_live = [idx_live, ii];
        
        prev_acquisition = current_acquisition;
        prev_orientation = current_orientation;
    end
end

% creation of a unique dataset
imgSet = imageSet_mine(imgFolders);

%% test normal imageSet

% for ii = 1:imgSet.Count
%     I = read(imgSet,ii);
%     
%     figure(1)
%     subplot_tight(3,1,1, [0.01, 0.01])
%     imshow(I)
%     
%     subplot_tight(3,1,2, [0.01, 0.01])
%     hold on
%     plot(positions(ii,3), positions(ii,4), '.r', 'MarkerSize', 10)
%     
%     subplot_tight(3,1,3, [0.01, 0.01])
%     plot(1:ii, velocity(1:ii, 3)')
%     
%     drawnow
%     
% end

%% load the results of the subsampling to the ds variable and clean

ds.data.memory.positions = positions_mem(idx_mem,:);
ds.data.memory.odometry =  velocity_mem(idx_mem,:);
ds.data.memory.orientations =  orientations_mem(idx_mem,:);
ds.data.memory.latitude =  latitude_mem(idx_mem,:);
ds.data.memory.longitude =  longitude_mem(idx_mem,:);

ds.data.live.positions = positions_live(idx_live,:);
ds.data.live.odometry =  velocity_live(idx_live,:);
ds.data.live.orientations =  orientations_live(idx_live,:);
ds.data.live.latitude =  latitude_live(idx_live,:);
ds.data.live.longitude =  longitude_live(idx_live,:);


ds.data.memory.idx = idx_mem;
ds.data.live.idx = idx_live;

idx = [idx_mem, memorySet.Count+idx_live];

ds.data.idx = idx;

% in the online case memory and live sets are the same
imgSet = select(imgSet, idx);
memorySet = imgSet;

% positions = positions(idx, :);
% velocity = velocity(idx, :);
% orientations = orientations(idx, :);
% latitude = latitude(idx, :);
% longitude = longitude(idx, :);

% These are local variables used during the algorithms.
positions = [ds.data.memory.positions; ds.data.live.positions];
velocity = [ds.data.memory.odometry; ds.data.live.odometry];
orientations = [ds.data.memory.orientations; ds.data.live.orientations];
latitude = [ds.data.memory.latitude; ds.data.live.latitude];
longitude = [ds.data.memory.longitude; ds.data.live.longitude];


%% cleaning
clear imgFolders
clear idx_mem idx_live idx
clear positions_mem velocity_mem orientations_mem latitude_mem longitude_mem
clear positions_live velocity_live orientations_live latitude_live longitude_live
% clear positions orientations velocity latitude longitude
clear positions orientations velocity
clear idx_live*
clear idx_mem*
clear current_acquisition current_orientation prev_orientation prev_acquisition

%% test results of subsampling

% for ii = 1:imgSet.Count
%     I = read(imgSet,ii);
%     
%     figure(1)
%     subplot_tight(3,1,1, [0.01, 0.01])
%     imshow(I)
%     
%     subplot_tight(3,1,2, [0.01, 0.01])
%     hold on
%     plot(positions(ii,3), positions(ii,4), '.r', 'MarkerSize', 10)
%     
%     subplot_tight(3,1,3, [0.01, 0.01])
%     plot(1:ii, velocity(1:ii, 3)')
%     
%     drawnow
%     
% end


