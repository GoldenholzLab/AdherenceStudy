%% Sensitivity analysis for the mixed-effects model 
% This script simulates seizures following missed ASM doses for a specified
% probability p, to determine the sensitivity of a mixed-effects approach
% to looking at the relationship between seizure occurence and missed ASMs.

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


%% Extract the ASM data for each subject 
% End of data format will be 3D matrix [Dose X ASM X Subject]

% Patient 4165: Column 3 Keppra, Column 4 Epidiolex, Column 5 Fluramine
ASM(:,1:3,1)=BIDMC4165(:,3:5);

% Patient 4216: Column 3 CBD oil, Column 4 Lamotrigine
ASM(:,1:2,2)=BIDMC4216(:,3:4);

% Patient 4251: Column 3 CBD oil, Column 5 Onfi
ASM(:,1,3)=BIDMC4251(:,3);
ASM(:,2,3)=BIDMC4251(:,5);

% Patient 4417: Column 5 Keppra, Column 6 Lamictal XR, Column 7 Vimpat
ASM(:,1:3,4)=BIDMC4417(:,5:7);

% Patient 4614: Column 3 Aptiom, Column 4 Xcopri
ASM(:,1:2,5)=BIDMC4614(:,3:4);

% Patient 4684: Column 5 Phenobarb, Column 6 Lamotrigine, Column 8
% Levetiracetam
ASM(:,1:2,6)=BIDMC4684(:,5:6);
ASM(:,3,6)=BIDMC4684(:,8);

% Patient 4711: Column 3 Felbatol, Column 4 Zonisamide, Column 5 Lamictal
ASM(:,1:3,7)=BIDMC4711(:,3:5);

% Patient 4722: Column 3 Felbatol, Column 4 Onfi, Column 6 Depakote, Column
% 7 Gabapentin, Column 8 Zonisamide, Column 9 Fenfluramine 
ASM(:,1:2,8)=BIDMC4722(:,3:4);
ASM(:,3:6,8)=BIDMC4722(:,6:9);

% Patient 4768: Column 3 Topomax, Column 4 Epidiolex, Column 5 Lamictal,
% Column 6 Zarontin
ASM(:,1:4,9)=BIDMC4768(:,3:6);

% Patient 4835: Column 3 Oxtellar, Column 4 Epidiolex, Column 5 Clobazam, Column 9 Fintepla
ASM(:,1:3,10)=BIDMC4835(:,3:5);
ASM(:,4,10)=BIDMC4835(:,9);

% Patient 4982: Column 3 Lamotrigine, Column 4 Banzel, Column 5 Epidiolex
ASM(:,1:3,11)=BIDMC4982(:,3:5);

% Patient 5057: Column 4 Keppra, Column 6 Onfi
ASM(:,1,12)=BIDMC5057(:,4);
ASM(:,2,12)=BIDMC5057(:,6);

% Patient 5117: Column 4 Zonisamide 
ASM(:,1,13)=BIDMC5117(:,4);

% Patient 5146: Column 3 Zonisamide
ASM(:,1,14)=BIDMC5146(:,3);

% Patient 5184: Column 3 Valproic Acid, Column 4 Keppra
ASM(:,1:2,15)=BIDMC5184(:,3:4);

% Patient 5274: Column 3 Lamictal XR, Column 6 Gabapentin, Column 7
% Fycompa
ASM(:,1,16)=BIDMC5274(:,3);
ASM(:,2:3,16)=BIDMC5274(:,6:7);

% Patient 5392: Column 3 Vimpat, Column 4 Keppra, Column 5 Depakote, Column
% 6 Zonegran 
ASM(:,1:4,17)=BIDMC5392(:,3:6);

% Patient 5412: Column 3 Zonegran, Column 4 Trileptal, Column 5 Fycompa
ASM(:,1:3,18)=BIDMC5412(:,3:5);

% Patient 5507: Column 3 Briviact, Column 4 Lamotrigine, Column 5
% Epidiolex, Column 6 Xcopri 
ASM(:,1:4,19)=BIDMC5507(:,3:6);

% Patient 5606: Column 3 Vimpat, Column 4 Epidiolex, Column 6 Keppra,
% Column 7 Keppra XR, Column 8 XCopri 
ASM(:,1:2,20)=BIDMC5606(:,3:4);
ASM(:,3:5,20)=BIDMC5606(:,6:8);

