function st = addfield(st, fieldname, mat)
% adds a new field to the structure
% 
% Inputs:
%     st : struct
%     fieldname: string containing the name of field to be added
%     mat : matrix containing the data which will be added to the structure
% 

n       = size(mat, 1);
data    = num2cell(mat, 2);
[st(1:n).(fieldname)] = data{:};

end