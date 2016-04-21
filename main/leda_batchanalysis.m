function leda_batchanalysis(varargin)

global leda2

valid_analysis_methods = {'none','CDA','DDA'};

%parse batch-mode arguments and check their validity
p = inputParser();
p.KeepUnmatched = true;

p.addRequired('dir', @ischar);
% addParameter would've been better but isn't supported in Octave and Matlab before R2013
%#ok<*NVREPL>
p.addParamValue('open','leda',@ischar);

p.addParamValue('filter',[0,0],checkfn(@isnumeric, ...
   'Filter settings require 2 numeric arguments (filter order, and lower cutoff, e.g. [1 5])'));

p.addParamValue('downsample',0,checkfn(@isnumeric, ...
   'Downsample option requires numeric argument (downsample factor)'));

p.addParamValue('smooth', 0, checkfn( ...
   @(arg) isequal(arg,0) || iscell(arg) && any(strcmpi(arg{1},{'hann','mean','gauss','adapt'})), ...
     'Smooth option requires cell; first argument is ''hann'', ''mean'', ''gauss'', or ''adapt'', second argument is width'));

p.addParamValue('analyze', 'none', @(arg) any(validatestring(arg,valid_analysis_methods)));

p.addParamValue('optimize', 2, checkfn(@isnumeric, ...
   'Optimize option requires numeric argument (# of initial values for optimization'));

p.addParamValue('export_era', [0,0,0,0], checkfn( ...
      isminsizenumeric(3), 'Export requires numeric argument (respwin_start respwin_end amp_threshold [filetype])'));

p.addParamValue('export_scrlist', [0,0], checkfn( ...
      isminsizenumeric(1), 'Export requires numeric argument (amp_threshold [filetype])'));

p.addParamValue('overview', 0);

p.addParamValue('zscale', 0, checkfn(@isboolornumeric, 'zscale requires boolean or numeric argument (1 = true, 0 = false)'));

p.parse(varargin{:});

args = p.Results;

%if ~(analysis_method || do_optimize || any(export_era_settings) || any(export_scrlist_settings) || do_save_overview) %invalid option or no option
%    disp('No valid operations for Batch-mode defined.')
%    return;
%end

analysis_method = find(strcmpi(args.analyze,valid_analysis_methods)) - 1;
if isempty(analysis_method)
    warning('No valid analysis method found');
    return;
end
args.analyze = analysis_method;

dirL = dir(args.dir);
dirL = dirL(~[dirL.isdir]);
nFile = length(dirL);

add2log(1,['Starting Ledalab batch for ',args.dir,' (',num2str(nFile),' file/s)'],1,0,0,1)
pathname = fileparts(args.dir);
leda2.current.batchmode.file = [];
leda2.current.batchmode.command = args;
leda2.current.batchmode.start = datestr(now, 21);
leda2.current.batchmode.version = leda2.intern.version;
leda2.current.batchmode.settings = leda2.set;
leda2.set.export.zscale = args.zscale;
tic

for iFile = 1:nFile
    filename = dirL(iFile).name;
    leda2.current.batchmode.file(iFile).name = filename;
    disp(' '); add2log(1,['Batch-Analyzing ',filename],1,0,0,1)
    
    %try
        %Open
        if strcmp(args.open,'leda')
            open_ledafile(0, pathname, filename);
        else
            import_data(args.open, pathname, filename);
        end
        if ~leda2.current.fileopen_ok
            disp('Unable to open file!');
            continue;
        end
        
        %Filter, MB: 14.05.2014
        if args.filter(1) > 0
            leda_filter(args.filter);
        end
        
        %Downsample
        if args.downsample > 1
            leda_downsample(args.downsample, 'mean');
        end
        
        %Smooth
        if iscell(args.smooth)
            if strcmpi(args.smooth{1},'adapt')
                adaptive_smoothing;
            else
                smooth_data(args.smooth{2}, args.smooth{1})
            end
        end
        
        %Analysis
        if analysis_method > 0
            delete_fit;
            if analysis_method == 1
                sdeco(args.optimize);
            elseif analysis_method == 2
                nndeco(args.optimize);
            end
            leda2.current.batchmode.file(iFile).tau = leda2.analysis.tau;
            leda2.current.batchmode.file(iFile).error = leda2.analysis.error;
        end
        
        %Export ERA
        if any(args.export_era)
            leda2.set.export.SCRstart = args.export_era(1);
            leda2.set.export.SCRend = args.export_era(2);
            leda2.set.export.SCRmin = args.export_era(3);
            if length(args.export_era) > 3
                leda2.set.export.savetype = args.export_era(4);
            else
                leda2.set.export.savetype = 1;
            end
            export_era;
        end
        
        %Export Scrlist
        if any(args.export_scrlist)
            leda2.set.export.SCRmin = args.export_scrlist(1);
            if length(args.export_scrlist) > 1
                leda2.set.export.savetype = args.export_scrlist(2);
            else
                leda2.set.export.savetype = 1;
            end
            export_scrlist;
        end
        
        %Save
        if args.overview
            % Legacy behaviour: if 'overview' is set to 1, assume
            % a tif file should be exported
            if args.overview == 1
                args.overview = 'tif';
            end

            analysis_overview(args.overview);
        end
        
        if args.filter(1) > 0 || args.downsample > 0 || analysis_method  || iscell(args.smooth)
            save_ledafile(0);
        end
        
    %catch
        %add2log(1,'ERROR (in leda_batchanalysis) !!!',1,0,0,1)
    %end
    
