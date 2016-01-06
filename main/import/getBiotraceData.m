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
    if iLine == 1   %based on content in first line of file determine Biotrace language format %%MB19.3.2014
        if strcmp(tline,'Unbearbeiteter Daten-Export (tab separat)')
            lang_format = 'GE';
        elseif strcmp(tline,'RAW Data export file (tab separated)')
            lang_format = 'UK';
        else
            error('The first line doesn''t seem to be from a Biotrace text export.');
        end
    end
    
    if iLine == 9
        if strcmp(lang_format, 'GE') %%MB19.3.2014
            freq = sscanf(tline,'Ausgabegeschwindigkeit:\t%d\tSamples/sek.');
        elseif  strcmp(lang_format, 'UK')
            freq = sscanf(tline,'Output rate:\t%d\tSamples/sec.');
        end
    end
    
    if iLine == 12
        labels = strsplit(tline,'\t');
    end
end
fclose(fid);
nLines = iLine;  %total number of lines

nSamples = nLines - (headerLines + footerLines);
nSignals = length(labels) - 1;

%read data
skip_samples = 1;  %avoid data errors at beginning
M = dlmread(filename,'\t',[headerLines+skip_samples, 0, headerLines+nSamples-1, nSignals]);


for i = 1:length(labels)
    scCol(i) = any(strfind(labels{i}, 'SC/GSR'));
end
scIdx = find(scCol);
conductance = M(:,scIdx(1)); %take first SC channel
time = (M(:,1) - M(1,1)) / freq;

%get events
eventCol = find(strcmp(labels,'Ereignisse') | strcmp(labels,'Events')); %column of events  %%MB19.3.2014
eventIdx = find(M(:,eventCol));
for iEvent = 1:length(eventIdx)
    iEventIdx = eventIdx(iEvent);
    event(iEvent).time = time(iEventIdx);
    event(iEvent).nid = M(iEventIdx, eventCol);
    event(iEvent).name = num2str(M(iEventIdx, eventCol));
end
