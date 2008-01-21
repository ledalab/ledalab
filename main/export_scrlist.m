function export_scrlist
global leda2

if ~isempty(leda2.analyze.fit)
    phasics = leda2.analyze.fit.phasiccoef;
    file = [leda2.file.filename(1:end-4), '_scrlist.txt']; %leda2.file.pathname
    scrlist = [phasics.onset', phasics.amp' phasics.tau'];

    dlmwrite(file, scrlist, 'delimiter', '\t', 'precision', '%.4f', 'newline', 'pc');
    add2log(0,['SCR-List exported to ',file], 1,1,1,0,0,1);
end


%Possible future extensions:
% upgrade to export panel
% set amp threshold
% set time limits or rangeview
% option for xls export
% choose path/filename
