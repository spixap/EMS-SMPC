% ----- FORECAST PLOTS (based on selected date) -----
%%
% mkdir FigOutTest
FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\Figs_Out\Revised_MS\Load_Steps\Revised_Figs\Font_12';   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    %       FigName   = num2str(get(FigHandle, 'Number'));
    FigName   = get(FigHandle,'Name');
    %     set(0, 'CurrentFigure', FigHandle);
    %     savefig(fullfile(FolderName, [FigName '.fig']));
    print(FigHandle, fullfile(FolderName, [FigName '.png']), '-r300', '-dpng')
end
%}