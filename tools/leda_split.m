function leda_split(action)
% LEDA_SPLIT(ACTION)
%
% LEDA_SPLIT splits continuous data into epochs according to the time of
%   events. Each category of events is used to define a condition. The
%   epoched and averaged data can be plotted with or without the standard
%   error of the mean.
%
% NOTE: To get the same number of samples for each epoche, the time stamps
%   of the events are moved to the time of the closest sample. If sampling
%   rates are extremely low and the times of the events are NOT in
%   accordance with the times the samples were recorded, the resulting mean
%   (and standard error) might be distorted.
%
% analysis.driver and analysis.phasicData is available, 2012-04-16.
% Christoph Huber-Huber, 2012.



if nargin < 1,
    action = 'start';
end

switch action,
    case 'start', start;
    case 'take_settings', take_settings;
    case 'split', split;
    case 'select_all', select_all;
    case 'deselect_select_all', deselect_select_all;
end

end


function start
global leda2

if ~leda2.file.open
    if leda2.intern.prompt
        msgbox('No open File!','Split','error')
    end
    return
end
if leda2.data.events.N < 1
    if leda2.intern.prompt
        msgbox('File has no Events!','Split','error')
    end
    return
end
if isempty(leda2.analysis) || ~strcmp(leda2.analysis.method,'sdeco')
    if leda2.intern.prompt
        msgbox('This function requires that data have been analyzed with Continuous Decomposition Analysis!','Split','error')
    end
    return;
end

conditionnames = unique({leda2.data.events.event.name});
nrconds = numel(conditionnames);
nrboxlines = ceil(numel(conditionnames) / 3);   % reserve space for three columns of codition names
nrlines = nrboxlines + 4;
dy = 1 / (nrlines + 6);     % height of one line (consider some more space between lines => +6)

leda2.gui.split = [];

leda2.gui.split.fig = figure('Units','normalized','Position', ...
    [.25 .125 .5 .5], ...
    'Name','Plot event-related data (Split and Average)','MenuBar','none','NumberTitle','off');

leda2.gui.split.text_WindowLimits = uicontrol('Style','text','Units','normalized', ...
    'Position',[.05 1-2*dy .30 dy],'BackgroundColor',get(gcf,'Color'), ...
    'String','Window around events (from BEFORE to AFTER event) [sec]:', ...
    'HorizontalAlignment','left');

% START value
leda2.gui.split.edit_WindowStart = uicontrol('Style','edit','Units','normalized', ...
    'Position',[.4 1-2*dy .1 dy],'BackgroundColor',[1 1 1], ...
    'String',num2str(leda2.set.split.start,'%1.2f'));
% END value
leda2.gui.split.edit_WindowEnd   = uicontrol('Style','edit','Units','normalized', ...
    'Position',[.55 1-2*dy .1 dy],'BackgroundColor',[1 1 1], ...
    'String',num2str(leda2.set.split.end,'%1.2f'));

% VARIABLE
leda2.gui.split.text_SplitVariable = uicontrol('Style','text','Units','normalized', ...
    'Position',[.05 1-4*dy .30 dy],'BackgroundColor',get(gcf,'Color'), ...
    'String','Variable:','HorizontalAlignment','right');
% make CURRENT DATA available!!!!
leda2.gui.split.edit_SplitVariable = uicontrol('Style','popupmenu','Units','normalized', ...
    'Position',[.4 1-4*dy .25 dy], ...
    'String',leda2.set.split.variables, ...
    'Value',leda2.set.split.var);

% standard error
leda2.gui.split.stderr = uicontrol('Style','checkbox', 'Units','normalized', ...
    'Position', [.70 1-4*dy .25 dy], 'Min', 0, 'Max', 1, ...
    'String', 'Include standard error', 'HorizontalAlignment','Left','BackgroundColor',get(gcf,'Color'));

leda2.gui.split.text_Conditions = uicontrol('Style','text','Units','normalized', ...
    'Position',[.05 1-6.5*dy .15 dy],'BackgroundColor',get(gcf,'Color'), ...
    'String','Conditions:','HorizontalAlignment','left');