end

leda2.current.batchmode.processing_time = toc;
protocol = leda2.current.batchmode;
save([pathname,filesep,'batchmode_protocol'],'protocol');
end

function flag = maybeError(flag, errormsg)
% throws an error if flag is false, else returns true
% used by checkfn
   if ~flag
      error(errormsg);
   end
end

function fn = isminsizenumeric(minsize)
   fn = @(arg) isnumeric(arg) && length(arg)>=minsize;
end

function res = isboolornumeric(arg)
   res = isnumeric(arg) || islogical(arg);
end

function fun = checkfn(fn, errormsg)
% returns a function that calls error(errormsg) if the supplied function returns false
% usage:
%     checkarg = checkfn(@isnumeric, 'must be numeric')
%     checkarg('foo') % error
%     checkarg(5) % returns true
   fun = @(arg) maybeError(fn(arg), errormsg);
end

function analysis_overview(format)
global leda2

t = leda2.data.time.data;
analysis = leda2.analysis;
events = leda2.data.events;
%correct for extended data range of older versions
if leda2.file.version < 3.12
    n_offset = length(analysis.time_ext);
    remainder = analysis.remainder(n_offset+1:end);
    driver = leda2.analysis.driver(n_offset+1:end);
else
    remainder = analysis.remainder;
    driver = leda2.analysis.driver;
end


figure('Units','normalized','Position',[0 0.05 1 .9],'MenuBar','none','NumberTitle','off','Visible','off');

%Decomposition
subplot(2,1,1);
cla; hold on;
title('SC Data')
if leda2.file.version < 3.12 || strcmp(leda2.analysis.method,'nndeco')
    if length(analysis.phasicRemainder) * length(analysis.tonicData) < 4*10^6
        for i = 2:length(analysis.phasicRemainder)
            plot(t, analysis.tonicData + analysis.phasicRemainder{i})
        end
    end
end

plot(t, leda2.data.conductance.data, 'k','Linewidth',2);
plot(t, analysis.tonicData + analysis.phasicData,'k:','Linewidth',2);
plot(t, analysis.tonicData,'Color',[.6 .6 .6],'Linewidth',2);
%plot(analysis.groundtime, analysis.groundlevel,'o','LineWidth',2,'MarkerEdgeColor',[.5 .5 .5],'MarkerFaceColor',[.9 .9 .9],'MarkerSize',3)

%ensure minimum scaling of 2 muS
yl = get(gca,'YLim');
if abs(diff(yl)) < 2
    yl(2) = yl(1) + 2;
end
set(gca, 'XLim', [t(1), t(end)],'Ylim',yl)
%Events
yl = ylim;
for i = 1:events.N
    plot([events.event(i).time, events.event(i).time], yl, 'r')
end
set(gca,'YLim',yl)
if strcmp(analysis.method,'nndeco')
    l = legend('SC Data','Decomposition Fit','Tonic Data', sprintf('tau = %4.2f, %4.2f,  dist0 = %4.4f',analysis.tau, analysis.dist0), sprintf('RMSE = %4.2f', analysis.error.RMSE));
else
    l = legend('SC Data','Decomposition Fit','Tonic Data', sprintf('tau = %4.2f, %4.2f',analysis.tau), sprintf('RMSE = %4.2f', analysis.error.RMSE));
end
set(l, 'FontSize',8,'Location','NorthEast');
xlabel('Time [s]'); ylabel('[\muS]')


%Driver
subplot(2,1,2);
cla; hold on;
title('Phasic Driver')
plot(t, driver,'k','LineWidth',1);
plot(t, -2*remainder,'b','LineWidth',1);
set(gca, 'XLim', [t(1), t(end)], 'YLim', [min(min(driver), min(-2*remainder))*1.2, max(1, max(driver)*1.2)])
%Events
yl = ylim;
for i = 1:events.N
    plot([events.event(i).time, events.event(i).time], yl, 'r')
end
set(gca,'YLim',yl)
l = legend('Driver', 'Remainder', sprintf('Error-compound = %5.2f',analysis.error.compound), sprintf('Error-discr = %4.2f,  %4.2f', analysis.error.discreteness), sprintf('Error-neg = %4.2f', analysis.error.negativity)); %SouthOutside
set(l, 'FontSize',8,'Location','NorthEast');
xlabel('Time [s]'); ylabel('[\muS]')

saveas(gcf, leda2.file.filename(1:end-4), format)

close(gcf);
drawnow;
end
