eeglab

%% About
% This script was created by Dr. Alexa Ruel for educational purposes in the context of the Project Seminar Course at the University of Hamburg and should not be used without direct authorization from Dr. Ruel
% Last updated on: April 22, 2024
% Email Dr. Ruel at alexa.ruel@uni-hambrug.de with any questions, concerns or to request permission to use this script outside the course.


%% 1. Re-sample and filter the raw data 
% First, you need to down sample and filter your data. Since this is the first step, you will be importing the raw data files.

subjects = [2001];

for id = subjects
    id = string(id); 
    disp(id)

    pathName0 = '/Users/colleen/Desktop/SoSe 24/Project/eeg-data';

    x = convertCharsToStrings(id{1});
    origName = strcat('bus_task_version2_', x,'.vhdr');

    disp(origName)

    EEG = pop_loadbv(pathName0, origName, [] ,[1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63]);
    
    EEG = pop_resample(EEG, 500);
    EEG = pop_eegfiltnew(EEG, 'locutoff',0.5,'hicutoff',30,'plotfreqz',1);

    EEG.setname= strcat(id{1});
    fileName = strcat(id{1},'_filtered_resampled.set');
    pathName1 = '/Users/colleen/Desktop/SoSe 24/Project/eeg-data';
    EEG = pop_saveset(EEG, fileName, pathName1);

end


%% 2. Re-reference the data the to averge of the mastoids
% Rememebr that data is always recorded with ONE reference electrode. 
% In our case, this is the LEFT MASTOID. To remove this bias,we need to re-reference the data to the average of the left and right mastoids.

subjects = [2001];

for id = subjects
    id = string(id); % convert the variable id to string
    disp(id)

    pathName = '/Users/colleen/Desktop/SoSe 24/Project/eeg-data';
    EEG = pop_loadset(strcat(id{1}, '_filtered_resampled.set'), pathName);
    EEG = pop_reref( EEG, 20,'keepref','on'); %keepref keeps the original reference when reref to 20

%save .set file with components rejected to separate folder
    EEG.setname= strcat(id{1});
    fileName = strcat(id{1},'_02_reref.set');
    pathName2 = '/Users/colleen/Desktop/SoSe 24/Project/eeg-data';
    EEG = pop_saveset(EEG, fileName, pathName2);
end

%% 3. Visual Inspection to Check & Deal with bad channels & interpolate channels & reject bad data
% There are many ways to check for and reject bad channels.
% Check the EEGLAB tutorial manual for the different methods.
% Recommended: visual inspection per participant, and interpolate bad channels. Keep note below of which channels and how many per subjectyou interpolate so you can decide if you should reject the participant overall.

% Check S. Luck book for recommendations regarding when to exclude a subject
% Scrolling through your data will also help you see how good or bad your data are, and help guide you in the next steps!

% comment everything!!!!
% example of a interpolated channels comment: 2001 - none



%% 4. Epoching
% This is where you decide on how and around which trigger to chunk up your data for later averaging.
% Remember that this should not impede on other stimulus presentation, and if it overlaps with responses, you will need to correct for this.

subjects = [2001];


