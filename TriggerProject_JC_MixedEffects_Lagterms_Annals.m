%% Mixed effects analysis for seizure trigger data 
% This script uses a moving average of 90 days in combination with missed
% doses of ASMs on the last day of the window to look at the relationship
% with seizures on day window+1 (i.e., day 91 for the first window). This
% code has also been extended to look at lag terms of ASM adherence over
% the past 7 days with seizure occurrence. 
% Importantly, as various individuals contribute repeated samples to the
% dataset (due to the nature of the time windows), it is important to
% account for this structure, as many typical analyses have the assumption
% that all the samples are completely independent. 

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

% Organize data for mixed-effects analysis with lagged predictors
% Let's organize the data first into a table and concatenate the variables
% vertically. 191 estimates x 27 subjects = 5157. 
MAConcat=reshape(MA_90,[5157,1]); %concatenate the MA data into a vector
SeizureDaysConcat=reshape(seizure_days_forecast,[5157,1]); %concatenate the seizure occurence data


%% Create lag terms for Missed_Doses_Periods_clean
% The variable Missed_Doses_Periods_clean represents the missed dose on
% the day *immediately before* the seizure outcome day. This is Lag 1.
% We will now create 6 more lags to look back a full week (Lags 2 through 7).
num_subjects = 27;
num_estimates = 191;
num_additional_lags = 6; % For days t-2 through t-7

% Rename for clarity and reshape into a single vector
MD_Lag1_Concat = reshape(Missed_Doses_Periods_clean, [5157, 1]);

% Initialize matrix to store the additional lagged data (lags 2 through 7)
MissedDoses_Lagged = NaN(num_estimates, num_subjects, num_additional_lags);

for s = 1:num_subjects
    current_subject_data = Missed_Doses_Periods_clean(:, s);
    for l = 1:num_additional_lags
        % Create the lagged vector for this subject and lag
        % Lag 'l' here corresponds to an actual lag of 'l+1' days.
        % For example, l=1 is Lag 2, l=6 is Lag 7.
        lagged_vector = [NaN(l, 1); current_subject_data(1:end-l)];
        MissedDoses_Lagged(:, s, l) = lagged_vector;
    end
end

% Reshape the lagged matrices into single vectors
MD_Lag2_Concat = reshape(MissedDoses_Lagged(:,:,1), [5157, 1]);
MD_Lag3_Concat = reshape(MissedDoses_Lagged(:,:,2), [5157, 1]);
MD_Lag4_Concat = reshape(MissedDoses_Lagged(:,:,3), [5157, 1]);
MD_Lag5_Concat = reshape(MissedDoses_Lagged(:,:,4), [5157, 1]);
MD_Lag6_Concat = reshape(MissedDoses_Lagged(:,:,5), [5157, 1]);
MD_Lag7_Concat = reshape(MissedDoses_Lagged(:,:,6), [5157, 1]);

% FEATURE SCALING 
% Standardize the MA variable
MA_scaled = (MAConcat - mean(MAConcat)) / std(MAConcat);
% Standardize the missed dose and its lagged variables
MD_Lag1_scaled = (MD_Lag1_Concat - mean(MD_Lag1_Concat, 'omitnan')) / std(MD_Lag1_Concat, 'omitnan');
MD_Lag2_scaled = (MD_Lag2_Concat - mean(MD_Lag2_Concat, 'omitnan')) / std(MD_Lag2_Concat, 'omitnan');
MD_Lag3_scaled = (MD_Lag3_Concat - mean(MD_Lag3_Concat, 'omitnan')) / std(MD_Lag3_Concat, 'omitnan');
MD_Lag4_scaled = (MD_Lag4_Concat - mean(MD_Lag4_Concat, 'omitnan')) / std(MD_Lag4_Concat, 'omitnan');
MD_Lag5_scaled = (MD_Lag5_Concat - mean(MD_Lag5_Concat, 'omitnan')) / std(MD_Lag5_Concat, 'omitnan');
MD_Lag6_scaled = (MD_Lag6_Concat - mean(MD_Lag6_Concat, 'omitnan')) / std(MD_Lag6_Concat, 'omitnan');
MD_Lag7_scaled = (MD_Lag7_Concat - mean(MD_Lag7_Concat, 'omitnan')) / std(MD_Lag7_Concat, 'omitnan');

%Let's create a subject ID that corresponds to each of the entries above
for i = 1:num_subjects;
    SubjectID(1:num_estimates,i)=i;
end
SubjectIDConcat=reshape(SubjectID,[5157,1]);

% Place the data into a single table, using the scaled variables
tbl = table(MD_Lag1_scaled,MD_Lag2_scaled,MD_Lag3_scaled,MD_Lag4_scaled, ...
    MD_Lag5_scaled,MD_Lag6_scaled,MD_Lag7_scaled, ...
    MA_scaled,SubjectIDConcat,SeizureDaysConcat,'VariableNames',{'MD_Lag1','MD_Lag2', ...
    'MD_Lag3','MD_Lag4','MD_Lag5','MD_Lag6','MD_Lag7','MA_tbl','ID_tbl', ...
    'Seizure_tbl'});

% Find the rows that have NaN values in any of the lag columns
% This ensures that all models are fitted on the same number of observations
non_nan_rows = ~any(ismissing(tbl(:, {'MD_Lag1', 'MD_Lag2', 'MD_Lag3', ...
    'MD_Lag4', 'MD_Lag5', 'MD_Lag6', 'MD_Lag7'})), 2);
