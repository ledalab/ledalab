function [parset, improvement] = gradientdescent(epoch, parset)
global leda2

improvement = 0;
Ndim = length(parset.onset)*2 + 1;

for iter = 1:Ndim 
    parset.iteration = parset.iteration + 1;
    olderror = parset.error;
    
    %GET GRADIENT    
    if iter == 1
        gradient = get_gradient(parset, epoch);
        direction = -gradient;
        if isempty(gradient)
            parset.alive = 0;
            return;
        end
        
    else
        new_gradient = get_gradient(parset, epoch);
        old_direction = direction;
        old_gradient = gradient;
        
        method = 4;
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
        [parset, step] = linesearch(parset, direction, epoch);   
        error_diff = parset.error - olderror;
        
    else 
        error_diff = 0; % empty gradient
        step = 0;
    end
    
    %history
    parset.history.x(parset.iteration + 1, :) = get_parset_position(parset);
    parset.history.direction(parset.iteration + 1, :) = direction;
    parset.history.step(parset.iteration + 1) = step;
    parset.history.h(parset.iteration + 1) = parset.h;
    parset.history.error(parset.iteration + 1) = parset.error;
    
    if error_diff > - leda2.data.conductance.error/10000 %no improvement
        
        parset.h = parset.h/2;            
        if parset.h < leda2.set.hThreshold;
            parset.alive = 0;
        end
        return
        
    else
        improvement = 1;
    end
    
end %for iter
