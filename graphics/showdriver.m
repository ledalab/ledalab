function showdriver
global leda2

if leda2.intern.batchmode || isempty(leda2.analysis)
    return;
end

analysis = leda2.analysis;


%Find relevant segments
start = leda2.gui.rangeview.start;
ende = leda2.gui.rangeview.start + leda2.gui.rangeview.range;
[ts, cs, t_idx] = subrange(start-.5, ende+.5);
driver = leda2.analysis.driver;
sr = leda2.data.samplingrate;
t = leda2.data.time.data;

%Plot
set(leda2.gui.driver.ax,'Visible','on')
axes(leda2.gui.driver.ax)
ch = get(leda2.gui.driver.ax,'Children');
delete(ch(strcmp(get(ch,'Tag'),'DriverComp')));
hold on;

if strcmp(leda2.analysis.method,'nndeco')
    impulse = leda2.analysis.impulse;
    overshoot = leda2.analysis.overshoot;
    %t_ext = [analysis.time_ext, leda2.data.time.data];
    
    
    idx = find((analysis.onset > (start - 12)) & ([analysis.onset] <= ende));
    
    %impulse
    for i = idx
        if mod(i,2)
            col = [.4 .6 .8];
        else
            col = [.5 .7 .9];
        end
        
        imp_nzidx = find(impulse{i});
        imp_nzidx = [imp_nzidx, imp_nzidx(end)+1];
        imp_idx = analysis.onset_idx(i)+imp_nzidx-1;
        ti = t(imp_idx);
        fill([ti, ti(end), ti(1)], [analysis.driver(imp_idx), 0, 0], col, 'linestyle', 'none')
        
    end
    plot(ts, driver(t_idx),'Color',[.2 .2 .8])
    
    %overshoot
    if 1%leda2.pref.showOvershoot
        for i = idx
            
            ovs_idx = analysis.onset_idx(i)+(1:length(overshoot{i}))-1;
            ti = t(ovs_idx);
            fill([ti, ti(end), ti(1)], [overshoot{i}*10, 0, 0], [.8 .6 .8], 'linestyle', 'none')
            plot(ti, overshoot{i}*10,'Color',[.8 .4 .4])
            
        end
    end
    
    kids = get(leda2.gui.driver.ax, 'Children');
    drivercomps = kids(1:length(idx)*3+1);
    set(drivercomps,'Tag','DriverComp');
    %     set(leda2.gui.driver.ax, 'Children',[kids((length(drivercomps)):end); drivercomps(end:-1:1)]);
    set(get(leda2.gui.driver.ax,'YLabel'),'String','Driver / Overshoot [ \muS]')
    
    
else
    
    driver0 = driver(t_idx);
    driver0((find(diff(sign(driver0)) ~= 0))+1) = 0;  %force zero transmission at zero value
    pdriver = driver0; %positiv data
    pdriver(pdriver < 0) = 0;
    ndriver = driver0; %negative data
    ndriver(ndriver > 0) = 0;
    fill([ts, ts(end) ts(1)], [pdriver,0,0],[.4 .6 .8])
    fill([ts, ts(end) ts(1)], [ndriver,0,0],[1 .8 .8])
    
    kids = get(leda2.gui.driver.ax, 'Children');
    drivercomps = kids(1:2);
    set(drivercomps,'Tag','DriverComp');
    %set(leda2.gui.driver.ax, 'Children',[kids((length(drivercomps)+1):end); drivercomps(end:-1:1)]);
    set(get(leda2.gui.driver.ax,'YLabel'),'String','Phasic Driver [\muS]')
    
end

set(leda2.gui.driver.ax, 'XLim', [start, ende], 'YLim',[min(driver(2*round(sr):length(driver)-2*round(sr)))-.02, max(1, max(driver(2*round(sr):length(driver)-2*round(sr)))*1.02)]);
