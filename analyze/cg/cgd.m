function [x, history] = cgd(start_val, error_fcn, h, crit_error, crit_iter, crit_h)


x = start_val;
newerror = error_fcn(x);
starterror = newerror;
history.x = x;
history.direction = zeros(size(x));
history.step = -1;
history.h = -ones(size(h));
history.error = newerror;
%disp(['Initial parameter:  ',sprintf(' %5.2f\t',x),sprintf('  Error: %6.3f',newerror)])
iter = 0;

while 1
    iter = iter + 1;
    olderror = newerror;

    %GET GRADIENT
    if iter == 1
        gradient = cgd_get_gradient(x, olderror, error_fcn, h);
        direction = -gradient;
        if isempty(gradient)
            break;
        end

    else
        new_gradient = cgd_get_gradient(x, olderror, error_fcn, h);
        old_direction = direction;
        old_gradient = gradient;

        method = 1;
        switch method
            case 1
                % no conjugation
                direction = -new_gradient;
            case 2
                % Fletcher-Reeves
                beta = norm(new_gradient, 2) / norm(old_gradient, 2);
                direction = -new_gradient + beta * old_direction;
            case 3
                %  Polak-Ribiere
                a = (new_gradient - old_gradient) * new_gradient';
                b = old_gradient * old_gradient';
                beta = max(a / b, 0);
                direction = -new_gradient + beta * old_direction;
            case 4
                % Hestenes-Stiefel
                a = (new_gradient - old_gradient) * new_gradient';
                b = old_direction * (new_gradient - old_gradient)';
                beta = a / b;
                direction = -new_gradient + beta * old_direction;
        end
    end


    if any(direction)
        %LINESEARCH
        [x, newerror, step] = cgd_linesearch(x, olderror, direction, error_fcn, h);
        error_diff = newerror - olderror;

    else
        error_diff = 0; % empty gradient
        step = 0;
    end

    %history
    history.x(iter + 1, :) = x;
    history.direction(iter + 1, :) = direction;
    history.step(iter + 1) = step;
    history.h(iter + 1, :) = h;
    history.error(iter + 1) = newerror;

    if iter > crit_iter
        break
    end
    if error_diff > -crit_error %no improvement

        h = h/2;
        if all(h < crit_h);
            break
        end
    end
    %disp([x, newerror, max(h)])

end

add2log(0,['Optimized parameter: ',sprintf('%5.2f\t',x),sprintf(' Error: %6.3f',newerror),' (Initial parameter: ',sprintf('%5.2f\t',start_val), sprintf(' Error: %6.3f)',starterror)], 0,0,1,1,0)

