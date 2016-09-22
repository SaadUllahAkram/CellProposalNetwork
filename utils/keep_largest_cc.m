function [bw, not_found] = keep_largest_cc(bw, fill_holes)
% Inputs:
%     bw: binary image
% Outputs:
%     bw: only the largest connected component is retained
%     not_found: is '1', if there is no object in the bw
%     

stats = regionprops(logical(bw), 'Area', 'PixelIdxList');
if isempty(stats)
    not_found = 1;
    return
else
    not_found = 0;
end

areas    = [stats(:).Area];
[~, idx] = max(areas);
for i=setdiff(1:length(stats), idx)
    bw(stats(i).PixelIdxList) = 0;
end

if fill_holes
    bw = imfill(bw, 'holes');
end

end