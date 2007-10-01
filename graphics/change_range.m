function change_range
global leda2

rgview = leda2.gui.rangeview;
time = leda2.data.time;

%check if field (X-values) is within overview
if rgview.start < 0, rgview.start = 0; end
if rgview.range > time.data(end),
    rgview.range = time.data(end);
end
if (rgview.start + rgview.range) >= time.data(end),
    rgview.start = time.data(end) - rgview.range;
end
set(rgview.edit_start,'String',num2str(rgview.start,'%3.2f'))
set(rgview.edit_range,'String',num2str(rgview.range,'%3.2f'))
set(rgview.edit_end,'String',num2str(rgview.start + rgview.range,'%3.2f'))

%check Y-limits for overview-field = rangeview
cond_rg.data = leda2.data.conductance.data(subrange_idx(rgview.start, rgview.start + rgview.range)); %(round(1+rgview.start*leda2.data.samplingrate) : round((rgview.start + rgview.range)*leda2.data.samplingrate));
cond_rg.min = min(cond_rg.data);
cond_rg.max = max(cond_rg.data);
cond_rg.height_diff = cond_rg.max - cond_rg.min;
scale_border = .25;
if (cond_rg.height_diff+2*scale_border) < leda2.pref.scalewidth_min
    scale_border = (leda2.pref.scalewidth_min - cond_rg.height_diff)/2;
end

if isempty(leda2.analyze.fit)
    rg_bottom = cond_rg.min - scale_border; %range-size
else
    ground_min = min(leda2.analyze.fit.data.tonic(subrange_idx(rgview.start, rgview.start + rgview.range)));
    rg_bottom = min(cond_rg.min, ground_min) - scale_border;
end
rg_top = cond_rg.max + scale_border;
rgview.bottom = rg_bottom;
rgview.top = rg_top;
rg_start = rgview.start;
rg_end = rgview.start + rgview.range;

set(leda2.gui.overview.rangefld, 'XData', [rg_start, rg_start, rg_end, rg_end],'YData',[rg_bottom, rg_top, rg_top, rg_bottom]);
set(rgview.ax, 'XLim', [rg_start, rg_end], 'Ylim', [rg_bottom, rg_top]);

%Define Epoch
if ~leda2.analyze.current.optimizing
    leda2.analyze.current.iEpoch = 1;
    epoch.start = leda2.gui.rangeview.start;
    epoch.end = epoch.start + leda2.gui.rangeview.range;

    if ~isempty(leda2.analyze.fit)
        phasics = leda2.analyze.fit.phasiccoef;
        tonics = leda2.analyze.fit.toniccoef;
        epoch.checkarea_start = epoch.start - leda2.set.epoch.leftFringe;
        epoch.checkarea_start = withinlimits(epoch.checkarea_start, leda2.data.time.data(1), leda2.data.time.data(end));
        epoch.checkarea_end = epoch.end + leda2.set.epoch.rightFringe;
        epoch.checkarea_end = withinlimits(epoch.checkarea_end, leda2.data.time.data(1), leda2.data.time.data(end));
        epoch.data.ca_idx = subrange_idx(epoch.checkarea_start, epoch.checkarea_end);
        epoch.data.ca_time = leda2.data.time.data(epoch.data.ca_idx);
        epoch.n_phasicsbefore = length(find([phasics.onset] < epoch.start));
        epoch.n_phasicsafter = length(find([phasics.onset] > epoch.end));
        epoch.phasic_idx = find((phasics.onset >= (epoch.start)) & ([phasics.onset] <= epoch.end));
        epoch.n_tonicsbefore = length(find([tonics.time] < epoch.start));
        epoch.n_tonicsafter = length(find([tonics.time] > epoch.end));
        epoch.tonic_idx = find((tonics.time >= (epoch.start)) & ([tonics.time] <= epoch.end));
        phasicRemainder = leda2.analyze.fit.data.phasicRemainder{epoch.n_phasicsbefore+1}(epoch.data.ca_idx);
        nextepochphasic_idx = find(leda2.analyze.fit.phasiccoef.onset > epoch.end & leda2.analyze.fit.phasiccoef.onset < epoch.checkarea_end);
        if ~isempty(nextepochphasic_idx)
            nextepochphasic = sum(reshape([leda2.analyze.fit.data.phasicComponent{nextepochphasic_idx}],[],length(nextepochphasic_idx)),2)';
            nextepochphasic = nextepochphasic(epoch.data.ca_idx);
        else
            nextepochphasic = zeros(size(phasicRemainder));
        end
        epoch.data.cond2fit = leda2.data.conductance.data(epoch.data.ca_idx) - phasicRemainder - nextepochphasic;

        epoch.parset(1).onset = phasics.onset(epoch.phasic_idx);
        epoch.parset(1).amp = phasics.amp(epoch.phasic_idx);
        epoch.parset(1).tau = phasics.tau(:, epoch.phasic_idx);
        epoch.parset(1).groundtime = tonics.time(epoch.tonic_idx);
        epoch.parset(1).groundlevel = tonics.ground(epoch.tonic_idx);
        epoch.parset(1).error = fiterror_parset(epoch, epoch.parset(1));
        epoch.bestparset = 1;
        epoch.error = epoch.parset(1).error;
        epoch.initial_error = epoch.parset(1).error;

    end
    leda2.analyze.epoch = epoch;
