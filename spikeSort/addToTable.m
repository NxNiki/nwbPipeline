function [T] = addToTable(T, varVal, varName)
%ADDTOTABLEW Summary of this function goes here
%   Detailed explanation goes here
T = addvars(T, varVal, 'NewVariableNames', varName);
end

