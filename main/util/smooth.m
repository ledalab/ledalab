function sdata = smooth(data, winwidth, type)

if nargin < 3
    type = 'gauss';
end

data = data(:)'; %ensure data as a row;
winwidth = ceil(winwidth/2)*2;   % force even winsize for odd window
switch type,
    case 'hann'
        window = 0.5*(1 - cos(2*pi*(0:1/winwidth:1)));  % hanning window
    case 'mean'
        window = ones(1,winwidth+1); %moving average
    case 'gauss'
        window = normpdf(1:(winwidth+1), winwidth/2+1, winwidth/8);
    otherwise
        error('Unknown type')
end
window = window / sum(window);  % normalize window
data_ext = [ones(1,winwidth/2)*data(1), data, ones(1,winwidth/2)*data(end)]; %extend data to reduce convolution error at beginning and end
sdata_ext = conv(data_ext, window); % convolute with window
sdata = sdata_ext(1+winwidth : end-winwidth); %cut to data length
