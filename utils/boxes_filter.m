function [aboxes, idx] = boxes_filter(aboxes, per_nms_topN, nms_overlap_thres, after_nms_topN, use_gpu, nms_score_thresh)
% Inputs:
%     aboxes : [x1,y1,x2,y2, score]
% 

if nargin < 6
    nms_score_thresh = 0;
end

% to speed up nms
if per_nms_topN > 0
    idx_topN= 1:min(size(aboxes,1), per_nms_topN);
    aboxes  = aboxes(idx_topN, :);
end
% do nms
if nms_overlap_thres > 0 && nms_overlap_thres < 1
    idx_nms = nms(aboxes, nms_overlap_thres, use_gpu);
    aboxes  = aboxes(idx_nms, :);
    idx     = idx_topN(idx_nms);
end
if after_nms_topN > 0
    idx_topN = 1:min(size(aboxes,1), after_nms_topN);
    aboxes = aboxes(idx_topN, :);
    idx     = idx(idx_topN);
end
if nms_score_thresh > 0
    idx_del = aboxes(:,5) < nms_score_thresh;
    aboxes(idx_del) = [];
    idx(idx_del) = [];
end
end