% ----- FORECAST PLOTS (based on selected date) -----
%%
% mkdir FigOutTest
FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\Figs_Out\Revised_MS';   % Your destination folder
% FolderName = '\\home.ansatt.ntnu.no\spyridoc\Documents\MATLAB\J2_PAPER\EMS-SMPC\Figs_Out\No_lgd_trial\Load\Resized_01\PDFfigs';   % Your destination folder
FigList = findobj(allchild(0), 'flat', 'Type', 'figure');
for iFig = 1:length(FigList)
    FigHandle = FigList(iFig);
    %       FigName   = num2str(get(FigHandle, 'Number'));
    FigName   = get(FigHandle,'Name');
    %     set(0, 'CurrentFigure', FigHandle);
    %     savefig(fullfile(FolderName, [FigName '.fig']));
    
    % -----------------------TO PRINT THE FIGURE---------------------------
    
%     print(FigHandle, fullfile(FolderName, [FigName '.png']), '-r300', '-dpng')

%     print(FigHandle, fullfile(FolderName, [FigName '.pdf']),'-dpdf','-fillpage')

%     pos = get(FigHandle,'Position');

pos = get(gcf,'Position');
set(gcf,'PaperSize',[pos(3) pos(4)],'PaperUnits','inches')
print(FigHandle, fullfile(FolderName, [FigName '.pdf']),'-dpdf')
    
%         print(FigHandle, fullfile(FolderName, [FigName '.jpg']),
%         '-r300','-djpeg') THE WORST QUALITY


end
%}