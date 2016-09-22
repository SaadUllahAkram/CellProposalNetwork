function bb_nms = cpn_im_detect(conf, cpn_net, ims)
% returns proposals bounding boxes after nms
% 
% Inputs:
%     conf : settings
%     cpn_net : caffe network
%     ims  : a cell array of images
% Outputs:
%     bb_nms : cell array of proposal boxes: [xmin ymin w h]
% 

opts_nms_default = struct('nms_overlap_thres', 0.5, 'nms_score_thresh', 0, 'after_nms_topN', 2000, 'per_nms_topN', 10000, 'use_gpu', gpuDeviceCount>0);
opts_nms         = updatefields(opts_nms_default, conf.cpn_nms);

N           = length(ims);
bb_nms      = cell(N,1);
for i=1:N
   [boxes, scores] = proposal_im_detect(conf, cpn_net, ims{i}, i);
   bb_corners = boxes_filter([boxes, scores], opts_nms.per_nms_topN, opts_nms.nms_overlap_thres, opts_nms.after_nms_topN, opts_nms.use_gpu);
   if opts_nms.nms_score_thresh > 0
        bb_corners(bb_corners(:,5) < opts_nms.nms_score, :) = [];
   end
   bb_nms{i} = [convert_bb(bb_corners(:,1:4), 'c2b'), bb_corners(:,5)];
end
end