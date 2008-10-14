function [xc, error1, step] = cgd_linesearch(x, error0, direction, error_fcn, h)

direction_n = direction / norm(direction,2);
error_list = error0;
factor = 0;
stepsize = h; 
maxSteps = 6;%!!!!

for iStep = 2:maxSteps

    factor(iStep) = 2^(iStep-2);
    xc = x + direction_n .* stepsize * factor(iStep);
    [error_list(iStep), xc] = error_fcn(xc);  %xc may be changed due to limits

    if error_list(end) >= error_list(end-1) %end of decline
        if iStep == 2 %no success
            step = 0;
            error1 = error0;
            
        else %parabolic
            p = polyfit(factor, error_list, 2);
            fx = factor(1):.1:factor(end);
            fy = polyval(p, fx);
            [mn, idx] = min(fy);
            fxm = fx(idx);
            xcm = x + direction_n .* stepsize * fxm;
            [error1, xcm] = error_fcn(xcm);  %xc may be changed due to limits

            if error1 < error_list(iStep - 1)
                xc = xcm;
                step = fxm;
                
            else %finding Minimum did not work
                xc = x + direction_n .* stepsize * factor(iStep-1);%before last point
                [error1, xc] = error_fcn(xc); %recalculate error in order to check for limits again
                step = factor(iStep-1);
            end
            
        end
        return;
        
    end %end of decline
    
end

step = factor(iStep);
error1 = error_list(iStep);

%Taylor-Check??
