EBdir = '/media/michele/Data/miche/file temporanei/DOCUMENTI MIEI/lavori università/robotics/master thesis/softwares/edges-master';


%% load pre-trained edge detection model and set opts (see edgesDemo.m)
model = load(fullfile(EBdir,'models/forest/modelBsds')); 
model = model.model;
model.opts.multiscale = 0; 
model.opts.sharpen = 2; 
model.opts.nThreads = 4;

%% set up opts for edgeBoxes (see edgeBoxes.m)
% defaults
dfts = 0;
if(dfts)
    opts = edgeBoxes;
    opts.alpha = .65;     % step size of sliding window search
    opts.beta  = .75;     % nms threshold for object proposals
    opts.minScore = .01;  % min score of boxes to detect
    opts.maxBoxes = 1e4;  % max number of boxes to detect
    opts.eta = 2;
    opts.edgeMinMag = .1;
    opts.edgeMergeThr = .5;
    opts.clusterMinMag = .5;
    opts.gamma = 2;
    opts.kappa = 1.5;
else
    opts = edgeBoxes;
    opts.alpha = .38;     % step size of sliding window search
    opts.beta  = .38;     % nms threshold for object proposals
    opts.minScore = .05;  % min score of boxes to detect
    opts.maxBoxes = 200;  % max number of boxes to detect
    opts.eta = 2;
    opts.edgeMinMag = .1;
    opts.edgeMergeThr = .5;
    opts.clusterMinMag = .5;    % very useful to be changed -- reduce the number of proposals
    opts.gamma = 2;
    opts.kappa = 1.5;
end


%% detect Edge Box bounding box proposals (see edgeBoxes.m)
% I = imread('peppers.png');
% I = imread('D:\miche\file temporanei\MATLAB\CV\left_#290.bmp');
% I = imread('D:\miche\file temporanei\MATLAB\CV\frame0250.jpg');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\VPRiCE-dataset\VPRiCE-dataset\live\image-03006.png');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\GardensPointWalking\day_left\Image120.jpg');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\GardensPointWalking\day_left\Image092.jpg');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\PASCAL VOC\VOCdevkit\VOC2007\JPEGImages\000006.jpg');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\alderley\FRAMESB\FRAMESB\Image00001.jpg');
% I = imread('D:\miche\file temporanei\DOCUMENTI MIEI\lavori universit�\robotics\master thesis\datasets\alderley\FRAMESA\FRAMESA\Image00050.jpg');


% I = imread('/media/michele/Data/miche/file temporanei/DOCUMENTI MIEI/lavori università/robotics/master thesis/datasets/GardensPointWalking/day_left/Image100.jpg');
% I = imread('/home/michele/Documents/master thesis/datasets/alderley/FRAMESA/FRAMESA/Image00001.jpg');
% I = '/media/michele/SAMSUNG/miche/files/stlucia/101215_153851_MultiCamera0_deb/cam0_image00002.bmp';

% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/city_centre/Images/Images');
% imgSet = imageSet('/media/michele/SAMSUNG/miche/files/stlucia/101215_153851_MultiCamera0_deb');

% imgSet = imageSet('/home/michele/Documents/master thesis/datasets/alderley/FRAMESB/FRAMESB');
imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images2');
imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images2');

idx = 1:1:imgSet.Count;
imgSet = select(imgSet,idx);

for ii = 1:imgSet.Count
    % tic
    I = read(imgSet,ii);
    
    figure(1)
    subplot_tight(2,1,1, [0.01, 0.01])
    imshow(I)
    
    bbs = edgeBoxes(I, model, opts);
    
    figure(1)
    subplot_tight(2,1,2, [0.01, 0.01])
    imshow(I);
    bb_plotted = 200;
    if bb_plotted > size(bbs,1)
        bb_plotted = size(bbs,1);
    end
    hs = bbApply('draw', bbs(1:bb_plotted,1:4), [], 2, '-', [], 1:bb_plotted);
    
    figure(2)
    imshow(I);
    bb_plotted = 200;
    if bb_plotted > size(bbs,1)
        bb_plotted = size(bbs,1);
    end
    hs = bbApply('draw', bbs(1:bb_plotted,1:4), [], 2, '-', [], 1:bb_plotted);
    
    drawnow

end


%% single bbs
imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images2');
imgSet = imageSet('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/dynamic_exposure/Images2');

% 2658
% 2668
% 
% 2100
% 2740
I = read(imgSet,2668);

bbs = edgeBoxes(I, model, opts);

figure(2)
imshow(I);
bb_plotted = 50;
if bb_plotted > size(bbs,1)
    bb_plotted = size(bbs,1);
end
hs = bbApply('draw', bbs(1:bb_plotted,1:4), [], 2, '-', [], 1:bb_plotted);