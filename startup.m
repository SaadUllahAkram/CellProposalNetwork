function startup()

cur_dir = pwd;
m_path  = mfilename('fullpath');
cpn_dir = fileparts(m_path);
addpath(genpath(fullfile(cpn_dir, 'functions')));
addpath(fullfile(cpn_dir, 'utils'));
mkdir_if_missing(fullfile(cpn_dir, 'bin'))
addpath(fullfile(cpn_dir, 'bin'));

cd(cpn_dir)
if ~exist('nms_mex', 'file')
  fprintf('Compiling nms_mex\n');
  mex -O -outdir bin CXXFLAGS="\$CXXFLAGS -std=c++11" -largeArrayDims ...
      functions/nms/nms_mex.cpp -output nms_mex;
end

if ~exist('nms_gpu_mex', 'file')
   fprintf('Compiling nms_gpu_mex\n');
   nvmex('functions/nms/nms_gpu_mex.cu', 'bin');
   delete('nms_gpu_mex.o');
end
activate_caffe(auto_select_gpu);

% Download data and models


cd(cur_dir)
end
