function leda_click
global leda2

if ~any(strcmp(fieldnames(leda2.data),'time')) %no data loaded yet
    return;
end


point1 = get(leda2.gui.overview.ax,'currentpoint');
finalRect = rbbox;
point2 = get(leda2.gui.overview.ax,'currentpoint');
point1 = point1(1,1:2);
point2 = point2(1,1:2);
pt1 = min(point1, point2); %left-bottom (x,y)
pt2 = max(point1, point2); %right-top (x,y)

if (pt1(1) > 0-leda2.data.samplingrate*10) && (pt1(1) < leda2.data.N+leda2.data.samplingrate*10) && (pt1(2) > 0) && (pt1(2) < leda2.data.conductance.max+1) %Hit within overview-axes
    pt1(1) = withinlimits(pt1(1), 0, leda2.data.N);
    leda2.gui.rangeview.start = pt1(1); 
    
    if norm(pt2-pt1) > 10 && (pt2(1) > 0) && (pt2(1) < leda2.data.N) && (pt2(2) > 0) && (pt2(2) < leda2.data.conductance.max+1)
        leda2.gui.rangeview.range = pt2(1) - pt1(1);
    end
    change_range;
end
set(leda2.gui.rangeview.slider,'value',leda2.gui.rangeview.start);
