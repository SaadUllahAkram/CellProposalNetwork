function demo()
opts.mode       = 2;% 1(icip), 2(dlmia)

evalc('caffe.reset_all()');

data_dir        = fullfile(fileparts(mfilename('fullpath')), 'data');
if ~exist(data_dir, 'dir')
    fetch_data();
end

for d = {'Fluo-N2DL-HeLa'}
    for s = 1:2
        dataset_name = sprintf('%s-%02d', d{1}, s);
        list         = dir(fullfile(data_dir, filesep, sprintf('%s-t*_res.png', dataset_name)));
        for i=1:length(list)
            delete(fullfile(data_dir, list(i).name))
        end
        list         = dir(fullfile(data_dir, filesep, sprintf('%s-t*.png', dataset_name)));
        if contains(dataset_name, 'Fluo-N2DL-HeLa')
            conf.foi_border = 25;
        else
            conf.foi_border = 0;
        end
        conf.cpn.model.use_padding = 0;
        conf.cpn_nms            = struct('nms_overlap_thres', 0.5, 'nms_score_thresh', 0, 'after_nms_topN', 2000, 'per_nms_topN', 10000, 'use_gpu', gpuDeviceCount>0);
        
        if opts.mode == 1
            cpn_model_dir     = fullfile(data_dir, 'models', 'CPN');
            model.cpn.test_net_def  = fullfile(cpn_model_dir, 'cpn_test.prototxt');
            model_fun         = @(x) sprintf('Fluo-N2DL-HeLa-%02d.caffemodel', x);
            model.cpn.final   = fullfile(cpn_model_dir, model_fun(s));
            cpn_net           = load_caffe_model(model.cpn.test_net_def, model.cpn.final);
           
            conf    = setfields(conf, 'feat_stride', 8, 'anchor_base_sz', 8, 'anchor_ratios', [0.5 1 2], 'anchor_scales', [3 1.5], 'seg_pad', 3);
            conf.anchors          = proposal_generate_anchors('','scales',conf.anchor_scales,'ratios',conf.anchor_ratios,'base_size',conf.anchor_base_sz,'ignore_cache',true);
            
            load(fullfile(cpn_model_dir, 'nms_settings.mat'), 'nms_settings')
        elseif opts.mode == 2
            cspn_model_dir    = fullfile(data_dir, 'models', 'CSPN');
            model_bb_fun      = @(x) sprintf('Fluo-N2DL-HeLa-%02d-bb.caffemodel', x);
            model_seg_fun     = @(x) sprintf('Fluo-N2DL-HeLa-%02d-seg.caffemodel', x);
            model.cpn.test_net_def  = fullfile(cspn_model_dir, 'cpn_bb_test.prototxt');
            model.cpn.final   = fullfile(cspn_model_dir, model_bb_fun(s));
            model.seg.test_net_def  = fullfile(cspn_model_dir, 'cpn_seg_test.prototxt');
            model.seg.final   = fullfile(cspn_model_dir, model_seg_fun(s));
            [cpn_net, seg_net]= load_caffe_model(model.cpn.test_net_def, model.cpn.final, model.seg.test_net_def, model.seg.final);
            
            conf    = setfields(conf, 'feat_stride', 4, 'anchor_base_sz', 4, 'anchor_ratios', [0.5 1 2], 'anchor_scales', [6 3]);
            conf.anchors          = proposal_generate_anchors('','scales',conf.anchor_scales,'ratios',conf.anchor_ratios,'base_size',conf.anchor_base_sz,'ignore_cache',true);
            load(fullfile(cspn_model_dir, 'nms_settings.mat'), 'nms_settings')
        end
        nms_iou     = nms_settings.(strrep(dataset_name, '-', '_')).iou;
        nms_score   = nms_settings.(strrep(dataset_name, '-', '_')).score;

        for i=1:length(list)
            im      = imread(fullfile(data_dir, list(i).name));
            bb_nms  = cpn_im_detect(conf, cpn_net, {im});
            if opts.mode == 1
                seg_nms = cpn_masks({im}, bb_nms, conf.seg_pad);
            else
                seg_nms = cspn_masks(conf, seg_net, {im}, bb_nms);
            end
            seg_nms      = remove_border_regions(seg_nms{1}, size(im), conf.foi_border);
            seg_greedy   = nms_seg(seg_nms, nms_iou, nms_score);
            
            im_seg = boundary_rgb(struct('alpha',1,'border_thickness',2), im, stat2im(seg_greedy, size(im)));
            imwrite(im_seg, fullfile(data_dir, strrep(list(i).name, '.png', '_res.png')));
            imshow(im_seg)
            drawnow
        end
        evalc('caffe.reset_all()');
    end
end
end