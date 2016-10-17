function image_batch = prepare_image_mine2(images, mean_data)
% same as prepare_image_mine but without crops, so just imresize for batchs
% caffe/matlab/+caffe/imagenet/ilsvrc_2012_mean.mat contains mean_data that
% is already in W x H x C with BGR channels

caffe_root = '/media/michele/Data/miche/file temporanei/DOCUMENTI MIEI/lavori università/robotics/master thesis/softwares/caffe-master';

% d = load(fullfile(caffe_root, 'matlab/+caffe/imagenet/ilsvrc_2012_mean.mat'));
% d = load(fullfile(caffe_root, 'matlab/+caffe/imagenet/ilsvrc_2012_mean_227.mat'));
% mean_data = d.mean_data;
% IMAGE_DIM = 256;
IMAGE_DIM = 227;

image_batch = zeros(IMAGE_DIM, IMAGE_DIM, 3, size(images,1));

% figure 

% Convert an image returned by Matlab's imread to im_data in caffe's data
% format: W x H x C with BGR channels
for ii = 1:size(images,1)
    im = images{ii};
    im_data = im(:, :, [3, 2, 1]);  % permute channels from RGB to BGR
    im_data = permute(im_data, [2, 1, 3]);  % flip width and height
    im_data = single(im_data);  % convert from uint8 to single
    image_batch(:,:,:,ii) = imresize(im_data, [IMAGE_DIM IMAGE_DIM], 'bilinear');  % resize im_data
    
%     figure
%     imshow(uint8(image_batch(:,:,:,ii)))
%     drawnow
end

image_batch = image_batch - repmat(mean_data, [1 1  1 size(images,1)]);  % subtract mean_data (already in W x H x C, BGR)

% for ii = 1:size(images,1)
%     figure
%     imshow(uint8(image_batch(:,:,:,ii)))
%     drawnow
% end

end

