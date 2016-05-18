function [time, conductance, event] = getBiotraceMatData(filename)
% Import Biotrace .mat files
data = load(filename);

assert(isfield(data,'Sessioninfo'), 'Data file doesn''t contain ''Sessioninfo''. Is this a Biotrace .mat-export?');
assert(isfield(data,'Sessiondata'), 'Data file doesn''t contain ''Sessiondata''. Is this a Biotrace .mat-export?');
info = data.Sessioninfo;
signals = data.Sessiondata;

freq = 0;
for i = 1:size(info,1)
    r=regexp(info(i,:),'(?:Abtastrate|Output rate|Ausgabegeschwindigkeit):\t(?<samplerate>\d+)\tSamples/se[ck]','tokens');
    if ~isempty(r)
        freq = str2double(r{1}{1});
        break;
    end
end

assert(freq ~= 0, 'Sample rate not found in Biotrace header');

% 3 'header' rows
nSamples = size(signals,1)-3;

labels = signals(2,:);
scIdx = find(~cellfun(@isempty,regexp(labels,'(SC/GSR|EDA)')));
conductance = cell2mat(signals(4:end,scIdx(1)));
time = (0:nSamples-1)' / freq;

eventCol = find(~cellfun(@isempty,regexp(labels,'(Ereignisse|Events)')));
% correct for 'header' rows again
eventIdx = find(~cellfun(@isempty,signals(4:end,eventCol)))+3;
% Generate unique identifiers for events
[~,~,eventNids] = unique(signals(eventIdx,eventCol));
event = struct('time',num2cell(time(eventIdx)), ...
    'nid', num2cell(eventNids), ...
    'name', signals(eventIdx,eventCol));
end

