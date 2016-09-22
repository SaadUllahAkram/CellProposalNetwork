function [stats_nms, pick] = nms_seg(stats, overlap, score_thresh)
% non-maxima suppression using segmentation masks
% stats must have a "Score" field which is used for NMS
% 
% Inputs:
%     stats.{Area, PixelIdxList, BoundingBox, Score} : score contains the probability
%     overlap : IoU threshold
%     score (optional): 
% Outputs:
%     stats_nms   : stats after nms
%     idx_nms     : idx of regions remaining after nms
%     

score = [stats(:).Score];
assert(length(score) == length(stats))
idx_use = find( score>score_thresh );% props to be used in nms
stats_orig = stats;
stats  = stats(idx_use);
score  = score(idx_use);

% sort descend
[~, idx]    = sort(score, 'descend');

pick    = 0*score;
counter = 1;
bb      = convert_bb(stats, 's2m');
iou_bb  = bboxOverlapRatio(bb, bb);

while ~isempty(idx)
    i               = idx(1);
    idx(1)          = [];
    pick(counter)   = i;
    counter         = counter + 1;
    
    iou     = zeros(1, length(idx));
    for k = 1:length(idx)
        j       = idx(k);
        if iou_bb(i,j) > 0
            inter   = sum(ismember(stats(i).PixelIdxList, stats(j).PixelIdxList));
            iou(k)  = inter/(length(stats(i).PixelIdxList) + length(stats(j).PixelIdxList) - inter);
        else
            iou(k)  = 0;
        end
    end
    idx = idx(iou <= overlap);
end
pick = pick(1:(counter-1));
pick = idx_use(pick);% get the idx corresponding to input idx
stats_nms = stats_orig(pick);

end