for id = subjects
    id = string(id);
    disp(id)
  
    pathName1 = '/Users/colleen/Desktop/SoSe 24/Project/eeg-data';
    pathName2 = '/Users/colleen/Desktop/SoSe 24/Project/eeg-data'; 


    FilteredName = strcat(id{1}, '_02_reref.set');
    EEG.setname=strcat(id, '_02_reref.set'); % name of the file in EEG structure


    EEG = pop_loadset(FilteredName,pathName1);


    EpochLength = [-0.5 1]; % epoch length in seconds, don't add a comma, just a space to separate
    
    % epoching; this step is the only step epoching the data
    EEG = pop_epoch(EEG,{ 'S 40','S 42', 'S 41','S 43', 'S 44','S 46', 'S 45','S 47', 'S 90','S 92', 'S 91','S 93' }, EpochLength, 'epochinfo', 'yes'); % the S's are the triggers, the numbers correspond the triggers that are sent when house2 (after the choice) shows up for the participant, ontrigger in the task is just one number; epochinfo is all information relating to the epoch

    % S = stimulus

    % baseline removal
    EEG = pop_rmbase( EEG, [-500 0]); % in ms, note that this is milliseconds while the epoch length is seconds!

    % now we have our epochs and they're baseline corrected
    % now we add tags/names for the epochs
    % adding tags now helps us with averaging later

    for i= 1:length(EEG.epoch)

        %mark each epoch for grandaveraging step
        I0=find([EEG.epoch(i).eventlatency{:}]==0); % Locking event (stimulus); based on the number of the epoch, what does it assign?
        if strcmp(EEG.epoch(i).eventtype(I0), 'S 40')
            EEG.epoch(i).condition = 'oddball';
            EEG.epoch(i).trialtype = 'assoc1';
            EEG.epoch(i).stimulus = 'house1';
            EEG.epoch(i).surprise = 'common';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 42')
            EEG.epoch(i).condition = 'oddball';
            EEG.epoch(i).trialtype = 'assoc1';
            EEG.epoch(i).stimulus = 'house2';
            EEG.epoch(i).surprise = 'common';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 41')
            EEG.epoch(i).condition = 'oddball';
            EEG.epoch(i).trialtype = 'assoc2';
            EEG.epoch(i).stimulus = 'house1';
            EEG.epoch(i).surprise = 'rare';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 43')
            EEG.epoch(i).condition = 'oddball';
            EEG.epoch(i).trialtype = 'assoc2';
            EEG.epoch(i).stimulus = 'house2';
            EEG.epoch(i).surprise = 'rare';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 44')
            EEG.epoch(i).condition = 'reversal';
            EEG.epoch(i).trialtype = 'assoc1';
            EEG.epoch(i).stimulus = 'house1';
            EEG.epoch(i).surprise = 'common';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 46')
            EEG.epoch(i).condition = 'reversal';
            EEG.epoch(i).trialtype = 'assoc1';
            EEG.epoch(i).stimulus = 'house2';
            EEG.epoch(i).surprise = 'common';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 45')
            EEG.epoch(i).condition = 'reversal';
            EEG.epoch(i).trialtype = 'assoc2';
            EEG.epoch(i).stimulus = 'house1';
            EEG.epoch(i).surprise = 'common';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 47')
            EEG.epoch(i).condition = 'reversal';
            EEG.epoch(i).trialtype = 'assoc2';
            EEG.epoch(i).stimulus = 'house2';
            EEG.epoch(i).surprise = 'common';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 90')
            EEG.epoch(i).condition = 'reversal';
            EEG.epoch(i).trialtype = 'assoc1';
            EEG.epoch(i).stimulus = 'house1';
            EEG.epoch(i).surprise = 'rare';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 92')
            EEG.epoch(i).condition = 'reversal';
            EEG.epoch(i).trialtype = 'assoc1';
            EEG.epoch(i).stimulus = 'house2';
            EEG.epoch(i).surprise = 'rare';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 91')
            EEG.epoch(i).condition = 'reversal';
            EEG.epoch(i).trialtype = 'assoc2';
            EEG.epoch(i).stimulus = 'house1';
            EEG.epoch(i).surprise = 'rare';

        elseif strcmp(EEG.epoch(i).eventtype(I0), 'S 93')
            EEG.epoch(i).condition = 'reversal';
            EEG.epoch(i).trialtype = 'assoc2';
            EEG.epoch(i).stimulus = 'house2';
            EEG.epoch(i).surprise = 'rare';
     end
    end

    EEG.setname= strcat(id, '_04_epoched'); % new internal name within EEGlab
    fileName = strcat(id{1},'_04_epoched.set');
    EEG = pop_saveset( EEG, fileName, pathName2);


end

%% Manually reject "bad epochs"
% Once again, go through the epochs, and via visual inspection, delete those that are "bad".
% Keep note below of how many epochs you reject to decide if any subject should be rejected based on this.







%% 5.  Run the ICA (Independent Component Analysis
% Run the independent component analysis.
% NOTE: this will take some time. Make sure you can let your computer run the ICA uninterupted (including its own sleep/shut down mode)
% This step simply runs the ICAs, without having you select components or reject them yet.

subjects = [2001];

for id = subjects
    id = string(id); 
    disp(id)

    pathName7 = '';
    pathName8 = '';
    filename = strcat(id{1},'_04_epoched.set');

    EEG = pop_loadset(filename, pathName7);

    %run ICA
    EEG = pop_runica(EEG, 'runica', 'extended',);

    EEG.setname= strcat(id);
    fileName = strcat(id{1},'_05_ICArun.set');
    EEG = pop_saveset( EEG, fileName, pathName8);

end

%% 6. Manual component selection
% This script will load each file saved from the last step, and ask you to manually select all bad components which will be rejected in the next step.
% Once you click ok, and then press any key with your cursor in the console, it will load the next particioant and so on until you are done.

subjects = [2001];

for id = subjects
    id = string(id); 
    disp(id)
    pathName1 = '';
    pathName2 = '' ; 

    EEG = pop_loadset(strcat(id{1}, '_05_ICArun.set'), pathName1);

    % participant information
    VP_INFO.icaweights = EEG.icaweights;
    VP_INFO.icasphere = EEG.icasphere;

    disp(id{1})
    pop_selectcomps(EEG, 1:);
    VP_INFO;
    pause
    VP_INFO.ICA_Remove = find(EEG.reject.gcompreject==1);
    id{1} = num2str(id{1});


    save(['' id{1}], 'VP_INFO')
    
    EEG.setname= strcat(id{1});
    fileName = strcat(id{1},'_06_ICAselected.set');
    EEG = pop_saveset( EEG, fileName, pathName2);

end

%% 7.  Remove components marked in previous step
% this step simply removes all the components you marked in the previous step.
% The benefit of doing this in many steps is being able to go back and see which components you rejected and modify if you need to!

subjects = [2001];

for id = subjects
    id = string(id); 
    disp(id)
    
    pathName = '';

    EEG = pop_loadset(strcat(id{1}, '_06_ICAselected.set'), pathName);

    disp(['Removing ' num2str(sum(EEG.reject.gcompreject)) ' ICs.'])
    EEG = pop_subcomp( EEG, find(EEG.reject.gcompreject==1), 0); 

    
    EEG.setname= strcat(id{1});
    fileName = strcat(id{1},'_07_ICAdone.set');
    pathName2 = '' ;
    EEG = pop_saveset(EEG, fileName, pathName2);
end




% If you made it this far, good job! You are now ready to create a grand average plot to visualise your ERP. :) 


