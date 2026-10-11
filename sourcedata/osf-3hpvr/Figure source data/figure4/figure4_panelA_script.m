%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 4A: Histogram of ripple durations and illustrations of short-
% and long-duration ripples
%
% Input:
% dirRoot   root directory 'Figure source data' containing the folders
%           'additional_functions' and 'figure4'
%
% Created by H.-V.V. Ngo


function figure4_panelA_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure4');

filName = 'figure4_panelA_data';


%% load results
inData = load(fullfile(dirData, [filName '.mat']));


%% Panel A (top)
figure('Name','Histogram of ripple durations');

histogram(inData.histogram.durations,50);

set(gca,'TickDir','out');
box off

xlabel('Ripple duration (s)');
xlim([0.02 0.18])

ylabel('Count');

arrayfun(@(x) vline(x,'r'),inData.histogram.tertial_split);


%% Panel A (middle)
%.. short-duration ripples
figure('Name','TFR: short ripples');
imagesc(inData.tfr.time,inData.tfr.freq,inData.tfr.short);

axis xy

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-0.2 0.2]);

ylabel('Frequency (Hz)');

c = colorbar;
c.Label.String = 'Change to baseline';
colormap(jet)
caxis([0 8])


%.. long-duration ripples
figure('Name','TFR: long ripples');
imagesc(inData.tfr.time,inData.tfr.freq,inData.tfr.long);
    
axis xy

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-0.2 0.2]);

ylabel('Frequency (Hz)');

c = colorbar;
c.Label.String = 'Change to baseline';
colormap(jet)
caxis([0 8])


%% Panel A (bottom):
%.. short-duration ripples
figure('Name','Example ripple trace: short');
subplot(2,1,1);
plot(inData.example_trace.time,inData.example_trace.short.rawTrace);

set(gca,'TickDir','out');
box off

xlim([-0.5 0.5]);

ylabel('Amplitude (uV)');
ylim([-400 500]);

hold on
fill([inData.example_trace.short.onset inData.example_trace.short.onset inData.example_trace.short.offset inData.example_trace.short.offset],...
     [-400 500 500 -400], [.8 .8 .8]);
hold off

h = get(gca,'Children');
set(h(1),'EdgeColor','none')
set(gca, 'Children',[h(end); h(1:end-1)])


subplot(2,1,2);
plot(inData.example_trace.time,inData.example_trace.short.filteredTrace);

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-0.5 0.5]);

ylabel('Amplitude (uV)');
ylim([-20 20])

hold on
fill([inData.example_trace.short.onset inData.example_trace.short.onset inData.example_trace.short.offset inData.example_trace.short.offset],...
     [-20 20 20 -20], [.8 .8 .8]);
hold off

h = get(gca,'Children');
set(h(1),'EdgeColor','none')
set(gca, 'Children',[h(end); h(1:end-1)])


%.. long-duration ripples
figure('Name','Example ripple trace: long');
subplot(2,1,1);
plot(inData.example_trace.time,inData.example_trace.long.rawTrace);

set(gca,'TickDir','out');
box off

xlim([-0.5 0.5]);

ylabel('Amplitude (uV)');
ylim([-400 500]);

hold on
fill([inData.example_trace.long.onset inData.example_trace.long.onset inData.example_trace.long.offset inData.example_trace.long.offset],...
     [-400 500 500 -400], [.8 .8 .8]);
hold off

h = get(gca,'Children');
set(h(1),'EdgeColor','none')
set(gca, 'Children',[h(end); h(1:end-1)])


subplot(2,1,2);
plot(inData.example_trace.time,inData.example_trace.long.filteredTrace);

set(gca,'TickDir','out');
box off

xlabel('Time (s)');
xlim([-0.5 0.5]);

ylabel('Amplitude (uV)');
ylim([-20 20])

hold on
fill([inData.example_trace.long.onset inData.example_trace.long.onset inData.example_trace.long.offset inData.example_trace.long.offset],...
     [-20 20 20 -20], [.8 .8 .8]);
hold off

h = get(gca,'Children');
set(h(1),'EdgeColor','none')
set(gca, 'Children',[h(end); h(1:end-1)])
