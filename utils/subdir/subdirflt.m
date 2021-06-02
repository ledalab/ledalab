function [files, filecell] = subdirflt(indir, varargin)
%SUBDIRFLT - return contents of a directory tree with some filtering options

% Initialise inputs
p = inputParser;
p.addRequired('indir', @isstr)

p.addParameter('patt_ext', '', @ischar)
p.addParameter('filefilt', '', @(x) ischar(x) || iscellstr(x)) %#ok<ISCLSTR>
p.addParameter('getdir', true, @islogical)
p.addParameter('getfile', true, @islogical)

p.parse(indir, varargin{:});
Arg = p.Results;

% Get files
files = subdir(fullfile(indir, Arg.patt_ext));
if isempty(files)
    error('subdirflt:no_matches', 'Nothing found for args %s%s%s'...
        , indir, filesep, Arg.patt_ext)
end

% Remove any hidden dir pointers
files(ismember({files.name}, {'.', '..'})) = [];

% Filter to given filename or path string
if ~isempty(Arg.filefilt)
    files = files(contains({files.name}, Arg.filefilt));
end

% Filter to directories or files or both
idxD = [files.isdir] & Arg.getdir;
idxF = ~[files.isdir] & Arg.getfile;
files = files(idxD | idxF);


if isempty(files)
    error('subdirflt:bad_fitlers', 'Filters removed all files!')
end

%Get just the first field of the subdir struct: fullpath-names
subx = fieldnames(files);
subx = struct2cell(rmfield(files, subx(2:end)))';

%Parse to paths & filenames
[~, filenames, exts] = cellfun(@fileparts, subx, 'Un', 0);
filenames = cellfun(@(x, y) [x y], filenames, exts, 'Un', 0);

[files.name] = deal(filenames{:});

filecell = fullfile({files.folder}, {files.name});

end