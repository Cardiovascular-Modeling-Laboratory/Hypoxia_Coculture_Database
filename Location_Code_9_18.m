%Author: Nida Qayyum 
%Location pointer script for hypoxia co-culture experiments

%The outputs of this code are .mat and .csv files named 'Data_Locations'
%with a time stamp to keep track of the database changes with each code run

%The file 'Data Locations' (without time stamp) contains the most recently
%updated information and is loaded into the MATLAB workspace with each code
%run and used to read the data

%Date updated: 09/18/23 (updated version of code 'Location_Code_9_15', took drive letter out of PathFileVec, check to make sure seed date input is correct length, and altered PathFile checks to make sure they are not case-sensitive)

clear; clc;

%Generate a time stamp for the file name
c = datetime;
cc = datevec(c);
time_stamp = [num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(round(cc(6)))];

%Format of each column of the BMDM count helper table:
%BMDM_Count_Designator,	Number_of_Cells
formatSpec = '%C%C';
%Ask the user for the file with BMDM count
[filename_BMDM_count, BMDM_count_path] = ...
    uigetfile('*.csv','Select a csv file with the CELL COUNT (BMDM) helper table','C:\Users\Nida Qayyum\Documents\UCI\CML Research\Database Project'); %replace with path to helper tables
    %uigetfile('*.csv','Select a csv file with the CELL COUNT (BMDM) helper table','C:\Users\Grosberg CML\Documents\Nida_Database'); %replace with path to helper tables

path_base = BMDM_count_path; %set the previous folder to be the current base folder

%Read the BMDM count helper table ignoring the first row
path_filename_BMDM_count = [BMDM_count_path filename_BMDM_count];
T_BMDM_Count = readtable(path_filename_BMDM_count,'Delimiter',',', ...
    'Format',formatSpec);
%Create a vector with BMDM count designators
BMDM_Count_Designator = T_BMDM_Count.BMDM_Count_Designator;
N_BMDM_Count = length(BMDM_Count_Designator); %Total number of possible cell counts
BMDM_Count_Num = (1:1:N_BMDM_Count)';

%Format of each column of the NRVM count helper table:
%NRVM_Count_Designator,	Number_of_Cells
formatSpec = '%C%C';
%Ask the user for the file with NRVM count
[filename_NRVM_count, NRVM_count_path] = ...
    uigetfile('*.csv','Select a csv file with the CELL COUNT (NRVM) helper table',path_base); %replace with path to helper tables
    %uigetfile('*.csv','Select a csv file with the CELL COUNT (NRVM) helper table',path_base); %replace with path to helper tables

%Read the NRVM count helper table ignoring the first row
path_filename_NRVM_count = [NRVM_count_path filename_NRVM_count];
T_NRVM_Count = readtable(path_filename_NRVM_count,'Delimiter',',', ...
    'Format',formatSpec);
%Create a vector with NRVM count designators
NRVM_Count_Designator = T_NRVM_Count.NRVM_Count_Designator;
N_NRVM_Count = length(NRVM_Count_Designator); %Total number of possible cell counts
NRVM_Count_Num = (1:1:N_NRVM_Count)';

%Format of each column of the cell type helper table:
%Cell_Type_Designator,	Description
formatSpec = '%C%C';
%Ask the user for the file with cell types
[filename_cell, cell_path] = ...
    uigetfile('*.csv','Select a csv file with the CELL TYPE helper table',path_base);

%Read the cell type helper table ignoring the first row
path_filename_cell = [cell_path filename_cell];
T_Cell = readtable(path_filename_cell,'Delimiter',',', ...
    'Format',formatSpec);
%Create a vector with cell type designators
Cell_Designator = T_Cell.Cell_Type_Designator;
N_Cell_Type = length(Cell_Designator); %Total number of cell types
Cell_Num = (1:1:N_Cell_Type)';

%Format of each column of the data type helper table:
%Data_Type_Designator,	Description
formatSpec = '%C%C';
%Ask the user for the file with the data type helper table
[filename_data_type, data_type_path] = ...
    uigetfile('*.csv','Select a csv file with the DATA TYPE helper table',path_base);

%Read the data type helper table ignoring the first row
path_filename_data_type = [data_type_path filename_data_type];
T_Data_Type = readtable(path_filename_data_type,'Delimiter',',', ...
    'Format',formatSpec);
%Create a vector with data type designators
Data_Designator = T_Data_Type.Data_Type_Designator;
Data_Description = T_Data_Type.Description;
N_Data_Type = length(Data_Designator); %Total number of possible data types
Data_Type_Num = (1:1:N_Data_Type)';

%Format of each column of the gas condition helper table:
%Gas Condition Designator,	Gas Condition
formatSpec = '%C%C';
%Ask the user for the file with gas conditions
[filename_gasc, gasc_path] = ...
    uigetfile('*.csv','Select a csv file with the GAS CONDITION helper table',path_base);

%Read the gas condition helper table ignoring the first row
path_filename_gasc = [gasc_path filename_gasc];
T_Gas_Cond = readtable(path_filename_gasc,'Delimiter',',', ...
    'Format',formatSpec);
%Create a vector with gas condition designators
Gas_Condition_Designator = T_Gas_Cond.Gas_Condition_Designator;
Gas_Condition_Description = T_Gas_Cond.Gas_Condition;
N_GasC = length(Gas_Condition_Designator); %Total number of gas conditions
GasC_Num = (1:1:N_GasC)';

%Format of each column of the media type helper table:
%Media Type Designator,	Description, M199, MCSF, IFN-gamma, IL-4, IL-13,
%LPS, SerumFree-LowGlucose (for additives 0 for not present and 1 for present)
formatSpec = '%C%C%C%C%C%C%C%C%C';
%Ask the user for the file with media types
[filename_media, media_path] = ...
    uigetfile('*.csv','Select a csv file with the MEDIA TYPE helper table',path_base);

