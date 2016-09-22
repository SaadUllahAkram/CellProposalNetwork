function im = boundary_rgb(opts, im, mask)
% uses pixels in mask to color the object borders in im.
%   im: image
%   mask: labelled image
% 

opts_default        = struct('cmap','prism','border_thickness',1,'alpha',0.5,'fun_boundary',@boundarymask);
opts                = updatefields(opts_default, opts);

border_thickness    = opts.border_thickness;
cmap                = opts.cmap;
alpha               = opts.alpha;
fun_boundary        = opts.fun_boundary;% 1:bwperim (thinner and may have holes) 2: boundarymask (thick)
if length(size(im)) == 2
    im = repmat(im, 1, 1, 3);
end

colors  = alpha*255*get_colors(cmap);
N       = numel(mask);

boundary_labeled    = fun_boundary(mask);
if border_thickness > 1
    boundary_labeled    = imdilate(boundary_labeled, ones(border_thickness));
end
boundary_labeled    = single(boundary_labeled).*single(mask);
stats               = regionprops(boundary_labeled, 'Area', 'PixelIdxList');

idx_active          = find([stats(:).Area]>0);
n_colors            = size(colors,1);
for i=idx_active(:)'
    color_id    = rem(i, n_colors)+1;
    idx         = stats(i).PixelIdxList;
    im(idx)     = colors(color_id, 1);
    im(idx+N)   = colors(color_id, 2);
    im(idx+2*N) = colors(color_id, 3);
end
end