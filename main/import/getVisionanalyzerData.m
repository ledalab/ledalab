function [time, conductance, event] = getVisionanalyzerData(filename)

file = load(filename);

time = file.t/1000;  %convert ms to sec
conductance = file.EDA;
%conductance = file.GSR_MR_100_xx;

%control for mismatching vector length
n1 = length(time);
n2 = length(conductance);
time = time(1:min(n1, n2));
conductance = conductance(1:min(n1, n2));

for i = 1:length(file.Markers)
    event(i).time = file.Markers(i).Position / file.SampleRate;
    event(i).name = file.Markers(i).Type;
    event(i).nid = str2double(file.Markers(i).Description);
end
