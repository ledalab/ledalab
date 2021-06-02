function CDA2CSV(ROOTDIR, varargin)
% CDA2CSV convert Ledalab CDA-analysed files into R-readable csv files

%% Parse input arguments and set varargin defaults
p = inputParser;

p.addRequired('ROOTDIR', @ischar)
p.addParameter('FILT', '', @ischar)
p.addParameter('EVT', true, @islogical)

p.parse(ROOTDIR, varargin{:})
Arg = p.Results;


%%
OUTDIR = fullfile(ROOTDIR, 'csv');
if ~isfolder(OUTDIR), mkdir(OUTDIR); end

%List all files that resulted from event-related analysis (ERA) in Ledalab
MATFILES = subdirflt(abspath(ROOTDIR)...
                        , 'patt_ext', '*.mat'...
                        , 'filefilt', Arg.FILT);
MATFILES(strcmp({MATFILES.name}, 'batchmode_protocol.mat')) = [];


%%
for k = 1:length(MATFILES)

	OUTPUT = fullfile(OUTDIR, OSL(2, @fileparts, MATFILES(k).folder));
	if ~isfolder(OUTPUT), mkdir(OUTPUT); end

	file = load(fullfile(MATFILES(k).folder, MATFILES(k).name));
    fprintf(1, '\t[%s] \t %s\n', datestr(now), MATFILES(k).name);

    hdr = {'time', 'conductance', 'driver', 'scr', 'scl'};
    data = cat(2, file.data.time', ...
                  file.data.conductance', ...
                  file.analysis.driver', ...
                  file.analysis.phasicData', ...
                  file.analysis.tonicData');

    if Arg.EVT
        events = cell(size(data, 1), 1);
        hdr{end + 1} = 'event'; %#ok<AGROW>
        evtm = [file.data.event.time];
        for e = 1:numel(evtm)
            idx = OSL(2, @min, abs(data(:, 1) - evtm(e)));
            events{idx} = file.data.event(e).name;
        end
    end
    filename = fullfile(OUTPUT, [OSL(2, @fileparts, MATFILES(k).name) '.csv']);

    fid = fopen(filename, 'w');

    % Write time offset
    fprintf(fid, '#offset=%f\n', file.data.timeoff);

    % Write header
    for h = 1:length(hdr)
        fprintf(fid, '%s', hdr{h});
        if h == length(hdr)
            fprintf(fid, '\n');
        else
            fprintf(fid, ',');
        end
    end

    % Write data
    if Arg.EVT
        for x = 1:size(data, 1)
            fprintf(fid, '%f,%f,%f,%f,%f,%s\n'...
                , data(x, 1), data(x, 2), data(x, 3), data(x, 4), data(x, 5)...
                , events{x});
        end
    else
        for x = 1:size(data, 1)
            fprintf(fid, '%f,%f,%f,%f,%f\n'...
                , data(x, 1), data(x, 2), data(x, 3), data(x, 4), data(x, 5));
        end
    end

    fclose(fid);
end
