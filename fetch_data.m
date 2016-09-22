function fetch_data()

opts.cspn_models = 'https://dl.dropboxusercontent.com/u/18078337/GitHub/CSPN_models.zip';
opts.cpn_models  = 'https://dl.dropboxusercontent.com/u/18078337/GitHub/CPN_models.zip';
opts.demo_images = 'https://dl.dropboxusercontent.com/u/18078337/GitHub/demo_images.zip';

dir_data    = fullfile(fileparts(mfilename('fullpath')), 'data');
dir_models  = fullfile(dir_data, 'models');
dir_cpn     = fullfile(dir_models, 'CPN');
dir_cspn    = fullfile(dir_models, 'CSPN');

mkdir_if_missing(dir_data);
mkdir_if_missing(dir_models);
mkdir_if_missing(dir_cpn);
mkdir_if_missing(dir_cspn);

if ~exist(fullfile(dir_cspn, 'Fluo-N2DL-HeLa-02-seg.caffemodel'), 'file')
    tmp_file = fullfile(dir_data, 'CSPN_models.zip');
    file_path = websave(tmp_file, opts.cspn_models);
    unzip(file_path, dir_cspn);
    delete(file_path)
end

if ~exist(fullfile(dir_cpn, 'Fluo-N2DL-HeLa-02.caffemodel'), 'file')
    tmp_file = fullfile(dir_data, 'CPN_models.zip');
    file_path = websave(tmp_file, opts.cpn_models);
    unzip(file_path, dir_cpn);
    delete(file_path)
end

if isempty(dir([dir_data, filesep, '*.png']))
    tmp_file = fullfile(dir_data, 'demo_images.zip');
    file_path = websave(tmp_file, opts.demo_images);
    unzip(file_path, dir_data);
    delete(file_path)
end

end
