function leda_keypress
global leda2

ch = double(get(leda2.gui.fig_main,'CurrentCharacter'));

if isempty(ch) %Strg / Cntrl
    return;
end

switch ch
    case 27,  %Esc
        leda2.analyze.current.optimizing_epoch = 0;
        leda2.analyze.current.optimizing = 0;
        
    case 110, %"n": next epoch
        leda2.analyze.current.optimizing_epoch = 0;
        
end
