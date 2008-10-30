function [time, conductance, event] = getVitaportData(filename)
%Import PortiLab data
%
%Mind: events (nid) must not be 0!

event = [];
headerLines = 5;
footerLines = 1;

%parsing file
iLine = 0;
fid = fopen(filename);
while  feof(fid) == 0
    iLine = iLine + 1;
    tline = fgetl(fid);
    if iLine == 1
        labels = strread(tline,'%s','delimiter','\t');
    elseif iLine == 5
            fac = strread(tline,'%s','delimiter','\t');
            fac = str2double(fac{2});
    end
end
fclose(fid);
nLines = iLine;  %total number of lines

nSamples = nLines - (headerLines + footerLines);
nSignals = length(labels) - 1;
freq = 16;

%read data
M = dlmread(filename,'\t',[headerLines, 0, headerLines+nSamples-1, nSignals]);
skip_samples = 0;  %avoid data errors at beginning
M = M(1+skip_samples :end, :);


for i = 1:length(labels)
    scCol(i) = any(strfind(labels{i}, 'GSR'));
    eventCol(i) = any(strfind(labels{i},'MARKER'));
end
conductance = M(:,scCol)/300; %fac
time = (0:nSamples-1) / freq;
marker = M(:,eventCol);

%get events
eventIdx = find(marker > 0 & diff([0;marker]) & diff([marker;0]) == 0);  %marker value > 0, marker channel shows difference, new marker value is kept in next sample
for iEvent = 1:length(eventIdx)
    iEventIdx = eventIdx(iEvent);
    event(iEvent).time = time(iEventIdx);
    event(iEvent).nid = M(iEventIdx, eventCol);
    event(iEvent).name = num2str(M(iEventIdx, eventCol));
end
