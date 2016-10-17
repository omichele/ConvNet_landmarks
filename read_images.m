% I = imread('peppers.png');
% I = imread('D:\miche\file temporanei\MATLAB\CV\left_#290.bmp');
% I = imread('D:\miche\file temporanei\MATLAB\CV\frame0250.jpg');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\VPRiCE-dataset\VPRiCE-dataset\live\image-03006.png');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\GardensPointWalking\day_left\Image120.jpg');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\PASCAL VOC\VOCdevkit\VOC2007\JPEGImages\000006.jpg');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\alderley\FRAMESB\FRAMESB\Image00001.jpg');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\alderley\FRAMESA\FRAMESA\Image00050.jpg');


% I = imread('/media/michele/Data/miche/file temporanei/DOCUMENTI MIEI/lavori università/robotics/master thesis/datasets/GardensPointWalking/day_left/Image100.jpg');
% I = imread('/home/michele/Documents/master thesis/datasets/alderley/FRAMESA/FRAMESA/Image00001.jpg');
% I = imread('/media/michele/SAMSUNG/miche/files/stlucia/Data/101215_153851_MultiCamera0/cam0_image00004.bmp');

%
% filename = sprintf('image%03d.jpeg', K);
%
% load cellsequence
% implay(cellsequence,10);

%% example visualization + debayering

 imgSet = imageSet('/media/michele/SAMSUNG/miche/files/stlucia/Data/101215_153851_MultiCamera0');
%imgSet = imageSet('/home/michele/Documents/master thesis/datasets/city_centre/Images/Images');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/new_college/Images');

% Imgs = dir(['/media/michele/SAMSUNG/miche/files/stlucia/Data/101215_153851_MultiCamera0/' 'cam0_image*.bmp']);
% Imgs = dir(['G:\miche\files\stlucia\101215_153851_MultiCamera0_deb\' 'cam0_image*.bmp']);


NumImgs = size(Imgs,1);

for i=1:NumImgs
    
%     I = imread(['/media/michele/SAMSUNG/miche/files/stlucia/Data/101215_153851_MultiCamera0/' Imgs(i).name]);
    
    I = imread(['G:\miche\files\stlucia\101215_153851_MultiCamera0_deb\' Imgs(i).name]);

%     RGB = demosaic(I,'gbrg');
    % 'gbrg'   it works!!!!!!
    % 'grbg'
    % 'bggr'
    % 'rggb'
    
%     imwrite(RGB, ['/media/michele/SAMSUNG/miche/files/stlucia/Data/101215_153851_MultiCamera0_deb/' Imgs(i).name]);
%     imwrite(RGB, ['G:\miche\files\stlucia\101215_153851_MultiCamera0_deb\' Imgs(i).name]);

    
%     if (size(image,3) == 1)
%         X(i,:,:) = image;
%     else
%         X(i,:,:,:) = image;
%     end
    
end


% figure(1)
% imshow(I);
%
% figure(2)
% imshow(RGB)



%% example of visualization + extracting features
imgSet = imageSet('/media/michele/SAMSUNG/miche/files/stlucia/101215_153851_MultiCamera0_deb');

idx = 1:50:imgSet.Count;
imgSet = select(imgSet,idx);

% implay(imgSet,10)


for ii = 1:imgSet.Count
    
    I = read(imgSet,ii);
    
    I = imresize(I, [480 640]);
    
    points = detectSURFFeatures(rgb2gray(I));
    strongest = points.selectStrongest(200);
    
    figure(1)
   % subplot(1,2,1)
    imshow(I)
    hold on
    
%     plot(points(end-4:end));
    plot(strongest);
    
%     [featureVector, hogVisualization] = extractHOGFeatures(I);
%     subplot(1,2,2)
%     imshow(I)
%     hold on
%     plot(hogVisualization);
    
    
    drawnow
    
    
end

%% simple visualization
% imgSet = imageSet('/media/michele/SAMSUNG1/miche/files/stlucia/101215_153851_MultiCamera0_deb');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/new_college/Images');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/city_centre/Images/Images');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/alderley/FRAMESA/FRAMESA');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/alderley/FRAMESB/FRAMESB');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/GardensPointWalking/day_left');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/GardensPointWalking/day_right');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/GardensPointWalking/night_right');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/VPRiCE-dataset/VPRiCE-dataset/live');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/VPRiCE-dataset/VPRiCE-dataset/memory');
% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/2015 CBD Dataset/2015 CBD Dataset/Day');
% imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images');
% imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images');
% imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images2');
% imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images2');



idx = 1:1:imgSet.Count;
% idx = 1:10:imgSet.Count;

imgSet = select(imgSet,idx);

% implay(imgSet,10)


for ii = 1:imgSet.Count
    
    I = read(imgSet, ii);
    
    
    figure(1)
   % subplot(1,2,1)
    imshow(I)
    hold on
    
    
    drawnow
    
    
end


%% single image visualization
Image = read(imgSet,5890);
figure(10)
imshow(Image)


%% play selected images

imgFiles = 
imgSet = imageSet('/home/michele/Documents/master thesis/datasets/new_college/Images');


%% readin kitty dataset

% it creates and array of image set objects
imgSet = imageSet('/media/michele/TOSHIBA EXT1/kitty/dataset/sequences', 'recursive');


for jj = 1:1:size(imgSet, 2)
    idx = 1:10:imgSet(jj).Count;
    imgSet = select(imgSet(jj),idx);
    for ii = 1:imgSet(jj).Count
        
        I = read(imgSet(jj), ii);
        
        
        figure(1)
        % subplot(1,2,1)
        imshow(I)
        hold on
        
        
        drawnow
        
        
    end
end

%% composite training set

imgFolders = { '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/Images', ...
               '/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images', ...
               '/home/michele/Documents/master thesis/datasets/city_centre/Images/Images', ...
               '/media/michele/SAMSUNG1/miche/files/stlucia/101215_153851_MultiCamera0_deb'
              };
imgSet = imageSet_mine(imgFolders);

imageSkip_nantes = 5;
size_sunny = 16353;
size_cloudy = 15970;

imageSkip_city_centre = 2;
begin_city_centre = size_sunny+size_cloudy;
size_city_centre = 2474;

imageSkip_stlucia = 100;
begin_stlucia = size_sunny+size_cloudy+size_city_centre;
size_stlucia = 66394;

idx1_1 = 9250:imageSkip_nantes:10690;
idx1_2 = 12050:imageSkip_nantes:12670;
idx1_3 = 13160:imageSkip_nantes:14760;
idx2_1 = size_sunny+8290:imageSkip_nantes:size_sunny+10060;
idx2_2 = size_sunny+11460:imageSkip_nantes:size_sunny+11710;
idx2_3 = size_sunny+12550:imageSkip_nantes:size_sunny+14040;
idx_city_centre = begin_city_centre:imageSkip_city_centre:begin_city_centre+size_city_centre;
idx_stlucia = begin_stlucia:imageSkip_stlucia:begin_stlucia+size_stlucia;

idx = [idx1_1, idx1_2, idx1_3, idx2_1, idx2_2, idx2_3, idx_city_centre, idx_stlucia];

imgSet = select(imgSet, idx);

%% sequence of images for testing

% imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/Images2');
% imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images2');

imageSkip = 10;
idx = 3850:imageSkip:4600;
idx = 3800:imageSkip:4740;
imgSet = select(imgSet, idx);
