function showdriver
global leda2

if leda2.intern.batchmode || isempty(leda2.analysis)
    return;
end

analysis = leda2.analysis;
impulse = leda2.analysis.impulse;
overshoot = leda2.analysis.overshoot;
t_ext = [analysis.time_ext, leda2.data.time.data];


%Find relevant segments
start = leda2.gui.rangeview.start;
ende = leda2.gui.rangeview.start + leda2.gui.rangeview.range;
idx = find((analysis.onset > (start - 12)) & ([analysis.onset] <= ende));

[ts, cs, t_idx] = subrange(start-.5, ende+.5);


%Plot
set(leda2.gui.driver.ax,'Visible','on')
axes(leda2.gui.driver.ax)
delete(get(leda2.gui.driver.ax,'Children'));
hold on;

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
    ti = t_ext(imp_idx);
    fill([ti, ti(end), ti(1)], [analysis.driver(imp_idx), 0, 0], col, 'linestyle', 'none')

end
driver_cut = leda2.analysis.driver(length(analysis.time_ext)+1:end);
plot(ts, driver_cut(t_idx),'Color',[.2 .2 .8])

%overshoot
if 1%leda2.pref.showOvershoot    
    for i = idx

    ovs_idx = analysis.onset_idx(i)+(1:length(overshoot{i}))-1;
    ti = t_ext(ovs_idx);
    fill([ti, ti(end), ti(1)], [overshoot{i}*10, 0, 0], [.8 .6 .8], 'linestyle', 'none')
    plot(ti, overshoot{i}*10,'Color',[.8 .4 .4])

    end
end

set(leda2.gui.driver.ax, 'XLim', [start, ende],'YLim',[0, max(driver_cut)*1.1]);
