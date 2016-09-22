function stats = cpn_roi_stats(mask, roi, sz, score)
% Inputs:
%     mask: binary mask
%     roi: [ymin ymax xmin xmax]
%     sz: size of full image
%     score: score of the roi
% Outputs:
%     stats:
%

idx     = find(mask);
[r,c]   = ind2sub(size(mask), idx);
r       = double(r+roi(1)-1);
c       = double(c+roi(3)-1);
idx_rm  = r < 1 | c < 1 | r > sz(1) | c > sz(2);
r(idx_rm) = [];
c(idx_rm) = [];
px      = sub2ind(sz, r, c);

stats   = pixelidxlist2stats(px, sz);
stats.Score = score;
end
