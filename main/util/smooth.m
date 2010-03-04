function sdata = smooth(data, winwidth, type)

if winwidth < 1
    sdata = data;
    return;
end
if nargin < 3
    type = 'gauss';
end

data = data(:)'; %ensure data as a row;
data = [data(1) data data(end)]; %pad to remove border errors
winwidth = floor(winwidth/2)*2;   % force even winsize for odd window

switch type,
    case 'hann'
        window = 0.5*(1 - cos(2*pi*(0:1/winwidth:1)));  % hanning window
    case 'mean'
        window = ones(1,winwidth+1); %moving average
    case 'gauss'
        window = normpdf(1:(winwidth+1), winwidth/2+1, winwidth/8);
    case 'expl'
        window = [zeros(1, winwidth/2), exp(-4*(0:2/winwidth:1))];
%     case 'bateman'
%         window = bateman(1:winwidth,0,0,5,50);
    otherwise
        error('Unknown type')
end
window = window / sum(window);  % normalize window

data_ext = [ones(1,winwidth/2)*data(1), data, ones(1,winwidth/2)*data(end)]; %extend data to reduce convolution error at beginning and end
sdata_ext = conv(data_ext, window); % convolute with window
sdata = sdata_ext(2+winwidth : end-winwidth-1); %cut to data length

%Smoothing by convolution needs different padding
%sdata = conv(data, window); % convolute with window
%sdata = sdata(2+winwidth/2 : end-winwidth/2-1); %cut to data length