tbl_clean = tbl(non_nan_rows, :);
fprintf('Number of observations for all models: %d\n\n', size(tbl_clean, 1));

%% Fit models for different combinations of lag terms and store them
% Models will be built cumulatively:
% Model 0: Intercept-only (Null)
% Model 1: MA only
% Model 2: MA + MD_Lag1 (missed dose day before)
% Model 3: MA + MD_Lag1 + MD_Lag2
% ... and so on up to Lag 7.

% Initialize a cell array to store the fitted model objects
all_models_lme = cell(num_additional_lags + 3, 1); % Null, MA-only, MA+Lag1, plus 6 more
% New array to store the p-values of the overall deviance tests
overall_p_values = zeros(num_additional_lags + 2, 1);

% Fit the intercept-only model (the true null model)
formula_null = 'Seizure_tbl ~ 1 + (1 | ID_tbl)';
lme_null = fitglme(tbl_clean, formula_null, 'Distribution', 'Binomial');
all_models_lme{1} = lme_null;
deviance_null = -2 * lme_null.LogLikelihood;
fprintf('Model 0 (Intercept Only): Deviance = %.4f\n\n', deviance_null);

% Fit Model 1: MA and random effects
formula_ma_only = 'Seizure_tbl ~ MA_tbl + (1 | ID_tbl)';
lme_ma_only = fitglme(tbl_clean, formula_ma_only, 'Distribution', 'Binomial');
all_models_lme{2} = lme_ma_only;
deviance_ma = -2 * lme_ma_only.LogLikelihood;
chi2_stat_ma = deviance_null - deviance_ma;
p_value_ma = 1 - chi2cdf(chi2_stat_ma, 1); % 1 df
overall_p_values(1) = p_value_ma;
fprintf('Model 1 (MA Only):\n');
fprintf(' Formula: %s\n', formula_ma_only);
fprintf(' --- Overall Model Significance (vs. Null) ---\n');
fprintf(' Chi-squared = %.4f, p = %.4f\n', chi2_stat_ma, p_value_ma);
fprintf(' Deviance = %.4f\n\n', deviance_ma);

% Fit Model 2: MA + MD_Lag1 (missed dose on day before)
formula_ma_lag1 = 'Seizure_tbl ~ MA_tbl + MD_Lag1 + (1 | ID_tbl)';
lme_ma_lag1 = fitglme(tbl_clean, formula_ma_lag1, 'Distribution', 'Binomial');
all_models_lme{3} = lme_ma_lag1;
deviance_ma_lag1 = -2 * lme_ma_lag1.LogLikelihood;
chi2_stat_ma_lag1 = deviance_null - deviance_ma_lag1;
p_value_ma_lag1 = 1 - chi2cdf(chi2_stat_ma_lag1, 2); % 2 df (MA + MD_Lag1)
overall_p_values(2) = p_value_ma_lag1;
fprintf('Model 2 (MA + MD_Lag1):\n');
fprintf(' Formula: %s\n', formula_ma_lag1);
fprintf(' --- Overall Model Significance (vs. Null) ---\n');
fprintf(' Chi-squared = %.4f, p = %.4f\n', chi2_stat_ma_lag1, p_value_ma_lag1);
fprintf(' Deviance = %.4f\n\n', deviance_ma_lag1);

% Loop through and add the remaining lag terms one at a time (Lags 2 through 7)
for i = 1:num_additional_lags
    % Dynamically build the formula string, always including MA and MD_Lag1
    lagged_terms = '';
    for j = 1:i
        % Start adding terms from MD_Lag2 onwards
        lagged_terms = strcat(lagged_terms, sprintf(' + MD_Lag%d', j + 1));
    end
    current_formula = strcat('Seizure_tbl ~ MA_tbl + MD_Lag1', lagged_terms, ' + (1 | ID_tbl)');
    fprintf('Fitting Model %d: %s\n', i + 2, current_formula);

    % Fit the model on the cleaned table
    lme = fitglme(tbl_clean, current_formula, 'Distribution', 'Binomial');

    % Store the fitted model object
    all_models_lme{i + 3} = lme;

    % Perform the Likelihood Ratio Test (LRT) by comparing to the null model
    deviance_full = -2 * lme.LogLikelihood;
    chi2_stat = deviance_null - deviance_full;
    df = i + 2; % i additional MD parameters + MA + MD_Lag1
    p_value = 1 - chi2cdf(chi2_stat, df);
    
    % Store the calculated p-value
    overall_p_values(i + 2) = p_value;

    fprintf(' --- Overall Model Significance (vs. Null) ---\n');
    fprintf(' Chi-squared = %.4f, p = %.4f\n', chi2_stat, p_value);
    fprintf(' Deviance = %.4f\n\n', deviance_full);
end

% Display a summary of all fitted models
fprintf('\n--- Summary of All Fitted Models ---\n');
for i = 1:length(all_models_lme)
    fprintf('\nModel %d:\n', i - 1);
    disp(all_models_lme{i});
end

% Display the stored overall p-values
fprintf('\n--- Overall P-values for Each Model (Compared to Intercept-Only Null Model) ---\n');
fprintf('Model 1 (MA only): p = %.4f\n', overall_p_values(1));
fprintf('Model 2 (MA + MD_Lag1): p = %.4f\n', overall_p_values(2));
for i = 1:num_additional_lags
    fprintf('Model %d (MA + Lags 1 to %d): p = %.4f\n', i + 2, i + 1, overall_p_values(i + 2));
end