% Patient 5698: Column 3 Keppra, Column 7 Depakote ER, Column 18 XCopri 
ASM(:,1,21)=BIDMC5698(:,3);
ASM(:,2,21)=BIDMC5698(:,7);
ASM(:,3,21)=BIDMC5698(:,18);

% Patient 5708: Column 9 Keppra, Column 14 XCopri, Column 20 Lamotrigine,
% Column 21 Clobazam, Column 26 Epidiolex 
ASM(:,1,22)=BIDMC5708(:,9);
ASM(:,2,22)=BIDMC5708(:,14);
ASM(:,3:4,22)=BIDMC5708(:,20:21);
ASM(:,5,22)=BIDMC5708(:,26);

% Patient 5731: Column 3 Carbamazepine, Column 4 Levetiracetam, Column 5
% Vimpat, Column 6 repeat Vimpat?? will ignore for now given no negative
% values/missed doses anyways
ASM(:,1:3,23)=BIDMC5731(:,3:5);

% Patient 5782: Column 3 Vimpat, Column 6 XCopri
ASM(:,1,24)=BIDMC5782(:,3);
ASM(:,2,24)=BIDMC5782(:,6);

% Patient 5790: Column 3 Keppra
ASM(:,1,25)=BIDMC5790(:,3);

% Patient 5799: Column 3 Keppra, Column 5 Tegretol XR
ASM(:,1,26)=BIDMC5799(:,3);
ASM(:,2,26)=BIDMC5799(:,5);

% Patient 59589: Column 3 Topamax, Column 4 Briviact, Column 5 Vimpat
ASM(:,1:3,27)=BIDMC59589(:,3:5);

%% Sensitivity Analysis
% Iterate 500 times, given the probabilistic nature of simulating seizures
significant_missed_doses = 0; % Initialize counter for significant p-values for missed doses
significant_ma = 0; % Initialize counter for significant p-values for MA

for iteration = 1:500

P = 0.75; %Set the probability (range 0-1)
nrows=size(ASM,1);
Sim=zeros(nrows,27);

%Simulate seizure timeseries for each subject with probability p the day
%after missed ASM doses. 1 = seizure, 0 = no seizure. 
for i = 1:27
for j = 1:nrows
    %Check for times when all doses are missed
    row = ASM(j,:,i);
    non_zero=row(row~=0);
    if all(non_zero < 0)
        for k = j+1:min(j+2, nrows)
            if rand() < P
                Sim(k,i)=1;
            end
        end
    end
end
end

% As the raw data is in half days, let's shrink the temporal data such that
% it goes by days rather than half days. The below commands just takes into
% account whether there was a seizure/no seizure for a given day.
[numRows, numCols] = size(Sim);
seizure_days = zeros(numRows / 2, numCols);
    for row = 1:numRows/2
        for col = 1:numCols
            % Check if there is a positive number in the two consecutive rows
            if Sim(2*row-1, col) > 0 || Sim(2*row, col) > 0
               seizure_days(row, col) = 1;
            end
        end
    end

% Since we are looking at the relationship between MA and seizures on day
% sliding window + 1, the first day would be day 91 since the MA requires
% 90 days of data. Let's create a matrix of seizure days that only starts
% at day 91 for further analysis later on. 
seizure_days_forecast=seizure_days(91:281,:);

%% Calculate MA for a 90 day window 
% Essentially within a 90 day sliding window, this takes the number of
% seizure days divided by 90 for an estimate of seizure risk. Note that
% this is done on the simulated seizure timeseries. 
for i = 1:191
    for j = 1:27
        MA(i,j)=sum(seizure_days(i:i+89,j));
        MA_90(i,j)=MA(i,j)/90;
    end
end

%% Matrix of missed doses
% The raw data for the ASM data is in half days. Let's similarly shrink the
% temporal resolution such that we look at ASMs in days rather than half
% days. We will account for missed doses in terms of "administration
% periods". I.e., if an individual missed morning doses of three different
% ASMs, that only counts as one missed administration period. For the
% possible range of values here, for each day it can be 0 (no missed
% doses), 1 (1 missed administration period, i.e., morning vs night), and
% 2 (missed both morning and night doses if scheduled for it). 
[numRows, numCols, numSubs] = size(ASM);
Missed_Doses = zeros(numRows / 2, numCols, numSubs);
    for row = 1:numRows/2
        for col = 1:numCols
            for subs = 1:numSubs
            if ASM(2*row-1, col, subs) < 0 && ASM(2*row, col, subs) < 0
               Missed_Doses(row, col, subs) = 2;
            elseif ASM(2*row-1, col, subs) < 0 && ASM(2*row, col, subs) >= 0 || ASM(2*row-1, col, subs) >= 0 && ASM(2*row, col, subs) < 0
               Missed_Doses(row, col, subs) = 1;
            end
        end
        end
    end

