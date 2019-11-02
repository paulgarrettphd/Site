<center> ![alt text](img/IntroImg.png) </center>


# Educational Materials 

## Statistics and report writing



## Matlab Basics

Matlab is a popular coding language used in a range of fields including engineering, mathematics and cognitive psychology. Leaning Matlab for a first-time programmer can be difficult; there are many new terms, concepts, and data types to learn. As part of my PhD, I had the fortune to teach Matlab to several undergraduate students and developed a series of Matlab lessons over this time targeted at cognitive psychologists. These lessons cover the following (downloadable) Matlab topics: [the basics], [matrix manipulation], functions, and plotting (functions and plotting tba). The code for these lessons are provided below, made easy to navigate with a handy table of contents.

### Starting a script

```matlab
% Paul Garrett
% 16/04/2019 21:49:29
% Purpose: Teach basic concepts of programming in Matlab to >= 4th year
% psych students. Lesson one of appx six. 

%% Lesson One - The Basics.
% Outline
% -> 1  An Introduction to Coding
%         - Hardcore Coding
%         - Variable Naming
%         - Commenting
% -> 2 Starting Scripts
%         - Sections
%         - Clearing
%         - Path Setting
%         - Folder Making and Deletion
% -> 3 Data Types and Formats
%         - Numeric Data
%         - Logical Data
%         - Vectors and Matricies
%         - Indexing and Logical Indexing
%         - Cells
% -> 4 Loops and Nested Loops
% -> 5 Logical Matrix Indexing

%% An Introduction to Coding
%% 1.1 Hardcore Coding
%%% What is it?
% This is the principle of being given a task and programming until you hit
% a wall.
% Once you hit a wall, you ask for help. Then an expert looks at your code
% and helps with the specific problem. They may also show you how to
% improve your previos code. 
% You then continue until you hit your next wall. Most Psych Students
% (unknowingly) learn through hardcore coding. It is the fastest way to meet
% your coding requirements.
%
%%% What are the downsides?
% There are entire philosophies dedicated to different coding languages,
% e.g., c++, Matlab, python, R; styles of coding e.g., obect-oriented or class 
% based code vs functional code; methods of best practice e.g., timing code
% and quality control; that hardcore coding doesn't teach. If you are
% interested in this, you will have to learn online or by asking others.
%
%% 1.2 Variable Naming and Commenting
% Variable Nameing
% Always use meaningful variable names. Always! You may revisit this code
% in two weeks, or two years. Be clear and don't name things 'blah1',
% 'blah2', etc.
%
% Types of Variable Name
%   Delimiter Separated Words - use spaces to separate words. Matlab will
% not take DSW variable names; so let's look at alternatives
%   Underscore - replaces spaces with underscores. variable_name
%   CamelCase - variables named by capital letters e.g., C's in CamelCase
%   LeadingNumbers - 1Var, 2Var. Matlab does not accept leading numbers.
%   Alphanumeric names - e.g., Var2, Matlab does accept
% 
% Commenting Semi-Professionally
% This is a walkthrough lesson, not a proper script. Here I comment a lot.
% Code comments should generally be brief, clear, and not on every
% line.
%
% Good practice - A comment that says what the next section will do
% Bad practice  - Saying what each line will do
% Good practice - Starting your script by saying what it's purpose is
% Bad practice  - Starting your script by calling a bunch of uncommented
% scripts and functions.
%
% You will know bad commenting when you see it. When learning, feel free to
% comment everything. Just keep in mind, your final analysis script will
% need debugging. A clean, clear code is easy to debug. A long winded code
% is very hard to debug.


% And remember. In coding, it's kill or be killed. < Ctrl + c >
% If you start a loop that won't end, kill it. 

%% 2 Starting Scripts
% Start all scripts by: 
%   i) Clearing the workspace i.e., variables. < clear >
%  ii) Closing all opened figures.
% iii) Clearing the command line < clc >
clear; close; clc;

% You may wish to write code in sections. Use '%% ' to do so.


%% 2.1 This is a new section
% Run a section with  < Crtl + enter >
% Run a section and advance to the next one with < Crtl + shift + enter >
% Alternately; run a line of highlighted code with < F9 >
%
% At the start of each section, you may want to clear all but a few
% variables.
KeptVar1 = 'Keep'
KeptVar3 = 'Keep'
KeptVar2 = 'Keep'
TempVar1 = 'Drop'
TempVar2 = 'Drop'
TempVar3 = 'Drop'
% Check your workspace. These variables will be there
%
%% 2.2 Clear a few select variables with clear
clear TempVar1 TempVar2 TempVar3
% Now check your Workspace. Only Kept Variables will remain
%
%% 2.3 Or Clear all but a few variables
clearvars -except KeptVar1
% Now Only KeptVar1 will remain
% We will revisit clearvars in a Lesson 2
%
%% 2.4 Setting Directories
% Your Current Folder must contain your main script (i.e., this one) if you
% wish to run the script using Sections or Run (F5)
%
% Check your current working directory
CurrentDir = pwd 
%
% Set your current working directory. For example, to my desktop
% < cd('C:\Users\Paul\Desktop') >
%
% If you are writing code that you want to run from the same folder, on
% different computers, you may wish to run this code snippet to quickly get
% the leading file path.

if ispc                               % Check if PC or Mac
    userdir = getenv('USERPROFILE');  % Get Leading Home Path
else
    userdir = getenv('HOME');         % Get Leading Root Path
end

%% 2.5 Make a Folder
% Add a folder to the path name (+ Desktop)

FolderPath = fullfile( userdir, 'Desktop', 'MyMatlabFolder' );

% Does your folder not exist < ~exist() >, then make it!
if ~exist(FolderPath, 'dir')
    mkdir(FolderPath);
end
% Now, check your Desktop. There should be a 'MyMatlabFolder'!
% This process is very useful for making a script and adding
% folders for Figures, Saved .mat files, etc.

%% 2.5 Delete a Folder
% Didn't mean to make that folder? Delete it!
rmdir(FolderPath)
cd(CurrentDir)
```

