function [time, conductance, event] = getBiopacMatData(filename)

D = load(filename);

conductance = D.data(:,1);
conductance = conductance - min(conductance) + 1;
sr = 1000/D.isi;
time = (1:length(conductance))/sr;

%setup event struct
event = [];

if size(D.data,2)>1
    ev_s = D.data(:,end);
    clear D;

    [onsetL, durationL, eventTypeL] = readEventSignal(ev_s, sr);

    for iEvent = 1:length(eventTypeL)
        event(iEvent).time = onsetL(iEvent);
        event(iEvent).nid = eventTypeL(iEvent);
        event(iEvent).name = ['T',num2str(eventTypeL(iEvent))];
        event(iEvent).userdata.duration = durationL(iEvent);
    end
end
