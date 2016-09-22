function stats_cell = cpn_masks(im_cell, bb_cell, pad)
% returns segmentation for CPN proposed bboxes by thresholding
%
% Inputs:
%     im_cell : cell array of images
%     bb_cell : cell array of proposed bboxes [x y w h score frame#]
%     pad : extra padding added to bb
% Outputs:
%     stats_cell: cell array containing stats of proposals for each image
%

N   = length(im_cell);
stats_cell = cell(N, 1);
for i = 1:N
    im  = im_cell{i};
    bb  = bb_cell{i};
    R   = size(bb, 1);
    sz  = [size(im, 1), size(im, 2)];
    
    clear stats_loc
    parfor j = 1:R
        rois        = bb(j,1:5);
        rect        = convert_bb(rois(1:4), 'b2r');
        rect_pad    = [max(1, rect(1)-pad), min(sz(1), rect(2)+pad), max(1, rect(3)-pad), min(sz(2), rect(4)+pad)];
        im_padded   = im(rect_pad(1):rect_pad(2), rect_pad(3):rect_pad(4));
        bw          = im_padded > mean(im_padded(:));
        bw          = imclose(bw, ones(3));
        [bw, not_found] = keep_largest_cc(bw, 1);
        if not_found% if no region found, create 1 itself
            rect_pad= rect;
            bw      = ones(rect(2)-rect(1), rect(4)-rect(3));
        end
        stats_loc(j,1) = cpn_roi_stats(bw, rect_pad, sz, rois(5));
    end
    stats_cell{i} = stats_loc;
end
end