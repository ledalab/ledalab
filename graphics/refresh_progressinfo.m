function refresh_progressinfo
global leda2

if isempty(leda2.analyze.fit)
    set(leda2.gui.progressinfo.text_fitIteration,'String','-');
    set(leda2.gui.progressinfo.text_fitError,'String','-');
    set(leda2.gui.progressinfo.text_epochNr,'String','Epoch');
    set(leda2.gui.progressinfo.text_epochIteration,'String','-');
    set(leda2.gui.progressinfo.text_epochError,'String','-');
    set(leda2.gui.progressinfo.text_parsetNr,'String','Parset');
    set(leda2.gui.progressinfo.text_parsetIteration,'String','-');
    set(leda2.gui.progressinfo.text_parsetError,'String','-');
    return;
end

set(leda2.gui.progressinfo.text_fitIteration,'String',leda2.analyze.fit.info.iterations);
set(leda2.gui.progressinfo.text_fitError,'String',[sprintf('%6.4f', leda2.analyze.fit.info.rmse),'  (',num2str(leda2.analyze.history.error(1),'%6.4f'),')']);
iEpoch = leda2.analyze.current.iEpoch;
bpar = leda2.analyze.epoch(iEpoch).bestparset;
set(leda2.gui.progressinfo.text_epochError,'String',[num2str(leda2.analyze.epoch(iEpoch).parset(bpar).error,'%6.4f'),'  (',num2str(leda2.analyze.epoch(iEpoch).initial_error,'%6.4f'),')']);

if leda2.analyze.current.optimizing

    iPar = leda2.analyze.current.iParset;
    nEpochs = length(leda2.analyze.epoch);

    set(leda2.gui.progressinfo.text_epochNr,'String',['Epoch  ',num2str(iEpoch),' / ',num2str(nEpochs)]);
    set(leda2.gui.progressinfo.text_epochIteration,'String',leda2.analyze.epoch(iEpoch).iteration);

    set(leda2.gui.progressinfo.text_parsetNr,'String',['Parset  ',num2str(iPar),' / ', num2str(length(leda2.analyze.epoch(iEpoch).parset))]);
    set(leda2.gui.progressinfo.text_parsetIteration,'String',leda2.analyze.epoch(iEpoch).parset(iPar).iteration);
    set(leda2.gui.progressinfo.text_parsetError,'String',[num2str(leda2.analyze.epoch(iEpoch).parset(iPar).error,'%6.4f'),'  (',num2str(leda2.analyze.epoch(iEpoch).parset(iPar).history.error(1),'%6.4f'),')']);  %

else %reset

    set(leda2.gui.progressinfo.text_epochNr,'String','Epoch');
    set(leda2.gui.progressinfo.text_epochIteration,'String','-');

    set(leda2.gui.progressinfo.text_parsetNr,'String','Parset');
    set(leda2.gui.progressinfo.text_parsetIteration,'String','-');
    set(leda2.gui.progressinfo.text_parsetError,'String','-');

end
