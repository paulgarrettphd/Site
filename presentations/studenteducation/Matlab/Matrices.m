%% Lesson Outline with excercises for matrix manipulation
% Data generated in section 1. Sections 2:n are exercises. 
% Author: Paul Garrett
% Date: 11/06/2019

% Make data to play with. Don't worry about how this is done, just run this
% section of code and view the output
clc; clear; close;
rng('default');

Participants = 3;
Trials = 100;
Conditions = 4;
ErrorRate = .2;
RTmodifier = 800;

% Preallocate the data matrix with NaNs (because good coding practice)
Data = nan( Trials*Participants, 4 );

% Make a participant column
Data(:, 1) = reshape( repmat( 1:Participants, [Trials,1]), [Trials*Participants,1]);

% Make a condition column (three conditions)
Data(:, 2) = reshape( repmat( 1:Conditions, [Trials/Conditions,Participants] ), [Participants*Trials,1]);

% Make a random RT range with Ntrials per Participant
Data(:,3:4) = rand(Trials*Participants, 2) .* repmat([RTmodifier, 1], [Trials*Participants,1] );

% Make a random Accuracy column with errors equal to the error rate
Data(Data(:,4)<=.2, 4) = 0;
Data(Data(:,4)~=0, 4)  = 1;

clearvars -except Data Participants Trials Conditions
fprintf('Everyone should now have a Data matrix with four columns:\n   Column one is participant number,\n   Column two is condition number (4 conditions),\n   Column three RT, and \n   Column four is accuracy. \n')

%% Excercise Number 1.1
% Using logical indexing, get the mean accuracy across all participants
% Does the error rate look like the previous ErrorRate variable? 
% (I hope so)

MeanAcc = mean(Data(:,4));

%% Excercise Number 1.2
% Using logical indexing, get the mean RT of accuracte trials across all
% participants

MeanRT = mean(Data( Data(:,4)==1, 3));

%% Excercise Number 2
% Using a for loop, calculate and store the mean RT of each condition,
% for each participant...but only for accurate trials!

% Hint #1. If you make all of the inaccurate RTs nan values, you can use
%    nanmean in your calculation.

% Hint #2. You can use AND e.g., &, operations to ensure the right 
%    participant AND the right condition are being assessed.

% Replace incorrect RTs with NaNs 
Data( Data(:,4)==0, 3) = NaN;

% Preallocate your mean matrix for storage
meanRTarray = nan( Participants, Conditions );

% start for loops for participants and conditions
for p = 1:Participants
    for c = 1:Conditions
        CorrectRows = Data(:,1) == p & Data(:,2) == c;
        meanRTarray(p, c) = nanmean( Data( CorrectRows, 3) );
    end
end
clear p c 

% This loop method has a few advantages
% It's easy to use and easy to read, especially with this data format
% But! It's not the only way we can get these means.

%% Exercise Number 3
% In this section, we are going to perform the same operations as above,
% but using a three dimensional array. Instead of loading all of our data,
% we are going to shape this array into the following dimensions:
%
% Data3D = [ConditionalTrials, Condition, Participant]
%
% So, each row will be an RT for a conditional trial
% each column will be a single condition
% and the third dimension will be each participant

% As I don't know how to teach this without being there, I'll walk you
% through how you can convert the RT data into a 3D array, and then into a
% 3D conditional array, and finally, how to calculate the above means using
% a three dimensional matrix.

% Please note: Everyone finds 3D arrays difficult to wrap their heads
% around. Don't worry about that. Their use is not critical for your
% analyses, but they are an important part of coding (especially in matlab)
% and you should have some expoure to them before we move onto functions
% and plotting.

% Make a 3D vector of all RTs
Data3D = reshape( Data(:,3), [Trials, 1, Participants]);

% Function: Reshape
% Reshape is used to change the size of a matrix. It takes two primary inputs
% input 1: your data.
% input 2: the new size dimensions. 
% I'll make an array at the end for you all to play with using reshape so
% you can get a handle on it. Remember, the dimensions of the new array
% must multiply to match the old array. 
% 
% e.g., old array = 3x3; new array = 1x9. Could never be 1x6. 
%
% To get around this issue, you'll see me setting new matrix dimensions by
% multiplying the variables we already have.
% 
% e.g., Using Trials to specify row numbers, or later
% Trials/Conditions to specify conditional row (trial) numbers


% Cheack the RT for participant one is the same in the old and new matrix
% There should be 74 RTs left after clearning for incorrect RTs
NonNanRTs = sum( ~isnan( Data3D(:,:,1) ) ); 
MatchingRTs = sum( Data3D(:,:,1) == Data(Data(:,1)==1, 3) );

% Reshape your 3D matrix with conditional columns
Data3D_2 = reshape( Data3D, [Trials/Conditions, Conditions, Participants] ); 

% Take the mean of this new 3D Array...
Mean3D = nanmean( Data3D_2 ); 

% Mean3D will be a three dimensional array with 1 row, four columns
% (conditions) and three participants along the third dimension. 
% This isn't quite how we usually view this kind of data. So let's change
% the dimensions of the array using 'Permute'

% Using permute, we can swap dimensions:
% We can swap the participants (Dim 3) with the mean rows (Dim 1)
MeanRT3D = permute( Mean3D , [3, 2, 1] );

% Similar functions can be done for standard deviations, medians, modes,
% etc.


%% Exercise Number 4.1 - REPMAT
% The above section was a walk through, not really an exercise. You could
% run each line and see how it worked, but it didn't let you play.
% So instead; use the following matrix functions to play with this next
% data set. 

% Repmat is a function designed to repeat a matrix or vector N number of
% times for you. This is useful in many instances, for example, if you
% wanted to make a condition matrix for an ANOVA. Column 1 might be factor
% A (high[2] vs low[1]) and column 2 might be factor B (high vs low), and
% the number of trilas in each condition might be 10;

% Here, we repeat [high, high] or [2, 2], for 10 rows, and one column
HH = repmat([2,2], [10, 1]); 
HL = repmat([2,1], [10, 1]); 

% Fill in LH and LL variables

% Then vertically concatenate these into a single matrix


% You can also use repmat to make a matrix of single value
% e.g., a five x five matrix of 10s
TENS = repmat(10, 5);

% And change change the number of rows, columns, or 3dims manually
TENS2 = repmat(10, [2, 4, 5] );

% Using REPMAT, make a matrix with columns of values 1:10, 
% five rows down and four elements deep along the third 
% dimension



%% Exercise Number 4.2 - RESHAPE
clear; close; clc; 

Trials = 20;
Conditions = 4;

Data = repmat(1:Conditions, [Trials, 1]);


% Using RESHAPE, reshape Data into a 3D matrix with:
%    20 Rows
%     2 Columns
%     2 Third dimensions
% make sure all of the 1s and 2s are in the first element of dimension 3,
% and all of the 3s and 4s are in the second element of dimension 3


% e.g., result
% ans(:,:,1) =
% 
%      1     2
%      1     2
%      1     2
%      1     2
%      ...
% 
% ans(:,:,2) =
% 
%      3     4
%      3     4
%      3     4
%      3     4
%      ...


%% Exercise Number 4.3 - PERMUTE
clear; close; clc; 

Trials = 20;
Conditions = 4;

Data = repmat(1:Conditions, [1, 1, Trials]);

% Using PERMUTE, change the dimensions of the below matrix, so that the
% third dimension becomes the first dimension.
% Note: the column doesn't change.


% e.g., result
% ans =
% 
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4
%      1     2     3     4


