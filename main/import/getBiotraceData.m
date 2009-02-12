function [time, conductance, event] = getBiotraceData(filename)
%Import Biotrace data
%
%Mind: events (nid) must not be 0!

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
skip_samples = 1;  %avoid data errors at beginning
M = M(1+skip_samples :end, :);


for i = 1:length(labels)
    scCol(i) = any(strfind(labels{i}, 'SC/GSR'));
end
scIdx = find(scCol);
conductance = M(:,scIdx(1));
time = (M(:,1) - M(1,1)) / freq;

%get events
eventCol = find(strcmp(labels,'Ereignisse')); %column of events
eventIdx = find(M(:,eventCol));
for iEvent = 1:length(eventIdx)
    iEventIdx = eventIdx(iEvent);
    event(iEvent).time = time(iEventIdx);
    event(iEvent).nid = M(iEventIdx, eventCol);
    event(iEvent).name = num2str(M(iEventIdx, eventCol));
end
