function optimize(this)
global leda2

leda2.analyze.current.optimizing = 0;
manual_edit('exit_medit');
startT = clock;

if ~leda2.file.open
    add2log(0,'Please open data file!',0,0,0,0,0,1);
    return;
end

if nargin < 1
    add2log(1,'Fit data', 1,1,1);
end

if isempty(leda2.analyze.fit)
    initial_solution;
end

%Evaluate argument
if nargin < 1
    start = leda2.data.time.data(1);
    ende = leda2.data.time.data(end);
    add2log(1,'Optimize all', 1,1,1);

elseif this == -1
    start = leda2.gui.rangeview.start;
    ende = start + leda2.gui.rangeview.range;
    add2log(1,['Optimize selection ',sprintf('%5.2f', start),' : ',sprintf('%5.2f', ende)], 1,1,1);

end


%Define epoch limits for section that shall be optimized
epoch = [];

timesize = ende - start;
nEpochs = ceil(timesize / leda2.set.epoch.core);
if ~leda2.intern.batchmode
    axes(leda2.gui.rangeview.ax);
    hold on
    return;
end

fit_iterations = leda2.analyze.fit.info.iterations;


for iEpoch = 1:nEpochs

    if iEpoch < nEpochs
        epoch(iEpoch).start = start + (iEpoch-1)*leda2.set.epoch.core;
        epoch(iEpoch).end = start + (iEpoch-1)*leda2.set.epoch.core + leda2.set.epoch.size;
        epoch(iEpoch).end = withinlimits(epoch(iEpoch).end, leda2.data.time.data(1), leda2.data.time.data(end));
    else
        epoch(iEpoch).end = ende; %ensure exact end of section
        epoch(iEpoch).start = epoch(iEpoch).end - leda2.set.epoch.size;
        epoch(iEpoch).start = withinlimits(epoch(iEpoch).start, leda2.data.time.data(1), leda2.data.time.data(end));
    end

    epoch(iEpoch).checkarea_start = epoch(iEpoch).start - leda2.set.epoch.leftFringe;
    epoch(iEpoch).checkarea_start = withinlimits(epoch(iEpoch).checkarea_start, leda2.data.time.data(1), leda2.data.time.data(end));
    epoch(iEpoch).checkarea_end = epoch(iEpoch).end + leda2.set.epoch.rightFringe;
    epoch(iEpoch).checkarea_end = withinlimits(epoch(iEpoch).checkarea_end, leda2.data.time.data(1), leda2.data.time.data(end));

end
leda2.analyze.epoch = epoch;


leda2.analyze.current.optimizing = 1;

