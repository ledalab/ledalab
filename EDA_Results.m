%EDA_Results: This script aggregates and saves event-related results 
% across all files of one experiment (analyzed with Ledalab) 
%
% To use it you first have to: 
%   - analyze your data in Ledalab (e.g. with Continuous Decomposition Analysis [CDA])
%   - export event-related activation data for specified event-windows in Ledalab
%   - put all resulting *_era.mat-files in a directory that can be specified below
%
% In this script you can specify whether to identify events by their ID or by their name (see below), 
% add the scores you want to be included, and modify scores (e.g. logarithmize them)
% 
% Mathias Benedek, 2014-01-30


% ==> Name your working directory where analyzed *_era-files are located:
wdir = 'D:\Uni\M\Forschung\Project\Matlab\leda\Workshop data\';     
files = dir([wdir, '*_era.mat']);   %List all files that resulted from event-related analysis (ERA) in Ledalab


 %% Read data for each file
for iFile = 1:length(files)
    
    filename_list{iFile} = files(iFile).name(1:end-8); %Get file name (without _era extension)
    era = load([wdir,files(iFile).name]);   %Load single file
    
    % ==> Use event-ID or event-name for identification of event-types
    events = era.results.Event.nid;         %Event.nid is used for identifying event-types
    %events = era.results.Event.name;       %You can also use Event.names for defining your events. To do so, uncomment this line
    
    event_list = unique(events);            %Create a unique list of all available event labels
    %(Mind that there have to be the same set of events in all data files!)
    
  
    for iEvent = 1:length(event_list)   %loop over events
        
        %Get position of specific events within stimulation sequence
        if isnumeric(event_list)    %if Event.nid was used for identification of events..
            event_idx = find(events == event_list(iEvent)); 
        else                        %if Event.name was used for identification of events..
            event_idx = find(strcmp(events, event_list{iEvent}));
        end
        
        
        % ==> Add EDA parameters/scores to be exported
        %Average SCR-AmpSum across trials of a specific event:
        EDA.AmpSum(iFile, iEvent) = mean(era.results.CDA.AmpSum(event_idx));    
        
        %You may wish to logarithmize SCR-scores before averaging:
        EDA.AmpSum_log(iFile, iEvent) = mean(log(1+era.results.CDA.AmpSum(event_idx)));
        
        %You can add any further EDA scores of interest, here ISCR, or Trough-to-peak AmpSum:
        EDA.ISCR(iFile, iEvent) = mean(era.results.CDA.ISCR(event_idx));
        EDA.AmpSum_TTP(iFile, iEvent) = mean(era.results.TTP.AmpSum(event_idx));
        
    end
end


%% Save EDA results to Excel file
eda_scores = fieldnames(EDA);   %Get list of scores saved in the Matlab variable EDA

for iScore = 1:length(eda_scores)
    %Write one worksheet per EDA parameter/score
    
    xlswrite([wdir, 'EDA_Results'], event_list, eda_scores{iScore},'B1');   %Write event names to worksheet
    xlswrite([wdir, 'EDA_Results'], filename_list', eda_scores{iScore},'A2');   %Write file names/codes
    xlswrite([wdir, 'EDA_Results'], EDA.(eda_scores{iScore}), eda_scores{iScore},'B2'); %Write EDA scores
    
end
