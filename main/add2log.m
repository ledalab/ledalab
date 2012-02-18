function add2log(includetime, newinfo, ledalog, sessionlog, filelog, display, replaceline, showmsgbox)
%add2log(includetime, newinfo, ledalog, sessionlog, filelog, display, replaceline, showmsgbox)

global leda2

if nargin < 8
    showmsgbox = 0;
end
if nargin < 7
    replaceline = 0;
end
if nargin < 6
    display = 0;
end
if nargin < 5
    filelog = 0;
end
if nargin < 4
    sessionlog = 0;
end

if includetime
    newinfo = [datestr(now,13),': ',newinfo];
end

if ledalog
    fid_ll = fopen(fullfile(leda2.intern.install_dir,'ledalog.txt'),'a');
    fprintf(fid_ll,'%s\r\n', newinfo);
    fclose(fid_ll);
end

if sessionlog && ~leda2.intern.batchmode
    if replaceline
        leda2.intern.sessionlog = [{newinfo}; leda2.intern.sessionlog(2:end)];
    else
        leda2.intern.sessionlog = [{newinfo}; leda2.intern.sessionlog];
    end
    set(leda2.gui.infobox,'String',leda2.intern.sessionlog);
    %drawnow;
end

if ~isfield(leda2.file,'log')
    leda2.file.log = {};
end

if filelog
    leda2.file.log = [leda2.file.log; {newinfo}];
end

if display
    disp(newinfo)
end

if showmsgbox && leda2.intern.prompt && ~leda2.intern.batchmode
    msgbox(newinfo,'Info','warn')
end