leda2.gui.split.all_Conditions = uicontrol('Style','checkbox', 'Units','normalized', ...
    'Position', [.25 1-6.5*dy .25 dy], 'Min', 0, 'Max', 1, ...
    'String', 'select all', 'HorizontalAlignment','Left','BackgroundColor',get(gcf,'Color'), 'Callback', 'leda_split(''select_all'')');

% create 'checkboxes' to enable selecting a subset of all conditions
for i = 1:(nrboxlines-1)
    for j = 1:3
        leda2.gui.split.edit_Conditions((i-1)*3+j) = ...
            uicontrol('Style','checkbox', 'Units','normalized', 'Position', ...
            [.03+.333*(j-1) (1-((7+i)*dy)) .333 dy], ... [6+condnamelength*(j-1) 10+(i*2) condnamelength 36], ...
            'Min', 0, 'Max', 1, ...
            'String',conditionnames{(i-1)*3+j}, 'HorizontalAlignment','Left','BackgroundColor',get(gcf,'Color'), ...
            'Callback', 'leda_split(''deselect_select_all'')');
    end
end
for j = 1:(nrconds-(nrboxlines-1)*3)
    leda2.gui.split.edit_Conditions((nrboxlines-1)*3+j) = ...
        uicontrol('Style','checkbox', 'Units','normalized', 'Position', ...
        [.03+.333*(j-1) (1-((7+nrboxlines)*dy)) .333 dy], ... [6+condnamelength*(j-1) 10+(i*2) condnamelength 36], ...
        'Min', 0, 'Max', 1, ...
        'String',conditionnames{(nrboxlines-1)*3+j}, 'HorizontalAlignment','Left','BackgroundColor',get(gcf,'Color'), ...
        'Callback', 'leda_split(''deselect_select_all'')');
end

% button
leda2.gui.split.butt_split = uicontrol('Units','normalized','Position', [.333 dy .333 dy], ...
    'String','Plot event-related data','Callback','leda_split(''take_settings'')');

end


function select_all
global leda2
if get(leda2.gui.split.all_Conditions, 'Value') == 0
    for i = 1:numel(leda2.gui.split.edit_Conditions)
        set(leda2.gui.split.edit_Conditions(i), 'Value', 0);
    end
else
    for i = 1:numel(leda2.gui.split.edit_Conditions)
        set(leda2.gui.split.edit_Conditions(i), 'Value', 1);
    end
end
end

function deselect_select_all
global leda2
if get(leda2.gui.split.all_Conditions, 'Value') == 1
    set(leda2.gui.split.all_Conditions, 'Value', 0);
else
    if all(cell2mat(get(leda2.gui.split.edit_Conditions, 'Value')))
        set(leda2.gui.split.all_Conditions, 'Value', 1);
    end
end
end

function take_settings
global leda2

leda2.set.split.start = str2double(get(leda2.gui.split.edit_WindowStart, 'String'));
leda2.set.split.end = str2double(get(leda2.gui.split.edit_WindowEnd, 'String'));

% Get variable
leda2.set.split.variable = leda2.set.split.variables{...
    get(leda2.gui.split.edit_SplitVariable, 'Value')};

% Get selected conditions
if get(leda2.gui.split.all_Conditions, 'Value') == 0
    conditionnames = unique({leda2.data.events.event.name});
    leda2.set.split.selectedconditions = ...
        conditionnames(logical(cell2mat(get(leda2.gui.split.edit_Conditions, 'Value'))));
    if isempty(leda2.set.split.selectedconditions)
        mbox = msgbox('No condition selected!', 'Condition error');
        return
    end
else
    leda2.set.split.selectedconditions = unique({leda2.data.events.event.name});
end

% get whether standard error should be plotted
leda2.set.split.stderr = get(leda2.gui.split.stderr, 'Value');

% check settings
if leda2.set.split.start > leda2.set.split.end
    mbox = msgbox('BEFORE event value is greater than AFTER event value!','Event window error');
    return
end
if leda2.set.split.start == leda2.set.split.end
    mbox = msgbox('Interval of 0 sec not allowed!','Event window error');
    return
end

split;

close(leda2.gui.split.fig)

end