%Read the media type helper table ignoring the first row
path_filename_media = [media_path filename_media];
T_Media = readtable(path_filename_media,'Delimiter',',', ...
    'Format',formatSpec);
%Create a vector with media type designators
Media_Designator = T_Media.Media_Type_Designator;
N_Media = length(Media_Designator); %Total number of media types
Media_Num = (1:1:N_Media)';

%Format of each column of the protocols helper table:
%Protocol Designator, Gas Condition Designator, O2 Percent, Time,
%Description
formatSpec = '%C%C%C%C%C';
%Ask the user for the file with protocols
[filename_protocol, protocol_path] = ...
    uigetfile('*.csv','Select a csv file with the PROTOCOL helper table',path_base);

%Read the protocol helper table ignoring the first row
path_filename_protocol = [protocol_path filename_protocol];
T_Protocol = readtable(path_filename_protocol,'Delimiter',',', ...
    'Format',formatSpec);
%Create a vector with protocol designators
Protocol_Designator = T_Protocol.Protocol_Designator;
Protocol_Description = T_Protocol.Description;
N_Protocol = length(Protocol_Designator); %Total number of protocols
Protocol_Num = (1:1:N_Protocol)';

%Format of each column of the study type helper table:
%Study_Type_Designator,	Description
formatSpec = '%C%C';
%Ask the user for the file with study types
[filename_study, study_path] = ...
    uigetfile('*.csv','Select a csv file with the STUDY TYPE helper table',path_base);

%Read the study type helper table ignoring the first row
path_filename_study = [study_path filename_study];
T_Study = readtable(path_filename_study,'Delimiter',',', ...
    'Format',formatSpec);
%Create a vector with signaling type designators
Study_Designator = T_Study.Study_Type_Designator;
Study_Description = T_Study.Description;
N_Study = length(Study_Designator); %Total number of study types
Study_Num = (1:1:N_Study)';

%Ask the user to pick an output directory
output_dir = uigetdir(path_base,'Please select the folder with your data base files (i.e. output of this code and the data reading code)...');
filename_well_base = [output_dir '\Data_Locations'];
filename_well_out = [filename_well_base '.mat']; %mat file that will be worked with
filename_well_table_out = [filename_well_base  '.csv']; %csv file that will be loaded into the access database
Cond_File_Name = 'Data_Locations'; %name that will be used for the output file

%Ask user to select root path (drive and parent folder) with analysis
%summary files
data_dir = uigetdir([],'Please select the root path (drive and parent folder) with your data summary files (i.e. z-line detect summary, etc.) ...');

%Check if any of the wells have been previously recorded and a file exists
if exist(filename_well_out, 'file') == 2 %file exists
    load(filename_well_out); %load previous locations into workspace
    Well_ID_Prev = {Well_Data_Loc_Set.WellDataType}; %create a vector with existing well data type IDs
    [temp, exist_well_counter] = size(Well_ID_Prev); %determine the existing number of records
    Well_path_Prev = {Well_Data_Loc_Set.PathFiles}; %create a vector of previously used data file locations
else
    %file does not exist.
    exist_well_counter = 0; %no previous records of locations
    Well_ID_Prev = {};
    Well_path_Prev = {};
end

previous_well_counter = exist_well_counter;
record_another_well = 1; %let the user decide when to stop
DoubleActionChoice = []; %initialize variable to check for duplicates

