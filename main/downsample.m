function downsample
global leda2

sc = leda2.data.conductance.data;
t = leda2.data.time.data;
Fs = round(leda2.data.samplingrate);

factorL = divisors(Fs);
FsL = Fs./factorL;    %list of possible new sampling rates

if isempty(FsL)
    msgbox('Current sampling rate can not be further broken down')
    return;
end

for i = 1:length(FsL)
    FsL_txt{i} = sprintf('%d Hz',FsL(i));
end

[sel, ok] = listdlg('Name','','PromptString',['Downsample from ',num2str(Fs),'Hz to:'],'SelectionMode','single','ListString',FsL_txt,'ListSize',[160,200]);
if ~ok
    return
end

if ~isempty(leda2.analyze.fit)
    cmd = questdlg('The current fit will be deleted!','Warning','Continue','Cancel','Continue');
    if isempty(cmd) || strcmp(cmd, 'Cancel')
        return
    end
end
    

factor = factorL(sel);

[td, scd] = downsamp(t, sc, factor);
%downsampling results in an additional offset = time(1), which will not be substracted (tim = time - offset) in order not to affect event times
leda2.data.time.data = td(:)';
leda2.data.conductance.data = scd(:)';
%update data statistics
leda2.data.N = length(leda2.data.time.data);
leda2.data.samplingrate = FsL(sel);
leda2.data.conductance.error = sqrt(mean(diff(scd).^2)/2);
leda2.data.conductance.min = min(scd);
leda2.data.conductance.max = max(scd);

delete_fit(0);
leda2.gui.rangeview.range = 60;
plot_data;
file_changed(1);
add2log(1,['Data downsampled to ',FsL_txt{sel},'.'],1,1,1);


function [t, data] = downsamp(t, data, factor)

N = length(data); %#samples
data = data(1:end-mod(N, factor)); %reduce samples to match a multiple of <factor>
data = mean(reshape(data, factor, []))'; %Mean of <factor> succeeding samples
t = t(1:end-mod(N, factor));
t = mean(reshape(t, factor, []))';
