function s= setfields(s, varargin)
% adds multiple fields to a given struct, similar (but sets multiple fields) as setfield func. 
% If a field already exists it overwrites it.
% 
% Inputs:
%     s : struct to which fields will be added
% Outputs:
%     s : struct after fields have been added
% 
% Usage:
%     st = struct('a',1,'b',2);
%     st = setfields(st, {'c', 'd'}, {'first string', 4});% usage cell
%     st = setfields(st, 'E', 99, 'F', 'second_string');% usage simple
% 
% 

if iscell(varargin{1})% usage cell
    assert(length(varargin{1}) == length(varargin{2}), '# of fields differs from # of values')
    assert(length(varargin) == 2, 'Expected only 2 inputs')
    for i=1:length(varargin{1})
        s.(varargin{1}{i}) = varargin{2}{i};
    end
else
    assert(rem(length(varargin), 2) == 0, 'field names and values should be in pairs')
    for i=1:length(varargin)/2
        s.(varargin{2*(i-1)+1}) = varargin{2*i};
    end
end
% for i=1:length(fields)
%     s.(fields{i}) = vals{i};
% end
