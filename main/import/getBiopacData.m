function [time, conductance, event] = getBiopacData(filename)
% Import BioPac File via BioSig Toolbox
% EDA Channel must labelled EDA
% Marker Channel must be labeled T0-T9


%%Check if BioSig is installed
if exist('biosigVersion','file') ~= 2
    add2log(0,'Import failed. BioSig not found on Matlab search path. BioPac import requires BioSig toolbox (see http://biosig.sourceforge.net/). ',1,1,0,0,0,1);
    time = []; conductance = []; event = [];
    return;
end


%%Read BioPac file
warning off
[s HDR] = sload(filename);
warning on
%HDR.Label'

%%Get EDA data
EDA_channel_idx = find(strncmpi(HDR.Label,'EDA',3) | strncmpi(HDR.Label,'GSR',3));
conductance = s(:,EDA_channel_idx);

sr = HDR.SampleRate;
time = (0:HDR.NRec-1)/sr;

if length(conductance) < 10 || length(time) < 10
    add2log(0,'Import failed. Valid data could not be identified.',1,1,0,0,0,1);
    time = []; conductance = []; event = [];
    return;
end
    
%%Get events
%get event channels
eventChannel_idx = [];
eventID = [];
%eventName = {};
for iLabel = 1:length(HDR.Label)
    if regexp(HDR.Label{iLabel}(1:2),'T[1-9]') == 1
        eventChannel_idx = [eventChannel_idx, iLabel];
        eventID = [eventID, str2double(HDR.Label{iLabel}(2))];
        %eventName = [eventName, HDR.Label{iLabel}(1:2)];
    end
end

%get events per channel
eventTypeL = [];
onsetL = [];
durationL = [];
for iEventType = 1:length(eventID);
    ev_s = s(:,eventChannel_idx(iEventType));  %continuous event data
    onset = (find(diff(ev_s) > 0) + 1)/sr;
    duration = (find(diff(ev_s) < 0) - find(diff(ev_s) > 0)) / sr;
    
    eventTypeL = [eventTypeL; ones(length(onset),1)*eventID(iEventType)];
    onsetL = [onsetL; onset];
    durationL = [durationL; duration];
    
end
[onsetL, idx] = sort(onsetL);
eventTypeL = eventTypeL(idx);
durationL = durationL(idx);

%setup event struct
event = [];
for iEvent = 1:length(eventTypeL)
    event(iEvent).time = onsetL(iEvent);
    event(iEvent).nid = eventTypeL(iEvent);
    event(iEvent).name = ['T',num2str(eventTypeL(iEvent))];
    event(iEvent).userdata.duration = durationL(iEvent);
end

%figure; plot(s(:,4),'k')
%hold on; plot(s(:,8)/100,'r')
