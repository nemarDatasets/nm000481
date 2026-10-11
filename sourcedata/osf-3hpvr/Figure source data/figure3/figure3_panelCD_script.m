%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 3C-D: NC-HIPP partial directed coherence around hippocampal
% ripples
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure3'
%
% Created by H.-V.V. Ngo


function figure3_panelCD_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure3');

filName = 'figure3_panelCD_data';


%% load data
inData = load(fullfile(dirData, [filName '.mat']));


%% Panel C
figure('Name','Histogram of PDC for significant spindle cluster');

for iCh = 1 : 2
    subplot(2,1,iCh)
    
    histogram(inData.pdc_histogram{iCh}.control,15,'FaceColor',[0.25 0.25 0.25]);
    
    set(gca,'TickDir','out');
    box off
    
    xlabel('PDC')
    xlim([0.02 0.08])

    ylabel('Count');
    ylim([0 20]);
    yticks([0 5 10 15 20])
    yticklabels({'0','5','10','15','20'})
    
    c = vline(inData.pdc_histogram{iCh}.ripple,'r');
    set(c,'LineWidth',2)
    
    title(inData.label{iCh})
end


%% Panel D
figure('Name','Time-resolved PDC in spindle band');

%... prepare non-significant coherence time series
tmp_coh = nan(1,numel(inData.coh_timeseries.time));
tmp_coh(inData.coh_timeseries.zValues <= 1.96) = inData.pdc_timeseries.zValues(inData.coh_timeseries.zValues <= 1.96);

hold on;
plot(inData.pdc_timeseries.time,inData.pdc_timeseries.zValues,'k');
plot(inData.pdc_timeseries.time,tmp_coh,'Color',[0.75 0.75 0.75]);
hold off;

set(gca,'TickDir','out');
box off

xlabel('Time (s)')
xlim([-1 1])
xticks([-1 -0.5 0 0.5 1])
xticklabels({'-1','-0.5','0','0.5','1'})

ylabel('PDC (z-score)')
ylim([-6 6])

hline(0);
hline(norminv(0.025),'b');
hline(norminv(1-0.025),'b');
vlinedashed(0,'k');