try %try/catch method included to allow user to generate output files even when code errors out
%loop through different conditions until the user wants to stop
while record_another_well==1
    %Select the signaling type you would like to input
    Combo_For_Disp = table(Study_Num, Study_Designator, Study_Description)
    Study_Index = input('From the list above, select the number of the study type for which you are entering data: ');
    disp(['Chosen study type: ' Study_Designator(Study_Index)])

    %Select the media type you would like to input
    Combo_For_Disp = table(Media_Num, Media_Designator)
    Media_Index = input('From the list above, select the number of the media type for which you are entering data: ');
    disp(['Chosen media type: ' Media_Designator(Media_Index)])

    %Select the cell type you are inputing
    Combo_For_Disp = table(Cell_Num, Cell_Designator);
    if double(isequal(char(Study_Designator(Study_Index)),'Mono')) == 1 %user has selected Mono (monoculture) as the study type
        rows = (Combo_For_Disp.Cell_Designator=='NRVM' | Combo_For_Disp.Cell_Designator=='BMDM'); %find rows with NRVM and BMDM options
        Combo_For_Disp_Mono = Combo_For_Disp(rows,:) %display only NRVM and BMDM as the cell type choices in the table
        Cell_Index = input('From the list above, select the number of the cell type for which you are entering data: ');
        disp(['Chosen cell type: ' Cell_Designator(Cell_Index)])
    else %user has selected Para (paracrine) or Juxt (juxtacrine) signaling as the study type
        rows = (Combo_For_Disp.Cell_Designator=='NRVM_BMDM'); %find row of table with NRVM_BMDM designator
        Cell_Index = find(rows == 1); %automatically set cell type to NRVM_BMDM
        disp('Cell Type: NRVM_BMDM') 
    end

    %Select the NRVM cell count you are inputing
    Combo_For_Disp = table(NRVM_Count_Num, NRVM_Count_Designator);
    if  double(isequal(char(Cell_Designator(Cell_Index)),'BMDM')) == 1 %user has selected BMDM (monoculture) as the cell type
        rows = (Combo_For_Disp.NRVM_Count_Designator=='0K'); %find row of table for 0K designator
        NRVM_Count_Index = find(rows == 1); %automatically set NRVM count to 0
        disp('NRVM cell count: 0' )
    else %user has selected NRVM_BMDM (co-culture) or NRVM (monoculture) as the cell type
        Combo_For_Disp = table(NRVM_Count_Num, NRVM_Count_Designator);
        rows = (Combo_For_Disp.NRVM_Count_Designator=='0K'); %find row of table for 0K designator
        Combo_For_Disp(rows,:) = []; %skip 0K display in table do avoid error in user selection
        Combo_For_Disp
        NRVM_Count_Index = input('From the list above, select the number of the NRVM cell count for which you are entering data: ');
        disp(['Chosen NRVM cell count: ' NRVM_Count_Designator(NRVM_Count_Index)])
    end

    %Select the BMDM cell count you are inputing
    Combo_For_Disp = table(BMDM_Count_Num, BMDM_Count_Designator);
    if  double(isequal(char(Cell_Designator(Cell_Index)),'NRVM')) == 1 %user has selected NRVM (monoculture) as the cell type
        rows = (Combo_For_Disp.BMDM_Count_Designator=='0K'); %find row of table for 0K designator
        BMDM_Count_Index = find(rows == 1); %set BMDM cell count to 0
        disp('BMDM cell count: 0' )
    elseif double(isequal(char(Cell_Designator(Cell_Index)),'BMDM')) == 1 %user has selected BMDM (monoculture) as the cell type
        Combo_For_Disp = table(BMDM_Count_Num, BMDM_Count_Designator);
        rows = (Combo_For_Disp.BMDM_Count_Designator=='0K'); %find row of table for 0K designator
        Combo_For_Disp(rows,:) = []; %skip 0K display in table do avoid error in user selection
        Combo_For_Disp
        BMDM_Count_Index = input('From the list above, select the number of the BMDM cell count for which you are entering data: ');
        disp(['Chosen BMDM cell count: ' BMDM_Count_Designator(BMDM_Count_Index)])
    else
        Combo_For_Disp
        BMDM_Count_Index = input('From the list above, select the number of the BMDM cell count for which you are entering data: ');
        disp(['Chosen BMDM cell count: ' BMDM_Count_Designator(BMDM_Count_Index)])
    end

    %Select the gas condition you are inputing
    Combo_For_Disp = table(GasC_Num, Gas_Condition_Designator, Gas_Condition_Description)
    GasC_Index = input('From the list above, select the number of the gas condition for which you are entering data: ');
    disp(['Chosen gas condition: ' Gas_Condition_Designator(GasC_Index)])

    %Select the protocol you are inputing
    Combo_For_Disp = table(Protocol_Num, Protocol_Designator,Protocol_Description);
    if double(isequal(char(Gas_Condition_Designator(GasC_Index)),'Norm')) == 1 %user has selected Norm (normoxia) as the gas condition type
        rows = contains(string(Combo_For_Disp.Protocol_Designator),'Norm'); %find rows of table for normoxia protocols
        Combo_For_Disp_Norm = Combo_For_Disp(rows,:)
        Protocol_Index = input('From the list above, select the number of the protocol for which you are entering data: ');
        disp(['Chosen protocol: ' Protocol_Designator(Protocol_Index)])
    elseif double(isequal(char(Gas_Condition_Designator(GasC_Index)),'CH')) == 1 %user has selected CH (continuous hypoxia) as the gas condition type
        rows = contains(string(Combo_For_Disp.Protocol_Designator),'CH'); %find rows of table for continuous hypoxia protocols
        Combo_For_Disp_CH = Combo_For_Disp(rows,:)
        Protocol_Index = input('From the list above, select the number of the protocol for which you are entering data: ');
        disp(['Chosen protocol: ' Protocol_Designator(Protocol_Index)])
    else %user has selected IH (intermittent hypoxia) as the gas condition
        rows = contains(string(Combo_For_Disp.Protocol_Designator),'IH'); %find rows of table for intermittent hypoxia protocols
        Combo_For_Disp_CH = Combo_For_Disp(rows,:)
        Protocol_Index = input('From the list above, select the number of the protocol for which you are entering data: ');
        disp(['Chosen protocol: ' Protocol_Designator(Protocol_Index)])
    end

    %loop through wells of same condition until user wants to stop
    Well_input = 1;
    while (Well_input == 1)
        %Create an ID for each well
        %(SignalingType_MediaType_CellType_NRVMCount_MacrophageCount_Protocol_SeedDate_WellNumber)
        Seed_date = '0000000'; %initialize variable for while loop
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
        while (record_another_data_type == 1)
            well_counter = previous_well_counter+1; %use previous counter to ensure that no existing data is overwritten
            %Select the data type you are inputing
            Combo_For_Disp = table(Data_Type_Num, Data_Designator, Data_Description)
            prompt = sprintf('From the list above, select the number of the data type you are entering for well %s of the condition %s_%s_%s_%s_%s: ',char(Well_letter),char(Study_Designator(Study_Index)),char(Media_Designator(Media_Index)),char(Cell_Designator(Cell_Index)),char(NRVM_Count_Designator(NRVM_Count_Index)),char(BMDM_Count_Designator(BMDM_Count_Index)));
            Data_Index = input(prompt);
            disp(['Chosen data type: ' Data_Designator(Data_Index)])

            %Create an ID with the well identifier and data type 
            %(SignalingType_MediaType_CellType_NRVMCount_MacrophageCount_Protocol_SeedDate_WellNumber_DataType)
            Well_ID_Data =[char(Study_Designator(Study_Index)) '_' char(Media_Designator(Media_Index)) '_' char(Cell_Designator(Cell_Index)) '_' char(NRVM_Count_Designator(NRVM_Count_Index)) '_' char(BMDM_Count_Designator(BMDM_Count_Index)) '_' char(Protocol_Designator(Protocol_Index)) '_' char(Seed_date) '_' char(Well_letter) '_' char(Data_Designator(Data_Index))];

            %Clear existing definitions to reset each variable
            clear Data_Fold_num PathFileVec data_path filename_data check_counter Split_path

            %Select file for well data type
            Data_Fold_Well = 0; %initialize
            while Data_Fold_Well == 0 %while loop added to avoid errors if '0' is accidently input for number of analysis folders
            Data_Fold_Well = input('How many analysis folders are you entering for this data type?\n(Unless the analysis code was re-run with different parameters, this should be 1. Entering a value of 0 (ERROR) will prompt you to re-enter the number of folders):');
            end
            for j=well_counter:(well_counter + Data_Fold_Well)-1 %loops through each folder, counter adjusted to account for existing data
                Display_string = ['Select the file with data for the ID ' char(Well_ID_Data)];
                [filename_data, data_path] = ...
                    uigetfile('*.mat', Display_string , data_dir);
                Split_path = split(data_path,':');
                PathFileVec = [Split_path{2} filename_data];
                disp(['Chosen file path (without drive letter): ' PathFileVec])

                %Determine previous number of folders for selected data type and well
                if double(max((startsWith(Well_ID_Prev,Well_ID_Data)))) == 1 %well data type IDs match (can only have 0 or 1 logical output)
                    check_counter = find(startsWith(Well_ID_Prev,Well_ID_Data));
                    for i = 1:length(check_counter)
                        Data_Fold_num(i) = Well_Data_Loc_Set(check_counter(i)).DataFold_Num; %list of previous data folder numbers
                    end
                    Previous_Data_Fold = max(Data_Fold_num); %find previous max data folder number
                    Data_Fold_B = Previous_Data_Fold+1; %start counter from previous maximum
                else
                    Data_Fold_B = j-well_counter+1; %start counter from 1 if data type for entered well and condition does not exist
                end

                Well_Data_Loc_Set(j).AnalysisID = [Well_ID '_' num2str(Data_Fold_B)]; %unqiue ID for each analysis run
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
                Well_Data_Loc_Set(j).PathFiles = PathFileVec;
                Well_Data_Loc_Set(j).UseData = 1; %logical output, 1 if analysis file is to be used, 0 if not to be used 

                %allow user to type in any notes for the entry
                Notes_input = input('Would you like to type any notes for this entry? 0=No, 1=Yes');
                if Notes_input == 1
                    TexttoEnter = input('Type the text you would like to enter:',"s");
                    Well_Data_Loc_Set(j).Notes = TexttoEnter;
                    clear TexttoEnter
                else
                    Well_Data_Loc_Set(j).Notes = {};
                end

                %ERROR CHECKS
                %Check for duplicates (same well ID and path file)
                if any(strcmp(Well_ID_Prev,Well_ID_Data)) %well data type IDs match
                    check_well_counter_1 = find(strcmp(Well_ID_Prev, Well_ID_Data));
                    for n=1:length(check_well_counter_1) %loop through each recognized match in ID
                        if any(strcmpi(Well_path_Prev(check_well_counter_1(n)),PathFileVec)) %path files match
                            DoubleActionChoice = input('An exact duplicate with the same path exists!\n 0=Delete existing duplicate from database\n 1=You made an error in entering data and want to select another file path for the same data type and condition you just entered\n 2=You made an error in entering data and want to select another data type for the condition you just entered (you will be prompted to re-enter the data type, number of analysis folders, and file path)\n 3=You made an error in entering data and want to enter another well for the conditon you just entered (you will be prompted to re-enter the seed date, well number, data type, number of analysis folders, and file path)\n 4=You made an error in entering data and want to enter a different condition (start from scratch)\n 5=exit code\n Choose what you want to do: ');
                            if DoubleActionChoice == 0
                                %delete row for existing duplicate from
                                %database (set as 'deleted directory' in file
                                %path and delete before generating output to
                                %avoid any issues with the counters
                                Well_Data_Loc_Set(check_well_counter_1(n)).WellDataType = [Well_ID_Data '_DUPLICATE']; %since entry is to be deleted, add _DUPLICATE to ID to avoid involving in checks
                                Well_Data_Loc_Set(check_well_counter_1(n)).PathFiles = 'deleted_directory';
                                %update previous files
                                Well_path_Prev = {Well_Data_Loc_Set(1:j-1).PathFiles}; %update data, ensure current entry is not added to avoid errors in checks
                                Well_ID_Prev = {Well_Data_Loc_Set(1:j-1).WellDataType}; %update data, ensure current entry is not added to avoid errors in checks
                            elseif DoubleActionChoice == 1
                                DoubleActionChoice = []; %create empty array to avoid errors in future checks
                                PathFileVec_dup = PathFileVec;
                                while any(strcmpi(Well_path_Prev,PathFileVec_dup))
                                    check_dup = find(strcmpi(Well_path_Prev,PathFileVec_dup));
                                    ERROR = sprintf('The previously selected file already exists for Row %d, please select the correct one',check_dup);
                                    Display_string = ['Select the file with data for the ID ' char(Well_ID_Data)]; %select correct file for selected well data type
                                    [filename_dup, dup_path] = ...
                                        uigetfile('*.mat', Display_string , data_dir);
                                    Split_path_dup = split(dup_path,':'); %split path at drive letter
                                    PathFileVec_dup = [Split_path_dup{2} filename_dup];
                                    Well_Data_Loc_Set(j).PathFiles = PathFileVec_dup;
                                end
                                PathFileVec = PathFileVec_dup;
                                clear filename_dup dup_path PathFileVec_dup check_dup Split_path_dup
                            elseif DoubleActionChoice == 2
                                Well_Data_Loc_Set(j) = []; %delete entered data
                                Well_ID_Data = []; %delete to avoid checks
                                PathFileVec = []; %delete to avoid checks
                                j = j-1; %reset counter to make sure no number is skipped
                                break;
                            elseif DoubleActionChoice == 3
                                Well_Data_Loc_Set(j) = []; %delete entered data
                                Well_ID_Data = []; %delete to avoid checks
                                PathFileVec = []; %delete to avoid checks
                                j = j-1; %reset counter to make sure no number is skipped
                                break;
                            elseif DoubleActionChoice == 4
                                Well_Data_Loc_Set(j) = []; %delete entered data
                                Well_ID_Data = []; %delete to avoid checks
                                PathFileVec = []; %delete to avoid checks
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
                end

                if DoubleActionChoice == 2
                    DoubleActionChoice = []; %create empty array to avoid errors in future checks
                    break; %break from current loop to automatically go to loop for selecting another data type
                elseif DoubleActionChoice == 3
                    break; %break from current loop
                elseif DoubleActionChoice == 4
                    break; %break from current loop
                end

                %Check for error in entering well IDs (same path files but not
                %matching well IDs)
                if any(strcmpi(Well_path_Prev,PathFileVec)) %path files match
                    check_well_counter_3 = find(strcmpi(Well_path_Prev, PathFileVec)); %should be a single row as checks are performed for every entry
                    ID_check = double(any(strcmp(Well_ID_Prev(check_well_counter_3),Well_ID_Data)));
                    if ID_check == 0 %no match in IDs
                        ID_Row = [check_well_counter_3; j];
                        ID_List = {Well_Data_Loc_Set(check_well_counter_3).WellDataType; Well_Data_Loc_Set(j).WellDataType};
                        ID_path = {Well_Data_Loc_Set(check_well_counter_3).PathFiles; Well_Data_Loc_Set(j).PathFiles};
                        ID_DNU = {Well_Data_Loc_Set(check_well_counter_3).UseData; Well_Data_Loc_Set(j).UseData};
                        Combo_For_Disp = table(ID_Row, ID_List, ID_path, ID_DNU) %table for displaying matching file path entries
                        IDAction = input('The entered path file already exists, but the well data IDs do not match.\n 0=Delete one of the records from the database\n 1=Delete both records from the database\n 2=You entered the path file incorrectly and would like to change it for one of the records:');
                        if IDAction == 0
                            %delete selected entry/entries from database (set as 'deleted
                            %directory' in file path and delete before generating
                            %output to avoid any issues with the counters
                            IncorrectIDChoice = input('Choose the row for the incorrect ID to delete it from the database:');
                            Well_Data_Loc_Set(IncorrectIDChoice).PathFiles = 'deleted_directory';
                            Well_Data_Loc_Set(IncorrectIDChoice).WellDataType = [Well_Data_Loc_Set(IncorrectIDChoice).WellDataType '_ERROR']; %since entry is to be deleted, add _ERROR to ID to avoid involving in checks
                            Well_ID_Prev = {Well_Data_Loc_Set(1:j-1).WellDataType}; %update data, ensure current entry is not added to avoid errors in checks
                            Well_path_Prev = {Well_Data_Loc_Set(1:j-1).PathFiles}; %update data, ensure current entry is not added to avoid errors in checks
                        elseif IDAction == 1
                            Well_Data_Loc_Set(check_well_counter_3).PathFiles = 'deleted_directory';
                            Well_Data_Loc_Set(check_well_counter_3).WellDataType = [Well_Data_Loc_Set(check_well_counter_3).WellDataType '_ERROR']; %since entry is to be deleted, add _ERROR to ID to avoid involving in checks
                            Well_Data_Loc_Set(j).PathFiles = 'deleted_directory';
                            Well_Data_Loc_Set(j).WellDataType = [Well_Data_Loc_Set(j).WellDataType '_ERROR']; %since entry is to be deleted, add _DUPLICATE to ID to avoid involving in checks
                            Well_ID_Prev = {Well_Data_Loc_Set(1:j-1).WellDataType}; %update data, ensure current entry is not added to avoid errors in checks
                            Well_path_Prev = {Well_Data_Loc_Set(1:j-1).PathFiles}; %update data, ensure current entry is not added to avoid errors in checks
                        else
                            NewFileRow = input('Choose the row for which you would like to enter a new path:');
                            PathFileVec_n = Well_Data_Loc_Set(NewFileRow).PathFiles;
                            while any(strcmpi(Well_path_Prev,PathFileVec_n))
                                check_n = find(strcmpi(Well_path_Prev,PathFileVec_n));
                                ERROR = sprintf('The previously selected file already exists for Row %d, please select the correct one',check_n);
                                Display_string = ['Select the new file for ' char(Well_Data_Loc_Set(NewFileRow).WellDataType)]; %select correct file for selected well data type
                                [filename_new, new_path] = ...
                                    uigetfile('*.mat', Display_string , data_dir);
                                Split_path_new = split(new_path,':'); %split at drive letter
                                PathFileVec_n = [Split_path_new{2} filename_new];
                                Well_Data_Loc_Set(NewFileRow).PathFiles = PathFileVec_n;
                                if NewFileRow == j
                                    PathFileVec = PathFileVec_n;
                                else
                                end
                            end
                            clear filename_new new_path PathFileVec_n check_n Split_path_new
                            Well_ID_Prev = {Well_Data_Loc_Set(1:j-1).WellDataType}; %update data, ensure current entry is not added to avoid errors in checks
                            Well_path_Prev = {Well_Data_Loc_Set(1:j-1).PathFiles}; %update data, ensure current entry is not added to avoid errors in checks
                        end
                    clear ID_row ID_list ID_path ID_DNU
                    else %separate check above for match in IDs and path files
                    end
                clear ID_check check_well_counter_3
                else
                end
                
                %Check for multiple analysis files of entered well condition and data type (same well data type ID but not path file)
                if any(strcmp(Well_ID_Prev,Well_ID_Data)) %well data type IDs match
                    check_well_counter_2 = find(strcmp(Well_ID_Prev, Well_ID_Data));
                    for k=1:length(check_well_counter_2)
                        Path_check(k) = double(any(strcmpi(Well_path_Prev(check_well_counter_2(k)),PathFileVec)));
                    end
                    if Path_check == 0 %no match in file paths
                        well_cond_row = [find(strcmp(Well_ID_Prev, Well_ID_Data)), j]';
                        Path_file_row = [{Well_Data_Loc_Set(well_cond_row).PathFiles}]';
                        UseData_row = [Well_Data_Loc_Set(well_cond_row).UseData]';
                        Notes_row = [{Well_Data_Loc_Set(well_cond_row).Notes}]';
                        Combo_For_Disp = table(well_cond_row,Path_file_row,UseData_row,Notes_row) %create table for display with same IDs but differing file paths
                        PrimaryChoice = input('Data for this well already exists!\nSelect the well condition row of the file you would like to use as the primary set (all other entries with the same well ID will be automatically assigned a 0 in the UseData column):');
                        Well_Data_Loc_Set(PrimaryChoice).UseData = 1;
                        UseData_row(find(well_cond_row == PrimaryChoice)) = 1; %update display table with primary selection

                        well_cond_row2 = well_cond_row;
                        well_cond_row2(find(well_cond_row2 == PrimaryChoice)) = []; %isolate row numbers which were not assigned as primary
                        for i = 1:length(well_cond_row2)
                        Well_Data_Loc_Set(well_cond_row2(i)).UseData = 0;
                        end
                        for i = 1:length(well_cond_row2)
                        UseData_row(find(well_cond_row == well_cond_row2(i))) = 0; %update display table with primary selection
                        end

                        Enter_notes_q = input('Would you like to enter notes for any of the well condition rows? 0=No, 1=Yes');
                        if Enter_notes_q == 1
                            Enter_notes = 1;
                            while Enter_notes == 1 %allow user to loop through rows to enter notes
                                Combo_For_Disp
                                NotesChoice = input('Select the well condition row for which you would like to enter notes:');
                                NotesText = input('Type the text you would like to enter:',"s");
                                if double(isempty(Well_Data_Loc_Set(NotesChoice).Notes)) == 1 %notes column is empty
                                    Well_Data_Loc_Set(NotesChoice).Notes = NotesText;
                                else
                                    Well_Data_Loc_Set(NotesChoice).Notes = {Well_Data_Loc_Set(NotesChoice).Notes NotesText};
                                    Well_Data_Loc_Set(NotesChoice).Notes = strjoin(Well_Data_Loc_Set(NotesChoice).Notes, '. '); %combine entered text with previously entered text to prevent overwriting
                                end
                                clear NotesText
                                Notes_row(find(well_cond_row == NotesChoice)) = {Well_Data_Loc_Set(NotesChoice).Notes}; %update table for display with entered notes
                                Enter_notes = input('Would you like to enter notes for another well condition row? 0=No, 1=Yes:');
                            end
                        else
                        end
                        clear well_cond_row Path_file_row UseData_row Notes_row 
                    else %separate check above for match in IDs and file paths
                    end
                    clear Path_check check_well_counter_2
                end
                %END OF CHECKS

                %update previous to include recent entry (will be used in checks for next selection)
                Well_ID_Prev = {Well_Data_Loc_Set.WellDataType};
                Well_path_Prev = {Well_Data_Loc_Set.PathFiles};
            end


            %record another data type
            if DoubleActionChoice == 3
                DoubleActionChoice = []; %create empty array to avoid errors in future checks
                break; %break from current loop to automatically go to loop for selecting another well number
            elseif DoubleActionChoice == 4
                break; %break from current loop
            end
            record_another_data_type = input('Would you like to enter another data type for this well? 0=No, 1=Yes:');
            previous_well_counter = j; %update previous well counter to avoid overwriting existing data
        end
        if DoubleActionChoice == 4
            DoubleActionChoice = []; %create empty array to avoid errors in future checks
            break; %break from current loop to automatically go to loop for selecting another condition
        end
        Well_input = input('Would you like to enter another well and/or seed date for this condition? 0=No, 1=Yes');
    end
    record_another_well = input('Would you like to enter data for another condition? 0=No, 1=Yes:');
end

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
[C, ~, ic] = unique(lower({Well_Data_Loc_Set.PathFiles}),'stable');
RowValues = find(ismember(lower({Well_Data_Loc_Set.PathFiles}), C(accumarray(ic,1)>1))); %find the indices of any matches
if RowValues ~= 0
    Entry_Row = RowValues';
    WellID_Row = [{Well_Data_Loc_Set(Entry_Row).WellDataType}]';
    Path_File_Row = [{Well_Data_Loc_Set(Entry_Row).PathFiles}]';
    clear Combo_For_Disp
    Combo_For_Disp = table(Entry_Row,WellID_Row,Path_File_Row);
    rows = find(strcmp(Combo_For_Disp.Path_File_Row,'deleted_directory')); %find rows with deleted directory
    Combo_For_Disp(rows,:) = []; %skip deleted directory display in table to only show actual file duplicates
    if double(isempty(Combo_For_Disp)) == 0 
        Combo_For_Disp
        disp('There are still matches in the file paths. You will now be prompted to delete any incorrect entries from the database; press the ENTER key to continue:');
        pause; %introduce pause to allow user to see errors, press the enter key to continue
    else
    end
else
end


%Ask to delete any files from database
DeleteAction = input('Would you like to delete any records from the database?\n(Do not delete files if the data is not to be used; this option is mainly for errors in entering condition/location information into the database): 0=No, 1=Yes:');
while DeleteAction == 1 %allow user to loop through and select multiple rows to delete
    Table = struct2table(Well_Data_Loc_Set,"AsArray",true);
    disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries (this is an intermediate output, and rows to be deleted will have deleted_directory in the PathFiles column)'); disp('Back in the editor, press continue to resume running of the code, where you will be prompted to enter a row number')
    keyboard
    Delete_row = input('Select the row number of the record you would like to delete:');
    ID_row = {Well_Data_Loc_Set(Delete_row).WellDataType};
    File_row = {Well_Data_Loc_Set(Delete_row).PathFiles};
    Combo_For_Disp = table(Delete_row,ID_row,File_row) %make table of all ID data types and file paths
    Confirmation = input('Confirm that this is the record you want to delete. 0=No 1=Yes');
    if Confirmation == 1
        Well_Data_Loc_Set(Delete_row).PathFiles = 'deleted_directory';
        Well_ID_Prev = {Well_Data_Loc_Set.WellDataType}; %update to account for changes
        Well_path_Prev = {Well_Data_Loc_Set.PathFiles}; %update to account for changes
    else
    end
    DeleteAction = input('Would you like to delete any other records from the database? 0=No, 1=Yes:');
end


%Erase all deleted records from database
if any(strcmp(Well_path_Prev,'deleted_directory'))
    delete_counter = find(strcmp(Well_path_Prev,'deleted_directory'));
    deleted_IDs = {Well_Data_Loc_Set(delete_counter).WellDataType}; %well ID data types to be deleted
    deleted_Datafold = [Well_Data_Loc_Set(delete_counter).DataFold_Num]; %well ID folder numbers to be deleted
    Well_Data_Loc_Set(delete_counter) = [];
    Well_ID_Prev = {Well_Data_Loc_Set.WellDataType};
    for p=1:length(deleted_IDs)
        Fold_to_delete = deleted_Datafold(p);
        if double(endsWith(deleted_IDs(p),'_DUPLICATE')) == 1
            deleted_IDs(p) = extractBefore(deleted_IDs(p),'_DUPLICATE');
        elseif double(endsWith(deleted_IDs(p),'_ERROR')) == 1
            deleted_IDs(p) = extractBefore(deleted_IDs(p),'_ERROR');
        else
        end
        check_well_counter_4 = find(strcmp(Well_ID_Prev, deleted_IDs(p)));
        Fold_to_reset = [Well_Data_Loc_Set(check_well_counter_4).DataFold_Num];
        Data_fold_reset = find(Fold_to_reset>Fold_to_delete); %find which folders and analysis IDs need to be reset
        if Data_fold_reset ~= 0
            for h=1:length(Data_fold_reset)
                Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).DataFold_Num = Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).DataFold_Num-1;
                clear ID_partial
                if double(isequal(char(Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).Data_Type),'ZLDet')) == 1
                    ID_partial = extractBefore(Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).WellDataType,'_ZLDet'); %well ID
                    Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).AnalysisID = [ID_partial '_' num2str(Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).DataFold_Num)];
                else %code for other data types
                end
            end
        else
        end
    end