function split
global leda2

% get names of all events
alleventnames = {leda2.data.events.event.name};
% get names of selected conditions
condnames = leda2.set.split.selectedconditions;
% number of conditions
nrcond = numel(condnames);
% number of instances per condition
npcond = zeros(1,nrcond);
for i = 1:nrcond
    npcond(i) = sum(strcmp(condnames(i), alleventnames));
end

% convert the event's times (in sec) to sample nr. ...
etsamplenr = [leda2.data.events.event.time] * ...
    leda2.data.samplingrate + 1;
% ... and round (i.e. move) them to the moment of the closest sample
etsamplenr = round(etsamplenr);

% get FROM and TO and convert to sample number.
% NOTE: START and END are presumably seconds.
%       And START is usually negative.
from = leda2.set.split.start * leda2.data.samplingrate;
to = leda2.set.split.end * leda2.data.samplingrate;
% lock them to sampling rate, but move both in same direction!
if from < to
    if round(from) < from
        to = floor(to);
    elseif round(from) > from
        to = ceil(to);
    else    % round(floor) == floor
        to = round(to);
    end
    from = round(from);
end

% get the number of data points (i.e. samples) in an epoch
% NOTE: FROM is included, thus: +1
nrpts = to - from + 1;

% assign the condition name to the data structure, reserve space, and add
% the start end end time in points.

%data.split(c) probably could be replaced by analysis.split.condition(c) %%MB
for c = 1:nrcond
    leda2.data.split(c).name = condnames{c};
    leda2.data.split(c).data = zeros(npcond(c), nrpts);
    leda2.data.split(c).start = from;
    leda2.data.split(c).end = to;
end

% get name of variable to be processed
%   get also 'type': analysis, data, or so?!?
variable = leda2.set.split.variable;


% enable choosing the variable !!!!!!!!!!!


% split data of the requested variable
for c = 1:nrcond
    i = 1;
    for j = find(strcmp(condnames(c), alleventnames))
        leda2.data.split(c).data(i,:) = leda2.analysis.(variable)((etsamplenr(j) + from):(etsamplenr(j) + to));   % FROM is negative!
        i = i+1;
    end
end

% compute mean/average
for c = 1:nrcond
    leda2.data.split(c).mean = mean(leda2.data.split(c).data, 1);
end

% compute std. error
for c = 1:nrcond
    leda2.data.split(c).stderr = std(leda2.data.split(c).data, 0, 1) / ...
        sqrt(size(leda2.data.split(c).data, 1));
end

% add a time vector to the global variable leda2, one for each condition
time = (from:to)/leda2.data.samplingrate;
for c = 1:nrcond
    leda2.data.split(c).time = time;
end

% plot mean and indicate the event for all conditions in one plot
if ~leda2.intern.batchmode || (leda2.intern.batchmode && leda2.set.split.plot)
    figure;
    hold on
    leg = cell(1,nrcond);   % for the legend
    yvals = nan(nrcond, numel(leda2.data.split(1).mean));
    if leda2.set.split.stderr
        stderrvals = nan(nrcond, numel(leda2.data.split(1).stderr)*2);
    end
    for c = 1:nrcond        % gather data to plot in one variable
        leg{c} = sprintf('%s (n = %d)', condnames{c}, npcond(c));
        yvals(c,:) = leda2.data.split(c).mean;
        stderrvals(c,:) = [leda2.data.split(c).mean + leda2.data.split(c).stderr, ...
            leda2.data.split(c).mean(end:-1:1) - leda2.data.split(c).stderr(end:-1:1)];
    end
    plt = plot(time,yvals);    % plot it
    if leda2.set.split.stderr
        col = get(plt, 'color');
        for c = 1:nrcond
            fill([time, time(end:-1:1)], stderrvals(c,:), ...
                col{c}, 'facealpha', .25, 'edgealpha', .25);
        end
    end
    plot([0; 0], get(gca, 'YLim')', 'r--');     % time of the event
    xlabel('time [sec]');
    ylabel(variable);
    legend(leg, 'location', 'best');
    xlim([leda2.set.split.start, leda2.set.split.end])
    hold off
end

end
