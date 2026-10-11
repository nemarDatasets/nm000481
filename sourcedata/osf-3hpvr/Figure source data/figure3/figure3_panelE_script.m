%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 3E: Histogram of NC- and HIPP spindle onsets time-locked to
% hippocampal ripples
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure3'
%
% Created by H.-V.V. Ngo


function figure3_panelE_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure3');

filName = 'figure3_panelE_data';


%% load results
inData = load(fullfile(dirData, [filName '.mat']));


%% Panel E
figure('Name','Histograms of spindle onsets around ripples');

%.... NC
subplot(2,1,1)
    
%.. prepare signifance vector
tmp_signifance = inData.zValues(1,:) > 1.96;
    
hold on;
%.. plot significant bins
tmp_histogram                   = inData.spiOnset(1,:);
tmp_histogram(~tmp_signifance)  = nan;
bar(inData.time+(0.5*0.05),tmp_histogram,1,'FaceColor','r','FaceAlpha',1,'EdgeColor','k')

%.. plot not significant bins with lighter color
tmp_histogram                   = inData.spiOnset(1,:);
tmp_histogram(tmp_signifance)   = nan;
bar(inData.time+(0.5*0.05),tmp_histogram,1,'FaceColor','r','FaceAlpha',0.33,'EdgeColor','k')

hold off

set(gca,'TickDir','out');
box off

xlabel('Time (s)')
xlim([-0.5 0.5])
xticks([-0.5 -0.25 0 0.25 0.5])
xticklabels({'-0.5','','0','','0.5'})
    
ylabel('Spindle incidence %')
ylim([3 7])

title('NC');


%.... HIPP
subplot(2,1,2)
    
%.. prepare signifance vector
tmp_signifance = inData.zValues(2,:) > 1.96;
    
hold on;
%.. plot significant bins
tmp_histogram                   = inData.spiOnset(2,:);
tmp_histogram(~tmp_signifance)  = nan;
bar(inData.time+(0.5*0.05),tmp_histogram,1,'FaceColor','b','FaceAlpha',1,'EdgeColor','k')

%.. plot not significant bins with lighter color
tmp_histogram                   = inData.spiOnset(2,:);
tmp_histogram(tmp_signifance)   = nan;
bar(inData.time+(0.5*0.05),tmp_histogram,1,'FaceColor','b','FaceAlpha',0.33,'EdgeColor','k')

hold off

set(gca,'TickDir','out');
box off

xlabel('Time (s)')
xlim([-0.5 0.5])
xticks([-0.5 -0.25 0 0.25 0.5])
xticklabels({'-0.5','','0','','0.5'})
    
ylabel('Spindle incidence %')
ylim([3 7])

title('HIPP');
