%Author: Nida Qayyum 
%Location pointer script for hypoxia co-culture experiments

%The outputs of this code are .mat and .csv files named 'Data_Locations' with a time stamp to keep track of the database changes with each code run

%The file 'Data Locations' (without time stamp) contains the most recently updated information and is loaded into the MATLAB workspace with each code run and used to read the data

%Date updated: 08/13/24 (updated version of code 'Location_Code_7_29_24', cleaned up code for uploading)

clear; clc;

%Generate a time stamp for the file name
c = datetime;
cc = datevec(c);
time_stamp = [num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(round(cc(6)))];

%%%% LOAD HELPER TABLES INTO MATLAB %%%%
helper_tables_path = ...
    uigetdir([],'Please select the folder with all the required helper tables');

%Format of each column of the BMDM count helper table:
%BMDM_Count_Designator,	Number_of_Cells
formatSpec = '%C%C';
%Read the BMDM count helper table ignoring the first row
path_filename_BMDM_count = [helper_tables_path '\Cell_Count_BMDM.csv'];
T_BMDM_Count = readtable(path_filename_BMDM_count,'Delimiter',',', ...
    'Format',formatSpec);
BMDM_Count_Designator = T_BMDM_Count.BMDM_Count_Designator; %create a vector with BMDM count designators
N_BMDM_Count = length(BMDM_Count_Designator); %total number of possible cell counts
BMDM_Count_Num = (1:1:N_BMDM_Count)';

%Format of each column of the NRVM count helper table:
%NRVM_Count_Designator,	Number_of_Cells
formatSpec = '%C%C';
%Read the NRVM count helper table ignoring the first row
path_filename_NRVM_count = [helper_tables_path '\Cell_Count_NRVM.csv'];
T_NRVM_Count = readtable(path_filename_NRVM_count,'Delimiter',',', ...
    'Format',formatSpec);
NRVM_Count_Designator = T_NRVM_Count.NRVM_Count_Designator; %create a vector with NRVM count designators
N_NRVM_Count = length(NRVM_Count_Designator); %total number of possible cell counts
NRVM_Count_Num = (1:1:N_NRVM_Count)';

%Format of each column of the cell type helper table:
%Cell_Type_Designator,	Description
formatSpec = '%C%C';
%Read the cell type helper table ignoring the first row
path_filename_cell = [helper_tables_path '\Cell_Type.csv'];
T_Cell = readtable(path_filename_cell,'Delimiter',',', ...
    'Format',formatSpec);
Cell_Designator = T_Cell.Cell_Type_Designator; %create a vector with cell type designators
N_Cell_Type = length(Cell_Designator); %total number of cell types
Cell_Num = (1:1:N_Cell_Type)';

%Format of each column of the data type helper table:
%Data_Type_Designator,	Description
formatSpec = '%C%C';
%Read the data type helper table ignoring the first row
path_filename_data_type = [helper_tables_path '\Data_Type.csv'];
T_Data_Type = readtable(path_filename_data_type,'Delimiter',',', ...
    'Format',formatSpec);
Data_Designator = T_Data_Type.Data_Type_Designator; %create a vector with data type designators
Data_Description = T_Data_Type.Description;
N_Data_Type = length(Data_Designator); %total number of possible data types
Data_Type_Num = (1:1:N_Data_Type)';

%Format of each column of the gas condition helper table:
%Gas Condition Designator,	Gas Condition
formatSpec = '%C%C';
%Read the gas condition helper table ignoring the first row
path_filename_gasc = [helper_tables_path '\Gas_Condition.csv'];
T_Gas_Cond = readtable(path_filename_gasc,'Delimiter',',', ...
    'Format',formatSpec);
Gas_Condition_Designator = T_Gas_Cond.Gas_Condition_Designator; %create a vector with gas condition designators
Gas_Condition_Description = T_Gas_Cond.Gas_Condition;
N_GasC = length(Gas_Condition_Designator); %total number of gas conditions
GasC_Num = (1:1:N_GasC)';

%Format of each column of the media type helper table:
%Media Type Designator,	Description, M199, MCSF, IFN-gamma, IL-4, IL-13,
%LPS, SerumFree-LowGlucose (for additives 0 for not present and 1 for present)
formatSpec = '%C%C%C%C%C%C%C%C%C';
%Read the media type helper table ignoring the first row
path_filename_media = [helper_tables_path '\Media_Type.csv'];
T_Media = readtable(path_filename_media,'Delimiter',',', ...
    'Format',formatSpec);
Media_Designator = T_Media.Media_Type_Designator; %create a vector with media type designators
N_Media = length(Media_Designator); %total number of media types
Media_Num = (1:1:N_Media)';

%Format of each column of the protocols helper table:
%Protocol Designator, Gas Condition Designator, O2 Percent, Time,
%Description
formatSpec = '%C%C%C%C%C';
%Read the protocol helper table ignoring the first row
path_filename_protocol = [helper_tables_path '\Protocol.csv'];
T_Protocol = readtable(path_filename_protocol,'Delimiter',',', ...
    'Format',formatSpec);
Protocol_Designator = T_Protocol.Protocol_Designator; %create a vector with protocol designators
Protocol_Description = T_Protocol.Description;
N_Protocol = length(Protocol_Designator); %total number of protocols
Protocol_Num = (1:1:N_Protocol)';

%Format of each column of the study type helper table:
%Study_Type_Designator,	Description
formatSpec = '%C%C';
%Read the study type helper table ignoring the first row
path_filename_study = [helper_tables_path '\Study_Type.csv'];
T_Study = readtable(path_filename_study,'Delimiter',',', ...
    'Format',formatSpec);
Study_Designator = T_Study.Study_Type_Designator; %create a vector with signaling type designators
Study_Description = T_Study.Description;
N_Study = length(Study_Designator); %total number of study types
Study_Num = (1:1:N_Study)';

