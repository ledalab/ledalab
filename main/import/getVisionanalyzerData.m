function [time, conductance, event] = getVisionanalyzerData(filename)

file = load(filename);

time = file.t/1000;  %convert ms to sec
fn = fieldnames(file);
field_idx = find(strncmpi(fn,'GSR',3) | strncmpi(fn,'EDA',3));
field = fn{field_idx};

conductance = file.(field);
%conductance = file.EDA;  //  file.GSR_MR_100_xx;

%control for mismatching vector length
n1 = length(time);
n2 = length(conductance);
time = time(1:min(n1, n2));
conductance = conductance(1:min(n1, n2));

for i = 1:length(file.Markers)
    event(i).time = file.Markers(i).Position / file.SampleRate;
    event(i).name = file.Markers(i).Type;
    num = regexp(file.Markers(i).Description, '[0-9]');   % By Christoph Berger
    event(i).nid = str2double(file.Markers(i).Description(num));
    if isempty(event(i).nid)
        event(i).nid = 0;
    end
end