### Types of data

```matlab
%% 3 Types of Data (by section)
%% 3.1 Numeric Types
clear; clc; close; 
% These are any type made from numbers
Float    = 2.0005;               % Decimal point value
Integer  = int8(2.0005);         % Whole digits only. Check Result.
Infinity = Inf;                  % Positive infinity value
NaNval   = nan;                  % Not-A-Number
% Use NaNs for placeholding, preallocating arrays, or, replacing data point
% without changing the shape of the matrix. More on this later.

% These are the primary Numeric types. To check the class of these values,
% use whos
whos
% Notice all variables except Integer is of class Double. This means a
% double-precision floating-point value, stored in 8bit format.
% Real talk, you can just think of them as 'floats'.

% You can change an Int to a Float through double()
Integer2Float = double(Integer);
% or a float to an Int via int8
Float2Integer  = int8(Float);
whos
```

### Logical and boolean values

```matlab
%% 3.2 Logical or Boolean (True/False)
clear; clc; close; 
% Logical types can only take 2 values: 0 or 1
% They are also known as Boolean, refering to being 'True'(1) or 'False'(0)
% Logical data types are very useful when you wish to index a position in a
% list of numbers or identify what values are the same/different

% The '==' opperator is a query statement. It asks 'is x equivilant to y' 
% and returns a logical result, true or false.
% true and false are key words and have values of logical 1 or logical 0

true == 1     % true
true == 0     % false
true == true  % true
true == false % false
false == 0    % true
false == 1    % false

LogicalNum = ( [1.2, 2.4, 3.6, 4.8] == [1.2, 2.0, 3.6, 4.0] );
% Returns [1,0,1,0] as only positions 1 and 3 are the same
LogicalStr = strcmp( 'String1', 'String2' );
% String Compare < strcmp() > returns logical comparisons of strings.

% Futher examples...
2 == 2                  % true
'a' == 'a'              % true
'abc' == 'abc'          % [true, true, true]. This checks each character.
strcmp('abc', 'abc')    % true. This checks if the whole string is ==
any( [0,2,0] )          % true. Checks if any value is not false.
all( [0,2,0] )          % false. Checks if all values are true.

% The 'Not' symbolc '~' replaces True for False and False for True...
true ~= false           % true
2 ~= 5                  % true
~strcmp('abc','def')    % true
~any([0,0,0])           % true
~true == true           % false

% Greater than and less than symbols are an extention of boolean query.
1 > 2                   % true
2 > 1                   % false
1 < 2                   % true
2 < 1                   % false
2 < 2                   % false
2 > 2                   % false
2 <= 2                  % true
2 >= 2                  % true

% As are OR queries '|', and AND queries '&'
1 > 2 | 3 > 2          % true
1 > 2 & 3 > 2          % false
```