%%% FILE LOCATIONS %%%
%Ask the user to pick an output directory
output_dir = uigetdir([],'Please select an output directory (i.e. the folder with your database files - output of this code and Data_Reading_Code)...');
Cond_File_Name = 'Data_Locations'; %name that will be used for the output file of this code
filename_well_out = [output_dir '\' Cond_File_Name '.mat']; %.mat file with Location_Code output (used as input for Location_Code and Data_Reading_Code)
filename_well_table_out = [output_dir '\' Cond_File_Name '.csv']; %.csv file with Location_Code output

%Ask user to select root path (drive and parent folder) of structural and contractility data files 
data_dir = uigetdir([],'Please select the root path (drive and parent folder) with your data files (i.e. z-line detect and contractility summary files) ...');

%%% LOAD PREVIOUS LOCATION_CODE OUTPUT %%%%
%Check if any of the wells have been previously recorded and a file exists
if exist(filename_well_out, 'file') == 2 %previous Location_Code output exists 
    load(filename_well_out); %load previous locations into workspace
    Well_ID_Data_prev = {Well_Data_Loc_Set.WellDataType}; %create a vector with existing well data type IDs
    [temp, exist_well_counter] = size(Well_ID_Data_prev); %determine the existing number of records
    Well_Path_prev = {Well_Data_Loc_Set.PathFiles}; %create a vector of previously used data file locations
else
    %file does not exist.
    exist_well_counter = 0; %no previous records of locations
    Well_ID_Data_prev = {};
    Well_Path_prev = {};
end

%%%% ID AND DATA FILE LOCATION ENTRY %%%%   
previous_well_counter = exist_well_counter;
record_another_well = 1; %let the user decide when to stop
DoubleActionChoice = []; %initialize variable to check for duplicates
IDChange = []; %initialize variable to change ID 

try %try/catch method included to allow user to generate output files even when code errors out (avoids loss of previously entered wells for that run)
%loop through different conditions until the user wants to stop
while record_another_well==1
    %Select the signaling type you would like to input
    Combo_For_Disp = table(Study_Num, Study_Designator, Study_Description)
    Study_Index = input('From the list above, select the number of the study type for which you are entering data: ');
    disp(['CHOSEN STUDY TYPE: ' Study_Designator(Study_Index)])

    %Select the media type you would like to input
    Combo_For_Disp = table(Media_Num, Media_Designator)
    Media_Index = input('From the list above, select the number of the media type for which you are entering data: ');
    disp(['CHOSEN MEDIA TYPE: ' Media_Designator(Media_Index)])

    %Select the cell type you are inputing
    Combo_For_Disp = table(Cell_Num, Cell_Designator);
    if double(isequal(char(Study_Designator(Study_Index)),'Mono')) == 1 %user has selected Mono (monoculture) as the study type
        rows = (Combo_For_Disp.Cell_Designator=='NRVM' | Combo_For_Disp.Cell_Designator=='BMDM'); %find rows with NRVM and BMDM options
        Combo_For_Disp_Mono = Combo_For_Disp(rows,:) %display only NRVM and BMDM as the cell type choices in the table
        Cell_Index = input('From the list above, select the number of the cell type for which you are entering data: ');
        disp(['CHOSEN CELL TYPE: ' Cell_Designator(Cell_Index)])
    else %user has selected Para (paracrine) or Juxt (juxtacrine) signaling as the study type
        rows = (Combo_For_Disp.Cell_Designator=='NRVM_BMDM'); %find row of table with the NRVM_BMDM designator
        Combo_For_Disp_Co = Combo_For_Disp(rows,:); %set NRVM_BMDM as the cell type 
        Cell_Index = find(rows == 1);
        disp('CELL TYPE: NRVM_BMDM')
    end

    %Select the NRVM cell count you are inputing
    Combo_For_Disp = table(NRVM_Count_Num, NRVM_Count_Designator);
    if  double(isequal(char(Cell_Designator(Cell_Index)),'BMDM')) == 1 %user has selected BMDM (monoculture) as the cell type
        rows = (Combo_For_Disp.NRVM_Count_Designator=='0K'); %find row of table for 0K designator
        NRVM_Count_Index = find(rows == 1); %automatically set NRVM count to 0
        disp('NRVM CELL COUNT: 0' )
    else %user has selected NRVM_BMDM or NRVM_MEF (co-culture) or NRVM (monoculture) as the cell type
        Combo_For_Disp = table(NRVM_Count_Num, NRVM_Count_Designator);
        rows = (Combo_For_Disp.NRVM_Count_Designator=='0K'); %find row of table for 0K designator
        Combo_For_Disp(rows,:) = []; %skip 0K display in table do avoid error in user selection
        Combo_For_Disp
        NRVM_Count_Index = input('From the list above, select the number of the NRVM cell count for which you are entering data: ');
        disp(['CHOSEN NRVM CELL COUNT: ' NRVM_Count_Designator(NRVM_Count_Index)])
    end

    %Select the BMDM cell count you are inputing
    Combo_For_Disp = table(BMDM_Count_Num, BMDM_Count_Designator);
    if  double(isequal(char(Cell_Designator(Cell_Index)),'NRVM')) == 1 %user has selected NRVM (monoculture) as the cell type
        rows = (Combo_For_Disp.BMDM_Count_Designator=='0K'); %find row of table for 0K designator
        BMDM_Count_Index = find(rows == 1); %set BMDM cell count to 0
        disp('BMDM CELL COUNT: 0' )
    elseif double(isequal(char(Cell_Designator(Cell_Index)),'BMDM')) == 1 %user has selected BMDM (monoculture) as the cell type
        Combo_For_Disp = table(BMDM_Count_Num, BMDM_Count_Designator);
        rows = (Combo_For_Disp.BMDM_Count_Designator=='0K'); %find row of table for 0K designator
        Combo_For_Disp(rows,:) = []; %skip 0K display in table do avoid error in user selection
        Combo_For_Disp
        BMDM_Count_Index = input('From the list above, select the number of the BMDM cell count for which you are entering data: ');
        disp(['CHOSEN BMDM CELL COUNT: ' BMDM_Count_Designator(BMDM_Count_Index)])
    else
        Combo_For_Disp
        BMDM_Count_Index = input('From the list above, select the number of the BMDM cell count for which you are entering data: ');
        disp(['CHOSEN BMDM CELL COUNT: ' BMDM_Count_Designator(BMDM_Count_Index)])
    end

    %Select the gas condition you are inputing
    Combo_For_Disp = table(GasC_Num, Gas_Condition_Designator, Gas_Condition_Description)
    GasC_Index = input('From the list above, select the number of the gas condition for which you are entering data: ');
    disp(['CHOSEN GAS CONDITION: ' Gas_Condition_Designator(GasC_Index)])

    %Select the protocol you are inputing
    Combo_For_Disp = table(Protocol_Num, Protocol_Designator,Protocol_Description);
    if double(isequal(char(Gas_Condition_Designator(GasC_Index)),'Norm')) == 1 %user has selected Norm (normoxia) as the gas condition type
        rows = contains(string(Combo_For_Disp.Protocol_Designator),'Norm'); %find rows of table for normoxia protocols
        Combo_For_Disp_Norm = Combo_For_Disp(rows,:)
        Protocol_Index = input('From the list above, select the number of the protocol for which you are entering data: ');
        disp(['CHOSEN PROTOCOL: ' Protocol_Designator(Protocol_Index)])
    elseif double(isequal(char(Gas_Condition_Designator(GasC_Index)),'CH')) == 1 %user has selected CH (continuous hypoxia) as the gas condition type
        rows = contains(string(Combo_For_Disp.Protocol_Designator),'CH'); %find rows of table for continuous hypoxia protocols
        Combo_For_Disp_CH = Combo_For_Disp(rows,:)
        Protocol_Index = input('From the list above, select the number of the protocol for which you are entering data: ');
        disp(['CHOSEN PROTOCOL: ' Protocol_Designator(Protocol_Index)])
    else %user has selected IH (intermittent hypoxia) as the gas condition
        rows = contains(string(Combo_For_Disp.Protocol_Designator),'IH'); %find rows of table for intermittent hypoxia protocols
        Combo_For_Disp_IH = Combo_For_Disp(rows,:)
        Protocol_Index = input('From the list above, select the number of the protocol for which you are entering data: ');
        disp(['CHOSEN PROTOCOL: ' Protocol_Designator(Protocol_Index)])
    end

    %loop through wells of same condition until user wants to stop
    Well_input = 1;
    while Well_input == 1
        %Create an ID for each well
        %(SignalingType_MediaType_CellType_NRVMCount_BMDMCount_Protocol_SeedDate_WellLetter)
        Seed_date = '0000000'; %initialize variable to enter while loop
        while length(Seed_date) ~= 8
            Seed_date = input('Enter the seed date for this condition (in the format YYYYMMDD):',"s");
            if length(Seed_date) ~= 8
                disp('Your seed date input is not the correct length');
            else
            end
        end
        Well_letter = input('Enter the well letter (capital letter) for this condition:',"s");
        Well_ID = [char(Study_Designator(Study_Index)) '_' char(Media_Designator(Media_Index)) '_' char(Cell_Designator(Cell_Index)) '_' char(NRVM_Count_Designator(NRVM_Count_Index)) '_' char(BMDM_Count_Designator(BMDM_Count_Index)) '_' char(Protocol_Designator(Protocol_Index)) '_' char(Seed_date) '_' char(Well_letter)];

        %loop through data types for selected well until user wants to stop
        record_another_data_type = 1;
        while record_another_data_type == 1
            well_counter = previous_well_counter+1; %use previous counter to ensure that no existing data is overwritten
            %Select the data type you are inputing
            Combo_For_Disp = table(Data_Type_Num, Data_Designator, Data_Description)
            prompt = sprintf('From the list above, select the number of the data type you are entering for Well %s of the condition %s_%s_%s_%s_%s_%s_%s: ',char(Well_letter),char(Study_Designator(Study_Index)),char(Media_Designator(Media_Index)),char(Cell_Designator(Cell_Index)),char(NRVM_Count_Designator(NRVM_Count_Index)),char(BMDM_Count_Designator(BMDM_Count_Index)),char(Protocol_Designator(Protocol_Index)),char(Seed_date));
            Data_Index = input(prompt);
            disp(['CHOSEN DATA TYPE: ' Data_Designator(Data_Index)])

            %Create an ID with the well ID and data type (Well Data Type ID - used in checks)
            %(SignalingType_MediaType_CellType_NRVMCount_BMDMCount_Protocol_SeedDate_WellLetter_DataType)
            Well_ID_Data =[char(Study_Designator(Study_Index)) '_' char(Media_Designator(Media_Index)) '_' char(Cell_Designator(Cell_Index)) '_' char(NRVM_Count_Designator(NRVM_Count_Index)) '_' char(BMDM_Count_Designator(BMDM_Count_Index)) '_' char(Protocol_Designator(Protocol_Index)) '_' char(Seed_date) '_' char(Well_letter) '_' char(Data_Designator(Data_Index))];

            %Clear existing definitions to reset each variable
            clear Data_Fold_num DataFilePath data_path filename_data check_counter Split_path

            %Select file for entered well and data type
            Data_Fold_Well = 0; %initialize
            while ~any(Data_Fold_Well) %while loop added to avoid errors if '0' is accidently input for number of analysis files or if user presses 'ENTER' at input prompt
                Data_Fold_Well = input('How many data files would you like to enter for this well and data type?\n(This can be >1 if ZlineDetect was run more than once for a single set of images, with different parameters, or if the MTFs on a single coverslip were analyzed as separate files.\nEntering a value of 0 (ERROR) will prompt you to re-enter the number of folders):');
            end
            for j=well_counter:(well_counter + Data_Fold_Well)-1 %loops through each data file, counter adjusted to account for existing data
                Display_string = ['Select the file with data for the ID ' char(Well_ID_Data)];
                [filename_data, data_path] = ...
                    uigetfile('*.mat', Display_string , data_dir);
                Split_path = split(data_path,':'); %remove drive letter from path
                DataFilePath = [Split_path{2} filename_data]; %path without drive letter
                disp(['CHOSEN FILE PATH (WITHOUT DRIVE LETTER): ' DataFilePath])

                %Determine previous number of folders for selected data type and well
                if any(strcmp(Well_ID_Data_prev,Well_ID_Data)) %match in Well Data Type IDs detected
                    check_counter = find(strcmp(Well_ID_Data_prev,Well_ID_Data)); %find row(s) with match in Well Data Type IDs
                    for i = 1:length(check_counter)
                        Data_Fold_num(i) = Well_Data_Loc_Set(check_counter(i)).DataFold_Num; %list of previous data folder numbers
                    end
                    Previous_Data_Fold = max(Data_Fold_num); %find previous maximum data folder number
                    Data_Fold_B = Previous_Data_Fold+1; %start counter from previous maximum
                else
                    Data_Fold_B = j-well_counter+1; %start counter from 1 if there is no existing data entered for current well and data type
                end

                Well_Data_Loc_Set(j).AnalysisID = [Well_ID_Data '_' num2str(Data_Fold_B)]; %unqiue ID for each associated data file
                Well_Data_Loc_Set(j).WellID = Well_ID;
                Well_Data_Loc_Set(j).WellDataType = Well_ID_Data;
                Well_Data_Loc_Set(j).Study_Type = Study_Designator(Study_Index);
                Well_Data_Loc_Set(j).Media_Type = Media_Designator(Media_Index);
                Well_Data_Loc_Set(j).Cell_Type = Cell_Designator(Cell_Index);
                Well_Data_Loc_Set(j).NRVM_Count = NRVM_Count_Designator(NRVM_Count_Index);
                Well_Data_Loc_Set(j).BMDM_Count = BMDM_Count_Designator(BMDM_Count_Index);
                Well_Data_Loc_Set(j).Protocol = Protocol_Designator(Protocol_Index);
                Well_Data_Loc_Set(j).Seed_Date = Seed_date;
                Well_Data_Loc_Set(j).Well_Letter = Well_letter;
                Well_Data_Loc_Set(j).Data_Type = Data_Designator(Data_Index);
                Well_Data_Loc_Set(j).DataFold_Num = Data_Fold_B;
                Well_Data_Loc_Set(j).PathFiles = DataFilePath;
                Well_Data_Loc_Set(j).UseData = 1; %logical output, 1 if data file is to be used in analysis, 0 if not to be used
                if double(isequal(char(Data_Designator(Data_Index)),'Cont')) == 0 %data type is not contractility
                    Well_Data_Loc_Set(j).UDO = 0; %user defined orientation for films in contractility data (used to address issues in film side designation)
                else
                    Orientation_Prompt = input('Enter the film orientation condition for the selected Summary_Auto.mat file\nUDO = 0, No change in film orientation\nUDO = 1, Change film side to top in Summary_Auto.mat (true orientation). Was incorrectly labeled as bottom by code\nUDO = 2, Flip top condition (film was flipped from bottom to top by user during processing, recorded as bottom film in Summary_Auto.mat)\nUDO = 3, Flip top condition (film was flipped from bottom to top by user during processing, recorded as top film in Summary_Auto.mat)\nUDO = 4, Change film side to bottom in Summary_Auto.mat (true orientation). Was incorrectly labeled as top by code\nPlease select an option:');
                    Well_Data_Loc_Set(j).UDO = Orientation_Prompt;
                end

                %Allow user to type in any notes for the entry
                Notes_input = input('Would you like to type any notes for this entry? 0=No, 1=Yes:');
                if Notes_input == 1
                    TexttoEnter = input('Type the text you would like to enter:',"s");
                    Well_Data_Loc_Set(j).Notes = TexttoEnter;
                    clear TexttoEnter
                else
                    Well_Data_Loc_Set(j).Notes = {};
                end

                %%%% ERROR CHECKS %%%%

                %Check for duplicates (same Well Data ID and data file path)
                if any(strcmp(Well_ID_Data_prev,Well_ID_Data)) %Well Data IDs match
                    check_well_counter_1 = find(strcmp(Well_ID_Data_prev, Well_ID_Data)); %rows with matching IDs
                    for n=1:length(check_well_counter_1) %loop through each recognized match in ID
                        if any(strcmpi(Well_Path_prev(check_well_counter_1(n)),DataFilePath)) %path files match (case insensitive check)
                            DoubleActionChoice = input('An exact duplicate exists!\n0 = Delete existing duplicate from database\n1 = You made an error in selecting the data file and want to choose another one for the Well Data Type ID you just entered\n2 = You made an error in entering data and want to select another data type for the well you just entered (you will be prompted to re-enter the data type and number of data files and re-select the data file)\n3 = You made an error in entering data and want to enter another well letter for the experimental conditon you just entered (you will be prompted to re-enter the seed date, well letter, data type, and number of data files and re-select the data file)\n4 = You made an error in entering data and want to enter a different experimental condition (start from scratch)\n5 = Exit code (previously entered data will not be saved)\nPlease choose what you would like to do: ');
                            if DoubleActionChoice == 0
                                DoubleActionChoice = []; %create empty array to avoid errors in future checks
                                %delete row for existing duplicate from database (set as 'deleted directory' in file path and delete before generating output to avoid any issues with the counters
                                Well_Data_Loc_Set(check_well_counter_1(n)).WellDataType = [Well_ID_Data '_DUPLICATE']; %since entry is to be deleted, add _DUPLICATE to ID to avoid involving in checks
                                Well_Data_Loc_Set(check_well_counter_1(n)).PathFiles = 'deleted_directory';
                                %update previous files
                                Well_Path_prev = {Well_Data_Loc_Set(1:j-1).PathFiles}; %update data, ensure current entry is not added to avoid errors in checks
                                Well_ID_Data_prev = {Well_Data_Loc_Set(1:j-1).WellDataType}; %update data, ensure current entry is not added to avoid errors in checks
                            elseif DoubleActionChoice == 1
                                DoubleActionChoice = []; %create empty array to avoid errors in future checks
                                PathFileVec_dup = DataFilePath;
                                while any(strcmpi(Well_Path_prev,PathFileVec_dup)) %path files match (case insensitive check)
                                    check_dup = find(strcmpi(Well_Path_prev,PathFileVec_dup));
                                    ERROR = sprintf('The previously selected file already exists for Row %d, please select the correct one for the current Well Data ID',check_dup);
                                    Display_string = ['Select the file with data for the ID ' char(Well_ID_Data)]; %select correct file for selected well data type
                                    [filename_dup, dup_path] = ...
                                        uigetfile('*.mat', Display_string , data_dir);
                                    Split_path_dup = split(dup_path,':'); %split path at drive letter
                                    PathFileVec_dup = [Split_path_dup{2} filename_dup];
                                    Well_Data_Loc_Set(j).PathFiles = PathFileVec_dup; %update with newly selected data file
                                end
                                DataFilePath = PathFileVec_dup; %update for next check
                                clear filename_dup dup_path PathFileVec_dup check_dup Split_path_dup
                            elseif DoubleActionChoice == 2
                                Well_Data_Loc_Set(j) = []; %delete entered data
                                Well_ID_Data = []; %delete to avoid checks
                                DataFilePath = []; %delete to avoid checks
                                j = j-1; %reset counter to make sure no number is skipped
                                break;
                            elseif DoubleActionChoice == 3
                                Well_Data_Loc_Set(j) = []; %delete entered data
                                Well_ID_Data = []; %delete to avoid checks
                                DataFilePath = []; %delete to avoid checks
                                j = j-1; %reset counter to make sure no number is skipped
                                break;
                            elseif DoubleActionChoice == 4
                                Well_Data_Loc_Set(j) = []; %delete entered data
                                Well_ID_Data = []; %delete to avoid checks
                                DataFilePath = []; %delete to avoid checks
                                j = j-1; %reset counter to make sure no number is skipped
                                break;
                            elseif DoubleActionChoice == 5
                                clear
                                return  %exit code
                            else
                            end
                        else %separate check for match in well data type IDs but not path files
                        end
                    end
                clear check_well_counter_1
                else
                end

                if DoubleActionChoice == 2
                    DoubleActionChoice = []; %create empty array to avoid errors in future checks
                    break; %break from current loop to automatically go to loop for selecting another data type
                elseif DoubleActionChoice == 3
                    break; %break from current loop
                elseif DoubleActionChoice == 4
                    break; %break from current loop
                end

                %Check for error in selecting data file (same file paths but not matching Well Data IDs)
                if any(strcmpi(Well_Path_prev,DataFilePath)) %data file paths match (case insensitive check)
                    check_well_counter_3 = find(strcmpi(Well_Path_prev, DataFilePath)); %should be a single row as checks are performed for every entry
                    ID_check = double(any(strcmp(Well_ID_Data_prev(check_well_counter_3),Well_ID_Data))); %check for matches in Well Data ID
                    if ID_check == 0 %no match in Well Data IDs
                        ID_Row = [check_well_counter_3; j]; %rows in database of matching Well Data IDs
                        ID_List = [string(Well_Data_Loc_Set(check_well_counter_3).WellDataType); string(Well_Data_Loc_Set(j).WellDataType)];
                        ID_Path = [string(Well_Data_Loc_Set(check_well_counter_3).PathFiles); string(Well_Data_Loc_Set(j).PathFiles)];
                        ID_UD = [double(Well_Data_Loc_Set(check_well_counter_3).UseData); double(Well_Data_Loc_Set(j).UseData)];
                        Combo_For_Disp = table(ID_Row, ID_List, ID_Path, ID_UD,'VariableNames',["Data Row","Well Data ID","Data File Path","UseData"]) %table for displaying matching file path entries
                        DataFile_Action = input('The selected data file already exists, but the Well Data IDs do not match.\n0 = Delete one of the records from the database\n1 = Delete both records from the database\n2 = You selected the data file incorrectly and would like to change it for one of the records\nPlease choose what you would like to do:');
                        if DataFile_Action == 0
                            %delete selected entry/entries from database (set as 'deleted directory' in file path and delete before generating output to avoid any issues with the counters
                            IncorrectFileChoice = input('Choose the row with the incorrect file path to delete it from the database:');
                            Well_Data_Loc_Set(IncorrectFileChoice).PathFiles = 'deleted_directory';
                            Well_Data_Loc_Set(IncorrectFileChoice).WellDataType = [Well_Data_Loc_Set(IncorrectFileChoice).WellDataType '_ERROR']; %since entry is to be deleted, add _ERROR to ID to avoid involving in checks
                            if IncorrectFileChoice == j
                                Well_ID_Data = [Well_Data_Loc_Set(IncorrectFileChoice).WellDataType '_ERROR']; %update data to avoid going through remaining checks
                                DataFilePath = 'deleted_directory'; %update data to avoid going through remaining checks
                            else
                                Well_ID_Data_prev = {Well_Data_Loc_Set(1:j-1).WellDataType}; %update data, ensure current entry is not added to avoid errors in checks
                                Well_Path_prev = {Well_Data_Loc_Set(1:j-1).PathFiles}; %update data, ensure current entry is not added to avoid errors in checks
                            end
                        elseif DataFile_Action == 1
                            Well_Data_Loc_Set(check_well_counter_3).PathFiles = 'deleted_directory';
                            Well_Data_Loc_Set(check_well_counter_3).WellDataType = [Well_Data_Loc_Set(check_well_counter_3).WellDataType '_ERROR']; %since entry is to be deleted, add _ERROR to ID to avoid involving in checks
                            Well_Data_Loc_Set(j).PathFiles = 'deleted_directory';
                            Well_Data_Loc_Set(j).WellDataType = [Well_Data_Loc_Set(j).WellDataType '_ERROR']; %since entry is to be deleted, add _DUPLICATE to ID to avoid involving in checks
                            Well_ID_Data_prev = {Well_Data_Loc_Set(1:j-1).WellDataType}; %update data
                            Well_Path_prev = {Well_Data_Loc_Set(1:j-1).PathFiles}; %update data
                            Well_ID_Data = [Well_Data_Loc_Set(j).WellDataType '_ERROR']; %update data to avoid going through remaining checks
                            DataFilePath = 'deleted_directory'; %update data to avoid going through remaining checks
                        else
                            NewFileSelection = input(sprintf('Would you like to re-select the data file for the existing entry (Row %d) or the current entry (Row %d)? 0 = Existing, 1 = Current:',check_well_counter_3,j));
                            if NewFileSelection == 0
                                NewFileRow = check_well_counter_3;
                            else
                                NewFileRow = j;
                            end
                            DataFileVec_n = Well_Data_Loc_Set(NewFileRow).PathFiles;
                            while any(strcmpi(Well_Path_prev,DataFileVec_n)) %match detected in data files
                                Display_string = ['Select the new file for ' char(Well_Data_Loc_Set(NewFileRow).WellDataType)]; %select correct file for chosen Well Data ID
                                [filename_new, new_path] = ...
                                    uigetfile('*.mat', Display_string , data_dir);
                                Split_path_new = split(new_path,':'); %split at drive letter
                                DataFileVec_n = [Split_path_new{2} filename_new];
                                Well_Data_Loc_Set(NewFileRow).PathFiles = DataFileVec_n; %update with newly selected data file
                                if NewFileRow == j
                                    DataFilePath = DataFileVec_n; %update for next check
                                else
                                end
                            end
                            clear filename_new new_path DataFileVec_n check_n Split_path_new
                            Well_ID_Data_prev = {Well_Data_Loc_Set(1:j-1).WellDataType}; %update data, ensure current entry is not added to avoid errors in checks
                            Well_Path_prev = {Well_Data_Loc_Set(1:j-1).PathFiles}; %update data, ensure current entry is not added to avoid errors in checks
                        end
                        clear ID_Row ID_List ID_Path ID_UD
                    else %separate check above for match in Well Data IDs and data file paths
                    end
                    clear ID_check check_well_counter_3
                else
                end
                
                %Check for multiple analysis files of entered well condition and data type (same Well Data ID but not data file path)
                if any(strcmp(Well_ID_Data_prev,Well_ID_Data)) %Well Data IDs match
                    check_well_counter_2 = find(strcmp(Well_ID_Data_prev, Well_ID_Data)); %find rows with matching Well Data IDs
                    for k=1:length(check_well_counter_2) %loop through each match found
                        Path_check(k) = double(any(strcmpi(Well_Path_prev(check_well_counter_2(k)),DataFilePath))); %detect matches in the data file path (case insensitive)
                    end
                    if max(Path_check) == 0 %no match in data file paths
                        Well_cond_row = [check_well_counter_2, j]';
                        Well_ID_row = {Well_Data_Loc_Set(Well_cond_row).WellDataType}';
                        Path_file_row = {Well_Data_Loc_Set(Well_cond_row).PathFiles}';
                        UseData_row = [Well_Data_Loc_Set(Well_cond_row).UseData]';
                        Notes_row = {Well_Data_Loc_Set(Well_cond_row).Notes}';
                        Combo_For_Disp = table(Well_cond_row,string(Well_ID_row),string(Path_file_row),double(UseData_row),Notes_row,'VariableNames',["Data Row","Well Data ID","Data File Path","UseData","Notes"]) %create table for display with same IDs but differing file paths
                        PrimaryAction = input('Data for this Well Data ID already exists!\n0 = Designate one entry as the primary set\n1 = You entered the Well Data ID incorrectly and would like to edit it\n2 = The matching Well Data ID enteries are for contractility data (different films/conditions for same chip) and you want to use all of them\nPlease choose what you want to do:');
                        if PrimaryAction == 0
                            PrimaryChoice = input('Enter the data row of the file you would like to use as the primary set (UseData = 1)\nALL OTHERS WILL AUTOMATICALLY BE SET TO USEDATA = 0:');
                            Well_Data_Loc_Set(PrimaryChoice).UseData = 1; %update data output with primary selection
                            UseData_row(find(Well_cond_row == PrimaryChoice)) = 1; %update display table with primary selection
                            NonprimaryChoice = find(Well_cond_row ~= PrimaryChoice); %find data rows to set as UseData = 0 (nonprimary sets)
                            for i=1:length(NonprimaryChoice)
                                Well_Data_Loc_Set(Well_cond_row(NonprimaryChoice(i))).UseData = 0; %update data output with nonprimary selection
                                UseData_row(NonprimaryChoice(i)) = 0; %update display table with nonprimary selection
                            end

                            Enter_notes_q = input('Would you like to enter notes for any of the data rows with duplicate Well Data IDs? 0=No, 1=Yes');
                            if Enter_notes_q == 1
                                Enter_notes = 1; %initialize to enter while loop
                                while Enter_notes == 1 %allow user to loop through rows to enter notes
                                    Combo_For_Disp = table(Well_cond_row,string(Well_ID_row),string(Path_file_row),double(UseData_row),Notes_row,'VariableNames',["Data Row","Well Data ID","Data File Path","UseData","Notes"]) %create table for display with same IDs but differing file paths
                                    NotesChoice = input('Select the data row for which you would like to enter notes:');
                                    NotesText = input('Type the text you would like to enter:',"s");
                                    if double(isempty(Well_Data_Loc_Set(NotesChoice).Notes)) == 1 %notes column is empty
                                        Well_Data_Loc_Set(NotesChoice).Notes = NotesText;
                                    else
                                        Well_Data_Loc_Set(NotesChoice).Notes = {Well_Data_Loc_Set(NotesChoice).Notes NotesText};
                                        Well_Data_Loc_Set(NotesChoice).Notes = strjoin(Well_Data_Loc_Set(NotesChoice).Notes, '. '); %combine entered text with previously entered text to prevent overwriting
                                    end
                                    clear NotesText
                                    Notes_row(find(Well_cond_row == NotesChoice)) = {Well_Data_Loc_Set(NotesChoice).Notes}; %update table for display with entered notes
                                    Enter_notes = input('Would you like to enter notes for another data row? 0=No, 1=Yes:');
                                end
                            else
                            end
                        elseif PrimaryAction == 1
                            IDChange = input('You chose to edit the Well Data ID.\n0 = You made an error in entering data and want to select another data type for the well you just entered (you will be prompted to re-enter the data type and number of data files and re-select the data file)\n1 = You made an error in entering data and want to enter another well letter for the experimental conditon you just entered (you will be prompted to re-enter the seed date, well number, data type, and number of data files and to re-select the data file)\n2 = You made an error in entering data and want to enter a different experimental condition (start from scratch)\n3 = Exit code (previously entered data will not be saved)\nPlease choose what you want to do: ');
                            if IDChange == 0
                                Well_Data_Loc_Set(j) = []; %delete entered data
                                Well_ID_Data = []; %delete to avoid checks
                                DataFilePath = []; %delete to avoid checks
                                j = j-1; %reset counter to make sure no number is skipped
                                break;
                            elseif IDChange == 1
                                Well_Data_Loc_Set(j) = []; %delete entered data
                                Well_ID_Data = []; %delete to avoid checks
                                DataFilePath = []; %delete to avoid checks
                                j = j-1; %reset counter to make sure no number is skipped
                                break;
                            elseif IDChange == 2
                                Well_Data_Loc_Set(j) = []; %delete entered data
                                Well_ID_Data = []; %delete to avoid checks
                                DataFilePath = []; %delete to avoid checks
                                j = j-1; %reset counter to make sure no number is skipped
                                break;
                            elseif IDChange == 3
                                clear
                                return  %exit code
                            else
                            end
                        else
                        end
                        clear Well_cond_row Path_file_row UseData_row Notes_row
                    else %separate check above for match in IDs and file paths
                    end
                    clear Path_check check_well_counter_2
                end
                if IDChange == 0
                    IDChange = []; %create empty array to avoid errors in future checks
                    break; %break from current loop to automatically go to loop for selecting another data type
                elseif IDChange == 1
                    break; %break from current loop
                elseif IDChange == 2
                    break; %break from current loop
                end
                %%%% END OF CHECKS %%%%

                %update previous to include recent entry (will be used in checks for next selection)
                Well_ID_Data_prev = {Well_Data_Loc_Set.WellDataType};
                Well_Path_prev = {Well_Data_Loc_Set.PathFiles};
            end


            %record another data type
            if DoubleActionChoice == 3
                DoubleActionChoice = []; %create empty array to avoid errors in future checks
                break; %break from current loop to automatically go to loop for selecting another well number
            elseif DoubleActionChoice == 4
                break; %break from current loop
            end
            if IDChange == 1
                IDChange = []; %create empty array to avoid errors in future checks
                break; %break from current loop to automatically go to loop for selecting another well number
            elseif IDChange == 2
                break; %break from current loop
            end
            record_another_data_type = input('Would you like to enter another data type for this well? 0=No, 1=Yes:');
            previous_well_counter = j; %update previous well counter to avoid overwriting existing data
        end
        if DoubleActionChoice == 4
            DoubleActionChoice = []; %create empty array to avoid errors in future checks
            break; %break from current loop to automatically go to loop for selecting another condition
        end
        if IDChange == 2
            IDChange = []; %create empty array to avoid errors in future checks
            break; %break from current loop to automatically go to loop for selecting another condition
        end
        Well_input = input('Would you like to enter another well and/or seed date for the entered condition? 0=No, 1=Yes');
    end
    record_another_well = input('Would you like to enter data for another condition? 0=No, 1=Yes:');
end

%%%% FINAL PROCESSING %%%%
%Ask if there are any records that cannot be used
DoNotUseAction = input('Are there any records that you do not want to use due to experimental error or any other reason? 0=No, 1=Yes:');
while DoNotUseAction == 1 %allow user to loop through and select multiple rows
    Table = struct2table(Well_Data_Loc_Set,"AsArray",true);
    disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries (this is an intermediate output, and rows to be deleted will have deleted_directory in the PathFiles column)'); disp('Back in the editor, press continue to resume running of the code, where you will be prompted to enter a row number')
    keyboard
    DoNotUseRow = input('Select the row of the entry you no longer want to use:');
    Well_Data_Loc_Set(DoNotUseRow).UseData = 0;
    NotesTextDNU = input('Explain why you do not want to use this data:',"s");
    if double(isempty(Well_Data_Loc_Set(DoNotUseRow).Notes)) == 1 %notes column is empty
        Well_Data_Loc_Set(DoNotUseRow).Notes = NotesTextDNU;
    else
        Well_Data_Loc_Set(DoNotUseRow).Notes = {Well_Data_Loc_Set(DoNotUseRow).Notes NotesTextDNU};
        Well_Data_Loc_Set(DoNotUseRow).Notes = strjoin(Well_Data_Loc_Set(DoNotUseRow).Notes, '. '); %combine currently entered text with previous text to avoid overwriting
    end
    DoNotUseAction = input('Are there any other records that you do not want to use? 0=No, 1=Yes:');
end

%Reassurance check for match in file paths
[C, ~, ic] = unique(lower({Well_Data_Loc_Set.PathFiles}),'stable'); %since file naming is not case sensitive, convert file path to all lowercase for checks
RowValues = find(ismember(lower({Well_Data_Loc_Set.PathFiles}), C(accumarray(ic,1)>1))); %find the indices of any matches
if RowValues ~= 0
    Entry_Row = RowValues';
    WellID_Row = {Well_Data_Loc_Set(Entry_Row).WellDataType}';
    Path_File_Row = {Well_Data_Loc_Set(Entry_Row).PathFiles}';
    clear Combo_For_Disp
    Combo_For_Disp = table(Entry_Row,string(WellID_Row),string(Path_File_Row),'VariableNames',["Data Row", "Well Data ID","Data File Path"]);
    rows = find(strcmp(Combo_For_Disp.('Data File Path'),'deleted_directory')); %find rows with deleted directory
    Combo_For_Disp(rows,:) = []; %skip deleted directory display in table to only show actual file duplicates
    if double(isempty(Combo_For_Disp)) == 0 %table is not empty
        Combo_For_Disp
        disp('There are still matches in the data file paths. You will now be prompted to delete any incorrect entries from the database; press the ENTER key to continue:');
        pause; %introduce pause to allow user to see errors, press the enter key to continue
    else
    end
else
end


%Ask to delete any files from database
DeleteAction = input('Would you like to delete any records from the database?\n(Do not delete files if the data is not to be used; this option is mainly for errors in entering condition/location information into the database). 0=No, 1=Yes:');
while DeleteAction == 1 %allow user to loop through and select multiple rows to delete
    Table = struct2table(Well_Data_Loc_Set,"AsArray",true);
    disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries (this is an intermediate output, and rows to be deleted will have deleted_directory in the PathFiles column)'); disp('Back in the editor, press continue to resume running of the code, where you will be prompted to enter a row number')
    keyboard
    Delete_row = input('Select the row number of the record you would like to delete:');
    ID_row = {Well_Data_Loc_Set(Delete_row).WellDataType};
    File_row = {Well_Data_Loc_Set(Delete_row).PathFiles};
    Combo_For_Disp = table(Delete_row,string(ID_row),string(File_row),'VariableNames',["Data Row", "Well Data ID","Data File Path"]) %make table of Well ID Data and corresponding data file path to be deleted
    Confirmation = input('Confirm that this is the record you want to delete. 0=No 1=Yes');
    if Confirmation == 1
        Well_Data_Loc_Set(Delete_row).PathFiles = 'deleted_directory';
        Well_ID_Data_prev = {Well_Data_Loc_Set.WellDataType}; %update to account for changes
        Well_Path_prev = {Well_Data_Loc_Set.PathFiles}; %update to account for changes
    else
    end
    DeleteAction = input('Would you like to delete any other records from the database? 0=No, 1=Yes:');
end


%Erase all deleted records from database
if any(strcmp(Well_Path_prev,'deleted_directory'))
    delete_counter = find(strcmp(Well_Path_prev,'deleted_directory')); %find rows of records to be deleted
    deleted_IDs = {Well_Data_Loc_Set(delete_counter).WellDataType}; %Well Data IDs corresponding to records to be deleted
    deleted_Datafold = [Well_Data_Loc_Set(delete_counter).DataFold_Num]; %Data file numbers corresponding to data files to be deleted
    Well_Data_Loc_Set(delete_counter) = [];
    Well_ID_Data_prev = {Well_Data_Loc_Set.WellDataType};
    Well_Path_prev = {Well_Data_Loc_Set.PathFiles};
    for p=1:length(deleted_IDs) %cycle through each row to be deleted
        Fold_to_delete = deleted_Datafold(p); %assigned data file number to be deleted
        if double(endsWith(deleted_IDs(p),'_DUPLICATE')) == 1
            deleted_IDs(p) = extractBefore(deleted_IDs(p),'_DUPLICATE'); %remove _DUPLICATE from Well Data ID
        elseif double(endsWith(deleted_IDs(p),'_ERROR')) == 1
            deleted_IDs(p) = extractBefore(deleted_IDs(p),'_ERROR'); %remove _ERROR from Well Data ID
        else
        end
        check_well_counter_4 = find(strcmp(Well_ID_Data_prev, deleted_IDs(p))); %find rows with same Well Data ID as the record to be deleted
        Fold_to_reset = [Well_Data_Loc_Set(check_well_counter_4).DataFold_Num]; %associated data file numbers
        Data_fold_reset_index = find(Fold_to_reset>Fold_to_delete); %find which data file numbers and analysis IDs which need to be reset
        if double(isempty(Data_fold_reset_index)) == 0 %there are data file numbers which need to be reset
            for h=1:length(Data_fold_reset_index) %cycle through each record to be reset
                Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).DataFold_Num = Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).DataFold_Num-1; %reset data file number
                Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).AnalysisID = [Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).WellDataType '_' num2str(Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).DataFold_Num)]; %reset Analysis ID
            end
        else
        end
    end
