function [time, conductance, event] = getBiotraceData(filename)

event = [];
headerLines = 14;
footerLines = 2;

%parsing file
iLine = 0;
fid = fopen(filename);
while  feof(fid) == 0
    iLine = iLine + 1;
    tline = fgetl(fid);
    if iLine == 9
        freq = strread(tline,'Ausgabegeschwindigkeit:\t%d\tSamples/sek.');
    elseif iLine == 12
        labels = strread(tline,'%s','delimiter','\t');
    end
end
fclose(fid);
nLines = iLine;  %total number of lines

nSamples = nLines - (headerLines + footerLines);
nSignals = length(labels) - 1;

%read data
M = dlmread(filename,'\t',[headerLines, 0, headerLines+nSamples-1, nSignals]);
scCol = find(strcmp(labels,'Sensor-13:SC/GSR')); %column of SC data
conductance = M(:,scCol);
time = M(:,1) / freq;

%get events
eventCol = find(strcmp(labels,'Ereignisse')); %column of events
eventIdx = find(M(:,eventCol));
for iEvent = 1:length(eventIdx)
    iEventIdx = eventIdx(iEvent);
    event(iEvent).time = time(iEventIdx);
    event(iEvent).nid = M(iEventIdx, eventCol);
    event(iEvent).name = num2str(M(iEventIdx, eventCol));
end
