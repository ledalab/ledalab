function leda_batchanalysis(varargin)
global leda2

%parse batch-mode arguments and check thei validity
[pathname, open_datatype, downsample_factor, do_fit, do_optimize, do_export_scr, do_export_era, do_save_overview] = parse_arguments(varargin{:});

dirL = dir(pathname);
dirL = dirL(~[dirL.isdir]);
nFile = length(dirL);
add2log(1,['Starting Ledalab batch for ',pathname,' (',num2str(nFile),' file/s)'],1,0,0,1)
pathname = fileparts(pathname);
leda2.current.batchmode.file = {};
leda2.current.batchmode.err = [];

for iFile = 1:nFile
    filename = dirL(iFile).name;
    leda2.current.batchmode.file{iFile} = filename;
    add2log(1,['Batch-Analyzing ',filename],1,0,0,1)

    try
    %Open
    if strcmp(open_datatype,'leda')
        open_ledafile(0, pathname, filename);
    else
        import_data(open_datatype, pathname, filename);
    end
    if ~leda2.current.fileopen_ok
        disp('Unable to open file!');
        continue;
    end

    %Downsample
    if downsample_factor > 0
        downsample(downsample_factor, 'mean');
    end

    %Fit
    if do_fit
        delete_fit;
        if do_optimize == 0,  %work-around
            do_optimize = 1;
        end
        deco(do_optimize);
        leda2.current.batchmode.err(iFile) = leda2.analysis.err;
    end

    %Export
    if do_export_scr
        export_scrlist
    end
    if do_export_era
        export_era('savePeaks')
    end

    %Save
    if do_save_overview
        analysis_overview;
    end

    save_ledafile(0);

    catch
        add2log(1,'ERROR !!!',1,0,0,1)
    end


end



function [wdir, open_datatype, downsample_factor, do_fit, do_optimize, do_export_scr, do_export_era, do_save_overview] = parse_arguments(varargin)

wdir = varargin{1};
if ~strcmp(wdir(end),'\') && ~strcmp(wdir(end),'/') && ~strcmp(wdir(end-4:end-3),'*.')
    wdir = [wdir,'\'];
end
wdir = [wdir, '*.mat'];

%default options
open_datatype = 'leda'; %open
downsample_factor = 0;
do_fit = 0;
do_optimize = 0;
do_export_scr = 0;
do_export_era = 0;
do_save_overview = 0;

%valid_datatypeL = {'leda','mat','text','cassylab','biotrace','visionanalyzer','userdef'};
%datatype_extL = {'*.mat','*.mat','*.txt','*.txt','*.txt','',''};

if nargin > 1
    vars = varargin(2:end);

    while length(vars) >= 2
        thisvar = vars(1:2);
        vars = vars(3:end);

        option_name = thisvar{1};
        option_arg = thisvar{2};

        switch option_name
            case 'open',
                %if ischar(option_arg) && any(strcmp(option_arg, valid_datatypeL))
                    open_datatype = option_arg;
                    wdir = wdir(1:end-5);  %remove default value *.mat
                    %wdir = [wdir(1:end-5), datatype_extL{strcmp(option_arg, valid_datatypeL)}];
                %else
                %    disp(['Unknown datatype: ',option_arg])
                %    return;
                %end

            case 'downsample'
                if isnumeric(option_arg)
                    downsample_factor = option_arg;
                else
                    disp('Downsample option requires numeric argument (downsample factor)')
                    return;
                end

            case 'analyze'
                if isnumeric(option_arg)
                    do_fit = option_arg;
                else
                    disp('Fit option requires numeric argument (1 = yes, 0 = no)')
                    return;
                end

            case 'optimize'
                if isnumeric(option_arg)
                    do_optimize = option_arg;
                else
                    disp('Optimize option requires numeric argument (# of initial values for optimization)')
                    return;
                end

            case 'export'
                if ischar(option_arg)
                    if strcmpi(option_arg, 'scr')
                        do_export_scr = 1;
                    elseif strcmpi(option_arg, 'era')
                        do_export_era = 1;
                    else
                        disp('Unkown export argument')
                    end
                else
                    disp('Export requires string argument')
                    return;
                end

            case 'overview'
                if isnumeric(option_arg)
                    do_save_overview = option_arg;
                else
                    disp('Overview option requires numeric argument (1 = yes, 0 = no)')
                    return;
                end

            otherwise
                disp(['Could not parse batch-mode option: ',option_name])

        end %switch

    end %while

end %if nargin > 1



function analysis_overview
global leda2

t = leda2.data.time.data;
t_ext = [leda2.analysis.time_ext, t];
analysis = leda2.analysis;
events = leda2.data.events;
%N = leda2.data.N;

figure('Units','normalized','Position',[0 0.05 1 .9],'MenuBar','none','NumberTitle','off');

%Fit
subplot(2,1,1);
cla; hold on;
if length(analysis.phasicRemainder) * length(analysis.tonicData) < 4*10^6
    for i = 2:length(analysis.phasicRemainder)
        plot(t, analysis.tonicData + analysis.phasicRemainder{i})
    end
end
plot(t, analysis.tonicData + analysis.phasicData,'c');
plot(t, analysis.tonicData,'g');
plot(analysis.groundtime, analysis.groundlevel,'g*')
plot(t, leda2.data.conductance.data, 'k');
legend(sprintf('tau = %4.2f, %4.2f,  dist0 = %4.4f',analysis.tau, analysis.dist0), sprintf('err = %4.2f', analysis.err),'Location','NorthWest')
set(gca, 'XLim', [t(1), t(end)])
%Events
yl = ylim;
for i = 1:events.N
    plot([events.event(i).time, events.event(i).time], yl, 'r')
end
set(gca,'YLim',yl)

%Driver
subplot(2,1,2);
cla; hold on;
plot(t_ext, analysis.driver);
plot(t_ext, -2*analysis.remainder,'g');
set(gca, 'XLim', [t(1), t(end)], 'YLim', [min(-2*analysis.remainder)*1.2, max(analysis.driver(analysis.peaktime_idx))*1.2])
%Events
yl = ylim;
for i = 1:events.N
    plot([events.event(i).time, events.event(i).time], yl, 'r')
end
set(gca,'YLim',yl)
legend(sprintf('err-adjR2 = %6.4f',analysis.err_adjR2), sprintf('err-chi2 = %4.2f',analysis.err_chi2), sprintf('err-succz = %4.2f,  %4.2f', analysis.err_succz),'Location','NorthWest')   %sprintf('err-dev = %4.2f,  %4.2f',analysis.err_dev)

saveas(gcf, leda2.file.filename(1:end-4), 'jpg')

close(gcf);
drawnow;
