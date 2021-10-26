function funAnimateQRF(ttData, ax, FigH, quantsY, t_current, par, Data, idx_t, window, idx_gif, animPar, xi2)
%funAnimateQRF Summary of this function goes here
%   Detailed explanation goes here

scnplot = gobjects(par.N_scn,1);    % scnearios graphics placeholder


% VIDEO
%
myVideo = VideoWriter(animPar.fulVidName);      % open video file
myVideo.FrameRate = 10;                 % can adjust this, 5 - 10 works well for me
open(myVideo)
%}

% FigH = figure('WindowState','maximized');
% axis tight manual                       % this ensures that getframe() returns a consistent size
% ax = gca;


p1 = plot(ax,ttData.time(window.t_slide_range), Data(window.t_slide_range),'-k','LineWidth',0.1);

hold all

ax.YLim = ([min(Data) max(Data)]);


grid on;
s1 = scatter(ax,ttData.time(idx_t), Data(idx_t),100,'+b','LineWidth',3);

p2 = plot(ax,ttData.time(window.t_slide_range),window.trueY,'-k*','LineWidth',2);
p3 = plot(ax,ttData.time(window.t_slide_range),window.predY,'--r*','LineWidth',2);
p4 = plot(ax,ttData.time(window.t_slide_range),window.quant005Y, '-g','LineWidth',0.5);
p5 = plot(ax,ttData.time(window.t_slide_range),window.quant05Y , '-b','LineWidth',0.5);
p6 = plot(ax,ttData.time(window.t_slide_range),window.quant095Y, '-g','LineWidth',0.5);

% 5%-95%
X_plot = [ttData.time(window.t_slide_start + window.width + 1 : window.t_slide_start+ window.width + par.N_prd)' , ...
          fliplr(ttData.time(window.t_slide_start + window.width + 1 : window.t_slide_start+ window.width + par.N_prd)')];
Y_plot  = [quantsY.quant005Y, fliplr(quantsY.quant095Y)];
f1      = fill(ax,X_plot, Y_plot , 1,'facecolor','green','edgecolor','none', 'facealpha', 0.1);
% 10%-90%
Y_plot  = [quantsY.quant010Y, fliplr(quantsY.quant090Y)];
f2      = fill(ax,X_plot, Y_plot , 1,'facecolor','green','edgecolor','none', 'facealpha', 0.2);
% 20%-80%
Y_plot  = [quantsY.quant020Y, fliplr(quantsY.quant080Y)];
f3      = fill(ax,X_plot, Y_plot , 1,'facecolor','green','edgecolor','none', 'facealpha', 0.3);
% 30%-70%
Y_plot  = [quantsY.quant030Y, fliplr(quantsY.quant070Y)];
f4      = fill(ax,X_plot, Y_plot , 1,'facecolor','green','edgecolor','none', 'facealpha', 0.4);
% 40%-60%
Y_plot  = [quantsY.quant040Y, fliplr(quantsY.quant060Y)];
f5      = fill(ax,X_plot, Y_plot , 1,'facecolor','green','edgecolor','none', 'facealpha', 0.5);

for i_scn = 1 : par.N_scn
    window.scenY(1:window.width + 1,1) = NaN;
    window.scenY(window.width + 2 : window.width + par.N_prd + 1,1) = xi2(1,:,i_scn);
    window.scenY(window.width + par.N_prd + 2 : length(window.t_slide_start:window.t_slide_end) ,1) = NaN;
    
    scnplot(i_scn) = plot(ax,ttData.time(window.t_slide_start : window.t_slide_end),window.scenY,'--m','LineWidth',1);

end

% GIF and VIDEO
pause(0.01);
title(['t_{idx} = ',num2str(t_current), ',   Time = ' datestr(ttData.time(t_current)), ',   gif frame # : ',num2str(idx_gif)])
drawnow

%
% Capture the plot as an image
frame = getframe(FigH);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
% Write to the GIF File
if idx_gif == 1
    imwrite(imind,cm,animPar.fulGifName,'gif', 'Loopcount',inf);
else
    imwrite(imind,cm,animPar.fulGifName,'gif','WriteMode','append');
end

% Write to the MP4 File
writeVideo(myVideo, frame);

hold off;

legend([p1 s1 p2 p3 p4 p5 p6 f1 f2 f3 f4 f5 scnplot(1)],{'data','issue','true','mean forecast','quantile 5%',...
    'quantile 50%','quantile 95%','pred. int. 90%','pred. int. 80%','pred. int. 60%',...
    'pred. int. 40%','pred. int. 20%','Scenarios'},'NumColumns',6);




end