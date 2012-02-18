function refresh_fitoverview
global leda2

if isempty(leda2.analysis) || leda2.intern.batchmode
    return;
end


%Get downsample factor for overview
N = leda2.data.N;
if  N > 2000
    fac = floor(N/2000);
else
    fac = 1;
end


if leda2.file.version < 3.12 %correct for extended data range of older versions, and downsample
    n_offset = length(leda2.analysis.time_ext);
    remainder = leda2.analysis.remainder(n_offset+1:fac:end);
    driver = leda2.analysis.driver(n_offset+1:fac:end);
    tonicData = leda2.analysis.tonicData(1:fac:end);
    phasicData = leda2.analysis.phasicData(1:fac:end);
    
else %V3.1.2+
    remainder = leda2.analysis.remainder(1:fac:end);
    driver = leda2.analysis.driver(1:fac:end);
    tonicData = leda2.analysis.tonicData(1:fac:end);
    phasicData = leda2.analysis.phasicData(1:fac:end);
end

time = leda2.data.time.data(1:fac:end);



if isempty(leda2.gui.overview.driver) %setup
    axes(leda2.gui.overview.ax);
    
    x = [time time(end) time(1)];
    
    %overshoot
    if strcmp(leda2.analysis.method,'nndeco')
        overshoot_sc = leda2.gui.overview.min + remainder / max(.1,max(remainder)) * (leda2.gui.overview.max-leda2.gui.overview.min)/15;
        leda2.gui.overview.overshoot = fill(x, [overshoot_sc, 0, 0], [.8 .4 .4], 'linestyle', 'none','ButtonDownFcn','leda_click(1)');
    end
    
    %driver
    driver_sc = leda2.gui.overview.min + driver / max(1,max(driver)) * (leda2.gui.overview.max-leda2.gui.overview.min)/2;
    leda2.gui.overview.driver = fill(x, [driver_sc, 0, 0], [.5 .7 .9], 'linestyle', 'none','ButtonDownFcn','leda_click(1)');
    
    %tonic
    leda2.gui.overview.tonic_component = fill(x, [tonicData 0 0], [.5 .5 .5], 'linestyle', 'none','ButtonDownFcn','leda_click(1)');
    
    %phasic
    y = tonicData + phasicData;
    leda2.gui.overview.phasic = fill(x, [y 0 0], [.0 .5 .7], 'linestyle', 'none','ButtonDownFcn','leda_click(1)');
    
    n = 4;
    kids = get(leda2.gui.overview.ax, 'Children');
    fitcomps = kids(1:n);
    set(fitcomps,'Tag','FitComp');
    set(leda2.gui.overview.ax, 'Children',[kids((n+1):end); fitcomps(n:-1:1)]);
    set(gca,'XLim', [time(1), time(end)]);
    
    
else %refresh
    axes(leda2.gui.overview.ax);
    
    set(leda2.gui.overview.tonic_component, 'YData', [tonicData 0 0]);
    
    y = tonicData + phasicData;
    set(leda2.gui.overview.phasic, 'YData', [y 0 0]);
    
    driver_sc = leda2.gui.overview.min + driver / max(1,max(driver)) * (leda2.gui.overview.max-leda2.gui.overview.min)/2;
    set(leda2.gui.overview.driver, 'YData', [driver_sc, 0, 0]);
    
    if strcmp(leda2.analysis.method,'nndeco')
        overshoot_sc = leda2.gui.overview.min + remainder / max(.1,max(remainder)) * (leda2.gui.overview.max-leda2.gui.overview.min)/10;
        set(leda2.gui.overview.overshoot, 'YData', [overshoot_sc, 0, 0]);
        %leda2.gui.overview.overshoot = fill([time time(end) time(1)], [overshoot_sc, 0, 0], [.8 .4 .4], 'linestyle', 'none','ButtonDownFcn','leda_click(1)');
    end
    
end