end

%Confirmation to make sure there are no repeating file paths or analysis IDs
[B, ~, ib] = unique(lower({Well_Data_Loc_Set.PathFiles}),'stable'); %since file naming is not case sensitive, convert file path to all lowercase for checks
RowValuesb = find(ismember(lower({Well_Data_Loc_Set.PathFiles}), B(accumarray(ib,1)>1)));
if double(isempty(RowValuesb)) == 1 %no match in file paths detected
    disp('DATA FILE PATH FINAL CHECK: There are no matches in the data file paths')
else
    disp('ERROR: There is still a match in file paths. Analyze output file to locate the error and erase from the database.')
end

[C, ~, ic] = unique(lower({Well_Data_Loc_Set.AnalysisID}),'stable'); %since file naming is not case sensitive, convert file path to all lowercase for checks
RowValuesc = find(ismember(lower({Well_Data_Loc_Set.AnalysisID}), C(accumarray(ic,1)>1)));
if double(isempty(RowValuesc)) == 1 %no match in analysis IDs detected
    disp('ANALYSIS ID FINAL CHECK: There are no matches in the Analysis IDs')
else
    disp('ERROR: There is still a match in Analysis IDs. Analyze output file to locate the error and erase from the database.')
end

%%%% GENERATE OUTPUTS %%%%
cd(output_dir)

