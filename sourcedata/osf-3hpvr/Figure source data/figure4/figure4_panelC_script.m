%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 4C: Time-resolved partial directed coherence for short- and
% long-duration ripples
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure4'
%
% Created by H.-V.V. Ngo


function figure4_panelC_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure4');

filName = 'figure4_panelC_data';


%% load results
inData = load(fullfile(dirData, [filName '.mat']));


%% Panel C
figure('Name','Time-resolved PDC for short- and long-duration ripples');

hold on
p1 = plot(inData.time,inData.zValues.short,'Color',[.75 .75 .75]);
p2 = plot(inData.time,inData.zValues.long,'k');
hold off

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

legend([p1,p2],'Short','Long');
legend('boxoff');