### Vectors and matrices
```matlab
%% 3.3 Vectors and Matrices
clear; clc; close; 
% Variables are any non-keyword that has been assigned a value.

% For example, Var is a variable of value 2, whereas '1' is a keyword 
% and its value cannot be changed
Var = 2;

% Vectors are a series of values. Vectors may be separated by commas...
Vector = [1, 2, 3, 4]

% Or Spaces. Just don't mix them.
Vector = [1 2 3 4]

% A matrix is a series of vectors, forming columns and rows.
Matrix = [1 2 3 4; 5 6 7 8; 9 10 11 12]

% You can check the size of a Variable, Vector or Matrix using size
RowN = size(Matrix, 1)
ColumnN = size(Matrix, 2)
MatSize = size(Matrix)

% Finally, you can transpose a vector or matrix so the columns become rows,
% or the rows become columns
RowVector = [1 2 3 4]
ColumnVector = RowVector'

TransposedMatrix = Matrix'
```

### Indexing and logical indexing
```matlab
%% 3.4 Indexing and Logical Indexing
clear; clc; close; 
% You can access the value of a Vector Position by indexing. e.g., 3rd Pos.
Vector = [1 2 3 4]
Position3 = Vector(3)
% You can access the value of a Matrix by giving (Row, Column) indicies
% e.g., Row 1, Column 3.
Matrix = [1 2 3 4; 5 6 7 8; 9 10 11 12]
MatPositionR1C3 = Matrix(1,3)

% You can also access the value of a Matrix through a logical index
% For example, I might only want odd numbers in my Matrix.
% To do this I would:
%    i) Use mod(x,2) to identify the odd numbers, and 
%   ii) Use logical() to convert this into a logical matrix format
LogicalMatrix_Odd = mod( Matrix, 2 )
LogicalMatrix_Odd = logical( LogicalMatrix_Odd )

% 'LogicalMatrix_Even' is now a logical matrix of 1's and 0's.
% Remember, this means the ones are all 'true' and zeros 'false'.
% We can now use Logical Indexing to...

% i) Get a vector of only the odd Values
OddValues = Matrix( LogicalMatrix_Odd )

% ii) Replace even values with not-a-numbers (NaNs).
Matrix_Odd = Matrix
Matrix_Odd( ~OddValues ) = nan % notice the not (~) symbol

% iii) Get a vector of only Even Values
EvenValues = Matrix( ~LogicalMatrix_Odd )

% iv) Replace odd values with not-a-numbers(NaNs)
Matrix_Even = Matrix
Matrix_Even( OddValues ) = nan

% But after all that, I realise. I only want a matrix with values > 6
GreaterThan6Matrix = Matrix
GreaterThan6Matrix( GreaterThan6Matrix <= 6 ) = nan
```

### NaN values
```matlab
%% 3.4.2 Why NaNs? 
clearvars -except GreaterThan6Matrix Matrix
% Matlab is great at producing fast, mathematical outputs
% For example, to get the mean and standard deviation of each column in the
% Matrix, we can perform:

ColMean = mean( Matrix )
ColStd  = std( Matrix )

% To get the row Mean and SD, we can use
RowMean = mean( Matrix, 2) % Or < mean( Matrix' ) >
RowStd  = std( Matrix' )

% But to do this, matlab requires the matrix to be a set size. e.g., 3x3,
% or 3x4, or 4x4 etc. If you do not have enough data to make a full matrix,
% you can preallocate the required space with NaNs. 

% For example, we want a 4 x 4 matrix, and will fit the old Matrix data in
% it.
NewMatrix = nan(4, 4)
NewMatrix(1:3, 1:4) = Matrix

% Now calculate the column mean
NanColMean = mean( NewMatrix )

% Notice this new column mean has a value of NaN! This is because you
% cannot compute the mean of not-a-number. Instead, tell matlab to ignore
% nan values with nanmean!
NanColMean = nanmean( NewMatrix )

% Similar NaN functions
% nanmax
% nanmin
% nanstd
% nanmedian
% nansum
```

