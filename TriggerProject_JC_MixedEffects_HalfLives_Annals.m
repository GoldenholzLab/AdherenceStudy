%% Mixed effects analysis for seizure trigger data, accounting for half-lives of ASMs
% This script uses a moving average of 90 days in combination with missed
% doses of ASMs on the last day of the window to look at the relationship
% with seizures on day window+1 (i.e., day 91 for the first window).
% Notably, this script takes into account the ASM half life. 


%% Format data for excel spreadsheet
% Load file 
filename = 'all_patient_diaries.xlsx';

% Extract information about number of sheets in the excel 
[~, sheetNames] = xlsfinfo(filename);

% Load the data from each sheet/participant as a separate variable
for i = 1:length(sheetNames)
    sheetData = xlsread(filename, sheetNames{i});
    varName = matlab.lang.makeValidName(sheetNames{i});
    assignin('base', varName, sheetData);
end

% Extract only the seizure data (i.e., column 2) and place it all into one
% variable called seizure where each column is a different participant
for i = 1:length(sheetNames)
    sheetData = xlsread(filename, sheetNames{i});
    seizure(:,i)=sheetData(:,2);
end

% As the raw data is in half days, let's shrink the temporal data such that
% it goes by days rather than half days. The below commands just takes into
% account whether there was a seizure/no seizure for a given day. For
% example, if someone had 3 seizures in a given day, under this format they
% would just be counted as having 1 seizure day for that day. 
[numRows, numCols] = size(seizure);

seizure_days = zeros(numRows / 2, numCols);
    for row = 1:numRows/2
        for col = 1:numCols
            % Check if there is a positive number in the two consecutive rows
            if seizure(2*row-1, col) > 0 || seizure(2*row, col) > 0
               seizure_days(row, col) = 1;
            end
        end
    end

%% Calculate MA for a 90 day window 
% Essentially within a 90 day sliding window, this takes the number of
% seizure days divided by 90 for an estimate of seizure risk. 
for i = 1:191
    for j = 1:27
        MA(i,j)=sum(seizure_days(i:i+89,j));
        MA_90(i,j)=MA(i,j)/90;
    end
end

% Since we are looking at the relationship between MA and seizures on day
% sliding window + 1, the first day would be day 91 since the MA requires
% 90 days of data. Let's create a matrix of seizure days that only starts
% at day 91 for further analysis later on. 
seizure_days_forecast=seizure_days(91:281,:);

%% Extract the ASM data for each subject 
% End of data format will be 3D matrix [Dose X ASM X Subject]. Essentially
% this section will mark the timepoints (with a 1) when the number of consecutive
% doses missed exceeds one half life for the ASM missed. This will then
% reset if the medication is re-dosed. 
ASM_HL=zeros(562,6,27);

% Patient 4165: Column 3 Keppra, Column 4 Epidiolex, Column 5 Fluramine
ASM(:,1:3,1)=BIDMC4165(:,3:5);
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers      
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,1))
    % Check if the current number is negative
    if ASM(i,1,1) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,1) = 1;
    end
end
% Epidiolex has a max half life of 61 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,1))
    % Check if the current number is negative
    if ASM(i,2,1) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,1) = 1;
    end
end
% Flenfluramine has a max half life of 30 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,1))
    % Check if the current number is negative
    if ASM(i,3,1) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,1) = 1;
    end
end

% Patient 4216: Column 3 CBD oil, Column 4 Lamotrigine
ASM(:,1:2,2)=BIDMC4216(:,3:4);
% Epidiolex has a max half life of 61 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,2))
    % Check if the current number is negative
    if ASM(i,1,2) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,2) = 1;
    end
end
% Lamotrigine has a max half life of ~33 hours so if there are 2 missed
% doses consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,2))
    % Check if the current number is negative
    if ASM(i,2,2) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,2) = 1;
    end
end

% Patient 4251: Column 3 CBD oil, Column 5 Onfi
ASM(:,1,3)=BIDMC4251(:,3);
ASM(:,2,3)=BIDMC4251(:,5);
% Epidiolex has a max half life of 61 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,3))
    % Check if the current number is negative
    if ASM(i,1,3) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,3) = 1;
    end
end
% Onfi has a max half life of 42 hours, so if there are 3 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 3;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,3))
    % Check if the current number is negative
    if ASM(i,2,3) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,3) = 1;
    end
end