end

%Slider
rem = time.data(end) - rgview.range;
if rem <= 0,
    rem = 2; %dummy value > 0
end
sliderstep = rgview.range/rem;
smallsliderstep = sliderstep/10;
if sliderstep > 1, sliderstep = 1; end
if smallsliderstep > 1, smallsliderstep = 1; end
set(leda2.gui.rangeview.slider,'sliderstep',[smallsliderstep, sliderstep],'min',0,'max',rem,'Value',rgview.start)


%Events
if leda2.data.events.N > 0
    set(rgview.eventtxt,'Visible','off')
    set(rgview.markerL,'LineWidth',1);
    eventTimeList = [leda2.data.events.event.time];
    eventInRange = find(eventTimeList > rg_start & eventTimeList < rg_end);
    for ev = eventInRange
        ev_t = leda2.data.events.event(ev).time;
        set(rgview.eventtxt(ev),'Position',[ev_t-rgview.range/200, rg_bottom+.1, 0],'Visible','on');
    end
    if ~isempty(eventInRange)
        if leda2.gui.eventinfo.showEvent %was just set in event-info
            current_event = leda2.gui.eventinfo.showEvent;
        else
            current_event = eventInRange(1); %else first event is current event
        end
        leda2.gui.eventinfo.current_event = current_event;
        set(rgview.markerL(current_event),'LineWidth',2);

        set(leda2.gui.eventinfo.edit_eventnr,'String',num2str(current_event));
        set(leda2.gui.eventinfo.txt_name,'String',leda2.data.events.event(current_event).name);
        set(leda2.gui.eventinfo.txt_time,'String',sprintf('%5.2f',leda2.data.events.event(current_event).time));
        if ischar(leda2.data.events.event(current_event).userdata)
            udtxt = [', ',leda2.data.events.event(current_event).userdata];
        else
            udtxt = '';
        end
        set(leda2.gui.eventinfo.txt_niduserdata,'String',[num2str(leda2.data.events.event(current_event).nid), udtxt]);
    else
        leda2.gui.eventinfo.current_event = 0;
        set(leda2.gui.eventinfo.edit_eventnr,'String','');
        set(leda2.gui.eventinfo.txt_name,'String','');
        set(leda2.gui.eventinfo.txt_time,'String','');
        set(leda2.gui.eventinfo.txt_niduserdata,'String','');
    end
end
leda2.gui.eventinfo.showEvent = 0;

set(leda2.gui.epochinfo.list_scr,'Value',1);
set(leda2.gui.epochinfo.list_tonic,'Value',1);
set(leda2.gui.manualedit.edit_ons, 'String','');
set(leda2.gui.manualedit.edit_amp, 'String','');
set(leda2.gui.manualedit.edit_tau1, 'String','');
set(leda2.gui.manualedit.edit_tau2, 'String','');
set(leda2.gui.manualedit.edit_t, 'String','');
set(leda2.gui.manualedit.edit_g, 'String','');
refresh_epochinfo;
refresh_progressinfo; %epoch error
showfit(rgview.start, rgview.start + rgview.range);

leda2.gui.rangeview = rgview;
