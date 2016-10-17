function window = rcnn_im_crop_batch(im, bbs, crop_mode, crop_size, padding, image_mean)
% window = rcnn_im_crop(im, bbs, crop_mode, crop_size, padding, image_mean)
%   Crops a window specified by bbs (in [x1 y1 x2 y2] order) out of im.
%
%   crop_mode can be either 'warp' or 'square'
%   crop_size determines the size of the output window: crop_size x crop_size
%   padding is the amount of padding to include at the target scale
%   image_mean to subtract from the cropped window
%
%   N.B. this should be as identical as possible to the cropping
%   implementation in Caffe's WindowDataLayer, which is used while
%   fine-tuning.

% AUTORIGHTS
% ---------------------------------------------------------
% Copyright (c) 2014, Ross Girshick
%
% This file is part of the R-CNN code and is available
% under the terms of the Simplified BSD License provided in
% LICENSE. Please retain this notice and LICENSE if you use
% this file (or any portion of it) in your project.
% ---------------------------------------------------------

use_square = false;
if strcmp(crop_mode, 'square')
    use_square = true;
end

% defaults if padding is 0
pad_w = 0;
pad_h = 0;
crop_width = crop_size;
crop_height = crop_size;
if padding > 0 || use_square
    %figure(1); showboxesc(im/256, bbs, 'b', '-');
    scale = crop_size/(crop_size - padding*2);
    half_height = (bbs(:,4)-bbs(:,2)+1)/2;
    half_width = (bbs(:,3)-bbs(:,1)+1)/2;
    center = [bbs(:,1)+half_width bbs(:,2)+half_height];
    if use_square
        % make the box a tight square
        ind1 = (half_height > half_width) == 1;
        ind0 = (half_height > half_width) == 0;
        half_width(ind1) = half_height(ind1);
        half_height(ind0) = half_width(ind0);
        
    end
    bbs = round([center center] + ...
        [-half_width -half_height half_width half_height]*scale);
    unclipped_height = bbs(:,4)-bbs(:,2)+1;
    unclipped_width = bbs(:,3)-bbs(:,1)+1;
    %figure(1); showboxesc([], bbs, 'r', '-');
    pad_x1 = max(0, 1 - bbs(:,1));
    pad_y1 = max(0, 1 - bbs(:,2));
    % clipped bbs
    bbs(:,1) = max(1, bbs(:,1));
    bbs(:,2) = max(1, bbs(:,2));
    bbs(:,3) = min(size(im,2), bbs(:,3));
    bbs(:,4) = min(size(im,1), bbs(:,4));
    clipped_height = bbs(:,4)-bbs(:,2)+1;
    clipped_width = bbs(:,3)-bbs(:,1)+1;
    scale_x = crop_size./unclipped_width;
    scale_y = crop_size./unclipped_height;
    crop_width = round(clipped_width.*scale_x);
    crop_height = round(clipped_height.*scale_y);
    pad_x1 = round(pad_x1.*scale_x);
    pad_y1 = round(pad_y1.*scale_y);
    
    pad_h = pad_y1;
    pad_w = pad_x1;
    
    ind1 = ((pad_y1 + crop_height) > crop_size) == 1;
    crop_height(ind1) = crop_size - pad_y1(ind1);
    ind0 = ((pad_x1 + crop_width) > crop_size) == 0;
    crop_width(ind0) = crop_size - pad_x1(ind0);
end % padding > 0 || square

window = zeros(crop_size, crop_size, 3, size(bbs,1), 'single');
for jj = size(bbs,1)
    window = im(bbs(jj,2):bbs(jj,4), bbs(jj,1):bbs(jj,3), :);
    % We turn off antialiasing to better match OpenCV's bilinear
    % interpolation that is used in Caffe's WindowDataLayer.
    tmp(:,:,:,jj) = imresize(window, [crop_height(jj) crop_width(jj)], ...
        'bilinear', 'antialiasing', false);
    
    if ~isempty(image_mean)
        tmp(:,:,:,jj) = tmp(:,:,:,jj) - image_mean(pad_h(jj)+(1:crop_height(jj)), pad_w(jj)+(1:crop_width(jj)), :);
    end
    % figure(2); window_ = tmp; imagesc((window_-min(window_(:)))/(max(window_(:))-min(window_(:)))); axis image;
    window(pad_h(jj)+(1:crop_height(jj)), pad_w(jj)+(1:crop_width(jj)), :, jj) = tmp(:,:,:,jj);
    % figure(3); imagesc((window-min(window(:)))/(max(window(:))-min(window(:)))); axis image; pause;
end