### Cells and cell arrays
```matlab
%% 3.5 Cells and Cell Arrays
clear; clc; close; 
% These data types are able to contain a 'cell' of any data format.
% Make and access data in cells using { } brackets
CellInt   = {1}
CellStr   = {'String'}
CellCell  = { [2,3,4] }

% Check the contents of CellCell
CellCell(1) % returns the cell
CellCell{1} % returns the contents of the cell

% But cells can store anything! A series of cells is known as a Cell Array
% Below is a cell array that contains a:
%   i) matrix, 
%  ii) vector, 
% iii) string, 
%  iv) another cell array, 
%   v) logical vector
CellArray = { magic(3), [1,2], 'string', ...      % ... go to next line
    { 'A Cell', 'Another Cell!' }, logical([1,0]) };

whos
```

### Loops
```matlab
%% 4.1 Loops
clear; close; clc;
% Loops are power tools for iterating through a list of items
% Note. A loop starts with 'for' and closes with 'end'.
ListOfItems = 1:10
% Set the loop over the list of items
% i.e., for item in the ListOfItems
for item = ListOfItems
    % Do this thing with the item
    disp(item); % print item
end

% But maybe you have your own list of unique items,
UnsortedListOfItems = [1,30,51,20]
% Set the loop over the list of items
for item = UnsortedListOfItems
    disp(item);
end

% Or maybe iterate through the rows in the 1st column of a Matrix
Matrix = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16];
for row = 1:size(Matrix,1)
    disp(Matrix(row,1))
end

% You can also loop with an else or elseif statement
% These are conditional loops

% For example:
% If ROW is 2, display the data
% If ROW is 3, print ROW THREE! to the consol
% Else, PRINT 'What what!'
Matrix = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16];
for row = 1:size(Matrix,1)
    if row == 2
        disp(Matrix(row,:));
    elseif row == 3
        fprintf('Row Three!')
    else
        fprintf('What what!')
    end
end
```

#### Nested loops
```matlab
%% 4.2 Nested Loops
clear; close; clc;
% Nested loops are loops within loops.

% For example, we might want to iterate through the rows 
% of each column in Matrix
Matrix = [1 2 3 4; 5 6 7 8; 9 10 11 12; 13 14 15 16];
for row = 1:size(Matrix,1)
    for column = 1:size(Matrix,2)
        disp(Matrix(row,column))
    end
end

% or the other way around
for column = 1:size(Matrix,2)
    for row = 1:size(Matrix,1)
        disp(Matrix(row,column))
    end
end
```

#### Switch loops
```matlab
%% 4.3 Special Loops
%% 4.3. 1 Switch-Case and Switch Loops
% Switch - Case - Otherwise. 
% The switch function is used to execute a set of conditional expressions,
% when you do not wish to use boolean logic. For example:

string = 'StringyStringString!';

switch string
    case 'String?'
        fprintf('Case number 1 \n')
    case 'StringStringy?'
        fprintf('Case number 2 \n')
    case 'StringyStringString!'
        fprintf('Case number 3 \n')
    otherwise
        fprintf('Case not found \n')
end

% Switch Loops - a special form of conditional looping, used to iterate over a string array.
% The switch loop works the same way as a normal loop; provided each conditional
% check were completed with string compare < strcmp(string1, string2) >

strings = {'StringyStringString!', 'StringStringy?', 'String?', ...
           'STRING!'};

for n = 1:numel(strings)
    switch strings{n}
        case 'String?'
            fprintf('Case number 1 \n')
        case 'StringStringy?'
            fprintf('Case number 2 \n')
        case 'StringyStringString!'
            fprintf('Case number 3 \n')
        otherwise
            fprintf('Case not found \n')
    end
end

```

