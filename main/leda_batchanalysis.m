function leda_batchanalysis(varargin)
global leda2

%parse batch-mode arguments and check thei validity
[pathname, open_datatype, downsample_factor, artifact_thresh, do_fit, do_export_scr, do_export_era] = parse_arguments(varargin{:});

dirL = dir(pathname);
dirL = dirL(~[dirL.isdir]);
nFile = length(dirL);
add2log(1,['Starting Ledalab batch for ',pathname,' (',num2str(nFile),' file/s)'],1,0,0,1)
pathname = fileparts(pathname);


for iFile = 1:nFile
    filename = dirL(iFile).name;
    add2log(1,['Batch-Analyzing ',filename],1,0,0,1)

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

    %Artifact-Detection
    if artifact_thresh > 0
        artifact_detect(artifact_thresh);
        nart = length(leda2.current.artifact_samples);
        if nart > 0
            disp([num2str(nart),' artifacts detected'])
        end
    end

    %Fit
    if do_fit
        optimize
    end

    %Export
    if do_export_scr
        export_scrlist
    end
    if do_export_era
        export_era('save_peaks')
    end

    %Save
    save_ledafile(0);

end



function [wdir, open_datatype, downsample_factor, artifact_thresh, do_fit, do_export_scr, do_export_era] = parse_arguments(varargin)

wdir = varargin{1};

%default options
open_datatype = 'leda'; %open
downsample_factor = 0;
artifact_thresh = 0;
do_fit = 0;
do_export_scr = 0;
do_export_era = 0;

valid_datatypeL = {'leda','mat','text','cassy','biotrace','visionanalyzer','userdef'};


if nargin > 1
    vars = varargin(2:end);

    while length(vars) >= 2
        thisvar = vars(1:2);
        vars = vars(3:end);

        option_name = thisvar{1};
        option_arg = thisvar{2};

        switch option_name
            case 'open',
                if ischar(option_arg) && any(strcmp(option_arg, valid_datatypeL))
                    open_datatype = option_arg;
                else
                    disp(['Unknown datatype: ',option_arg])
                    return;
                end

            case 'downsample'
                if isnumeric(option_arg)
                    downsample_factor = option_arg;
                else
                    disp('Downsample option requires numeric argument (downsample factor)')
                    return;
                end

            case 'detect_artifact'
                if isnumeric(option_arg)
                    artifact_thresh = option_arg;
                else
                    disp('Artifact option requires numeric argument (artifact threshold)')
                    return;
                end

            case 'fit'
                if isnumeric(option_arg)
                    do_fit = option_arg;
                else
                    disp('Fit option requires numeric argument (1 = yes, 0 = no)')
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

            otherwise
                disp(['Could not parse batch-mode option: ',option_name])

        end %switch

    end %while

end %if nargin > 1
