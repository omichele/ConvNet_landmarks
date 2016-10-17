% code images Nantes dataset

%% first part - test images

% I1 = imread('F:\Nantes_city_centre_dataset\test_images\Image00289.png');
% I2 = imread('F:\Nantes_city_centre_dataset\test_images\Image02475.png');
% I3 = imread('F:\Nantes_city_centre_dataset\test_images\Image04627.png');
% I4 = imread('F:\Nantes_city_centre_dataset\test_images\Image06353.png');
% I5 = imread('F:\Nantes_city_centre_dataset\test_images\Image06357.png');
I1 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/test_images/Image00289.bmp');
I2 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/test_images/Image02475.bmp');
I3 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/test_images/Image04627.bmp');
I4 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/test_images/Image06353.bmp');
I5 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/test_images/Image06357.bmp');

figure, imshow(I3)

I1 = I1(1:850,:,:);
I2 = I2(1:850,:,:);
I3 = I3(1:850,:,:);
I4 = I4(1:850,:,:);
I1 = rgb2gray(I1);
I2 = rgb2gray(I2);
I3 = rgb2gray(I3);
I4 = rgb2gray(I4);

imshow([I1 I2; I3 I4])

ptsOriginal  = detectSURFFeatures(I3);
ptsDistorted = detectSURFFeatures(I4);

[featuresOriginal,validPtsOriginal] = extractFeatures(I3, ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(I4, ptsDistorted);

index_pairs = matchFeatures(featuresOriginal, featuresDistorted);
matchedPtsOriginal  = validPtsOriginal(index_pairs(:,1));
matchedPtsDistorted = validPtsDistorted(index_pairs(:,2));
figure; 
showMatchedFeatures(I3, I4, matchedPtsOriginal, matchedPtsDistorted);
title('Matched SURF points,including outliers');

% [tform, inlierPtsDistorted, inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted, matchedPtsOriginal,'projective', 'MaxDistance', 50);
[tform, inlierPtsDistorted, inlierPtsOriginal] = estimateGeometricTransform(matchedPtsDistorted, matchedPtsOriginal,'similarity', 'MaxDistance', 50);
tform.T
figure; 
showMatchedFeatures(I3, I4, inlierPtsOriginal, inlierPtsDistorted);
figure;
showMatchedFeatures(I3, I4, inlierPtsOriginal, inlierPtsDistorted, 'blend');
figure;
showMatchedFeatures(I3, I4, inlierPtsOriginal, inlierPtsDistorted, 'montage');
title('Matched inlier points');

outputView = imref2d(size(I3));
Ir = imwarp(I4, tform, 'OutputView', outputView);
figure; 
imshow(Ir);
title('Recovered image');
figure;
imshow(I3);


%% second part

I1 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/Images2/Image00289.png');
I2 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/Images2/Image02475.png');
I3 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/Images2/Image04627.png');
I4 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/Images2/Image06353.png');
I5 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/sunny/Images2/Image06357.png');

I1 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images/Image00289.png');
I2 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images/Image02475.png');
I3 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images/Image04627.png');
I4 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images/Image06353.png');
I5 = imread('/media/michele/TOSHIBA EXT1/Nantes_city_centre_dataset/cloudy/Images/Image06357.png');


figure
imshow([I1 I2; I3 I4])

I1 = rgb2gray(I1);
I2 = rgb2gray(I2);
I3 = rgb2gray(I3);
I4 = rgb2gray(I4);



%%

I1 = read(imgSet,10);
I2 = read(imgSet,20);
I3 = read(imgSet,30);
I4 = read(imgSet,40);
I5 = read(imgSet,50);

I1 = read(imgSet,10);
I2 = read(imgSet,40);
I3 = read(imgSet,70);
I4 = read(imgSet,100);
I5 = read(imgSet,130);
figure(10)
imshow([I1, I2, I3, I4, I5])
