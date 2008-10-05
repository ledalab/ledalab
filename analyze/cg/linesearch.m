function [wparset, step] = linesearch(wparset, direction, epoch)

direction_n = direction / norm(direction,2);
x = get_parset_position(wparset);
error_list = wparset.error;
factor = 0;
stepsize = wparset.h; %.5;
maxSteps = 20;%!!!!

for iStep = 2:maxSteps
    
    factor(iStep) = stepsize * 2^(iStep-2);
    xc = x + direction_n * factor(iStep);
    cparset = set_parset_position(wparset, xc, epoch);
    error_list(iStep) = fiterror_parset(epoch, cparset);
    
    if error_list(end) >= error_list(end-1) %end of decline
        if iStep == 2 %no success
            step = 0;
        else %parabolic
            p = polyfit(factor, error_list, 2);
            fx = factor(1):stepsize/10:factor(end);
            fy = polyval(p, fx);
            [mn, idx] = min(fy);
            fxm = fx(idx);
            xcm = x + direction_n * fxm;
            mnparset = set_parset_position(wparset, xcm, epoch);
            error = fiterror_parset(epoch, mnparset);
            
            if error < error_list(iStep - 1)
                wparset = mnparset;
                wparset.error = error;
                step = fxm;
            else %finding Minimum did not work
                xc = x + direction_n * factor(iStep-1);%before last point
                wparset = set_parset_position(wparset, xc, epoch); 
                wparset.error = error_list(iStep - 1);
                step = factor(iStep-1);
            end
        end
        return;
    end
end
step = factor(iStep);

%Taylor-Check??
