function [time, conductance, event] = getPsychlabData(fullpathname)

M = dlmread(fullpathname);

conductance = M(:,1);
answer = inputdlg('Enter Sampling Frequency:');
sr = str2double(answer);
time = (0:length(conductance)-1) / sr;

eventCol = 2;
marker = M(:,eventCol);
%get events
eventIdx = find(marker > 0 & diff([0;marker]) & diff([marker;0]) == 0);  %marker value > 0, marker channel shows difference, new marker value is kept in next sample
for iEvent = 1:length(eventIdx)
    iEventIdx = eventIdx(iEvent);
    event(iEvent).time = time(iEventIdx);
    event(iEvent).nid = M(iEventIdx, eventCol);
    event(iEvent).name = num2str(M(iEventIdx, eventCol));
end
