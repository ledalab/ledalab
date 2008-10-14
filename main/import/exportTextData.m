function exportTextData
global leda2

M = [leda2.data.time.data', leda2.data.conductance.data'];

if ~isempty(leda2.data.events)

    eventCol = zeros(size(M,1),1);

    for iEvent = 1:leda2.data.events.N
        evIdx = time_idx(leda2.data.time.data, leda2.data.events.event(iEvent).time);
        eventCol(evIdx) = leda2.data.events.event(iEvent).nid;
    end

    M = [M, eventCol];

end

file = fullfile(leda2.file.pathname, leda2.file.filename);
file = [file(1:end-4),'.txt'];
dlmwrite(file, M,'delimiter','\t','newline','pc')  %,'precision','%5.5f'

add2log(1,[' Data exported to file ',file],1,1,1);
