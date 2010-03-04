function [time, conductance, event] = getVarioportData(filename)
%Import Varioport data
%Contributed by Christoph Berger

%open file
fid = fopen(filename,'r','b'); %big-endian byte ordering

%channel count
fseek(fid, 7, 'bof');
vario.head.channel_count = fread(fid, 1);

%scanrate in Hertz
fseek(fid, 20, 'bof');
vario.head.ScanRate = fread(fid, 1, 'uint16');
%scaled scanrate
%SCAN_CONST divided by weighted global scanrate = scaled global scanrate in Hertz .
vario.head.SCAN_CONST = 76800;
vario.head.Scaled_Scan_Rate = vario.head.SCAN_CONST / vario.head.ScanRate;
%date of measure
fseek(fid, 16, 'bof');
vario.head.measure_date = fread(fid, 3);
%time of measure
fseek(fid, 12, 'bof');
vario.head.measure_time = fread(fid, 3);
%file header length
fseek(fid, 2, 'bof');
vario.head.length = fread(fid, 1, 'uint16');
% get eda (and marker) info
for i=1:vario.head.channel_count
    %channel name
    fseek(fid, (i - 1) * 40 + 36, 'bof');
    channel_name = strtrim(fread(fid, 6,'*char')');
    if strcmpi(channel_name,'eda') || strcmpi(channel_name,'gsr')
        vario.eda = vario_channel_read(i,channel_name,fid,vario.head.Scaled_Scan_Rate,vario.head.channel_count);
    elseif strcmpi(channel_name,'marker')
        vario.marker = vario_channel_read(i,channel_name,fid,vario.head.Scaled_Scan_Rate,vario.head.channel_count);
    end;
end;
fclose(fid);

%Ledalab data
conductance = (vario.eda.data - vario.eda.offset) .* (vario.eda.mul / vario.eda.div);
time = (1:length(conductance)) / vario.eda.scaled_scan_fac;

%get events
vario.marker.time = (1:length(vario.marker.data)) / vario.marker.scaled_scan_fac;

%marker value > 0, marker channel shows difference, new marker value is
%kept in next sample
eventIdx = find(vario.marker.data > 0 & diff([0;vario.marker.data]) & diff([vario.marker.data;0]) == 0);

%allocating
event= struct('time', {}, 'nid', {},'name', {});
if ~isempty(eventIdx)
    event(length(eventIdx)).nid=0;
    %events
    for iEvent = 1:length(eventIdx)
        iEventIdx = eventIdx(iEvent);
        event(iEvent).time = vario.marker.time(iEventIdx);
        event(iEvent).nid = vario.marker.data(iEventIdx);
        event(iEvent).name = num2str(vario.marker.data(iEventIdx));
    end
end

clear vario;


function out = vario_channel_read(chnr,chname,fid,scnrate, chncnt)

out.name = chname;
%channel info
%mul
fseek(fid, (chnr - 1) * 40 + 52, 'bof');
out.mul = fread(fid, 1, 'uint16');
%div
fseek(fid, (chnr - 1) * 40 + 56, 'bof');
out.div = fread(fid, 1, 'uint16');
%offset
fseek(fid, (chnr - 1) * 40 + 54, 'bof');
out.offset = fread(fid, 1, 'uint16');
%channel resolution. 1: 2 byte(WORD), 0: 1 byte(BYTE)
fseek(fid, (chnr - 1) * 40 + 47, 'bof');
out.res = fread(fid, 1);
if out.res && 1
    out.sres = 'uint16';
else
    out.sres = 'uint8';
end;
%channel unit
fseek(fid, (chnr - 1) * 40 + 42, 'bof');
out.unit = strtrim((fread(fid, 4,'*char'))');
%store_rate in Hertz
fseek(fid, (chnr - 1) * 40 + 48, 'bof');
out.scan_fac = fread(fid, 1);
fseek(fid, (chnr - 1) * 40 + 50, 'bof');
out.store_fac = fread(fid, 1);
out.scaled_scan_fac = scnrate/(out.scan_fac * out.store_fac);

%file offset: begin of channel data
fseek(fid, (chnr - 1) * 40 + 60, 'bof');
%origin=after cheksum header incl. channeldef
out.doffs = fread(fid, 1,'uint32') + 38 + chncnt* 40;
%channel length in byte
fseek(fid, (chnr - 1) * 40 + 64, 'bof');
out.dlen = fread(fid, 1,'uint32');
%channel data
fseek(fid, out.doffs, 'bof');
out.data = fread(fid, out.dlen / (out.res + 1), out.sres);
