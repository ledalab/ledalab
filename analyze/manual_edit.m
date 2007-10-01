function manual_edit(action)
global leda2

if nargin < 1,
    if ~leda2.analyze.current.manualedit
        action = 'start_medit';
    else
        action = 'exit_medit';
    end
end

switch action,
    case 'start_medit', start_medit;
    case 'select_scr', select_scr;
    case 'change_scr', modify_scr(1);
    case 'add_scr', modify_scr(2);
    case 'delete_scr', modify_scr(3);
    case 'select_tp', select_tp;
    case 'change_tp', modify_tp(1);
    case 'add_tp', modify_tp(2);
    case 'delete_tp', modify_tp(3);
    case 'exit_medit', exit_medit;
end


function start_medit
global leda2

if isempty(leda2.analyze.fit)
    add2log(0,'No Fit available!',0,0,0,0,0,1);
    return;
end
add2log(1,' Edit Fit',1,1);
leda2.analyze.current.manualedit = 1;

pos  = get(leda2.gui.epochinfo.list_scr, 'Position');
set(leda2.gui.epochinfo.list_scr, 'Position',[pos(1) pos(2)+.06 pos(3) pos(4)-.06]);
pos  = get(leda2.gui.epochinfo.list_tonic, 'Position');
set(leda2.gui.epochinfo.list_tonic, 'Position',[pos(1) pos(2)+.06 pos(3) pos(4)-.06]);

drawnow;
leda2.analyze.epoch = [];
change_range; %epoch is defined


function select_scr
global leda2

if isempty(leda2.analyze.fit) || ~leda2.analyze.current.manualedit
    return;
end
parset = leda2.analyze.epoch.parset;
if isempty(parset.onset)
    return;
end

isel = get(leda2.gui.epochinfo.list_scr,'Value');
set(leda2.gui.manualedit.edit_ons,'String',parset.onset(isel));
set(leda2.gui.manualedit.edit_amp,'String',parset.amp(isel));
set(leda2.gui.manualedit.edit_tau1,'String',parset.tau(1,isel));
set(leda2.gui.manualedit.edit_tau2,'String',parset.tau(2,isel));


function modify_scr(type)
global leda2

isel = get(leda2.gui.epochinfo.list_scr,'Value');
epoch = leda2.analyze.epoch;

if ~isempty(findstr(',',[get(leda2.gui.manualedit.edit_ons,'String'),get(leda2.gui.manualedit.edit_amp,'String'),get(leda2.gui.manualedit.edit_tau1,'String'),get(leda2.gui.manualedit.edit_tau2,'String')]))
    add2log(0,'Use ''.'' for decimal point instead of '',''!',0,0,0,0,0,1);
    return;
end
onset = str2double(get(leda2.gui.manualedit.edit_ons,'String'));
amp = str2double(get(leda2.gui.manualedit.edit_amp,'String'));
tau1 = str2double(get(leda2.gui.manualedit.edit_tau1,'String'));
tau2 = str2double(get(leda2.gui.manualedit.edit_tau2,'String'));
%check values
if ~(isempty(onset) || isempty(amp) || isempty(tau1) || isempty(tau2)) && (isnumeric(onset) && isnumeric(amp) && isnumeric(tau1) && isnumeric(tau2)) && length(onset)*length(amp)*length(tau1)*length(tau2) == 1 && (onset > epoch.start && onset < epoch.end)

    if type == 1 %change_scr
        epoch.parset.onset(isel) = onset;
        epoch.parset.amp(isel) = amp;
        epoch.parset.tau(1:2, isel) = [tau1; tau2];
        set(leda2.gui.epochinfo.list_scr,'Value', length(find(epoch.parset.onset < onset))+1);
    elseif type == 2 %add_scr
        epoch.parset.onset(end+1) = onset; %will be sorted in update_fit
        epoch.parset.amp(end+1) = amp;
        epoch.parset.tau(1:2, end+1) = [tau1; tau2];
    elseif type == 3 %delete_scr
        epoch.parset.onset = [epoch.parset.onset(1:isel-1), epoch.parset.onset(isel+1:end)];
        epoch.parset.amp = [epoch.parset.amp(1:isel-1), epoch.parset.amp(isel+1:end)];
        epoch.parset.tau = [epoch.parset.tau(1:2,1:isel-1), epoch.parset.tau(1:2,isel+1:end)];
        set(leda2.gui.epochinfo.list_scr,'Value', 1);
    end

    epoch.parset.error = fiterror_parset(epoch, epoch.parset);
    epoch.error = epoch.parset.error;

    leda2.analyze.epoch = epoch;
    update_fit(3);
    refresh_epochinfo;
    refresh_progressinfo;
    if type == 2, set(leda2.gui.epochinfo.list_scr,'Value', length(find(epoch.parset.onset < onset))+1); end
    showfit;

