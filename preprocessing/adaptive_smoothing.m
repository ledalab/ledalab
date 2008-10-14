function adaptive_smoothing
global leda2


winwidth_max = leda2.data.samplingrate*3;
[scs, winwidth] = smooth_adapt(leda2.data.conductance.data, 'gauss', winwidth_max, .00003);

if winwidth == winwidth_max
    warndlg('Data could not meet smoothness criteria','Adaptive smoothing');

elseif winwidth == 0
    warndlg('Data already satisfies smoothness criteria','Adaptive smoothing');

else
    leda2.data.conductance.data = scs(:)';

    refresh_data(1);
    file_changed(1);
    add2log(1,['Adaptive data smoothing applied (',num2str(winwidth),' samples gauss window)'],1,1,1);

end
