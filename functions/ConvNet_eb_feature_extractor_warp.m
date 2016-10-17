function [features, featureMetrics, varargout] = ConvNet_eb_feature_extractor_warp(I)
% Custom feature extractor

global ds
% bb_plotted = ds.conf.bb_plotted;
% input_caffe = ds.conf.params.input_caffe;
% num_patches = ds.conf.params.num_patches;
% mean_data = ds.caffe.mean_data;
% G = ds.data.G;


% compute edge boxes #################################
bbs = edgeBoxes(I, ds.eb.model, ds.eb.opts);

if(ds.conf.enable_figures)
    figure(1)
    subplot_tight(2,2,2, [0.01, 0.01])
    imshow(I);
    if ds.conf.bb_plotted > size(bbs,1)
        ds.conf.bb_plotted = size(bbs,1);
    end
    hs = bbApply('draw', bbs(1:ds.conf.bb_plotted,1:4), [], 2, '-', [], 1:ds.conf.bb_plotted);
    drawnow
end

% extract patches and compute features   #################################
num_patches_current = min(ds.conf.params.num_patches, size(bbs,1));

if(ds.conf.save_patches)
    % column vector
    patches = cell(num_patches_current,1);
    
    for jj = 1:num_patches_current
        patches{jj} = I( bbs(jj,2):bbs(jj,2)+bbs(jj,4) , bbs(jj,1):bbs(jj,1)+bbs(jj,3) , :);
    end
    
    if size(ds.results.saved_patches,1) == 0
        ds.results.saved_patches = {patches};
    else
        ds.results.saved_patches = [ds.results.saved_patches, {patches}];   % 50 x # num images
    end
end


I = single(I(:,:,[3 2 1]));


% the feature metric will be the output score of EdgeBoxes
% !!!!!!!!!!!!!!!!!!!!!!!!!!
featureMetrics = bbs(1:num_patches_current, 5);


if num_patches_current ~= 0
    
    if num_patches_current < ds.conf.params.num_patches
        ds.caffe.net.blobs('data').reshape([ds.conf.params.input_caffe, ds.conf.params.input_caffe, 3, num_patches_current]);
    end
    
    batch = zeros(ds.conf.params.input_caffe, ds.conf.params.input_caffe, 3, num_patches_current);
    centers = zeros(num_patches_current, 2);
    dimensions = zeros(num_patches_current, 2);
    
    for jj = 1:num_patches_current
        %                         patch = I( bbs(jj,2):bbs(jj,2)+bbs(jj,4) , bbs(jj,1):bbs(jj,1)+bbs(jj,3) , :);
        %                         figure(4), imshow(uint8(patch(:,:,[3 2 1])));
        [batch(:,:,:,jj), centers(jj, :)] = rcnn_im_crop(I, [bbs(jj,1), bbs(jj,2), bbs(jj,1)+bbs(jj,3), bbs(jj,2)+bbs(jj,4)], 'warp', ds.conf.params.input_caffe, 16, ds.caffe.mean_data);
        %                         figure(5), imshow(uint8(batch(:,:,[3 2 1],jj)));
        dimensions(jj,:) = [bbs(jj,3), bbs(jj,4)];
    end
    
    input_data = {batch};
    
    if(ds.conf.use_places_cnn)
        ds.caffe.net.forward(input_data);
        features = ds.caffe.net.blobs('conv3').get_data();
        features = reshape(features, [], num_patches_current);
    else
        features = ds.caffe.net.forward(input_data);
        features = reshape(features{1}, [], num_patches_current);
    end

    
    if num_patches_current < ds.conf.params.num_patches
        ds.caffe.net.blobs('data').reshape([ds.conf.params.input_caffe, ds.conf.params.input_caffe, 3, ds.conf.params.num_patches]);
    end
    
    
    % Gaussian random projection
    features = features'*ds.data.G;
    
    if(ds.conf.save_features)
        if size(ds.results.saved_features, 1) == 0
            ds.results.saved_features = {features};
        else
            ds.results.saved_features = [ds.results.saved_features, {features}];
        end
    end
    
    if nargout > 2
        % Return feature location information
        varargout{1} = centers;
        varargout{2} = dimensions;
    end
    
    
end

end
