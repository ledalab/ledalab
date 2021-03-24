function Ledalab_batch_tree(indir, varargin)
% Ledalab_batch_tree applies Ledalab batch processing to files across a tree
% 
% Syntax:
%       Ledalab_batch_tree(indir, 'key', [value], ...)
%
% Description: finds all EDA *.mat files from an experiment (that is, any
%              file matching string 'filefilt' in any folder below 'indir')
%              Use Ledalab batch script to decompose EDA according to
%              parameters in varargin
%              Overwrite the input file with the Leda-processed version
%
% Input:
%   indir       string, root folder: all target files here or in any subfolder
%                       (recursive) are returned for processing
% 
% Varargin:
%   downsamp    int, factor to downsample by, default = 1 (no downsample)
%   filt        string, part of filename to match subset of files for, e.g. 
%                       different conditions, default = ''
%   ext         string, extension of the required files, default = 'mat'
%   DA          boolean, perform decomposition analysis?, default = true
%   parfor      boolean, perform DA in a parallel for loop?, default = false
%   exp_era     boolean, perform ERA export?, default = true
%   exp_scrlist boolean, perform SCR-list export?, default = true
% 
% (for all following parameters, see Leda docs for more detail)
%   format      string, data format for Ledalab to read, default = 'leda'
%                       FOR 'format' OPTOINS SEE LEDALAB'S import_data.m
%   filter      [1 2], filter order & low-pass cutoff, default = 0 (no filter)
%   smooth      cell, smoothing parameters, default = {'gauss' 20}
%   analyze     string, decomposition analysis algorithm, default = 'CDA'
%   optimize    int, Optimisation steps, default = 2
%   era_beg     int vector, start times of ERA windows relative to events,
%                           default = 0
%   era_end     int vector, finish times of ERA windows relative to events,
%                           default = 1
%   scr_thr     double, lower threshold of SCR amplitude in uS, default = 0.01
%   sav_typ     int, type of ERA and scrlist file to write, default = 2 (txt)
% 


%% Parse input arguments and set varargin defaults
p = inputParser;

p.addRequired('indir', @ischar)

p.addParameter('downsamp', 1, @isscalar)
p.addParameter('filt', '', @ischar)
p.addParameter('ext', 'mat', @ischar)

p.addParameter('DA', true, @islogical) %perform decomposition analysis?
p.addParameter('parfor', false, @islogical)

p.addParameter('exp_era', true, @islogical)
p.addParameter('exp_scrlist', true, @islogical)

p.addParameter('format', 'leda', @ischar)
p.addParameter('filter', 0, @isnumeric)
p.addParameter('smooth', {'gauss', 20}, @iscell)
p.addParameter('analyze', 'CDA', @ischar)
p.addParameter('optimize', 2, @isscalar)

p.addParameter('era_beg', 0, @isnumeric)
p.addParameter('era_end', 1, @isnumeric)

p.addParameter('scr_thr', 0.01, @isnumeric)
p.addParameter('sav_typ', 2, @isnumeric)


p.parse(indir, varargin{:})
Arg = p.Results;

scrlist_thr = Arg.scr_thr;

%List all files that resulted from event-related analysis (ERA) in Ledalab
[files, fcell] = subdirflt(abspath(indir)...
                        , 'patt_ext', ['*.' Arg.ext], 'filefilt', Arg.filt);


%% Leda-process and export ERAs for each file
fcell(strcmp({files.name}, 'batchmode_protocol.mat')) = [];

% Open raw mats and decompose with CDA or DDA
if Arg.DA
    if Arg.parfor
        fm = Arg.format;
        filt = Arg.filter;
        ds = Arg.downsamp;
        sm = Arg.smooth;
        az = Arg.analyze;
        oz = Arg.optimize;
        parfor (ix = 1:numel(fcell))
            Ledalab(fcell{ix}...
                , 'open', fm...
                , 'filter', filt...
                , 'downsample', ds...
                , 'smooth', sm...
                , 'analyze', az...
                , 'optimize', oz)
        end
    else
        Ledalab(fcell...
            , 'open', Arg.format...
            , 'filter', Arg.filter...
            , 'downsample', Arg.downsamp...
            , 'smooth', Arg.smooth...
            , 'analyze',Arg.analyze...
            , 'optimize', Arg.optimize)
    end
end


%% Open Leda mats and export ERAs
if Arg.exp_era
if ~isscalar(Arg.era_beg) || ~isscalar(Arg.era_end) || ~isscalar(Arg.scr_thr)
%             TODO: USE allcomb() HERE??!!
    reps = [numel(Arg.era_beg) numel(Arg.era_end) numel(Arg.scr_thr)];
    pars = {'era_beg', 'era_end', 'scr_thr'};
    for i = 1:numel(pars)
        if isscalar(Arg.(pars{i}))
            Arg.(pars{i}) = repmat(Arg.(pars{i}), [1 max(reps)]);
        elseif reps(i) ~= max(reps)
            error('Ledalab_batch_tree:bad_era_export', ...
            'To export >1 ERAs, params must be scalar or match in size')
        end
    end
    for i = 1:max(reps)
        Ledalab(fcell...
            , 'open', 'leda'...
            , 'zscale', 1 ...
            , 'export_era', ...
            [Arg.era_beg(i) Arg.era_end(i) Arg.scr_thr(i) Arg.sav_typ])
        sbf_rename_exp(fcell, '_era_z'...
            , Arg.era_beg(i), Arg.era_end(i), Arg.scr_thr(i), Arg.sav_typ)
    end
else
    Ledalab(fcell...
        , 'open', 'leda'...
        , 'zscale', 1 ...
        , 'export_era', ...
        [Arg.era_beg Arg.era_end Arg.scr_thr Arg.sav_typ])
    sbf_rename_exp(fcell, '_era_z'...
        , Arg.era_beg, Arg.era_end, Arg.scr_thr, Arg.sav_typ)
end
end


%% Open Leda mats and export SCR lists
if Arg.exp_scrlist
if ~isscalar(scrlist_thr)
    for i = 1:numel(scrlist_thr)
        Ledalab(fcell...
            , 'open', 'leda'...
            , 'zscale', 1 ...
            , 'export_scrlist', [scrlist_thr(i) Arg.sav_typ])
        sbf_rename_exp(fcell, '_scrlist_z', '', '', scrlist_thr(i), Arg.sav_typ)
    end
else
    Ledalab(fcell...
        , 'open', 'leda'...
        , 'zscale', 1 ...
        , 'export_scrlist', [scrlist_thr Arg.sav_typ])
    sbf_rename_exp(fcell, '_scrlist_z', '', '', scrlist_thr, Arg.sav_typ)
end
end

    % add descriptive suffix to exported file to prevent overwriting by next
    function sbf_rename_exp(filecell, name, first, last, thr, sav)
        save_type = {'mat' 'txt' 'xls'};
        for ixf = 1:numel(filecell)
            [p, f, ~] = fileparts(filecell{ixf});
            if isempty(first) || isempty(last)
                sfx = sprintf('%.2fuS.', thr);
            else
                sfx = sprintf('%dto%d_%.2fuS.', first, last, thr);
            end
            movefile(fullfile(p, [f name '.' save_type{sav}])...
                , fullfile(p, [f name '_' sfx save_type{sav}]) )
        end
    end

    
end %Ledalab_batch_tree()