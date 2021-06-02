function leda_resist2conduct(indir, varargin)


%% Parse input arguments and set varargin defaults
p = inputParser;

p.addRequired('indir', @ischar)

p.addParameter('filt', '', @ischar)
p.addParameter('scale', 1000, @isnumeric)

p.parse(indir, varargin{:})
Arg = p.Results;

%List all files that resulted from event-related analysis (ERA) in Ledalab
files = subdirflt(abspath(indir), 'patt_ext', '*.mat', 'filefilt', Arg.filt);
                            
for f = 1:numel(files)
    file = load(fullfile(files(f).folder, files(f).name));
    data = file.data;
    fileinfo = file.fileinfo;
    data.conductance = Arg.scale ./ data.conductance;
    save(fullfile(files(f).folder, files(f).name), 'data', 'fileinfo')
end


end