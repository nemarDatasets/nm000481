%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 1: Averaged HIPP activity time-locked to offline identified
% ripples
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure1'
%
% Created by H.-V.V. Ngo


function figure1_avgRipple_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure1');

filName = 'figure1_avgRipple_data';


%% load data
inData = load(fullfile(dirData,[filName '.mat']));


%% plot figure
figure('Name','Averaged ripple events in HIPP');

boundedline(inData.time,inData.avgRipple(1,:),inData.avgRipple(2,:),'k');

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-0.5 0.5]);

ylabel('Amplitude (uV)')
ylim([-80 70]);
