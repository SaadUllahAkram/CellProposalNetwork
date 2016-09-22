function pred_seg_masks = cspn_im_detect(conf, caffe_net, im, boxes, max_rois_num_in_gpu)
% --------------------------------------------------------
% Fast R-CNN
% Reimplementation based on Python Fast R-CNN (https://github.com/rbgirshick/fast-rcnn)
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

    conf_default = struct('image_means', 128, 'cpn_resize_im', 0);
    conf         = updatefields(conf_default, conf);

    im_size = size(im);
    channels = size(caffe_net.blobs('data').get_data(), 3);
    if channels == 3
        if size(im, 3) == 1
            im = repmat(im, [1 1 3]);
        end
        im = im(:, :, [3, 2, 1], :); % from rgb to brg
    end    
    if ~conf.cpn_resize_im
        conf = setfields(conf, 'test_scales', min(im_size(1:2)), 'test_max_size', max(im_size(1:2)));
    end
    [im_blob, rois_blob, ~] = get_blobs(conf, im, boxes);    

    % When mapping from image ROIs to feature map ROIs, there's some aliasing
    % (some distinct image ROIs get mapped to the same feature ROI).
    % Here, we identify duplicate feature ROIs, so we only compute features
    % on the unique subset.
    [~, index, inv_index] = unique(rois_blob, 'rows');
    rois_blob = rois_blob(index, :);
    
    % permute data into caffe c++ memory, thus [num, channels, height, width]
    if length(size(im_blob)) == 3%rgb image
        im_blob = im_blob(:, :, [3, 2, 1], :); % from rgb to brg
    end
    im_blob = permute(im_blob, [2, 1, 3, 4]);
    im_blob = single(im_blob);
    rois_blob = rois_blob - 1; % to c's index (start from 0)
    rois_blob = permute(rois_blob, [3, 4, 2, 1]);
    rois_blob = single(rois_blob);
    
    total_rois = size(rois_blob, 4);
    total_seg_masks = cell(ceil(total_rois / max_rois_num_in_gpu), 1);
    for i = 1:ceil(total_rois / max_rois_num_in_gpu)
        sub_ind_start = 1 + (i-1) * max_rois_num_in_gpu;
        sub_ind_end = min(total_rois, i * max_rois_num_in_gpu);
        sub_rois_blob = rois_blob(:, :, :, sub_ind_start:sub_ind_end);
        
        net_inputs = {im_blob, sub_rois_blob};
        % Reshape net's input blobs
        caffe_net.reshape_as_input(net_inputs);
        output_blobs = caffe_net.forward(net_inputs);

        seg_masks = output_blobs{1};
        seg_masks = squeeze(seg_masks);
        seg_masks = permute(seg_masks, [3 1 2]);
        total_seg_masks{i} = seg_masks;
    end
    
    seg_masks = cell2mat(total_seg_masks);
    pred_seg_masks = seg_masks(inv_index, :, 2:end);
end

function [data_blob, rois_blob, im_scale_factors] = get_blobs(conf, im, rois)
    [data_blob, im_scale_factors] = get_image_blob(conf, im);
    rois_blob = get_rois_blob(conf, rois, im_scale_factors);
end

function [blob, im_scales] = get_image_blob(conf, im)
    [ims, im_scales] = arrayfun(@(x) prep_im_for_blob(im, conf.image_means, x, conf.test_max_size), conf.test_scales, 'UniformOutput', false);
    if isfield(conf, 'seg')
        assert(im_scales{1} == 1)
    end
    im_scales = cell2mat(im_scales);
    blob = im_list_to_blob(ims);    
end

function [rois_blob] = get_rois_blob(conf, im_rois, im_scale_factors)
    [feat_rois, levels] = map_im_rois_to_feat_rois(conf, im_rois, im_scale_factors);
    rois_blob = single([levels, feat_rois]);
end

function [feat_rois, levels] = map_im_rois_to_feat_rois(conf, im_rois, scales)
    im_rois = single(im_rois);
    
    if length(scales) > 1
        widths = im_rois(:, 3) - im_rois(:, 1) + 1;
        heights = im_rois(:, 4) - im_rois(:, 2) + 1;
        
        areas = widths .* heights;
        scaled_areas = bsxfun(@times, areas(:), scales(:)'.^2);
        [~, levels] = min(abs(scaled_areas - 224.^2), [], 2); 
    else
        levels = ones(size(im_rois, 1), 1);
    end
    
    feat_rois = round(bsxfun(@times, im_rois-1, scales(levels))) + 1;
end