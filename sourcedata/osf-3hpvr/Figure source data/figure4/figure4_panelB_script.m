%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 4B: Time-frequency representations of short- and
% long-duration ripples at NC
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure4'
%
% Created by H.-V.V. Ngo


function figure4_panelB_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure4');

filName = 'figure4_panelB_data';


%% load results
inData = load(fullfile(dirData, [filName '.mat']));


%% Panel B
%.. short-duration ripples
figure('Name','TFR of short-duration ripples (t-values)');

imagesc(inData.time,inData.freq, inData.short.tval);
  
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

caxis([-5 5]);
    
vline(0,'k');

    
%.. long-duration ripples
figure('Name','TFR of long-duration ripples: t-values');

imagesc(inData.time,inData.freq, inData.long.tval);

c = hvn_sign_contour(inData.time,inData.freq,inData.long.mask,'round');
set(c,'LineColor','w');

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
caxis([-5 5]);
    
vline(0,'k');
