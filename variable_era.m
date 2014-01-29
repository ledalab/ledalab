% This script allows to compute the event-related phasic activity for stimuli/events with variable duration.
% It requires a Ledalab-file containing event-data which has been analyzed with CDA, 
% and it also requires a Matlab file containing information on event durations - see below.
% It returns SCR and ISCR as indicators of phasic activity - mind that ISCR is a cumulative measure 
% that expected to increase with stimulus duration whereas SCR (average over total stimulus) is not.

clear all

%Load data
datafile = 'AVOIDANCESTRESS_S260001.mat';%'myfilename.mat'; 		% Ledalab file containing EDA data and events (onsets), after CDA
durationfile = 'eventduration.mat';	% This Matlab-file should contain a variable 'duration' which is an array of the duration of each event in sec.
									% This file can be built with: duration = [2,4,2,6,4,6, ..]; save('eventduration','duration');

load(datafile) 
load(durationfile) 								

nEvents = length(data.event); 		% length(duration) should be equal to nEvents
dt = mean(diff(data.time));
samplingrate = round(1/dt);

resp_win = [1, 4];  % response-window [x,y]: x sec after event-onset to y sec after event-offset as recommended in Benedek & Kaernbach (2010)

% Compute phasic activity for each event
for iEvent = 1:nEvents
   
    event_onset = data.event(iEvent).time;
    event_offset = event_onset + duration(iEvent);
    respwin_idx = find(data.time > event_onset + resp_win(1) & data.time < event_offset + resp_win(2)); %data samples within response window
    
    SCR(iEvent) = max(0, mean(analysis.driver(respwin_idx)));    			% average phasic activity in response window
    ISCR(iEvent) = max(0, sum(analysis.driver(respwin_idx))/samplingrate);  % cumulative phasic activity in response window
    
end

% Save to Excel
xlswrite(datafile(1:end-4),{'Event','Duration', 'SCR','ISCR'},'ERA','A1')
xlswrite(datafile(1:end-4),[1:nEvents; duration; SCR; ISCR]','ERA','A2')
