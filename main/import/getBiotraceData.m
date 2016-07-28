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
freq = 0;

% First line should be the characteristic Biotrace Header
if ~any(strcmp(fgetl(fid),{'Unbearbeiteter Daten-Export (tab separat)','RAW Data export file (tab separated)'}))
    error('The first line doesn''t seem to be from a Biotrace text export.');
end
% Skip empty lines
fgetl(fid); fgetl(fid);

while ~feof(fid)
    tline = fgetl(fid);
    if isempty(tline) || all(tline == ' ')
        break;
    end
    res = regexp(tline,'(?:Abtastrate|Output rate|Ausgabegeschwindigkeit):\t(\d+)\tSamples/se[ck]','tokens');
    if ~isempty(res)
        freq = str2num(res{1}{1});
    end
end    
% Skip line with sample rates
fgetl(fid);
labels = strsplit(fgetl(fid),'\t');
fgetl(fid); fgetl(fid); % skip 2 empty lines

% count samples
nSamples = 0;
while ~feof(fid)
    tline = fgetl(fid);
    if isempty(tline) || all(tline == ' ')
        break;
    end
    nSamples = nSamples + 1;
end
fclose(fid);

nSignals = length(labels) - 1;

%read data
skip_samples = 1;  %avoid data errors at beginning
M = dlmread(filename,'\t',[headerLines+skip_samples, 0, nSamples-skip_samples+headerLines, nSignals]);

% Which column label(s) contain either SC/GSR or EDA?
scIdx = find(~cellfun(@isempty,regexp(labels,'(SC/GSR|EDA)')));
if isempty(scIdx)
    error([filename ' doesn''t contain any SC / EDA channels']);
end
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
