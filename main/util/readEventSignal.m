function [onsetL, durationL, eventTypeL] = readEventSignal(ev_s, sr)

% Convert continuous event-signal to discrete event data 

ev_s = round(ev_s);     % only integer event-ids accepted

val = unique(ev_s);     % different unique values in event-signal

if length(val) > 128
    error('Too many different event-types detected')  % event-types probably not correctly identified 
end
baseline_val = val(1);
event_val = val(2:end);

ev_s = [baseline_val; ev_s(:); baseline_val];  %patted, to account for possibility of markers in first or last sample

onsetL = [];
%offsetL = [];
durationL = [];
eventTypeL = [];

for iEv = 1:length(event_val)
    ev_on = (ev_s == event_val(iEv));
    ons_idx = find(diff(ev_on) > 0);  %+1 due to diff not necessary in patted signal
    offs_idx = find(diff(ev_on) < 0);

    ons = ons_idx/sr;
    offs = (offs_idx-1)/sr;
    duration = offs - ons;

    onsetL = [onsetL; ons];
    %offsetL = [offsetL; offs];
    durationL = [durationL; duration];
    eventTypeL = [eventTypeL; ones(length(ons),1)*event_val(iEv)];

end

if length(onsetL) > 1000
    error('Too many events detected (> 1000)')  % event-types probably not correctly identified
end

[onsetL, sidx] = sort(onsetL);
%offsetL = offsetL(sidx);
durationL = durationL(sidx);
eventTypeL = eventTypeL(sidx);

% figure; plot(time, ev_s(2:end-1),'k')
% hold on; plot(onsetL,eventTypeL,'g*'); plot(offsetL,eventTypeL,'r*')
