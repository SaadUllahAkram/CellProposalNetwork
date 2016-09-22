function activate_caffe(gpu_id)
% --------------------------------------------------------
% Faster R-CNN
% Copyright (c) 2015, Shaoqing Ren
% Licensed under The MIT License [see LICENSE for details]
% --------------------------------------------------------

    % set gpu in matlab
    gpuDevice(gpu_id);
    cur_dir = pwd;
    
    m_dir   = mfilename('fullpath');
    cpn_dir = fileparts(m_dir);
    cpn_dir = fileparts(cpn_dir);
    caffe_dir = fullfile(cpn_dir, 'caffe', 'matlab');
    if ~exist(caffe_dir, 'dir')
        warning('Caffe not found at: %s', caffe_dir)
    end

    addpath(genpath(caffe_dir));
    cd(caffe_dir);
    caffe.set_device(gpu_id-1);
    caffe.set_mode_gpu();
    cd(cur_dir);
end
