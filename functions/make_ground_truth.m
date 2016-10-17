global ds

% load the a local map of the dataset location along with the reference to
% its scale and position in the world
load '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/map.mat'
load '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/latVec.mat'
load '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/lonVec.mat'

% if isempty(ds.data)
% ds.data = yaml.ReadYaml('data.yaml');
% positions = [ds.data.memory.positions; ds.data.live.positions];
% odometry = [ds.data.memory.odometry; ds.data.live.odometry];
% orientations = [ds.data.memory.orientations; ds.data.live.orientations];
% latitude = [ds.data.memory.latitude; ds.data.live.latitude];
% longitude = [ds.data.memory.longitude; ds.data.live.longitude];

% positions = cell2mat(positions);
% odometry = cell2mat(odometry);
% orientations = cell2mat(orientations);
% latitude = cell2mat(latitude);
% longitude = cell2mat(longitude);

lat = latitude(:,3);
lon = longitude(:,3);
% 
% lat = ds.data.latitude(:,3);
% lon = ds.data.longitude(:,3);

% transform lat and lon in meters
[x_coord, y_coord, lat_origin, long_origin] = GPS2Cart(lat, lon);

% plot the travelled path on the Google map
figure(5)
plot(x_coord, y_coord, '.b', 'MarkerSize', 20)
ylabel({'$y$ [metres]'}, 'interpreter', 'latex', 'FontSize', 20)
xlabel({'$x$ [metres]'}, 'interpreter', 'latex', 'FontSize', 20)
axis equal
axis([0 max(x_coord) 0 max(y_coord)])


%% ground truth generation
gt_enlarged = zeros(size(lat,1));

% make the ground truth
% for ii = ds.conf.params.tolerance+1:size(latitude,1)
%     % checking all the indexes of reading that mathes the current one +- 10 meter
%     % Of course this match will include the diagonal and around it
%     ind = x_coord <= x_coord(ii)+ds.conf.params.tolerance & x_coord >= x_coord(ii)-ds.conf.params.tolerance &...
%           y_coord <= y_coord(ii)+ds.conf.params.tolerance & y_coord >= y_coord(ii)-ds.conf.params.tolerance;
%     
%     gt(ii,ind) = 1;
% end

tolerance = ds.conf.params.tolerance_enlarged; % 10 metri di tolleranza
for ii = 1:size(lat,1)
    % checking all the indexes of reading that mathes the current one +- 10 meter
    % Of course this match will include the diagonal and around it
    [~, ind] = sort(sum([x_coord - x_coord(ii), y_coord - y_coord(ii)].^2, 2).^(1/2));
    
    mask = x_coord(ind) <= x_coord(ii)+tolerance & x_coord(ind) > x_coord(ii)-tolerance &...
          y_coord(ind) <= y_coord(ii)+tolerance & y_coord(ind) > y_coord(ii)-tolerance;
    matches_enlarged = ind(mask);
    gt_enlarged(ii,ind(mask)) = 1;
end

% figure;
% imshow(gt);

% zeroing the upper-right part of the confusion matrix
for ii = 1:size(lat,1)
    for jj = 1:size(lat,1)
        if ii < jj
            gt_enlarged(ii,jj) = 0;
        end
    end
end

% figure; 
% imshow(gt);

% the tolerance value is expressed in meters. The frame_tolerance is and
% expession of this tolerance in number of frames
frame_tolerance = ds.conf.params.frame_tolerance_enlarged;
% In the following it is used the value of frame_tolerance*2 to cut the
% matches that are too close in time.
% zeroing the diagonal and its neighborhood
for ii = 1:size(latitude,1)
    for jj = 1:size(latitude,1)
        if ii == jj
            if jj ~= 1
                if jj < frame_tolerance*2 +1
                    ind = jj-1;
                    gt_enlarged(ii,jj-ind:jj) = zeros(1,ind+1);
                else
                    ind = frame_tolerance*2;
                    gt_enlarged(ii,jj-ind:jj) = zeros(1,ind+1);
                end
            end
        end
    end
end

% for ii = 1:size(lat,1)
%     for jj = 1:size(lat,1)
%         if ii == jj
%             gt(ii,jj) = 0;
%             
%         end
%     end
% end


figure; 
imshow(gt_enlarged);

ds.data.gt_enlarged = gt_enlarged;
ds.data.matches_enlarged = matches_enlarged;

truth_enlarged = gt_enlarged;


%% ground truth generation unique
gt_unique = zeros(size(lat,1));

% make the ground truth
% for ii = ds.conf.params.tolerance+1:size(latitude,1)
%     % checking all the indexes of reading that mathes the current one +- 10 meter
%     % Of course this match will include the diagonal and around it
%     ind = x_coord <= x_coord(ii)+ds.conf.params.tolerance & x_coord >= x_coord(ii)-ds.conf.params.tolerance &...
%           y_coord <= y_coord(ii)+ds.conf.params.tolerance & y_coord >= y_coord(ii)-ds.conf.params.tolerance;
%     
%     gt(ii,ind) = 1;
% end

% in this case we should have one match per image
tolerance = ds.conf.params.tolerance_unique; % 10 metri di tolleranza
for ii = 1:size(lat,1)
    % checking all the indexes of reading that mathes the current one +- 10 meter
    % Of course this match will include the diagonal and around it
    [~, ind] = sort(sum([x_coord - x_coord(ii), y_coord - y_coord(ii)].^2, 2).^(1/2));
    
    mask = x_coord(ind) <= x_coord(ii)+tolerance & x_coord(ind) > x_coord(ii)-tolerance &...
          y_coord(ind) <= y_coord(ii)+tolerance & y_coord(ind) > y_coord(ii)-tolerance;
    matches_unique = ind(mask);
    gt_unique(ii,ind(mask)) = 1;
end

% figure;
% imshow(gt);

% zeroing the upper-right part of the confusion matrix
for ii = 1:size(lat,1)
    for jj = 1:size(lat,1)
        if ii < jj
            gt_unique(ii,jj) = 0;
        end
    end
end

% figure; 
% imshow(gt);

% the tolerance value is expressed in meters. The frame_tolerance is and
% expession of this tolerance in number of frames
frame_tolerance = ds.conf.params.frame_tolerance_unique;
% In the following it is used the value of frame_tolerance*2 to cut the
% matches that are too close in time.
% zeroing the diagonal and its neighborhood
for ii = 1:size(latitude,1)
    for jj = 1:size(latitude,1)
        if ii == jj
            if jj ~= 1
                if jj < frame_tolerance*2 +1
                    ind = jj-1;
                    gt_unique(ii,jj-ind:jj) = zeros(1,ind+1);
                else
                    ind = frame_tolerance*2;
                    gt_unique(ii,jj-ind:jj) = zeros(1,ind+1);
                end
            end
        end
    end
end

% for ii = 1:size(lat,1)
%     for jj = 1:size(lat,1)
%         if ii == jj
%             gt(ii,jj) = 0;
%             
%         end
%     end
% end


figure; 
imshow(gt_unique);

ds.data.gt_unique = gt_unique;
ds.data.matches_unique = matches_unique;

truth_unique = gt_unique;