end

%Confirmation to make sure there are no repeating file paths
[B, ~, ib] = unique(lower({Well_Data_Loc_Set.PathFiles}),'stable');
RowValuesb = find(ismember(lower({Well_Data_Loc_Set.PathFiles}), B(accumarray(ib,1)>1)));
if double(isempty(RowValuesb)) == 1 %no match in file paths detected
    disp('FINAL CHECK: There are no matches in the file paths')
else
    disp('ERROR: There is still a match in file paths. Analyze output file to locate the error and erase from the database.')
end

filename_well_out = [output_dir '\' Cond_File_Name '.mat']; %mat file that will be worked with (updated every iteration of code)
save(filename_well_out,'Well_Data_Loc_Set') %save as mat file (updated every iteration of code)

%files with time stamps (check how data is updated with each run of code
%and fallback for any errors in code iteration)
filename_well_out_time = [output_dir '\' Cond_File_Name time_stamp '.mat']; %mat file that will be worked with
save(filename_well_out_time,'Well_Data_Loc_Set') %save as mat file

%save the table as a csv file for visual checks
T = struct2table(Well_Data_Loc_Set,"AsArray",true);
filename_table_out_con = [output_dir '\Data_Locations_Table.csv'];
filename_table_out = [output_dir '\Data_Locations_Table' time_stamp '.csv'];
writetable(T,filename_table_out_con);
writetable(T,filename_table_out);

catch ME %steps taken if code errors out due to invalid input
    disp('The code errored out during execution of the script. A description of the error is provided in the output ME in the workspace.'); disp('To avoid loss of previous entries during this run, the output files will be generated after selection of any records that you do not want to use or delete');
    disp('Press ENTER to continue');
    pause
    Well_ID_Prev = {Well_Data_Loc_Set.WellDataType};
    Well_path_Prev = {Well_Data_Loc_Set.PathFiles};
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
    [C, ~, ic] = unique(lower({Well_Data_Loc_Set.PathFiles}),'stable'); %since file naming is not case sensitive, convert file path to all lower for checks
    RowValues = find(ismember(lower({Well_Data_Loc_Set.PathFiles}), C(accumarray(ic,1)>1))); %find the indices of any matches
    if RowValues ~= 0
        Entry_Row = RowValues';
        WellID_Row = [{Well_Data_Loc_Set(Entry_Row).WellDataType}]';
        Path_File_Row = [{Well_Data_Loc_Set(Entry_Row).PathFiles}]';
        clear Combo_For_Disp
        Combo_For_Disp = table(Entry_Row,WellID_Row,Path_File_Row);
        rows = find(strcmp(Combo_For_Disp.Path_File_Row,'deleted_directory')); %find rows with deleted directory
        Combo_For_Disp(rows,:) = []; %skip deleted directory display in table to only show actual file duplicates
        if double(isempty(Combo_For_Disp)) == 0
            Combo_For_Disp
            disp('There are still matches in the file paths. You will now be prompted to delete any incorrect entries from the database; press the ENTER key to continue:');
            pause; %introduce pause to allow user to see errors, press the enter key to continue
        else
        end
    else
    end


    %Ask to delete any files from database
    DeleteAction = input('Would you like to delete any records from the database?\n(Do not delete files if the data is not to be used; this option is mainly for errors in entering condition/location information into the database): 0=No, 1=Yes:');
    while DeleteAction == 1 %allow user to loop through and select multiple rows to delete
        Table = struct2table(Well_Data_Loc_Set,"AsArray",true);
        disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries (this is an intermediate output, and rows to be deleted will have deleted_directory in the PathFiles column)'); disp('Back in the editor, press continue to resume running of the code, where you will be prompted to enter a row number')
        keyboard
        Delete_row = input('Select the row number of the record you would like to delete:');
        ID_row = {Well_Data_Loc_Set(Delete_row).WellDataType};
        File_row = {Well_Data_Loc_Set(Delete_row).PathFiles};
        Combo_For_Disp = table(Delete_row,ID_row,File_row) %make table of all ID data types and file paths
        Confirmation = input('Confirm that this is the record you want to delete. 0=No 1=Yes');
        if Confirmation == 1
            Well_Data_Loc_Set(Delete_row).PathFiles = 'deleted_directory';
            Well_ID_Prev = {Well_Data_Loc_Set.WellDataType}; %update to account for changes
            Well_path_Prev = {Well_Data_Loc_Set.PathFiles}; %update to account for changes
        else
        end
        DeleteAction = input('Would you like to delete any other records from the database? 0=No, 1=Yes:');
    end


    %Erase all deleted records from database
    if any(strcmp(Well_path_Prev,'deleted_directory'))
        delete_counter = find(strcmp(Well_path_Prev,'deleted_directory'));
        deleted_IDs = {Well_Data_Loc_Set(delete_counter).WellDataType}; %well ID data types to be deleted
        deleted_Datafold = [Well_Data_Loc_Set(delete_counter).DataFold_Num]; %well ID folder numbers to be deleted
        Well_Data_Loc_Set(delete_counter) = [];
        Well_ID_Prev = {Well_Data_Loc_Set.WellDataType};
        for p=1:length(deleted_IDs)
            Fold_to_delete = deleted_Datafold(p);
            if double(endsWith(deleted_IDs(p),'_DUPLICATE')) == 1
                deleted_IDs(p) = extractBefore(deleted_IDs(p),'_DUPLICATE');
            elseif double(endsWith(deleted_IDs(p),'_ERROR')) == 1
                deleted_IDs(p) = extractBefore(deleted_IDs(p),'_ERROR');
            else
            end
            check_well_counter_4 = find(strcmp(Well_ID_Prev, deleted_IDs(p)));
            Fold_to_reset = [Well_Data_Loc_Set(check_well_counter_4).DataFold_Num];
            Data_fold_reset = find(Fold_to_reset>Fold_to_delete); %find which folders and analysis IDs need to be reset
            if Data_fold_reset ~= 0
                for h=1:length(Data_fold_reset)
                    Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).DataFold_Num = Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).DataFold_Num-1;
                    clear ID_partial
                    if double(isequal(char(Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).Data_Type),'ZLDet')) == 1
                        ID_partial = extractBefore(Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).WellDataType,'_ZLDet'); %well ID
                        Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).AnalysisID = [ID_partial '_' num2str(Well_Data_Loc_Set(check_well_counter_4(Data_fold_reset(h))).DataFold_Num)];
                    else %code for other data types
                    end
                end
            else
            end
        end
    end

    %Confirmation to make sure there are no repeating file paths
    [B, ~, ib] = unique(lower({Well_Data_Loc_Set.PathFiles}),'stable'); %since file naming is not case sensitive, convert file path to all lower for checks
    RowValuesb = find(ismember(lower({Well_Data_Loc_Set.PathFiles}), B(accumarray(ib,1)>1)));
    if double(isempty(RowValuesb)) == 1 %no match in file paths detected
        disp('FINAL CHECK: There are no matches in the file paths')
    else
        disp('ERROR: There is still a match in file paths. Analyze output file to locate the error and erase from the database.')
    end

    filename_well_out = [output_dir '\' Cond_File_Name '.mat']; %mat file that will be worked with (updated every iteration of code)
    save(filename_well_out,'Well_Data_Loc_Set') %save as mat file (updated every iteration of code)

    %files with time stamps (check how data is updated with each run of code
    %and fallback for any errors in code iteration)
    filename_well_out_time = [output_dir '\' Cond_File_Name time_stamp '.mat']; %mat file that will be worked with
    save(filename_well_out_time,'Well_Data_Loc_Set') %save as mat file

    %save the table as a csv file for visual checks
    T = struct2table(Well_Data_Loc_Set,"AsArray",true);
    filename_table_out_con = [output_dir '\Data_Locations_Table.csv'];
    filename_table_out = [output_dir '\Data_Locations_Table' time_stamp '.csv'];
    writetable(T,filename_table_out_con);
    writetable(T,filename_table_out);
end


