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

% M = dlmread(fullpathname);
% time = table2array(M(:,1));
% conductance = M(:,2);

M = readtable(fullpathname);
time = table2array(M(:,1));
conductance = table2array(M(:,2));
    
event = [];
if size(M,2) > 2
    eventCol = 3;
    evt = table2array(M(:, eventCol));
    eventIdx = find(~cellfun(@isempty, evt));
%     eventIdx = find(M(:,eventCol));
    nid = 1;
    for iEvent = 1:length(eventIdx)
        iEventIdx = eventIdx(iEvent);
        event(iEvent).time = time(iEventIdx);
        event(iEvent).nid = nid;%M(iEventIdx, eventCol);
        event(iEvent).name = evt{iEventIdx};
        nid = nid + 1;
    end
end
