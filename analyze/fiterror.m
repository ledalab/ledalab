function error = fiterror(data, fit, npar, errortype)
global leda2
%npars = number of unfree parameters with df = n - npar

residual = data - fit;

n = length(data);
df = n - npar;
SSE = sum(residual.^2);

switch errortype
    case 'MSE',
        error = SSE/n; %MSE, non-normalized
    case 'RMSE',
        error = sqrt(SSE/n); %RMSE, non-normalized
    case 'adjR2',
        SST = std(data, 1) * n;
        r2 = 1 - SSE/SST;
        error = 1 - (1 - r2) * (n-1) / df; %adjusted-R^2
        %for optimization use 1 - adjR2 since you want to minimize the function
    case 'Chi2'
        error = SSE/leda2.data.conductance.error;

end
