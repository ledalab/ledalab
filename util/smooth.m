function sdata = smooth(data, winwidth)

win = ceil(winwidth/2);   % force even winsize for odd window
window = 0.5*(1 - cos(2*pi*(0:1/(2*win):1)));  % hanning window
window = window / sum(window);  % normalize window
data_ext = [ones(1,win)*data(1), data, ones(1,win)*data(end)]; %extend data to reduce convolution error at beginning and end
sdata_ext = conv(data_ext, window); % convolute with window
sdata = sdata_ext(1+2*win : end-2*win); %cut to data length