% Patient 4417: Column 5 Keppra, Column 6 Lamictal XR, Column 7 Vimpat
ASM(:,1:3,4)=BIDMC4417(:,5:7);
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,4))
    % Check if the current number is negative
    if ASM(i,1,4) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,4) = 1;
    end
end
% Lamictal XR has a max half life of ~33 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Loop through each element of the column
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
for i = 1:length(ASM(:,2,4))
    % Check if the current number is negative
    if ASM(i,2,4) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,4) = 1;
    end
end
% Vimpat has a max half life of ~13 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,4))
    % Check if the current number is negative
    if ASM(i,3,4) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,4) = 1;
    end
end

% Patient 4614: Column 3 Aptiom, Column 4 Xcopri
ASM(:,1:2,5)=BIDMC4614(:,3:4);
% Aptiom has a max half life of ~20 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,5))
    % Check if the current number is negative
    if ASM(i,1,5) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,5) = 1;
    end
end
% XCopri has a max half life of ~60 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,5))
    % Check if the current number is negative
    if ASM(i,2,5) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,5) = 1;
    end
end


% Patient 4684: Column 5 Phenobarb, Column 6 Lamotrigine, Column 8
% Levetiracetam
ASM(:,1:2,6)=BIDMC4684(:,5:6);
ASM(:,3,6)=BIDMC4684(:,8);
% Phenobarb has a max half life of ~118 hours, so if there are 9 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 9;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,6))
    % Check if the current number is negative
    if ASM(i,1,6) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,6) = 1;
    end
end
% Lamictal has a max half life of ~33 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Loop through each element of the column
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
for i = 1:length(ASM(:,2,6))
    % Check if the current number is negative
    if ASM(i,2,6) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,6) = 1;
    end
end
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,6))
    % Check if the current number is negative
    if ASM(i,3,6) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,6) = 1;
    end
end

% Patient 4711: Column 3 Felbatol, Column 4 Zonisamide, Column 5 Lamictal
ASM(:,1:3,7)=BIDMC4711(:,3:5);
% Felbatol has a max half life of 23 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,7))
    % Check if the current number is negative
    if ASM(i,1,7) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,7) = 1;
    end
end
% Zonisamide has a max half life of 63 hours, so if there is 5 missed doses then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,7))
    % Check if the current number is negative
    if ASM(i,2,7) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,7) = 1;
    end
end
% Lamictal has a max half life of ~33 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Loop through each element of the column
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
for i = 1:length(ASM(:,3,7))
    % Check if the current number is negative
    if ASM(i,3,7) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,7) = 1;
    end
end

% Patient 4722: Column 3 Felbatol, Column 4 Onfi, Column 6 Depakote, Column
% 7 Gabapentin, Column 8 Zonisamide, Column 9 Fenfluramine 
ASM(:,1:2,8)=BIDMC4722(:,3:4);
ASM(:,3:6,8)=BIDMC4722(:,6:9);
% Felbatol has a max half life of 23 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,8))
    % Check if the current number is negative
    if ASM(i,1,8) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,8) = 1;
    end
end
% Onfi has a max half life of 42 hours, so if there are 3 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 3;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,8))
    % Check if the current number is negative
    if ASM(i,2,8) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,8) = 1;
    end
end
% Depakote has a max half life of 16 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,8))
    % Check if the current number is negative
    if ASM(i,3,8) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,8) = 1;
    end
end
% Gabapentin has a max half life of 7 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,4,8))
    % Check if the current number is negative
    if ASM(i,4,8) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,4,8) = 1;
    end
end
% Zonisamide has a max half life of 63-69 hours, so if there is 5 missed doses then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,5,8))
    % Check if the current number is negative
    if ASM(i,5,8) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,5,8) = 1;
    end
end
% Flenfluramine has a max half life of 30 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,6,8))
    % Check if the current number is negative
    if ASM(i,6,8) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,6,8) = 1;
    end
end

% Patient 4768: Column 3 Topomax, Column 4 Epidiolex, Column 5 Lamictal,
% Column 6 Zarontin
ASM(:,1:4,9)=BIDMC4768(:,3:6);
% Topomax has a max half life of ~21 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,9))
    % Check if the current number is negative
    if ASM(i,1,9) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,9) = 1;
    end
end
% Epidiolex has a max half life of 61 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,9))
    % Check if the current number is negative
    if ASM(i,2,9) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,9) = 1;
    end
