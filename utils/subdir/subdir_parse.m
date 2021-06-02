function [strucut, in_sort] = subdir_parse(strucin, prestr, pststr, subname)
% SUBDIR_PARSE get the names of a subdir return struc edited down to
% bare essentials
% 
% Description:
% 
% Usage:
%   [strucut, in_sort] = subdir_parse(strucin, prestr, pststr, subname)
% 
% Input:
%   strucin     struct, output of a call to subdir, with long file names
%   prestr      string, initial segment of long filenames to remove, e.g. the
%                       input to the call to subdir that produced 'strucin'
%   pststr      string, as 'prestr' but matches to end of filename, e.g. when
%                       subdir returned files with same name from diff folders
%   subname     string, name of the field in the output 'strucut' that contains
%                       the requested varying segment of filenames
% 
% Output:
%   strucut     struct, contains the filenames, and file paths, plus any 
%                       requested varying segment of full filenames
%   in_sort     struct, the input structure sorted according to the order
%                       of any requested varying segment of filenames
% 


%% Parse input arguments and set varargin defaults
p = inputParser;

p.addRequired('strucin', @isstruct)
p.addOptional('prestr', '', @ischar)
p.addOptional('pststr', '', @ischar)
p.addOptional('subname', 'file', @ischar)

p.parse(strucin, prestr, pststr, subname)
% Arg = p.Results;


%% Work

%Get just the first field of the subdir struct: fullpath-names
subx = fieldnames(strucin);
subx = struct2cell(rmfield(strucin, subx(2:end)))';

%Parse to paths & filenames
[paths, filenames, exts] = cellfun(@fileparts, subx, 'Un', 0);
filenames = cellfun(@(x, y) [x y], filenames, exts, 'Un', 0);

%Extract the interesting part of the fullpaths: SUB-STRING X
if ~isempty(prestr)
    ps = [prestr(1:end - 1) strrep(prestr(end), filesep, '')];
    prestr = cellfun(@(x) x(1:strfind(x, ps) + length(ps)), subx, 'Un', 0);
    subx = cellfun(@(x, y) strrep(x, y, ''), subx, prestr, 'Un', 0);
end

if ~isempty(pststr)
    pststr = cellfun(@(x) x(strfind(x, pststr):end), subx, 'Un', 0);
    subx = cellfun(@(x, y) strrep(x, y, ''), subx, pststr, 'Un', 0);
end

%Sort and squeeze the paths and parts
[subx, ix] = sort(subx);
filenames = filenames(ix);
paths = paths(ix);
[usubx, ~, ius] = unique(subx, 'stable');
% [ufiles, iof, iuf] = unique(files);
upaths = unique(paths, 'stable');

%Return output
in_sort = strucin(ix);
strucut = cell2struct(usubx, subname, find(size(usubx) == 1));
[strucut.path] = deal(upaths{:});

for i = 1:numel(strucut)
    strucut(i).name = filenames(ius == i);
end
    
end