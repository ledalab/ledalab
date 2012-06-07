function [time, conductance, event] = gettext3data(fullpathname)

M = dlmread(fullpathname);

while 1
    answer = inputdlg({'SC data are in which column (indicate column number, e.g., 1)?','Event marker are in which column (leave empty if there is no event column):','Sampling frequency [Hz] (e.g. 100)'},'Provide information on data file format');
    if ~isempty(answer) %Cancel
        sc_col = str2double(answer{1});
        ev_col = str2double(answer{2});
        sr = str2double(answer{3});
    end
    if sc_col <= size(M,2) && (ev_col <= size(M,2) || isnan(ev_col)) && ~isnan(sr)
        break;
    end
end

conductance = M(:,sc_col);
time = (0:length(conductance)-1) / sr;

if ~isnan(ev_col)
    eventIdx = find(M(:,ev_col));
    for iEvent = 1:length(eventIdx)
        iEventIdx = eventIdx(iEvent);
        event(iEvent).time = time(iEventIdx);
        event(iEvent).nid = M(iEventIdx, ev_col);
        event(iEvent).name = num2str(M(iEventIdx, ev_col));
    end
else
    event = [];
end
