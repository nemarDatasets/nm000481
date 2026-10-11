%% Ngo et al., eLife 2020: Sleep spindles mediate hippocampal-neocortical coupling during long-duration ripples
%
% Plot Figure 2 - Figure supplement 1: SO power in NC and HIPP time-locked
% to hippocampal ripples, NREM control events and REM control events
%
% Input:
% dirRoot   root directory 'figure source data' containing the folders
%           'additional_functions' and 'figure2_figureSupplement1'
%
% Created by H.-V.V. Ngo


function figure2_figureSupplement1_script(dirRoot)

%% directories and filenames
addpath(fullfile(dirRoot,'additional_functions'))

dirData = fullfile(dirRoot,'figure2_figureSupplement1');

filName = 'figure2_figureSupplement1_data';


%% load data
inData = load(fullfile(dirData, [filName '.mat']));


%% Panel A
figure('Name','Panel A: SO Power in NC');
hold on
bar(0.25, inData.ripple_ctrlNREM.mean(1,1),0.3,'r');
ploterr(0.25,inData.ripple_ctrlNREM.mean(1,1),[],inData.ripple_ctrlNREM.sem(1,1),'k','abshhy',0.1);

bar(0.75, inData.ripple_ctrlNREM.mean(2,1),0.3,'FaceColor',[0.4 0.4 0.4]);
ploterr(0.75,inData.ripple_ctrlNREM.mean(2,1),[],inData.ripple_ctrlNREM.sem(2,1),'k','abshhy',0.1);


bar(1.75, inData.ripple_ctrlREM.mean(1,1),0.3,'r');
ploterr(1.75,inData.ripple_ctrlREM.mean(1,1),[],inData.ripple_ctrlREM.sem(1,1),'k','abshhy',0.1);

bar(2.25, inData.ripple_ctrlREM.mean(2,1),0.3,'FaceColor',[0.8 0.8 0.8]);
ploterr(2.25,inData.ripple_ctrlREM.mean(2,1),[],inData.ripple_ctrlREM.sem(2,1),'k','abshhy',0.1);


bar(3.25, inData.ctrlNREM_ctrlREM.mean(1,1),0.3,'FaceColor',[0.4 0.4 0.4]);
ploterr(3.25,inData.ctrlNREM_ctrlREM.mean(1,1),[],inData.ctrlNREM_ctrlREM.sem(1,1),'k','abshhy',0.1);

bar(3.75, inData.ctrlNREM_ctrlREM.mean(2,1),0.3,'FaceColor',[0.8 0.8 0.8]);
ploterr(3.75,inData.ctrlNREM_ctrlREM.mean(2,1),[],inData.ctrlNREM_ctrlREM.sem(2,1),'k','abshhy',0.1);
hold off

xlim([0 4]);
xticks([0.25 0.75 1.75 2.25 3.25 3.75])
xticklabels({'Ripple','Control-NREM','Ripple','Control-REM','Control-NREM','Control-REM'})

ylabel('Power (uV^2)')


%% Panel B
figure('Name','Panel B: SO Power in HIPP');
hold on
bar(0.25, inData.ripple_ctrlNREM.mean(1,2),0.3,'r');
ploterr(0.25,inData.ripple_ctrlNREM.mean(1,2),[],inData.ripple_ctrlNREM.sem(1,2),'k','abshhy',0.1);

bar(0.75, inData.ripple_ctrlNREM.mean(2,2),0.3,'FaceColor',[0.4 0.4 0.4]);
ploterr(0.75,inData.ripple_ctrlNREM.mean(2,2),[],inData.ripple_ctrlNREM.sem(2,2),'k','abshhy',0.1);


bar(1.75, inData.ripple_ctrlREM.mean(1,2),0.3,'r');
ploterr(1.75,inData.ripple_ctrlREM.mean(1,2),[],inData.ripple_ctrlREM.sem(1,2),'k','abshhy',0.1);

bar(2.25, inData.ripple_ctrlREM.mean(2,2),0.3,'FaceColor',[0.8 0.8 0.8]);
ploterr(2.25,inData.ripple_ctrlREM.mean(2,2),[],inData.ripple_ctrlREM.sem(2,2),'k','abshhy',0.1);


bar(3.25, inData.ctrlNREM_ctrlREM.mean(1,2),0.3,'FaceColor',[0.4 0.4 0.4]);
ploterr(3.25,inData.ctrlNREM_ctrlREM.mean(1,2),[],inData.ctrlNREM_ctrlREM.sem(1,2),'k','abshhy',0.1);

bar(3.75, inData.ctrlNREM_ctrlREM.mean(2,2),0.3,'FaceColor',[0.8 0.8 0.8]);
ploterr(3.75,inData.ctrlNREM_ctrlREM.mean(2,2),[],inData.ctrlNREM_ctrlREM.sem(2,2),'k','abshhy',0.1);
hold off

set(gca,'TickDir','out');
box off

xlim([0 4]);
xticks([0.25 0.75 1.75 2.25 3.25 3.75])
xticklabels({'Ripple','Control-NREM','Ripple','Control-REM','Control-NREM','Control-REM'})

ylabel('Power (uV^2)')