for j = 1:27
     Storage=Missed_Doses(:,:,j);
     Missed_Doses_Periods(:,j)=max(Storage,[],2);
end

% Since the first 90 days are used to estimate MA, for the missed doses,
% the first number used should be on day 90 to look at how it influences
% seizure risk on day 91. The last day used should be day 280, since day
% 281 is the last day to look at seizure risk. 
Missed_Doses_Periods_clean=Missed_Doses_Periods(90:280,:);


%% Organize the data for mixed effects analysis 
% Let's organize the data first into a table and concatenate the variables
% vertically. 191 estimates x 27 subjects = 5157. 
MAConcat=reshape(MA_90,[5157,1]); %concatenate the MA data into a vector
MissedDosesConcat=reshape(Missed_Doses_Periods_clean,[5157,1]); %concatenate the missed ASMs into a vector 
SeizureDaysConcat=reshape(seizure_days_forecast,[5157,1]); %concatenate the seizure day (MA window + 1) data

%Let's create a subject ID that corresponds to each of the entries above 
for i = 1:27;
    SubjectID(1:191,i)=i;
end
SubjectIDConcat=reshape(SubjectID,[5157,1]);

% Z-score standardization of the predictor variables
MissedDosesZ = zscore(MissedDosesConcat);
MAZ = zscore(MAConcat);

% Place the data into a single table
% Table will essentially have one column consisting of Z-scored MA, Z-scored missed doses the
% day prior, seizures on day window+1, and subject ID
tbl = table(MissedDosesZ, MAZ, SubjectIDConcat, SeizureDaysConcat, 'VariableNames', {'MissedDoses_tbl', 'MA_tbl', 'ID_tbl', 'Seizure_tbl'});

%% Fit the mixed effects binomial model:
% Seizure on day window+1 is the response variable (0 = no seizure, 1 = seizure)
% Z-scored missed doses the day prior is a fixed effect/predictor variable
% Z-scored MA for the window is a fixed effect/predictor variable
% Subject ID is the grouping variable/random effect
% Of note, we will allow for some flexibility and let the slopes between MA
% and missed doses vary across individuals
% Essentially this analysis will show whether MA or #of missed doses on the
% day prior is statistically significantly related to seizure on day
% window+1, while taking into account the fact that some of the data is
% sampled from the same individuals. 
lme = fitglme(tbl,'Seizure_tbl ~ MissedDoses_tbl + MA_tbl + (1|ID_tbl)', 'Distribution', 'Binomial');

Stats_coeff(iteration,1)=lme.Coefficients{2,2}; %Beta for Missed Doses, each row is an iteration
Stats_coeff(iteration,2)=lme.Coefficients{3,2}; %Beta for MA, each row is an iteration
Stats_p(iteration,1)=lme.Coefficients{2,6}; %p-value for Missed Doses, each row is an iteration
Stats_p(iteration,2)=lme.Coefficients{3,6}; %p-value for MA, each row is an iteration 
Stats_CI_MissedDoses(iteration, :) = lme.Coefficients(2, 7:8); % 95% CI for MissedDoses
Stats_CI_MA(iteration, :) = lme.Coefficients(3, 7:8); % 95% CI for MA

% Check for significance and increment counters
if Stats_p(iteration,1) < 0.05
    significant_missed_doses = significant_missed_doses + 1;
end
if Stats_p(iteration,2) < 0.05
    significant_ma = significant_ma + 1;
end

end

% Calculate and display the final proportions
proportion_missed_doses = significant_missed_doses / 500;
proportion_ma = significant_ma / 500;

fprintf('Proportion of significant p-values for Missed Doses: %.2f\n', proportion_missed_doses);
fprintf('Proportion of significant p-values for MA: %.2f\n', proportion_ma);