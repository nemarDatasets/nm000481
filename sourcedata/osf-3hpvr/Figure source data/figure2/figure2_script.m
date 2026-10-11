%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 2: Time-frequency representations time-locked to offline
% identified ripples for HIPP and NC
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure2'
%
% Created by H.-V.V. Ngo


function figure2_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure2');

filName = 'figure2_data';


%% Load data
inData = load(fullfile(dirData,[filName '.mat']));


%% Panel A
figure('Name','TFR for HIPP (t-values)');
    
tmp_tfr     = squeeze(inData.tfr.tval(2,:,:));
tmp_mask    = squeeze(inData.tfr.mask(2,:,:));
tmp_mask_v2 = squeeze(inData.tfr_v2.mask(2,:,:));

imagesc(inData.time,inData.freq,tmp_tfr);

cntr = hvn_sign_contour(inData.time,inData.freq,tmp_mask,'round');
set(cntr,'LineColor','w');

cntr2 = hvn_sign_contour(inData.time,inData.freq,tmp_mask_v2,'round');
set(cntr2,'LineColor','w');
set(cntr2,'LineStyle','--');

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
c.Label.String = 't-value';
colormap(hvn_cmap_hotcold);
caxis([-max(abs(tmp_tfr(:))) max(abs(tmp_tfr(:)))]);

vline(0,'k');
       
clear tmp_tfr tmp_mask tmp_mask_v2


%% Panel B
figure('Name','TFR for NC (t-values)');
    
tmp_tfr     = squeeze(inData.tfr.tval(1,:,:));
tmp_mask    = squeeze(inData.tfr.mask(1,:,:));
    
imagesc(inData.time,inData.freq,tmp_tfr);

cntr = hvn_sign_contour(inData.time,inData.freq,tmp_mask,'round');
set(cntr,'LineColor','w');

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
c.Label.String = 't-value';
colormap(hvn_cmap_hotcold);
caxis([-max(abs(tmp_tfr(:))) max(abs(tmp_tfr(:)))]);

vline(0,'k');
       
clear tmp_tfr tmp_mask


%% Panel C
figure('Name','Intersecting significance t-values for NC and HIPP');

tmp_tfr             = squeeze(inData.tfr.tval(1,:,:) + inData.tfr.tval(2,:,:)) ./ 2;
tmp_mask            = squeeze(inData.tfr.mask(1,:,:) .* inData.tfr.mask(2,:,:));
tmp_tfr(~tmp_mask)  = 0;

imagesc(inData.time,inData.freq,tmp_tfr);

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
c.Label.String  = 't-value';
colormap(hot);
caxis([0 abs(max(tmp_tfr(:)))]);

vline(0,'w');

clear tmp_tfr tmp_mask
