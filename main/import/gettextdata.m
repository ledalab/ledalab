function [time, conductance, event] = gettextdata(fullpathname)

% Matlab V7.x+
% fid = fopen(fullpathname);
% data = textscan(fid, '%f %f','headerlines',0);
% fclose(fid);
%
% time = data{1}';
% conductance = data{2}';
% event = {};

%V213
%[time, conductance] = textread(fullpathname,'%f\t%f','headerlines',0);
%event = {};

M = dlmread(fullpathname);

time = M(:,1);
conductance = M(:,2);
    
event = [];
if size(M,2) > 2
    eventCol = 3;
    eventIdx = find(M(:,eventCol));
    for iEvent = 1:length(eventIdx)
        iEventIdx = eventIdx(iEvent);
        event(iEvent).time = time(iEventIdx);
        event(iEvent).nid = M(iEventIdx, eventCol);
        event(iEvent).name = num2str(M(iEventIdx, eventCol));
    end
end
