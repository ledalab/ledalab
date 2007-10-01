function [x,y,events] = getcassydata(file)
% getcassydata(file)
%
% gets CASSY data from lab file

x = [];
y = [];
m = [];
%xoff = [];
events = {};
x1 = 0;
eta = [];
eca = [];
ela = {};

fid = fopen(file,'rt');

labno = 0;
off = 0;
p_scin  = [];
p_event = [];
p_mark  = [];
for i=1:100
    line = fgets(fid);
    if i>5 & isletter(line(1))
        labno = labno+1;
        lab = line(1:end-1);
        label{labno} = lab;
        switch lab
            case 'Hautleitwert'
                p_scin = labno;
            case 'Ereignisse'
                p_event = labno;
            case {'Marker', 'Markierer'}
                p_mark = labno;
        end
        lineno(labno) = i+off;
        line = fgets(fid);
        line = fgets(fid);
        off=off+2;
    end
end
fclose(fid);

if isempty(p_scin)
    error('no scin conductance axis detected');
end

if isempty(p_event) & isempty(p_mark)
    %    error('no event/marker axis detected');
end

fid = fopen(file,'rt');
for i=1:lineno(end)+4
    line = fgets(fid);
end

gota = sscanf(line,'%f');
datno = gota(2);

h = waitbar(0,'Importing Cassy-Lab data...');
for i=1:datno
    if mod(i,50) == 0, waitbar(i/datno); end

    line = fgets(fid);
    gota = sscanf(line,'%f');
    dt = gota(2);
    if isnan(dt); continue; end
    scin = gota(p_scin);
    x = [x dt];
    y = [y scin];
    if ~isempty(p_mark)
        mark = gota(p_mark);
        m = [m mark];
    end
end
close(h)

%if ~isempty(x)
%    xoff = x(1);
%    x = x - xoff;
%end

% either get event data from marker
if ~isempty(p_mark)
    m(find(isnan(m))) = 0;  % correct for NAN
    m1 = m(1:end-1);
    m2 = m(2:end);
    e  = find(m1==0&m2>0)+1;
    eca = m(e);
    eta = x(e);
    fclose(fid);
    %events = {eta eca};

    for ev = 1:length(eta)
        events(ev).time = eta(ev);
        events(ev).nid = eca(ev);
    end
    return
end

% or get event data from event list
% skip
while(1)
    line = fgets(fid);
    if line==-1;
        fclose(fid);
        return
    end
    if strncmp(line,'58432',5); break; end
end

line = fgets(fid);
evno = sscanf(line,'%d');
for i=1:evno
    line = fgets(fid);
    if line==-1;
        fclose(fid);
        return
    end
    type = sscanf(line,'%d');
    if type(1)==1                       % line
        C_p = find(line=='C');
        sline = line(C_p+1:end);
        gota = sscanf(sline,'%f');
        ec = gota(1);                   % color
        et = gota(4);                   % time
        eca = [eca ec];
        eta = [eta et];
    elseif type(1)==0                   % text
        s_p = find(line==' ');
        line = line(s_p(9)+1:end-1);
        ela{size(ela,2)+1} = line;
    end
end

%if ~isempty(x)
%    eta = eta - xoff;
%end

%events = {eta eca ela};
for ev = 1:length(eta)
    events(ev).time = eta(ev);
    events(ev).name = ela(ev);
    events(ev).nid = eca(ev);
end

fclose(fid);