end
% Lamictal has a max half life of ~33 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Loop through each element of the column
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
for i = 1:length(ASM(:,3,9))
    % Check if the current number is negative
    if ASM(i,3,9) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,9) = 1;
    end
end
% Zarontin has a max half life of ~60 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,4,9))
    % Check if the current number is negative
    if ASM(i,4,9) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,4,9) = 1;
    end
end

% Patient 4835: Column 3 Oxtellar, Column 4 Epidiolex, Column 5 Clobazam, Column 9 Fintepla
ASM(:,1:3,10)=BIDMC4835(:,3:5);
ASM(:,4,10)=BIDMC4835(:,9);
% Oxtellar has a max half life of ~11 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,10))
    % Check if the current number is negative
    if ASM(i,1,10) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,10) = 1;
    end
end
% Epidiolex has a max half life of 61 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,10))
    % Check if the current number is negative
    if ASM(i,2,10) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,10) = 1;
    end
end
% Onfi has a max half life of 42 hours, so if there are 3 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 3;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,10))
    % Check if the current number is negative
    if ASM(i,3,10) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,10) = 1;
    end
end
% Flenfluramine has a max half life of 30 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,4,10))
    % Check if the current number is negative
    if ASM(i,4,10) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,4,10) = 1;
    end
end

% Patient 4982: Column 3 Lamotrigine, Column 4 Banzel, Column 5 Epidiolex
ASM(:,1:3,11)=BIDMC4982(:,3:5);
% Lamictal has a max half life of ~33 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Loop through each element of the column
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
for i = 1:length(ASM(:,1,11))
    % Check if the current number is negative
    if ASM(i,1,11) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,11) = 1;
    end
end
% Rufinamide has a max half life of ~10 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Loop through each element of the column
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
for i = 1:length(ASM(:,2,11))
    % Check if the current number is negative
    if ASM(i,2,11) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,11) = 1;
    end
end
% Epidiolex has a max half life of 61 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,11))
    % Check if the current number is negative
    if ASM(i,3,11) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,11) = 1;
    end
end

% Patient 5057: Column 4 Keppra, Column 6 Onfi
ASM(:,1,12)=BIDMC5057(:,4);
ASM(:,2,12)=BIDMC5057(:,6);
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,12))
    % Check if the current number is negative
    if ASM(i,1,12) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,12) = 1;
    end
end
% Onfi has a max half life of 42 hours, so if there are 3 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 3;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,12))
    % Check if the current number is negative
    if ASM(i,2,12) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,12) = 1;
    end
end

% Patient 5117: Column 4 Zonisamide 
ASM(:,1,13)=BIDMC5117(:,4);
% Zonisamide has a max half life of 63 hours, so if there is 5 missed doses then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,13))
    % Check if the current number is negative
    if ASM(i,1,13) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,13) = 1;
    end
end

% Patient 5146: Column 3 Zonisamide
ASM(:,1,14)=BIDMC5146(:,3);
% Zonisamide has a max half life of 63 hours, so if there is 5 missed doses then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,14))
    % Check if the current number is negative
    if ASM(i,1,14) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,14) = 1;
    end
end

% Patient 5184: Column 3 Valproic Acid, Column 4 Keppra
ASM(:,1:2,15)=BIDMC5184(:,3:4);
% Depakote has a max half life of 16 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,15))
    % Check if the current number is negative
    if ASM(i,1,15) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,15) = 1;
    end
end
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,15))
    % Check if the current number is negative
    if ASM(i,2,15) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,15) = 1;
    end
end

% Patient 5274: Column 3 Lamictal XR, Column 6 Gabapentin, Column 7
% Fycompa
ASM(:,1,16)=BIDMC5274(:,3);
ASM(:,2:3,16)=BIDMC5274(:,6:7);
% Lamictal has a max half life of ~33 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Loop through each element of the column
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
for i = 1:length(ASM(:,1,16))
    % Check if the current number is negative
    if ASM(i,1,16) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,16) = 1;
    end
end
% Gabapentin has a max half life of 7 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,16))
    % Check if the current number is negative
    if ASM(i,2,16) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,16) = 1;
    end
end
% Fycompa has a max half life of 105 hours, so if there are 8 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 8;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,16))
    % Check if the current number is negative
    if ASM(i,3,16) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,16) = 1;
    end
end


