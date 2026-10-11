%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 3 - Figure supplement 2C-D: Phase-locking value between NC
% and HIPP around hippocampal ripples
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure3_figureSupplement2'
%
% Created by H.-V.V. Ngo


function figure3_figureSupplement2_panelCD_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure3_figureSupplement2');

filName = 'figure3_figureSupplement2_panelCD_data';


%% load data
inData = load(fullfile(dirData, [filName '.mat']));


%% Panel C
figure('Name','Time-resolved phase-locking value (z-score)');

imagesc(inData.timefreqmap.time,inData.timefreqmap.freq,inData.timefreqmap.zValues);
mask = hvn_sign_contour(inData.timefreqmap.time,inData.timefreqmap.freq,inData.timefreqmap.mask_spindleCluster);
set(mask,'LineColor','w');

axis xy

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-1 1]);
xticks([-1 -0.5 0 0.5 1])
xticklabels({'-1','-0.5','0','0.5','1'})

ylabel('Frequency (Hz)');
ylim([1 20]);
yticks([2 5 10 15 20])
yticklabels({'2','5','10','15','20'})

c = colorbar;
c.Label.String = 'z-score';
colormap(hvn_cmap_hotcold);
caxis([-max(abs(inData.timefreqmap.zValues(:))) max(abs(inData.timefreqmap.zValues(:)))]);

vlinedashed(0,'w');


%% Panel D
figure('Name','Time-resolved phase-locking value in spindle band');

plot(inData.timeseries.time,inData.timeseries.zValues,'k','LineWidth',2);

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-1 1])
xticks([-1 -0.5 0 0.5 1])
xticklabels({'-1','-0.5','0','0.5','1'})

ylabel('z-score');
ylim([-3.5 3.5])

vlinedashed(0,'k');
hline(0);
hline(norminv(0.025),'b');
hline(norminv(1-0.025),'b');
