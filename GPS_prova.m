% code for generating ground truth and plot gps on google maps

addpath '/media/michele/Data/miche/file temporanei/MATLAB/GPS2Cart'
% addpath '/media/michele/Data/miche/file
% temporanei/MATLAB/plot_google_map'

load '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/gt_longitude.txt'
load '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/gt_latitude.txt'

load '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/map.mat'
load '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/latVec.mat'
load '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/lonVec.mat'

lat = gt_latitude(:,3);
lon = gt_longitude(:,3);

% transform lat and lon in meters
[x_coord, y_coord, lat_origin, long_origin] = GPS2Cart(lat, lon);

figure(5)
plot(x_coord, y_coord, '.b', 'MarkerSize', 20)
ylabel({'$y$ [metres]'}, 'interpreter', 'latex', 'FontSize', 20)
xlabel({'$x$ [metres]'}, 'interpreter', 'latex', 'FontSize', 20)
axis equal
axis([0 max(x_coord) 0 max(y_coord)])

%% ground truth generation
gt = zeros(size(gt_latitude,1));

tollerance = 30;
% make the ground truth
for ii = tollerance+1:size(gt_latitude,1)
    % checking all the indexes of reading that mathes the current one +- 10 meter
    % Of course this match will include the diagonal and around it
    ind = x_coord <= x_coord(ii)+tollerance & x_coord >= x_coord(ii)-tollerance &...
          y_coord <= y_coord(ii)+tollerance & y_coord >= y_coord(ii)-tollerance;
    
    gt(ii,ind) = 1;
end

% figure;
% imshow(gt);

% zeroing the upper-right part of the confusion matrix
for ii = 1:size(gt_latitude,1)
    for jj = 1:size(gt_latitude,1)
        if ii < jj
            gt(ii,jj) = 0;
        end
    end
end

% figure; 
% imshow(gt);

% zeroing the diagonal and its neighborhood
for ii = 1:size(gt_latitude,1)
    for jj = 1:size(gt_latitude,1)
        if ii == jj
            if jj ~= 1
                if jj < tollerance +1
                    ind = jj-1;
                    gt(ii,jj-ind:jj) = zeros(1,ind+1);
                else
                    ind = tollerance;
                    gt(ii,jj-ind:jj) = zeros(1,ind+1);
                end
            end
        end
    end
end

figure; 
imshow(gt);


%% plot gps readings
% lat = gt_latitude(1,2);    
% lon = gt_longitude(1,2);

% figure(1)
% plot(lon, lat, '.r', 'MarkerSize', 10)      % print the points and at the same time set the size of the plot so plot_google_map knows what to display
% axis([-1.557  -1.542  47.213   47.225])
% plot_google_map
% hold on


% ax = gca; % current axes
% ax.XLim = [-1.557  -1.542];
% ax.YLim = [47.213   47.225];

% download the image to be stored
% [lonVec, latVec, imag] = plot_google_map('axis', ax, 'height', 640, 'width', 640);

figure(1)
imshow(imag)

% !!!!!!!!!!!  normal way of emplying a google map already downloaded
ax = gca; % current axes
ax.XLim = [-1.557  -1.542];
ax.YLim = [47.213   47.225];
hold(ax, 'on');
cax = caxis;
h = image(lonVec, latVec, imag, 'Parent', ax);
caxis(cax); % Preserve caxis that is sometimes changed by the call to image()
set(ax, 'YDir', 'Normal')
set(h, 'tag', 'gmap')
% set(h,'AlphaData', alphaData)   % add transparency --> it does not work

% !!!!!!!!!!!!!! very important - plot on a subimage
% h1 = subplot(1,2,1);
% ax = gca; % current axes
% ax.XLim = [-1.557  -1.542];
% ax.YLim = [47.213   47.225];
% hold(ax, 'on');
% cax = caxis;
% h2 = subimage(lonVec, latVec, imag);
% set(ax,'YDir','Normal')
% set(h2,'tag','gmap')

    

% plot upon the existing figure
for i = 1:2:size(gt_latitude,1)
    
    lat = gt_latitude(i,3);
    
    lon = gt_longitude(i,3);
    
%     figure(1)
    plot(lon, lat, '.r', 'MarkerSize', 10)
    
    drawnow
end