% Patient 5392: Column 3 Vimpat, Column 4 Keppra, Column 5 Depakote, Column
% 6 Zonegran 
ASM(:,1:4,17)=BIDMC5392(:,3:6);
% Vimpat has a max half life of ~13 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,17))
    % Check if the current number is negative
    if ASM(i,1,17) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,17) = 1;
    end
end
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,17))
    % Check if the current number is negative
    if ASM(i,2,17) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,17) = 1;
    end
end
% Depakote has a max half life of 16 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,17))
    % Check if the current number is negative
    if ASM(i,3,17) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,17) = 1;
    end
end
% Zonisamide has a max half life of 63 hours, so if there is 5 missed doses then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,4,17))
    % Check if the current number is negative
    if ASM(i,4,17) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,4,17) = 1;
    end
end

% Patient 5412: Column 3 Zonegran, Column 4 Trileptal, Column 5 Fycompa
ASM(:,1:3,18)=BIDMC5412(:,3:5);
% Zonisamide has a max half life of 63 hours, so if there is 5 missed doses then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,18))
    % Check if the current number is negative
    if ASM(i,1,18) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,18) = 1;
    end
end
% Oxtellar has a max half life of 2 hours, MHD is 9 hours. So if 1 missed
% dose, then already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,18))
    % Check if the current number is negative
    if ASM(i,2,18) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,18) = 1;
    end
end
% Fycompa has a max half life of 105 hours, so if there are 8 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 8;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,18))
    % Check if the current number is negative
    if ASM(i,3,18) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,18) = 1;
    end
end

% Patient 5507: Column 3 Briviact, Column 4 Lamotrigine, Column 5
% Epidiolex, Column 6 Xcopri 
ASM(:,1:4,19)=BIDMC5507(:,3:6);
% Briviact has a max half life of 9 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,19))
    % Check if the current number is negative
    if ASM(i,1,19) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,19) = 1;
    end
end
% Lamictal has a max half life of ~33 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Loop through each element of the column
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
for i = 1:length(ASM(:,2,19))
    % Check if the current number is negative
    if ASM(i,2,19) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,19) = 1;
    end
end
% Epidiolex has a max half life of 61 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,19))
    % Check if the current number is negative
    if ASM(i,3,19) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,19) = 1;
    end
end
% XCopri has a max half life of ~60 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,4,19))
    % Check if the current number is negative
    if ASM(i,4,19) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,4,19) = 1;
    end
end

% Patient 5606: Column 3 Vimpat, Column 4 Epidiolex, Column 6 Keppra,
% Column 7 Keppra XR, Column 8 XCopri 
ASM(:,1:2,20)=BIDMC5606(:,3:4);
ASM(:,3:5,20)=BIDMC5606(:,6:8);
% Vimpat has a max half life of ~13 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,20))
    % Check if the current number is negative
    if ASM(i,1,20) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,20) = 1;
    end
end
% Epidiolex has a max half life of 61 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,20))
    % Check if the current number is negative
    if ASM(i,2,20) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,20) = 1;
    end
end
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,20))
    % Check if the current number is negative
    if ASM(i,3,20) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,20) = 1;
    end
end
% Keppra XR has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,4,20))
    % Check if the current number is negative
    if ASM(i,4,20) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,4,20) = 1;
    end
end
% XCopri has a max half life of ~60 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,5,20))
    % Check if the current number is negative
    if ASM(i,5,20) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,5,20) = 1;
    end
end


% Patient 5698: Column 3 Keppra, Column 7 Depakote ER, Column 18 XCopri 
ASM(:,1,21)=BIDMC5698(:,3);
ASM(:,2,21)=BIDMC5698(:,7);
ASM(:,3,21)=BIDMC5698(:,18);
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,21))
    % Check if the current number is negative
    if ASM(i,1,21) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,21) = 1;
    end
end
% Depakote has a max half life of 16 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,21))
    % Check if the current number is negative
    if ASM(i,2,21) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,21) = 1;
    end
end
% XCopri has a max half life of ~60 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,21))
    % Check if the current number is negative
    if ASM(i,3,21) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,21) = 1;
    end
end

% Patient 5708: Column 9 Keppra, Column 14 XCopri, Column 20 Lamotrigine,
% Column 21 Clobazam, Column 26 Epidiolex 
ASM(:,1,22)=BIDMC5708(:,9);
ASM(:,2,22)=BIDMC5708(:,14);
ASM(:,3:4,22)=BIDMC5708(:,20:21);
ASM(:,5,22)=BIDMC5708(:,26);
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,22))
    % Check if the current number is negative
    if ASM(i,1,22) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,22) = 1;
    end
