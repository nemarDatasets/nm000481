%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 3A-B: NC-HIPP coherence around hippocampal ripples
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure3'
%
% Created by H.-V.V. Ngo


function figure3_panelAB_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure3');

filName = 'figure3_panelAB_data';


%% load data
inData = load(fullfile(dirData,[filName '.mat']));


%% Panel A
figure('Name','Histogram of coherence for significant spindle cluster');

histogram(inData.coh_histogram.control,15,'FaceColor',[0.25 0.25 0.25]);

c = vline(inData.coh_histogram.ripple,'r');
set(c,'LineWidth',2)

set(gca,'TickDir','out');
box off

xlabel('Coherence');
xlim([0.06 0.1])

ylabel('Count');
ylim([0 18]);
yticks([0 5 10 15])
yticklabels({'0','5','10','15'})


%% Panel B:
figure('Name','Time-resolved coherence in spindle band');

plot(inData.coh_timeseries.time,inData.coh_timeseries.zValues,'k');

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-1 1])
xticks([-1 -0.5 0 0.5 1])
xticklabels({'-1','-0.5','0','0.5','1'})

ylabel('Coherence (z-score)');
ylim([-3 3])

hline(0)
hline(norminv(0.025),'b');
hline(norminv(1-0.025),'b');
vlinedashed(0,'k');
