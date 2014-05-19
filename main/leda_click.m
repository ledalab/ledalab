function leda_click(ax_flag)
global leda2

if ~any(strcmp(fieldnames(leda2.data),'time')) %no data loaded yet
    return;
end

if ax_flag == 1 %overview display
    point1 = get(leda2.gui.overview.ax,'currentpoint');
    finalRect = rbbox;
    point2 = get(leda2.gui.overview.ax,'currentpoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    pt1 = min(point1, point2); %left-bottom (x,y)
    pt2 = max(point1, point2); %right-top (x,y)

    if (pt1(1) > 0-leda2.data.samplingrate*10) && (pt1(1) < leda2.data.N+leda2.data.samplingrate*10) && (pt1(2) < leda2.data.conductance.max+1) %Hit within overview-axes   %% MB&& (pt1(2) > 0) 
        pt1(1) = withinlimits(pt1(1), 0, leda2.data.time.data(end));
        leda2.gui.rangeview.start = pt1(1);

        if norm(pt2-pt1) > 2 && (pt2(1) > 0) && (pt2(1) < leda2.data.N) && (pt2(2) > 0) && (pt2(2) < leda2.data.conductance.max+1)
            pt2(1) = withinlimits(pt2(1), 0, leda2.data.time.data(end));
            leda2.gui.rangeview.range = pt2(1) - pt1(1);
        end
        change_range;
    end
    set(leda2.gui.rangeview.slider,'value',leda2.gui.rangeview.start);


elseif ax_flag == 2 %epoch display
    point1 = get(leda2.gui.rangeview.ax,'currentpoint');
    finalRect = rbbox;
    point2 = get(leda2.gui.rangeview.ax,'currentpoint');
    point1 = point1(1,1:2);
    point2 = point2(1,1:2);
    pt1 = min(point1, point2); %left-bottom (x,y)
    pt2 = max(point1, point2); %right-top (x,y)

    if (pt1(1) > 0-leda2.data.samplingrate*.1) && (pt1(1) < leda2.data.N+leda2.data.samplingrate*.1) && (pt1(2) > leda2.gui.rangeview.bottom) && (pt1(2) < leda2.gui.rangeview.top) %Hit within rangeview-axes
        pt1(1) = withinlimits(pt1(1), 0, leda2.data.N);

        if norm(pt2-pt1) > 1
            leda2.gui.rangeview.start = pt1(1);

            if (pt2(1) > 0) && (pt2(1) < leda2.data.N) && (pt2(2) > leda2.data.conductance.min-1) && (pt2(2) < leda2.data.conductance.max+1)
                leda2.gui.rangeview.range = pt2(1) - pt1(1);
            end

        else %when clicking in epoch window, center to this spot
            leda2.gui.rangeview.start = pt1(1) - leda2.gui.rangeview.range/2;
        end

        change_range;
    end
    set(leda2.gui.rangeview.slider,'Value',leda2.gui.rangeview.start);

end