end
% XCopri has a max half life of ~60 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,22))
    % Check if the current number is negative
    if ASM(i,2,22) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,22) = 1;
    end
end
% Lamictal has a max half life of ~33 hours, so if there are 2 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Loop through each element of the column
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 2;   % Set the limit for consecutive negative numbers
for i = 1:length(ASM(:,3,22))
    % Check if the current number is negative
    if ASM(i,3,22) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,22) = 1;
    end
end
% Onfi has a max half life of 42 hours, so if there are 3 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 3;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,4,22))
    % Check if the current number is negative
    if ASM(i,4,22) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,4,22) = 1;
    end
end
% Epidiolex has a max half life of 61 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,5,22))
    % Check if the current number is negative
    if ASM(i,5,22) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,5,22) = 1;
    end
end

% Patient 5731: Column 3 Carbamazepine, Column 4 Levetiracetam, Column 5
% Vimpat, Column 6 repeat Vimpat?? will ignore for now given no negative
% values/missed doses anyways
ASM(:,1:3,23)=BIDMC5731(:,3:5);
% Carbamazepine has a max half life of 65 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,23))
    % Check if the current number is negative
    if ASM(i,1,23) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,23) = 1;
    end
end
% Keppra has a max half life of 8 hours, so if there is 1 missed dose then
% already at risk of being at %50 concentration prior to the next dose 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,23))
    % Check if the current number is negative
    if ASM(i,2,23) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,23) = 1;
    end
end
% Vimpat has a max half life of ~13 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,23))
    % Check if the current number is negative
    if ASM(i,3,23) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,23) = 1;
    end
end

% Patient 5782: Column 3 Vimpat, Column 6 XCopri
ASM(:,1,24)=BIDMC5782(:,3);
ASM(:,2,24)=BIDMC5782(:,6);
% Vimpat has a max half life of ~13 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,24))
    % Check if the current number is negative
    if ASM(i,1,24) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,24) = 1;
    end
end
% XCopri has a max half life of ~60 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,24))
    % Check if the current number is negative
    if ASM(i,2,24) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,24) = 1;
    end
end

% Patient 5790: Column 3 Keppra
ASM(:,1,25)=BIDMC5790(:,3);
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,25))
    % Check if the current number is negative
    if ASM(i,1,25) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,25) = 1;
    end
end

% Patient 5799: Column 3 Keppra, Column 5 Tegretol XR
ASM(:,1,26)=BIDMC5799(:,3);
ASM(:,2,26)=BIDMC5799(:,5);
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,26))
    % Check if the current number is negative
    if ASM(i,1,26) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,26) = 1;
    end
end
% Carbamazepine has a max half life of 65 hours, so if there are 5 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 5;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,26))
    % Check if the current number is negative
    if ASM(i,2,26) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,26) = 1;
    end
end

% Patient 59589: Column 3 Topamax, Column 4 Briviact, Column 5 Vimpat
ASM(:,1:3,27)=BIDMC59589(:,3:5);
% Topomax has a max half life of 23 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,1,27))
    % Check if the current number is negative
    if ASM(i,1,27) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,1,27) = 1;
    end
end
% Briviact has a max half life of 9 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,2,27))
    % Check if the current number is negative
    if ASM(i,2,27) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,2,27) = 1;
    end
end
% Vimpat has a max half life of ~13 hours, so if there are 1 missed doses
% consecutively, then at risk of being at ~50% concentration. 
% Initialize variables
count = 0;               % To keep track of consecutive negative numbers       
consecutive_limit = 1;   % Set the limit for consecutive negative numbers
% Loop through each element of the column
for i = 1:length(ASM(:,3,27))
    % Check if the current number is negative
    if ASM(i,3,27) < 0
        count = count + 1;  % Increment the count of consecutive negatives
    else
        count = 0;          % Reset the count if a positive number is found
    end
    % If we have reached the limit of consecutive negatives, mark the row
    if count >= consecutive_limit
        ASM_HL(i,3,27) = 1;
    end
end

