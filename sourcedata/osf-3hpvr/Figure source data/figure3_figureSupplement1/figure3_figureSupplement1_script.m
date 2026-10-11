%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 3 - Figure supplement 1: Time-resolved coherence between NC
% and HIPP around hippocampal ripples
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure3_figureSupplement1'
%
% Created by H.-V.V. Ngo


function figure3_figureSupplement1_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure3_figureSupplement1');

filName = 'figure3_figureSupplement1_data';


%% load data
inData = load(fullfile(dirData, [filName '.mat']));


%% Plot figure
figure('Name','Time-resolved NC-HIPP coherence (z-score)');

imagesc(inData.time,inData.freq,inData.coh_zValues);
mask = hvn_sign_contour(inData.time,inData.freq,inData.mask_spindleCluster);
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
caxis([-max(abs(inData.coh_zValues(:))) max(abs(inData.coh_zValues(:)))]);

vline(0,'k');
