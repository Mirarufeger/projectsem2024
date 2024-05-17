eeglab

%% About
% This script was created by Dr. Alexa Ruel for educational purposes in the context of the Project Seminar Course at the University of Hamburg and should not be used without direct authorization from Dr. Ruel
% Last updated on: April 24, 2024
% Email Dr. Ruel at alexa.ruel@uni-hambrug.de with any questions, concerns or to request permission to use this script outside the course.
%before this script, all epochs are in a mess, all artifacts are removed, we only have chunks of data according to the triggers, we also have labels (i.e., oddball, etc.), we do this to get the
%average per condition, per trial to create the grand average of that one
%trial type per condition, we want four categories or lines
%% 1. Create Grand Average;

cd ''%working directory path

subjects = [];%i.e., 2001, 2005 etc., you put all subjects here, not just one at a time, you can't move to this script until you finish preprocessing all the data of all the subjects beforehand


GrandAverageEEG = nan(length(subjects), 4, 63, 750); %Grandaverage 4D: subjects, conditions, channels, time; you create the matrix and then fill it in the next loops; nan means 'not a number', the size of the matrix has 4 dimensions 1., how many subjects you have inserted up above, 2., conditions (4 different averages/lines), 3., channels (63 we don't include the reference electrode (the 64th electrode in this)), 4., the length of the epoch, or the time window/duration of the epoch (note that we might have to change this number if it gives us an error)


for i = 1 : length(subjects)
    EEG = pop_loadset([strcat(num2str(subjects(i)), '_07_ICAdone.set')]); %load the most recent dataset  

 %%
    EpochNames = {}; %create an empty list called epochnames, matlab prefers that you initialize the variable, and then later on fill it

    %within each subject, then go through each epoch
    for c = 1 : length(EEG.epoch)
        if EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "common" % steady = common
            EpochNames(c) = {'oddball_common'}; %instead of having two labels per epoch, as above, combine them to have one label for the epoch
        elseif EEG.epoch(c).condition == "oddball" && EEG.epoch(c).surprise == "switch"
             EpochNames(c) = {'oddball_rare'};
        elseif EEG.epoch(c).condition == "reversal" && EEG.epoch(c).surprise == "common"
             EpochNames(c) = {'reversal_common'};
        elseif EEG.epoch(c).condition == "reversal" && EEG.epoch(c).surprise == "rare"
             EpochNames(c) = {'reversal_rare'};
        end
    end

    %This is a Check! you can go through this and look at all epochs with the various name we just relabled, it takes the percentage of these, and prints them; this prints in the command window as it's doing this, as it's doing it, you know that these trials (rare trials) are roughly 20%, so the common should be roughly 80% - allows you to see if you labeled your epochs properly and see if you made a mistake somewhere beforehand; sometimes people didn't complete the trial as they answered too fast or too slow, so it's not exact 
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_common')))/length(EEG.epoch)) ' % stimuli of type oddball_common'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'oddball_rare')))/length(EEG.epoch)) ' % stimuli of type oddball_rare'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'reversal_common')))/length(EEG.epoch)) ' % stimuli of type reversal_common'])
    disp(['dataset contains ' num2str(sum(sum(strcmpi(EpochNames,'reversal_rare')))/length(EEG.epoch)) ' % stimuli of type reversal_rare'])

    epochtrans2 = {'oddball_common' 'oddball_rare' 'reversal_common' 'reversal_rare'}; % go through each item in the list, and count how many trials correspond to that label, in the previous step you have a rough percentage

   
    for nc = 1 : length(epochtrans2) %per person, you want to know out of all of the trials of the epoch that wasn't deleted, how many correspond to the current conditions, there should be more common epochs than rare epochs
        n_trials(i,nc) = sum(sum(strcmpi(EpochNames,epochtrans2{nc}))); 

        % save the current subject's data to GrandAverageEEG for subject
        % one, this fills in the matrix where each line goes subject by
        % subject
        GrandAverageEEG(i,nc,:,:) = mean(EEG.data(:,:,strcmpi(EpochNames,epochtrans2{nc})),3);
    end


end 

%if you do this step, and the numbers aren't what you expect, it's a way to
%check that everything is labeled correctly
%the output (grandaverage matrix in the workspace, is 4-D and so large,
%that it cannot be displayed; subjects, conditions (4 different lines we're
%looking at), electrodes, and time (MATLAB time)

%% 2. Plot Grand Average - with both conditions, and trial types shown
close all; %if you have any figures open on your screen it will close them all
hfig = figure;
hold on;

%effect at P300 occurs at the parietal region, this drives the search, we
%predict that the P300 is a parietal P300; some people plot one electrode
%(Pz), but you can also choose a region of interest, ROI such as P1, PZ, &
%P3. This guided by past research, but also what you see in your own research
%data. To see this, look at what the other electrodes look like, which is
%why you should run this again, again, and again. Do one, save it, do
%another one, save it. This is the only way if you're going to understand
%if your data is clean and what you're looking at.

%uncomment these to activate them, the electrode numbers and corresponding Fz/Cz
%etc., is in our EEG structure from our workspace from the previous
%preprocessing step (EEG chanloc) or EEG channel locations, the number to
%the left of it, is the electrode number, give MATLAB the number not the
%label. You have to deal with the number here. Previous literature has told
%us what the effect should be and you want to see what the data looks like
%elec = 2; %Fz
%elec = 23; %Cz
%elec = 12; %Pz

% if using more than one electrode... 


% Create electrode(s) by time point for ODDBALL_COMMON: 1 x num time points
OB_COMMON = GrandAverageEEG(:,1,elec,:); %the colon : means all values in that dimension i.e, here that is "all subjects", '1' corresponds to "oddball common", 'elec' is the number of the electrode you want, predetermined above, at all time points (the second colon); your matrix at this point is all subjects, one condition, 1 electrode, and all time points, but you want to take the mean of the subjects first (see next line)
OB_COMMON = squeeze(mean(OB_COMMON,1)); % electrode(s) X time points, squeeze = remove the dimensions that are just 1, it doesn't matter anymore, you end up with a matrix at this point that is just the electrodes by time point (you squeeze out (remove) the single condition you have; if you only fed in one electrode, you don't need another line, but if you wanted to do an ROI, you have to mean and squeeze again
%OB_COMMON = squeeze(mean(OB_COMMON,1)); %averaged across electrodes = 1 x time points 
%the above line is commented out because you only have to run this line if
%you're running an ROI across condition... (? unsure if I heard correctly)

% Create electrode(s) by time point for ODDBALL_RARE: 1 x num time points
OB_RARE = GrandAverageEEG(:,2,elec,:); 
OB_RARE = squeeze(mean(OB_RARE,1));
%OB_RARE = squeeze(mean(OB_RARE,1));

% Create electrode(s) by time point for REVERSAL_COMMON: 1 x num time points
REV_COMMON = GrandAverageEEG(:,3,elec,:);
REV_COMMON = squeeze(mean(REV_COMMON,1));
%REV_COMMON = squeeze(mean(REV_COMMON,1));

% Create electrode(s) by time point for REVERSAL_RARE: 1 x num time points
REV_RARE = GrandAverageEEG(:,4,elec,:); 
REV_RARE = squeeze(mean(REV_RARE,1));
%REV_RARE = squeeze(mean(REV_RARE,1));


%just plot the four lines now, the times, oddball common, time, oddball
%rare, time, etc., it needs to be told what the x range is.
plot (EEG.times, OB_COMMON,'b', EEG.times, OB_RARE, '--b', EEG.times, REV_COMMON, 'r', EEG.times, REV_RARE, '--r') %--b is blue color, --r is red color
title(['EEG at ' EEG.chanlocs(elec).labels])
set(gca, 'YDir') %this sets the direction, positive is plotted up
legend %gives us a legend that corresponds to the code above
xlabel('time'); ylabel('uV') %x axis is labaled time, y axis is labeled microvolts
xlim([-200 1000]); %if you run this whole thing you should get a plot!


%% Difference Value Plots.
ob_diff = OB_RARE - OB_COMMON ; 
%ob_diff = squeeze(mean(ob_diff,1)); 

rev_diff = REV_RARE - REV_COMMON ; 
%rev_diff = squeeze(mean(rev_diff,1));

common_diff = REV_COMMON - OB_COMMON;
%common_diff = squeeze(mean(common_diff,1));

rare_diff = REV_RARE - OB_RARE; 
%rare_diff = squeeze(mean(rare_diff,1));

% condition difference values
plot (EEG.times, ob_diff, EEG.times, rev_diff)
title(['EEG at ' EEG.chanlocs(elec).labels]) 
set(gca, 'YDir')
legend
xlabel('time'); ylabel('EEG')


% trial type difference values
plot (EEG.times, common_diff, EEG.times, rare_diff)
title(['EEG at ' EEG.chanlocs(elec).labels])
set(gca, 'YDir')
legend
xlabel('time'); ylabel('EEG')


%% 3. Topographies

% ODDBALL COMMON
OB_COMMON_TOPO = GrandAverageEEG(:,1,:,:); 
OB_COMMON_TOPO = squeeze(mean(OB_COMMON_TOPO,1)); % squeezes the 4D matrix into a channels by timepoints matrix. So squeezes across all subjects (means)
OB_COMMON_TOPO = OB_COMMON_TOPO(1:62, ); % selects only the time range we are interested in for the topography (window of analysis)

%average the voltages across the channels
OB_COMMON_TOPO = mean(OB_COMMON_TOPO,2);

% change the size of the matrix
OB_COMMON_TOPO = OB_COMMON_TOPO';




% REVERSAL COMMON
REV_COMMON_TOPO = GrandAverageEEG(:,3,:,:);
REV_COMMON_TOPO = squeeze(mean(REV_COMMON_TOPO,1));
REV_COMMON_TOPO = REV_COMMON_TOPO(1:62, );

%average the voltages across electrodes
REV_COMMON_TOPO = mean(REV_COMMON_TOPO,2);

% change the size of the matrix 
REV_COMMON_TOPO = REV_COMMON_TOPO'; 




% ODDBALL RARE 
OB_RARE_TOPO = GrandAverageEEG(:,2,:,:);
OB_RARE_TOPO = squeeze(mean(OB_RARE_TOPO,1));
OB_RARE_TOPO = OB_RARE_TOPO(1:62,  );

%average the voltages across channels
OB_RARE_TOPO = mean(OB_RARE_TOPO,2);

% change the size of the matrix 
OB_RARE_TOPO = OB_RARE_TOPO'; 
 



% REVERSAL RARE
REV_RARE_TOPO = GrandAverageEEG(:,4,:,:); 
REV_RARE_TOPO = squeeze(mean(REV_RARE_TOPO,1));
REV_RARE_TOPO = REV_RARE_TOPO(1:62, );

%average the voltages across channels
REV_RARE_TOPO = mean(REV_RARE_TOPO,2);

% change the size of the matrix
REV_RARE_TOPO = REV_RARE_TOPO'; 


%% Figures for condition differences (oddball vs. reversal)

% differnece between oddball common and oddball rare
ob_diff_topo = OB_RARE_TOPO - OB_COMMON_TOPO; 
% differnece between reversal common and reversal rare
rev_diff_topo = REV_RARE_TOPO - REV_COMMON_TOPO; % p= chp switch ; g = chp steady

figure;
subplot(1,2,1)
elec = EEG.chanlocs(1:62); 
topoplot(ob_diff_topo, elec);
caxis([-3, 3]) 
title('OB rare - OB common')
subplot(1,2,2)
topoplot(rev_diff_topo,elec);
caxis([-3, 3])
title('REV rare - REV common')
sgtitle('Condition differences')

%% Figures for trial type differences (common vs. rare)

% rev common - odd common
common_diff_topo = REV_COMMON_TOPO - OB_COMMON_TOPO;
% rev rare - odd rare
rare_diff_topo = REV_RARE_TOPO - OB_RARE_TOPO;

figure;
subplot(1,2,1)
elec = EEG.chanlocs(1:62); 
topoplot(common_diff_topo, elec);
caxis([-1.5, 1.5])
title('REV common - OB common')
subplot(1,2,2)
topoplot(rare_diff_topo,elec);
caxis([-1.5, 1.5])
title('REV rare - OB rare')
sgtitle('Trial type differences')

%% Figures for condition & trial types (4 individual plots)

figure;
subplot(2,2,1)
elec = EEG.chanlocs(1:62); 
topoplot(OB_COMMON_TOPO, elec); %oddball common
cbar('vert', 0,[-1, 1]*max(abs(OB_COMMON_TOPO)));
title('Oddball Common')
subplot(2,2,2)
topoplot(OB_RARE_TOPO, elec); %oddball rare
cbar('vert', 0,[-1, 1]*max(abs(OB_RARE_TOPO)));
title('Oddball Rare')
subplot(2,2,3)
topoplot(REV_COMMON_TOPO, elec); %reversal common
cbar('vert', 0,[-1, 1]*max(abs(REV_COMMON_TOPO)));
title('Reversal Common')
subplot(2,2,4)
topoplot(REV_RARE_TOPO, elec); %reversal rare
cbar('vert', 0,[-1, 1]*max(abs(REV_RARE_TOPO)));
title('Reversal Rare')
sgtitle('500-600ms')