else
    msgbox('Entered values are not valid');
end


function select_tp
global leda2

if isempty(leda2.analyze.fit) || ~leda2.analyze.current.manualedit
    return;
end
parset = leda2.analyze.epoch.parset;
if isempty(parset.groundtime)
    return;
end

isel = get(leda2.gui.epochinfo.list_tonic,'Value');
set(leda2.gui.manualedit.edit_t,'String',parset.groundtime(isel));
set(leda2.gui.manualedit.edit_g,'String',parset.groundlevel(isel));


function modify_tp(type)
global leda2

isel = get(leda2.gui.epochinfo.list_tonic,'Value');
epoch = leda2.analyze.epoch;

if ~isempty(findstr(',',[get(leda2.gui.manualedit.edit_t,'String'),get(leda2.gui.manualedit.edit_g,'String')]))
    add2log(0,'Use ''.'' for decimal point instead of '',''!',0,0,0,0,0,1);
    return;
end
groundtime = str2double(get(leda2.gui.manualedit.edit_t,'String'));
groundlevel = str2double(get(leda2.gui.manualedit.edit_g,'String'));
%check values
if ~(isempty(groundtime) || isempty(groundlevel)) && (isnumeric(groundtime) && isnumeric(groundlevel)) && length(groundtime)*length(groundlevel) == 1 && (groundtime > epoch.start && groundtime < epoch.end)

    if type == 1 %change_tp
        epoch.parset.groundtime(isel) = groundtime;
        epoch.parset.groundlevel(isel) = groundlevel;
        set(leda2.gui.epochinfo.list_tonic,'Value', length(find(epoch.parset.groundtime < groundtime))+1);
    elseif type == 2 %add_tp
        epoch.parset.groundtime(end+1) = groundtime;
        epoch.parset.groundlevel(end+1) = groundlevel;
        [epoch.parset.groundtime, idx] = sort(epoch.parset.groundtime);
        epoch.parset.groundlevel = epoch.parset.groundlevel(idx);
    elseif type == 3 %delete_tp
        epoch.parset.groundtime = [epoch.parset.groundtime(1:isel-1), epoch.parset.groundtime(isel+1:end)];
        epoch.parset.groundlevel = [epoch.parset.groundlevel(1:isel-1), epoch.parset.groundlevel(isel+1:end)];
        set(leda2.gui.epochinfo.list_tonic,'Value', 1);
    end

    epoch.parset.error = fiterror_parset(epoch, epoch.parset);
    epoch.error = epoch.parset.error;

    leda2.analyze.epoch = epoch;
    update_fit(3);
    refresh_epochinfo;
    refresh_progressinfo;
    if type == 2, set(leda2.gui.epochinfo.list_tonic,'Value', length(find(epoch.parset.groundtime < groundtime))+1); end
    showfit;
else
    msgbox('Entered values are not valid');
end


function exit_medit
global leda2

if leda2.analyze.current.manualedit
    leda2.analyze.current.manualedit = 0;

    set(leda2.gui.manualedit.edit_ons, 'String','');
    set(leda2.gui.manualedit.edit_amp, 'String','');
    set(leda2.gui.manualedit.edit_tau1, 'String','');
    set(leda2.gui.manualedit.edit_tau2, 'String','');
    set(leda2.gui.manualedit.edit_t, 'String','');
    set(leda2.gui.manualedit.edit_g, 'String','');

    pos  = get(leda2.gui.epochinfo.list_scr, 'Position');
    set(leda2.gui.epochinfo.list_scr, 'Position',[pos(1) pos(2)-.06 pos(3) pos(4)+.06]);
    pos  = get(leda2.gui.epochinfo.list_tonic, 'Position');
    set(leda2.gui.epochinfo.list_tonic, 'Position',[pos(1) pos(2)-.06 pos(3) pos(4)+.06]);
end