filename_well_out = [output_dir '\' Cond_File_Name '.mat']; %.mat file that will be worked with (updated every iteration of code)
save(filename_well_out,'Well_Data_Loc_Set') %save as .mat file (updated every iteration of code)

%Files with time stamps (check how data is updated with each run of code and fallback for any errors in code iteration)
filename_well_out_time = [output_dir '\' Cond_File_Name time_stamp '.mat']; %mat file that will be worked with
save(filename_well_out_time,'Well_Data_Loc_Set') %save as mat file

%Save as .csv files for visual checks
T = struct2table(Well_Data_Loc_Set,"AsArray",true);
filename_table_out_con = [output_dir '\Data_Locations_Table.csv'];
filename_table_out = [output_dir '\Data_Locations_Table' time_stamp '.csv'];
writetable(T,filename_table_out_con);
writetable(T,filename_table_out);

catch ME %steps taken if code errors out due to invalid input
    disp('The code errored out during execution of the script. A description of the error is provided in the output ME in the workspace.'); disp('To avoid loss of previous entries during this run, the output files will be generated after selection of any records that you do not want to use or delete');
    disp('Press ENTER to continue');
    pause
    Well_ID_Data_prev = {Well_Data_Loc_Set.WellDataType};
    Well_Path_prev = {Well_Data_Loc_Set.PathFiles};

    DoNotUseAction = input('Are there any records that you do not want to use due to experimental error or any other reason? 0=No, 1=Yes:');
    while DoNotUseAction == 1 %allow user to loop through and select multiple rows
        Table = struct2table(Well_Data_Loc_Set,"AsArray",true);
        disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries (this is an intermediate output, and rows to be deleted will have deleted_directory in the PathFiles column)'); disp('Back in the editor, press continue to resume running of the code, where you will be prompted to enter a row number')
        keyboard
        DoNotUseRow = input('Select the row of the entry you no longer want to use:');
        Well_Data_Loc_Set(DoNotUseRow).UseData = 0;
        NotesTextDNU = input('Explain why you do not want to use this data:',"s");
        if double(isempty(Well_Data_Loc_Set(DoNotUseRow).Notes)) == 1 %notes column is empty
            Well_Data_Loc_Set(DoNotUseRow).Notes = NotesTextDNU;
        else
            Well_Data_Loc_Set(DoNotUseRow).Notes = {Well_Data_Loc_Set(DoNotUseRow).Notes NotesTextDNU};
            Well_Data_Loc_Set(DoNotUseRow).Notes = strjoin(Well_Data_Loc_Set(DoNotUseRow).Notes, '. '); %combine currently entered text with previous text to avoid overwriting
        end
        DoNotUseAction = input('Are there any other records that you do not want to use? 0=No, 1=Yes:');
    end

    %Reassurance check for match in file paths
    [C, ~, ic] = unique(lower({Well_Data_Loc_Set.PathFiles}),'stable'); %since file naming is not case sensitive, convert file path to all lowercase for checks
    RowValues = find(ismember(lower({Well_Data_Loc_Set.PathFiles}), C(accumarray(ic,1)>1))); %find the indices of any matches
    if RowValues ~= 0
        Entry_Row = RowValues';
        WellID_Row = {Well_Data_Loc_Set(Entry_Row).WellDataType}';
        Path_File_Row = {Well_Data_Loc_Set(Entry_Row).PathFiles}';
        clear Combo_For_Disp
        Combo_For_Disp = table(Entry_Row,string(WellID_Row),string(Path_File_Row),'VariableNames',["Data Row", "Well Data ID","Data File Path"]);
        rows = find(strcmp(Combo_For_Disp.('Data File Path'),'deleted_directory')); %find rows with deleted directory
        Combo_For_Disp(rows,:) = []; %skip deleted directory display in table to only show actual file duplicates
        if double(isempty(Combo_For_Disp)) == 0 %table is not empty
            Combo_For_Disp
            disp('There are still matches in the data file paths. You will now be prompted to delete any incorrect entries from the database; press the ENTER key to continue:');
            pause; %introduce pause to allow user to see errors, press the enter key to continue
        else
        end
    else
    end


    %Ask to delete any files from database
    DeleteAction = input('Would you like to delete any records from the database?\n(Do not delete files if the data is not to be used; this option is mainly for errors in entering condition/location information into the database). 0=No, 1=Yes:');
    while DeleteAction == 1 %allow user to loop through and select multiple rows to delete
        Table = struct2table(Well_Data_Loc_Set,"AsArray",true);
        disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries (this is an intermediate output, and rows to be deleted will have deleted_directory in the PathFiles column)'); disp('Back in the editor, press continue to resume running of the code, where you will be prompted to enter a row number')
        keyboard
        Delete_row = input('Select the row number of the record you would like to delete:');
        ID_row = {Well_Data_Loc_Set(Delete_row).WellDataType};
        File_row = {Well_Data_Loc_Set(Delete_row).PathFiles};
        Combo_For_Disp = table(Delete_row,string(ID_row),string(File_row),'VariableNames',["Data Row", "Well Data ID","Data File Path"]) %make table of Well ID Data and corresponding data file path to be deleted
        Confirmation = input('Confirm that this is the record you want to delete. 0=No 1=Yes');
        if Confirmation == 1
            Well_Data_Loc_Set(Delete_row).PathFiles = 'deleted_directory';
            Well_ID_Data_prev = {Well_Data_Loc_Set.WellDataType}; %update to account for changes
            Well_Path_prev = {Well_Data_Loc_Set.PathFiles}; %update to account for changes
        else
        end
        DeleteAction = input('Would you like to delete any other records from the database? 0=No, 1=Yes:');
    end


    %Erase all deleted records from database
    if any(strcmp(Well_Path_prev,'deleted_directory'))
        delete_counter = find(strcmp(Well_Path_prev,'deleted_directory')); %find rows of records to be deleted
        deleted_IDs = {Well_Data_Loc_Set(delete_counter).WellDataType}; %Well Data IDs corresponding to records to be deleted
        deleted_Datafold = [Well_Data_Loc_Set(delete_counter).DataFold_Num]; %Data file numbers corresponding to data files to be deleted
        Well_Data_Loc_Set(delete_counter) = [];
        Well_ID_Data_prev = {Well_Data_Loc_Set.WellDataType};
        Well_Path_prev = {Well_Data_Loc_Set.PathFiles};
        for p=1:length(deleted_IDs) %cycle through each row to be deleted
            Fold_to_delete = deleted_Datafold(p); %assigned data file number to be deleted
            if double(endsWith(deleted_IDs(p),'_DUPLICATE')) == 1
                deleted_IDs(p) = extractBefore(deleted_IDs(p),'_DUPLICATE'); %remove _DUPLICATE from Well Data ID
            elseif double(endsWith(deleted_IDs(p),'_ERROR')) == 1
                deleted_IDs(p) = extractBefore(deleted_IDs(p),'_ERROR'); %remove _ERROR from Well Data ID
            else
            end
            check_well_counter_4 = find(strcmp(Well_ID_Data_prev, deleted_IDs(p))); %find rows with same Well Data ID as the record to be deleted
            Fold_to_reset = [Well_Data_Loc_Set(check_well_counter_4).DataFold_Num]; %associated data file numbers
            Data_fold_reset_index = find(Fold_to_reset>Fold_to_delete); %find which data file numbers and analysis IDs which need to be reset
            if double(isempty(Data_fold_reset_index)) == 0 %there are data file numbers which need to be reset
                for h=1:length(Data_fold_reset_index) %cycle through each record to be reset
                    Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).DataFold_Num = Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).DataFold_Num-1; %reset data file number
                    Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).AnalysisID = [Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).WellDataType '_' num2str(Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset_index(h))).DataFold_Num)]; %reset Analysis ID
                end
            else
            end
        end
    end

    %Confirmation to make sure there are no repeating file paths or analysis IDs
    [B, ~, ib] = unique(lower({Well_Data_Loc_Set.PathFiles}),'stable'); %since file naming is not case sensitive, convert file path to all lowercase for checks
    RowValuesb = find(ismember(lower({Well_Data_Loc_Set.PathFiles}), B(accumarray(ib,1)>1)));
    if double(isempty(RowValuesb)) == 1 %no match in file paths detected
        disp('DATA FILE PATH FINAL CHECK: There are no matches in the data file paths')
    else
        disp('ERROR: There is still a match in file paths. Analyze output file to locate the error and erase from the database.')
    end

    [C, ~, ic] = unique(lower({Well_Data_Loc_Set.AnalysisID}),'stable'); %since file naming is not case sensitive, convert file path to all lowercase for checks
    RowValuesc = find(ismember(lower({Well_Data_Loc_Set.AnalysisID}), C(accumarray(ic,1)>1)));
    if double(isempty(RowValuesc)) == 1 %no match in analysis IDs detected
        disp('ANALYSIS ID FINAL CHECK: There are no matches in the Analysis IDs')
    else
        disp('ERROR: There is still a match in Analysis IDs. Analyze output file to locate the error and erase from the database.')
    end

    %%%% GENERATE OUTPUTS %%%%
    cd(output_dir)

    filename_well_out = [output_dir '\' Cond_File_Name '.mat']; %.mat file that will be worked with (updated every iteration of code)
    save(filename_well_out,'Well_Data_Loc_Set') %save as .mat file (updated every iteration of code)

    %Files with time stamps (check how data is updated with each run of code and fallback for any errors in code iteration)
    filename_well_out_time = [output_dir '\' Cond_File_Name time_stamp '.mat']; %mat file that will be worked with
    save(filename_well_out_time,'Well_Data_Loc_Set') %save as mat file

    %Save as .csv files for visual checks
    T = struct2table(Well_Data_Loc_Set,"AsArray",true);
    filename_table_out_con = [output_dir '\Data_Locations_Table.csv'];
    filename_table_out = [output_dir '\Data_Locations_Table' time_stamp '.csv'];
    writetable(T,filename_table_out_con);
    writetable(T,filename_table_out);
end


