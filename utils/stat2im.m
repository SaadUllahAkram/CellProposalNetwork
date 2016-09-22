function iml = stat2im(stats, sz)
% create a labeled image from stats
% 
% Inputs:
%     stats.{Area, PixelIdxList} : stats of objects in the image
%     sz : [w, h, d], size of resulting image
% Outputs:
%     iml : labeled stack
% 

for i = 1:length(stats)
    if isempty(stats(i).Area)
        stats(i).Area = 0;
    end
end
idx = find([stats.Area] > 0);

iml = zeros(sz, 'uint16');
for k=idx
    iml(stats(k).PixelIdxList) = k;
end