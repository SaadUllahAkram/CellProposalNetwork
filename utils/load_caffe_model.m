function [model1, model2] = load_caffe_model(def1, weights1, def2, weights2)
% loads caffe models from .caffemodel files
% 
% Inputs:
%     def       : full path of network definition file
%     weights   : full path of file containing trained model weights
% 

model1     = caffe.Net(def1, 'test');% network for testing
model1.copy_from(weights1);

if nargin == 4
    model2    = caffe.Net(def2, 'test');% network for testing
    model2.copy_from(weights2);
else
    model2    = [];
end

end