#### While and try loops
```matlab
%% 4.3.2 While and Try Loops
% A while loop is like a conditional for loop; but will continue until a
% specific conditional statement is met.

ii = 0;
while ii < 5
    fprintf('%d Less than 5 \n', ii)
    ii = ii + 1;
end

% But while loops are also dangerous! They will continue into infinity.
% Here is an infinite while loop, kill it with < Ctrl + c >
ii = 0;
while ii < 5
    fprintf('%d Less than 5 \n', ii)
end
%% 4.3.3 Try Statements
% Another 'dangerous' function is the try statement
% Try will attempt to perform a function, and, should that function crash,
% move on like nothing happened.
% You can build catch statements into a try function, but I strongly
% recommend not using try statements in your analysis
try 
    x = unknownvariable;
    fprintf('This is fine. \n')
catch
    fprintf('Everything is on fire. \n')
end

knownvariable = 10;
try 
    x = knownvariable;
    fprintf('This is fine. \n')
catch
    fprintf('Everything is on fire. \n')
end


```

### Logical matrix indexing
```matlab
%% 5 Logical Matrix Indexing
% Nested loops are intuitive to understand, but are very slow.
% If you only need to do something once; then nested loops are great.
% But if you need to do something 1000 times; they suck.
% Matlab was made for 'Matrix Opperations' - Matrix Laboratory
% So here, we will compare Nested Loops to Logical Matrix Indexing

clear; close; clc;
% First, we need a timer. We can check how much time has
% passed in seconds using tic and toc.
Timer1 = tic;
pause(1); % wait 1 seconds.
TimeSinceTimer1 = toc(Timer1);

% Now, let's make a BIG matrix.
Matrix = magic(10000);

% The challenge. Count all the numbers in the Matrix between 500 and 1000,
% inclusive.


% i) Using a nested for loop. 
LoopTimer = tic;
LoopCounter = 0;
for row = 1:size(Matrix,1)
    for column = 1:size(Matrix,2)
        if Matrix(row, column) >= 500 & Matrix(row, column) <= 1000
            LoopCounter = LoopCounter + 1;
        end
    end
end
LoopTime = toc(LoopTimer);


% ii) Using Logical Matrix Indexing
IndexTimer = tic;
IndexCounter = numel( Matrix( Matrix >= 500 & Matrix <= 1000 ) );
IndexTime = toc(IndexTimer);

Ratio = LoopTime / IndexTime;

fprintf('Logical Indexing was %f times faster than Looping \n', Ratio);


```

### Exercises - The Basics
```matlab
%% Lesson One Exercises
% Here are a few exercises you can use to help learn the principles from
% Lesson One.


%% Clearing Variables 
clear; close; clc;
load('cereal.mat');

%% Remove ONLY the variable Calories from the Workspace



%% Remove ALL VARIABLES EXCEPT: Sugars Cups and Fiber, from the workspace



%% Remove any remaining variables from the workspace



%% Change your working directory to your Desktop, Make a folder, then, delete it!


%% Load In the Data Set DoggoVsPupper.mat
load('DoggoVsPupper.mat')

%% Find the mean Age of all Dogs

% Indexing via Number
Age1 = Table{:,3}
Age2 = Table.Age

M1 = mean( Age1 )
M2 = mean( Age2 )

%% Using Logical Indexing, get Ages for Subject 2
Subjects = Table.Subject;
Ages     = Table.Age;

MeanAge = mean( Ages( Subjects == 2 ) )


%% Using a For Loop, 
%   - Loop through each of the five subjects and
%     find the mean age

Subjects = Table.Subject;
Ages     = Table.Age;

for ii = 1:5
    AGEvector = Ages( Subjects == ii ) 
    MeanAge(ii,1) = mean( AGEvector )
end


%% Use Logical Indexing to replace all incorrect RTs with a NaN value




%% Calculate the mean RT, Only for subject 3


%% Calculate the mean Zscore for across all Puppers

```

## Matrix Coding
### Data generation
```matlab
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

```

### Logical indexing & data cleaning
```matlab

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

```

### Matrix manipulation
```matlab

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

% Please note: Everyone finds 3D arrays difficult to wrap their heads
% around. Don't worry about that. Their use is not critical for your
% analyses, but they are an important part of coding (especially in matlab)
% and you should have some exposure to them before we move onto functions
% and plotting.

% Make a 3D vector of all RTs
Data3D = reshape( Data(:,3), [Trials, 1, Participants]);
```

#### Reshaping matrices
```matlab
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

```

#### Repeating matrices
```matlab
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


```

### Exercises - Matrix manipulation
```matlab
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




```

