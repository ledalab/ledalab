%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% new event marker read function for import_eventdata.m and import_eventinfo.m 
% by Til Ole Bergmann, bergmann@psychologie.uni-kiel.de
% last edit 2014-06-13 by TOB
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function event = getevents(fullpath)

% read in text file with unknown number of columns into cell array
fid = fopen(fullpath);
firstLine = fgetl(fid);
fclose(fid);
numFields = length(strfind(firstLine,sprintf('\t'))) + 1;
formatString = repmat('%s',1,numFields);
fid = fopen(fullpath);
C = textscan(fid, formatString,'Delimiter','\t');
fclose(fid);

for ev = 1:size(C{1},1)-1 % starts in line 2 as first line contians header
    for nf = 1:numFields
        event(ev).userdata = [];
        switch C{nf}{1}
            case 'time'
                event(ev).time = str2num(C{nf}{1+ev});
            case 'nid' 
                event(ev).nid = str2num(C{nf}{1+ev});
                if ~isfield(event(ev),'name')
                    event(ev).name = num2str(event(ev).nid);           
                end
            case 'name' 
                event(ev).name = C{nf}{1+ev};           
            otherwise % user specific data will be stored in cell array
                event(ev).userdata.(genvarname(C{nf}{1}(isstrprop(C{nf}{1},'alphanum')))) = C{nf}{1+ev}; % replaces characters invalid for fielnames TOB 27.08.2015
        end
    end
end


