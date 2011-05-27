function [time, conductance, event] = getBiopacData(filename)
% Import BioPac File
%
% For automatic identification, EDA Channel must be labelled EDA... or GSR... or SC... and
% Event/Marker Channel must be labelled EVENT
% Otherwise channel can be selected manually what however should be avoided if using batch-analysis



acq = load_acq(filename);


sampletime = acq.hdr.graph.sample_time;         % time per sample
%timeoffset = acq.hdr.graph.time_offset/1000;    % ms -> sec  %if used, has to be considered in data.time and event.time
sr = 1000/sampletime;
nSamples = size(acq.data,1);
%nChannels = size(acq.data,2);

label = {acq.hdr.per_chan_data.comment_text};

%% Get EDA and TIME data
EDA_channel_idx = find(strncmpi(label,'EDA',3) | strncmpi(label,'GSR',3) | strncmpi(label,'SC',2));
%manual selection of eda-channel if it could not be identified automatically
if isempty(EDA_channel_idx) || length(EDA_channel_idx) > 1
    [EDA_channel_idx, ok] = listdlg('PromptString','Select EDA-channel:','SelectionMode','single','ListString',label);
end
conductance = acq.data(:,EDA_channel_idx);
% minimum of data should not be lower than 1 for correct display of tonic component
if min(conductance) < 1
    conductance = conductance - min(conductance) + 1;
end

time = (0:nSamples-1)/sr;


%% Get EVENTS/MARKER
event = [];

Event_channel_idx = find(strncmpi(label,'EVENT',5));
%manual selection of event-channel if it could not be identified automatically
if isempty(Event_channel_idx) || length(Event_channel_idx) > 1
    [Event_channel_idx, ok] = listdlg('PromptString','Select event-channel:','SelectionMode','multiple','ListString',[label,{'none'}]);
    if ~ok  || Event_channel_idx(end) == length(label)+1  % Cancel or 'none' selected
        return;
    end
end

onsetL = [];
durationL = [];
eventTypeL = [];
if length(Event_channel_idx) == 1
    ev_s = acq.data(:, Event_channel_idx);
    [onsetL, durationL, eventTypeL] = readEventSignal(ev_s, sr);

else  % in case of multiple event-channel
    for iChannel = 1:length(Event_channel_idx)
        iEvent = Event_channel_idx(iChannel);
        ev_s = acq.data(:, iEvent);
        [onsL, durL, evL] = readEventSignal(ev_s, sr);

        onsetL = [onsetL; onsL];
        durationL = [durationL; durL];
        eventTypeL = [eventTypeL; ones(length(onsL),1)*iEvent];
    end
    [onsetL, idx] = sort(onsetL);
    eventTypeL = eventTypeL(idx);
    durationL = durationL(idx);

end

%setup event struct
for iEvent = 1:length(eventTypeL)
    event(iEvent).time = onsetL(iEvent);
    event(iEvent).nid = eventTypeL(iEvent);
    event(iEvent).name = num2str(eventTypeL(iEvent));
    event(iEvent).userdata.duration = durationL(iEvent);
end