for iEpoch = 1:nEpochs

    leda2.analyze.current.iEpoch = iEpoch;

    %Setup epoch data
    epoch = leda2.analyze.epoch;  %needed?
    epoch(iEpoch).data.ca_idx = subrange_idx(epoch(iEpoch).checkarea_start, epoch(iEpoch).checkarea_end);
    epoch(iEpoch).data.ca_time = leda2.data.time.data(epoch(iEpoch).data.ca_idx);

    epoch(iEpoch).n_phasicsbefore = length(find([leda2.analyze.fit.phasiccoef.onset] < leda2.analyze.epoch(iEpoch).start));
    epoch(iEpoch).n_phasicsafter = length(find([leda2.analyze.fit.phasiccoef.onset] > leda2.analyze.epoch(iEpoch).end));
    epoch(iEpoch).n_tonicsbefore = length(find([leda2.analyze.fit.toniccoef.time] < leda2.analyze.epoch(iEpoch).start));
    epoch(iEpoch).n_tonicsafter = length(find([leda2.analyze.fit.toniccoef.time] > leda2.analyze.epoch(iEpoch).end));

    phasicRemainder = leda2.analyze.fit.data.phasicRemainder{epoch(iEpoch).n_phasicsbefore+1}(epoch(iEpoch).data.ca_idx);

    %nextepoch-phasicRemainder needed for building cond2fit in overlap
    nextepochphasic_idx = find(leda2.analyze.fit.phasiccoef.onset > epoch(iEpoch).end & leda2.analyze.fit.phasiccoef.onset < epoch(iEpoch).checkarea_end);
    if ~isempty(nextepochphasic_idx)
        nextepochphasic = sum(reshape([leda2.analyze.fit.data.phasicComponent{nextepochphasic_idx}],[],length(nextepochphasic_idx)),2)';
        nextepochphasic = nextepochphasic(epoch(iEpoch).data.ca_idx);
    else
        nextepochphasic = zeros(size(phasicRemainder));
    end
    epoch(iEpoch).data.cond2fit = leda2.data.conductance.data(epoch(iEpoch).data.ca_idx) - phasicRemainder - nextepochphasic;
    leda2.analyze.epoch = epoch;

    %%Initialize Parameter sets
    initialize_parset;
    nParsets = length(leda2.analyze.epoch(iEpoch).parset);
    leda2.analyze.epoch(iEpoch).error = min([leda2.analyze.epoch(iEpoch).parset.error]);
    leda2.analyze.epoch(iEpoch).initial_error = leda2.analyze.epoch(iEpoch).error;
    %_setup epochs

    if ~leda2.intern.batchmode
        refresh_progressinfo;
        refresh_epochinfo;

        leda2.gui.rangeview.start = leda2.analyze.epoch(iEpoch).start - leda2.set.epoch.leftFringe * leda2.pref.showEpochFringe;
        leda2.gui.rangeview.range = leda2.analyze.epoch(iEpoch).end - leda2.analyze.epoch(iEpoch).start + (leda2.set.epoch.leftFringe + leda2.set.epoch.rightFringe) * leda2.pref.showEpochFringe;

        if leda2.pref.updateFit >= 2
            change_range;
        end
    end

    leda2.analyze.current.optimizing_epoch = 1;

    while leda2.analyze.current.optimizing_epoch

        for iParset = 1:nParsets

            if ~leda2.analyze.current.optimizing_epoch
                break;
            end
            leda2.analyze.current.iParset = iParset;

            if leda2.analyze.epoch(iEpoch).parset(iParset).alive

                [p, improvement] = gradientdescent(leda2.analyze.epoch(iEpoch), leda2.analyze.epoch(iEpoch).parset(iParset));
                leda2.analyze.epoch(iEpoch).parset(iParset) = p;

                leda2.analyze.epoch(iEpoch).iteration = sum([leda2.analyze.epoch(iEpoch).parset.iteration]);
                leda2.analyze.fit.info.iterations =  fit_iterations + sum([leda2.analyze.epoch.iteration]);

                if improvement
                    %check if parset is new best
                    error = leda2.analyze.epoch(iEpoch).parset(iParset).error;
                    if error < leda2.analyze.epoch(iEpoch).error
                        leda2.analyze.epoch(iEpoch).error = error;
                        leda2.analyze.epoch(iEpoch).bestparset = iParset;

                        if leda2.pref.updateFit >= 3
                            update_fit(2);
                            showfit;
                        end
                    end
                end %_improvement

                refresh_progressinfo;
                refresh_epochinfo;
                drawnow;

            end %alive

        end % for iParset
        if leda2.analyze.epoch(iEpoch).error < leda2.data.conductance.error * leda2.set.errorThresholdFac
            leda2.analyze.current.optimizing_epoch = 0;
        end

        if ~any([leda2.analyze.epoch(iEpoch).parset.alive]) %| epoch.iteration >= x
            leda2.analyze.current.optimizing_epoch = 0;
        end
    end %while optimizing epoch


    if iEpoch < nEpochs
        update_fit(2);
    end

    if leda2.pref.updateFit >=2
        showfit;
        pause(.3);
    end

    if ~leda2.analyze.current.optimizing
        break;
    end

end %for iEpoch

update_fit(3); %fullupdate

stopT = clock;
file_changed(1);
if leda2.analyze.current.optimizing
    add2log(1,['Optimization finished successfully (elapsed time = ',sprintf('%5.1f',etime(stopT,startT)),'sec)'],1,1,1);
else
    add2log(1,'Optimization aborted.',1,1,1);
end

leda2.analyze.current.oldEpoch = leda2.analyze.epoch; %for software testing reasons
leda2.analyze.current.optimizing = 0;
refresh_progressinfo; %=reset
