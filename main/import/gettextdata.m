function [time, conductance, event] = gettextdata(fullpathname)

% Matlab V7.x+
% fid = fopen(fullpathname);
% data = textscan(fid, '%f %f','headerlines',0);
% fclose(fid);
% 
% time = data{1}';
% conductance = data{2}';
% event = {};

[time, conductance] = textread(fullpathname,'%f\t%f','headerlines',0);
event = {};

