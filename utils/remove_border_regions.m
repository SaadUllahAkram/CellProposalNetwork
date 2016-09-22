function [stats, idx_del] = remove_border_regions(stats, sz, b)
% removes objects completely within 'b' pixels from image border.
% 
bb      = convert_bb(stats, 's2r');
idx_del = bb(:,2) < b | bb(:,4) < b | bb(:,1) > sz(1)-b+1 | bb(:,3) > sz(2)-b+1;
stats(idx_del) = [];
end