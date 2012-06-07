function [time, conductance, event] = gettext2data(fullpathname)

M = dlmread(fullpathname);

conductance = M(:,1);
answer = inputdlg('Enter Sampling Frequency:');
sr = str2double(answer);
time = (0:length(conductance)-1) / sr;

if size(M,2) > 1
    eventCol = 2;
    eventIdx = find(M(:,eventCol));
    for iEvent = 1:length(eventIdx)
        iEventIdx = eventIdx(iEvent);
        event(iEvent).time = time(iEventIdx);
        event(iEvent).nid = M(iEventIdx, eventCol);
        event(iEvent).name = num2str(M(iEventIdx, eventCol));
    end
else
    event = [];
end
