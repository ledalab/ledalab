function [t, data] = downsamp(t, data, fac, type)

N = length(data); % #samples
if strcmp(type,'step')
    t = t(1:fac:end);
    data = data(1:fac:end);

elseif strcmp(type,'mean')
    t = t(1:end-mod(N, fac));
    t = mean(reshape(t, fac, []))';
    data = data(1:end-mod(N, fac)); %reduce samples to match a multiple of <factor>
    data = mean(reshape(data, fac, []))'; %Mean of <factor> succeeding samples
    
elseif strcmp(type, 'gauss')
    t = t(1:fac:end);
    data = smooth(data,2^fac,'gauss');
    data = data(1:fac:end);
end
