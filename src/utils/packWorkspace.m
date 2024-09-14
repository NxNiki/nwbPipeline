function workspaceStruct = packWorkspace()
% save all variables in workspace to a struct. This is used to avoid
% variables being overwritten when loading multiple .mat files with same
% variable names.

workspaceVars = evalin('base', 'who');
workspaceStruct = cell2struct(cellfun(@(x) evalin('base', x), workspaceVars, 'UniformOutput', false), workspaceVars, 1);
cellfun(@(x) evalin('base', ['clear ', x]), workspaceVars);

end
