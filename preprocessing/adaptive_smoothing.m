function adaptive_smoothing
global leda2


if ~isempty(leda2.analysis) && ~leda2.intern.batchmode
    cmd = questdlg('The current fit will be deleted!','Warning','Continue','Cancel','Continue');
    if isempty(cmd) || strcmp(cmd, 'Cancel')
        return
    end
end
delete_fit(0);
refresh_data(~leda2.intern.batchmode);
file_changed(1);



winwidth_max = leda2.data.samplingrate*3;
[scs, winwidth] = smooth_adapt(leda2.data.conductance.data, 'gauss', winwidth_max, .00003);

if winwidth == winwidth_max && ~leda2.intern.batchmode
    warndlg('Data could not meet smoothness criteria','Adaptive smoothing');
    
elseif winwidth == 0 && ~leda2.intern.batchmode
    warndlg('Data already satisfies smoothness criteria','Adaptive smoothing');
    
else
    leda2.data.conductance.data = scs(:)';
    
    refresh_data(~leda2.intern.batchmode);
    file_changed(1);
    add2log(1,['Adaptive data smoothing applied (',num2str(winwidth),' samples gauss window)'],1,1,1);
    
end
