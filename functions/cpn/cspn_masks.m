function [stats_cell, prob_cell] = cspn_masks(conf, seg_net, im_cell, rois_cell)
% returns the segmentation for given rois
%
% Inputs:
%     conf: settings
%     seg_net: caffe network
%     im: cell array of images
%     rois: cell array of rois, [xmin ymin xmax ymax prob.]
% Outputs:
%     stats_cell: cell array of proposal stats
%     prob_cell: pixel probability map
%

if ~isfield(conf, 'num_rois')
    num_rois    = 1000;
end
thresh      = 0.5;

N           = length(im_cell);
stats_cell  = cell(N,1);
prob_cell   = cell(N,1);
for i = 1:N
    im      = im_cell{i};
    rois    = rois_cell{i};
    R       = size(rois,1);% # of rois
    sz      = [size(im, 1), size(im, 2)];    
    prob    = zeros(sz);

    rois(:,1:4)    = convert_bb(rois(:,1:4), 'b2c');
    rois_score_vec = cspn_im_detect(conf, seg_net, im, rois(:, 1:4), num_rois);
    roi_mask_sz    = sqrt(length(rois_score_vec(1,:)));

    rect          = convert_bb(rois, 'c2r');
    rect(:,[1,3]) = max(1, rect(:,[1,3]));
    rect(:,[2,4]) = min(repmat([sz(1), sz(2)], R, 1), rect(:,[2,4]));

    p_cell        = cell(R,1);
    clear stats_loc
    parfor j = 1:R
        p   = reshape(rois_score_vec(j, :), roi_mask_sz, roi_mask_sz)';% transpose
        r   = rect(j, :);
        bsz = [r(2)-r(1)+1, r(4)-r(3)+1];
        p   = imresize(p, bsz, 'bicubic');
        bw  = keep_largest_cc(p > thresh, 1);
        p_cell{j}       = p;
        stats_loc(j,1)  = cpn_roi_stats(bw, r, sz, rois(j,5));
    end
    stats_cell{i} = stats_loc;

    for j = 1:R
        r  = rect(j, :);
        p  = p_cell{j};
        prob(r(1):r(2), r(3):r(4)) = max(p, prob(r(1):r(2), r(3):r(4)));% keep max prob. for each pixel
    end
    prob_cell{i} = prob;
end
end