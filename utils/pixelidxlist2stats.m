function stats = pixelidxlist2stats(px, sz)
% Computes stats of object specified by pixel indices.
% 
% Inputs:
%     px: indices of object pixels
%     sz: size of image
% Outputs:
%     stats: BoundingBox, Centroid, Area & PixelIdxList stats are computed.
% 
num_dims = numel(sz);

stats.PixelIdxList  = px;
stats.Area          = length(px);

[r, c] = ind2sub(sz, px);
list = [c, r];
if isempty(list)
    stats.BoundingBox   = [0.5*ones(1, num_dims) zeros(1, num_dims)];
    stats.Centroid      = NaN*ones(1, num_dims);
else
    min_corner = min(list,[],1) - 0.5;
    max_corner = max(list,[],1) + 0.5;
    stats.BoundingBox   = [min_corner (max_corner - min_corner)];
    stats.Centroid      = mean(list, 1);
end
end