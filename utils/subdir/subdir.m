function varargout = subdir(varargin)
%SUBDIR Performs a recursive file search
%
% subdir
% subdir(name)
% files = subdir(...)
%
% This function performs a recursive file search.  The input and output
% format is identical to the dir function.
%
% Input variables:
%
%   name:   pathname or filename for search, can be absolute or relative
%           and wildcards (*) are allowed.  If ommitted, the files in the
%           current working directory and its child folders are returned    
%
% Output variables:
%
%   files:  m x 1 structure with the following fields:
%           name:   full filename
%           date:   modification date timestamp
%           bytes:  number of bytes allocated to the file
%           isdir:  1 if name is a directory; 0 if no
%
% Example:
%
%   >> a = subdir(fullfile(matlabroot, 'toolbox', 'matlab', '*.mat'))
%
%   a = 
%
%   67x1 struct array with fields:
%       name
%       date
%       bytes
%       isdir
%
%   >> a(2)
%
%   ans = 
%
%        name: '/Applications/MATLAB73/toolbox/matlab/audiovideo/chirp.mat'
%        date: '14-Mar-2004 07:31:48'
%       bytes: 25276
%       isdir: 0
%
% See also:
%
%   dir

% Copyright 2006 Kelly Kearney


%---------------------------
% Get folder and filter
%---------------------------

narginchk(0,1);
nargoutchk(0,1);

if nargin == 0
    folder = pwd;
    filter = '*';
else
    [folder, name, ext] = fileparts(varargin{1});
    if isempty(folder)
        folder = pwd;
    end
    if isempty(ext)
        if isdir(fullfile(folder, name))
            folder = fullfile(folder, name);
            filter = '*';
        else
            filter = [name ext];
        end
    else
        filter = [name ext];
    end
    if ~isdir(folder)
        error('Folder (%s) not found', folder);
    end
end

%---------------------------
% Search all folders
%---------------------------

pathstr = genpath_local(folder);
pathfolders = regexp(pathstr, pathsep, 'split');  % Same as strsplit without the error checking
pathfolders = pathfolders(~cellfun('isempty', pathfolders));  % Remove any empty cells

Files = [];
pathandfilt = fullfile(pathfolders, filter);
for ifolder = 1:length(pathandfilt)
    NewFiles = dir(pathandfilt{ifolder});
    if ~isempty(NewFiles)
        fullnames = cellfun(@(a) fullfile(pathfolders{ifolder}, a), {NewFiles.name}, 'UniformOutput', false); 
        [NewFiles.name] = deal(fullnames{:});
        Files = [Files; NewFiles];
    end
end

%---------------------------
% Prune . and ..
%---------------------------

if ~isempty(Files)
    [~, ~, tail] = cellfun(@fileparts, {Files(:).name}, 'UniformOutput', false);
    dottest = cellfun(@(x) isempty(regexp(x, '\.+(\w+$)', 'once')), tail);
    Files(dottest & [Files(:).isdir]) = [];
end

%---------------------------
% Output
%---------------------------
    
if nargout == 0
    if ~isempty(Files)
        fprintf('\n');
        fprintf('%s\n', Files.name);
        fprintf('\n');
    end
elseif nargout == 1
    varargout{1} = Files;
end


function [p] = genpath_local(d)
% Modified genpath that doesn't ignore:
%     - Folders named 'private'
%     - MATLAB class folders (folder name starts with '@')
%     - MATLAB package folders (folder name starts with '+')

files = dir(d);
if isempty(files)
  return
end
p = '';  % Initialize output

% Add d to the path even if it is empty.
p = [p d pathsep];

% Set logical vector for subdirectory entries in d
isdir = logical(cat(1,files.isdir));
dirs = files(isdir);  % Select only directory entries from the current listing

for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp( dirname,'.') && ~strcmp( dirname,'..')
       p = [p genpath(fullfile(d,dirname))];  % Recursive calling of this function.
   end
end
