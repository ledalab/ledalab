function [time, conductance, event] = getPortilabData(filename)
%Import PortiLab data
%
%Mind: events (nid) must not be 0!

event = [];
headerLines = 3;
footerLines = 0;

%parsing file
iLine = 0;
fid = fopen(filename);
while  feof(fid) == 0
    iLine = iLine + 1;
    tline = fgetl(fid);
    if iLine == 1
        freq = strread(tline,'%d\tHz');
    elseif iLine == 3
        labels = strread(tline,'%s','delimiter','\t');
    end
end
fclose(fid);
nLines = iLine;  %total number of lines

nSamples = nLines - (headerLines + footerLines);
nSignals = length(labels) - 1;

%read data
M = dlmread(filename,'\t',[headerLines, 0, headerLines+nSamples-2, nSignals]);
skip_samples = 16;  %avoid data errors at beginning
M = M(1+skip_samples :end, :);


for i = 1:length(labels)
    scCol(i) = any(strfind(labels{i}, 'SCR'));
end
conductance = M(:,scCol);
time = (M(:,1) - M(1,1)) / freq;

%get events
eventCol = find(strcmp(labels,'Digi(Bit)')); %column of events
eventIdx = find(M(:,eventCol));
for iEvent = 1:length(eventIdx)
    iEventIdx = eventIdx(iEvent);
    event(iEvent).time = time(iEventIdx);
    event(iEvent).nid = M(iEventIdx, eventCol);
    event(iEvent).name = num2str(M(iEventIdx, eventCol));
end
