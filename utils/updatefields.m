function struct_default = updatefields(struct_default, struct_new)
% Updates the structure "struct_default" with values from "struct_new".
% 
% Inputs:
%     struct_default : structure with default values
%     struct_new : structure with new values
% Outputs:
%     struct_default : structure after its fields have been updated
%     

if isempty(struct_new)
    return
end
struct_default = catstruct(struct_default, struct_new);
end