%% Matrix of missed doses
% The raw data for the ASM data is in half days. Let's similarly shrink the
% temporal resolution such that we look at seizure risk from missed ASMs as
% days rather than half days. 
[numRows, numCols, numSubs] = size(ASM_HL);
Missed_Doses = zeros(numRows / 2, numCols, numSubs);
    for row = 1:numRows/2
        for col = 1:numCols
            for subs = 1:numSubs
            if ASM_HL(2*row-1, col, subs) == 1 || ASM_HL(2*row, col, subs) == 1
               Missed_Doses(row, col, subs) = 1;
            else
                Missed_Doses(row,col,subs)= 0;
            end
        end
        end
    end

for j = 1:27
     Storage=Missed_Doses(:,:,j);
     Missed_Doses_Periods(:,j)=max(Storage,[],2);
end

% Let's create a way to determine how many days back we look at for missed
% doses. 
Window_MissedDoses = 0; %set window length here in days. 0 is the starting value (day prior) 
for i = 90:280
    for j = 1:27
        k = i-Window_MissedDoses;
    Missed_Doses_Periods2(i,j)=sum(Missed_Doses_Periods(k:i,j));
    end
end
Missed_Doses_Periods_clean=Missed_Doses_Periods2(90:280,:);


%% Organize the data for mixed effects analysis
% Let's organize the data first into a table and concatenate the variables
% vertically. 191 estimates x 27 subjects = 5157.
MAConcat=reshape(MA_90,[5157,1]); %concatenate the MA data into a vector
MissedDosesConcat=reshape(Missed_Doses_Periods_clean,[5157,1]); %concatenate the missed ASMs into a vector
SeizureDaysConcat=reshape(seizure_days_forecast,[5157,1]); %concatenate the seizure occurence data
%Let's create a subject ID that corresponds to each of the entries above
for i = 1:27;
    SubjectID(1:191,i)=i;
end
SubjectIDConcat=reshape(SubjectID,[5157,1]);

%% Feature Scaling with Fisher Transform
% We apply it to the MA data which is a proportion in the range [0, 1].
% Note: The MissedDoses variable is a binary categorical variable, so no
% scaling is needed for it.
FisherTransformedMA = atanh(MAConcat);

%% Place the data into a single table
% The table now includes the transformed MA data.
% Table will essentially have one column consisting of MA, missed doses the
% day prior, seizures on day window+1, and subject ID
tbl = table(MissedDosesConcat, FisherTransformedMA, SubjectIDConcat, SeizureDaysConcat, 'VariableNames', {'MissedDoses_tbl', 'MA_tbl', 'ID_tbl', 'Seizure_tbl'});

%% Fit the mixed effects binomial model:
%Seizure on day window+1 is the response variable (0 = no seizure, 1 =
%seizure)
%Fisher transformed MA is a fixed effect/predictor variable
%MissedDoses is a fixed effect/predictor variable (0 = above one half life, 1 = below one half life)
%Subject ID is the grouping variable/random effect (range 1-27)
lme=fitglme(tbl,['Seizure_tbl ~ MissedDoses_tbl + MA_tbl + (1|ID_tbl)'],'Distribution','Binomial');

%% Display model summary
% This command displays a detailed summary of the fitted mixed effects model,
% including coefficient estimates, p-values, and model fit statistics.
disp(lme);

%% Compare full model to null model using deviance
% As requested, this section manually calculates the deviance difference
% and transforms it to a chi-squared test statistic.
% A small p-value indicates that the full model is a significantly
% better fit than the null model.

% First, fit a simpler "null" model that only includes the intercept
% and the random effect.
lme_null = fitglme(tbl, ['Seizure_tbl ~ 1 + (1|ID_tbl)'], 'Distribution', 'Binomial');

% Calculate the difference in deviance between the two models using the log-likelihood.
% The deviance is -2 * log-likelihood, so the difference is -2 * (logLikelihood_full - logLikelihood_null).
% This difference follows a chi-squared distribution.
deviance_diff = lme_null.LogLikelihood - lme.LogLikelihood;
deviance_diff = -2 * deviance_diff;

% The degrees of freedom for the test is the difference in the number
% of fixed-effects parameters (3 for the full model, 1 for the null model).
df = 2;

% Calculate the p-value using the chi-squared cumulative distribution function.
p = 1 - chi2cdf(deviance_diff, df);

% Display the deviance difference and p-value
fprintf('The deviance difference between the full model and the null model is: %.4f\n', deviance_diff);
fprintf('The p-value for the chi-squared test is: %.4f\n', p);
