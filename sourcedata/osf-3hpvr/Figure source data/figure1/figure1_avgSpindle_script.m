%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 1: Averaged NC and HIPP activity time-locked to offline
% identified spindles
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure1'
%
% Created by H.-V.V. Ngo


function figure1_avgSpindle_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure1');

filName = 'figure1_avgSpindle_data';


%% load data
inData = load(fullfile(dirData,[filName '.mat']));


%% plot figure for NC
figure('Name','Averaged spindle events in NC');
    
boundedline(inData.time,squeeze(inData.avgSpindle(1,1,:)),squeeze(inData.avgSpindle(2,1,:)),'k');

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-1 1]);

ylabel('Amplitude (uV)')
ylim([-20 25])
    

%% plot figure for HIPP
figure('Name','Averaged spindle events in HIPP');
    
boundedline(inData.time,squeeze(inData.avgSpindle(1,2,:)),squeeze(inData.avgSpindle(2,2,:)),'k');

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-1 1]);

ylabel('Amplitude (uV)')
ylim([-150 100])
