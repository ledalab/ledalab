function refresh_fitinfo
global leda2

if isempty(leda2.analyze.fit)
    set(leda2.gui.text_adjR2,'String','Adj. R2: ');
    set(leda2.gui.text_rmse,'String','RMSE: ');
    set(leda2.gui.text_nPhasic,'String','SCRs: ');
    set(leda2.gui.text_nTonic,'String','TPs: ');
    set(leda2.gui.text_df,'String','DF: ');
    return;
end

if isempty(leda2.analyze.history)
    leda2.analyze.history.nIter = [];
    leda2.analyze.history.error = [];
    leda2.analyze.history.nPhasic = [];
    leda2.analyze.history.nPar = [];
end

nTonic = length(leda2.analyze.fit.toniccoef.ground);
set(leda2.gui.text_nTonic,'String',['TPs: ', num2str(nTonic)]);
nPhasic = length(leda2.analyze.fit.phasiccoef.onset);
%nTau = length(unique(leda2.analyze.fit.phasiccoef.tau(1,:)));
set(leda2.gui.text_nPhasic,'String',['SCRs: ', num2str(nPhasic)]); %,' (', num2str(2*nTau),')'
nPar = nPhasic * 4 + nTonic + 1;
leda2.analyze.fit.info.df = leda2.data.N - nPar;

leda2.analyze.fit.info.rmse = fiterror(leda2.data.conductance.data, (leda2.analyze.fit.data.tonic + leda2.analyze.fit.data.phasic), nPar,'RMSE');
leda2.analyze.fit.info.adjR2 = fiterror(leda2.data.conductance.data, (leda2.analyze.fit.data.tonic + leda2.analyze.fit.data.phasic), nPar, 'adjR2');
set(leda2.gui.text_rmse,'String',['RMSE: ', sprintf('%6.4f', leda2.analyze.fit.info.rmse)]);
set(leda2.gui.text_adjR2,'String',['Adj. R2: ', sprintf('%6.4f',leda2.analyze.fit.info.adjR2)]);
set(leda2.gui.text_df,'String',['DF: ', num2str(leda2.analyze.fit.info.df)]);

leda2.analyze.history.nIter = [leda2.analyze.history.nIter, leda2.analyze.fit.info.iterations];
leda2.analyze.history.error = [leda2.analyze.history.error, leda2.analyze.fit.info.(lower(leda2.set.errorType))];
leda2.analyze.history.nPhasic = [leda2.analyze.history.nPhasic, nPhasic];
leda2.analyze.history.nPar = [leda2.analyze.history.nPar, nPar];
