%Author: Nida Qayyum
%Data reading code for conditions and locations output from Location_Code

%The outputs of this code are .mat and .csv files named ZLD_Analysis_Data and Contractility_Data with a time stamp to keep track of the database changes with each code run

%The files 'ZLD_Analysis_Data' and 'Contractility_Data' (without time stamp) contain the most recently
%updated information

%Date updated: 08/30/24 (updated version of 'Data_Reading_Code_8_15_24', removed option to manually adjust primacy and the following primacy check (these options are still present in the 8_15_24 version) and added in code to produce output with film numbers, notes, and UseData changes)

clear; clc;

%Generate a time stamp for the file name
c = datetime;
cc = datevec(c);
time_stamp = [num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(round(cc(6)))];

%%%% LOADING REQUIRED INFORMATION %%%%
[filename_loc, loc_path] = ...
    uigetfile('*.mat','Select the .mat file output of Location_Code (i.e. Data_Locations.mat)',[]);
filename_well_out = [loc_path filename_loc]; %path of .mat file to be loaded into workspace
path_base = loc_path; %set the previous folder to be the current base folder
output_dir = uigetdir(path_base,'Please select an output directory with your database files (i.e. Data_Locations.mat, etc)...');

load(filename_well_out) %load condition and path data into workspace (output of Location_Code)

%Add all data storage drives to MATLAB path
Drive_num = input('How many drives are your data analysis files (Z-line detect summary files, images, contractility data, etc.) stored on?');
for d=1:Drive_num %cycle through each drive
    clear Display_string
    Display_string = ['Select the root data folder for Drive ' num2str(d)];
    Root_path{d} = uigetdir([],Display_string);
    Split_drive_path{d} = split(Root_path{d},':');
    addpath(genpath(Root_path{d}))
end

%Extract data from Location_Code output
AnalysisID_vec = {Well_Data_Loc_Set.AnalysisID};
WellID_vec = {Well_Data_Loc_Set.WellID};
StudyType_vec = {Well_Data_Loc_Set.Study_Type};
MediaType_vec = {Well_Data_Loc_Set.Media_Type};
CellType_vec = {Well_Data_Loc_Set.Cell_Type};
NRVM_vec = {Well_Data_Loc_Set.NRVM_Count};
BMDM_vec = {Well_Data_Loc_Set.BMDM_Count};
Protocol_vec = {Well_Data_Loc_Set.Protocol};
SeedDate_vec = {Well_Data_Loc_Set.Seed_Date};
DataType_vec = {Well_Data_Loc_Set.Data_Type};
FoldNum_vec = {Well_Data_Loc_Set.DataFold_Num};
WellLetter_vec = {Well_Data_Loc_Set.Well_Letter};
UseData_vec = {Well_Data_Loc_Set.UseData};
Notes_vec = {Well_Data_Loc_Set.Notes};
Pathfiles_vec = {Well_Data_Loc_Set.PathFiles};
UDO_vec = {Well_Data_Loc_Set.UDO};

%% STRUCTURAL DATABASE (DATA FROM Z-LINE DETECTION)
Struct_data = find(contains(string(DataType_vec),'ZLDet')); %rows from Location_Code output with structural data 
Num_Sdata = length(Struct_data); %total number of structural data files to be read

if Num_Sdata ~=0 %structural data exists in Location_Code
for j=1:Num_Sdata %loop through each entry with structural data 
    %Populate output structure with condition data (from Location_Code)
    Well_Data_Set_ZLD(j).AnalysisID = AnalysisID_vec(Struct_data(j));
    Well_Data_Set_ZLD(j).WellID = WellID_vec(Struct_data(j));
    Well_Data_Set_ZLD(j).Study_Type = StudyType_vec{Struct_data(j)}; %curly brackets to ensure output is categorical
    Well_Data_Set_ZLD(j).Media_Type = MediaType_vec{Struct_data(j)};
    Well_Data_Set_ZLD(j).Cell_Type = CellType_vec{Struct_data(j)};
    Well_Data_Set_ZLD(j).NRVM_Count = NRVM_vec{Struct_data(j)};
    Well_Data_Set_ZLD(j).BMDM_Count = BMDM_vec{Struct_data(j)};
    Well_Data_Set_ZLD(j).Protocol = Protocol_vec{Struct_data(j)};
    Well_Data_Set_ZLD(j).Seed_Date = SeedDate_vec{Struct_data(j)};
    Well_Data_Set_ZLD(j).Well_Letter = WellLetter_vec(Struct_data(j));
    Well_Data_Set_ZLD(j).Data_Type = DataType_vec{Struct_data(j)};
    Well_Data_Set_ZLD(j).DataFold_Num = FoldNum_vec(Struct_data(j));
    Well_Data_Set_ZLD(j).UseData = UseData_vec(Struct_data(j));
    Well_Data_Set_ZLD(j).Notes = Notes_vec(Struct_data(j));

    %Populate output structure with structural data (output from Z-line Detection) 
    Partial_path = char(Pathfiles_vec(Struct_data(j))); %path without drive letter
    Current_directory = pwd;
    Current_directory_split = split(Current_directory,':'); %split directory into drive letter and remaining path

    file_exist = exist([Current_directory_split{1} ':' Partial_path],'file'); %check if data file exists in current drive
    if file_exist == 0 %change drive if file does not exist
    for d=1:Drive_num
        cd([Split_drive_path{d}{1} ':']) %change drive
        file_exist = exist([Split_drive_path{d}{1} ':' Partial_path],'file'); %check if file exists in new drive
        if file_exist == 2 %file exists
            Current_directory = pwd;
            Current_directory_split = split(Current_directory,':');
            break %break out of loop to prevent cycling through remaining drives
        else %go to next drive
        end
    end
    else %continue with code if file exists
    end
    load(Partial_path,'CS_results','settings'); %load data file into workspace
    Well_Data_Set_ZLD(j).Zline_Fraction = CS_results.CS_zlinefrac;
    Well_Data_Set_ZLD(j).Zline_OOP = CS_results.CS_OOPs;
    Well_Data_Set_ZLD(j).Zline_Angle_Count = CS_results.angle_count;
    Well_Data_Set_ZLD(j).Actin_OOP = CS_results.ACTINCS_OOPs;
    Well_Data_Set_ZLD(j).Actin_Angle_Count = CS_results.ACTINangle_count;
    avg_sarcd = mean(vertcat(CS_results.FOV_sarcdistance{:}));
    Well_Data_Set_ZLD(j).Average_Sarcdistance = avg_sarcd;
    Well_Data_Set_ZLD(j).ContL_Median = CS_results.CS_medians;
    Well_Data_Set_ZLD(j).ContL_Mean = CS_results.CS_means;
    
    [Image_folder_path, ~, ~] = fileparts(Partial_path); %splits into file path, file name, and extension
    Image_Analysis_Output = [Current_directory_split{1} ':' Image_folder_path '\Image_Analysis_Outputs.mat']; %file path for image analysis output (Confluency and Diffuse AA Fraction)
    if exist(Image_Analysis_Output,'file') == 0 %file with saved image analysis outputs does not exist
        [TotalPixels, TotalPixels_AA] = Confluency_background(CS_results,Current_directory_split{1},char(Pathfiles_vec(Struct_data(j))));
        Well_Data_Set_ZLD(j).Total_Pixels = TotalPixels;
        Well_Data_Set_ZLD(j).AA_Pixels = TotalPixels_AA;
        AA_Confluency = (TotalPixels_AA/TotalPixels)*100;
        Well_Data_Set_ZLD(j).AA_Confluency = AA_Confluency;
        [Overlay_int, AA_int] = Diffusefrac_mCherry(CS_results,Current_directory_split{1},char(Pathfiles_vec(Struct_data(j))));
        shadow = 0.88; %shadow of signal around zline in microns (must be determined for each microscope)
        Diffuse_AA_Fraction = 1-(Overlay_int*shadow*settings.pix2um/AA_int);
        NonDiffuse_AA_Fraction = 1 - Diffuse_AA_Fraction;
        Well_Data_Set_ZLD(j).Diffuse_AA_Fraction = Diffuse_AA_Fraction;
        Well_Data_Set_ZLD(j).NonDiffuse_AA_Fraction = NonDiffuse_AA_Fraction;
        save(Image_Analysis_Output,'TotalPixels','TotalPixels_AA','AA_Confluency','Overlay_int','AA_int','Diffuse_AA_Fraction','NonDiffuse_AA_Fraction');
    else %file with image analysis output already exists
        load(Image_Analysis_Output);
        Well_Data_Set_ZLD(j).Total_Pixels = TotalPixels;
        Well_Data_Set_ZLD(j).AA_Pixels = TotalPixels_AA;
        Well_Data_Set_ZLD(j).AA_Confluency = AA_Confluency;
        Well_Data_Set_ZLD(j).Diffuse_AA_Fraction = Diffuse_AA_Fraction;
        Well_Data_Set_ZLD(j).NonDiffuse_AA_Fraction = NonDiffuse_AA_Fraction;
    end
    
    Well_Data_Set_ZLD(j).Threshold = CS_results.CS_thresholds;
    Well_Data_Set_ZLD(j).Gridsize = CS_results.CS_gridsizes;

    clear CS_results TotalPixels TotalPixels_AA AA_Confluency avg_sarcd settings Overlay_int AA_int Partial_path Image_Analysis_Output Diffuse_AA_Fraction Image_folder_path %clear each file and variable after recording data to save memory
end

cd(output_dir) %switch to output directory

ZLD_Data_File_Name = 'ZLD_Analysis_Data';
filename_data_out = [output_dir '\' ZLD_Data_File_Name '.mat']; %.mat file that will be worked with (updated every iteration of code)
save(filename_data_out,'Well_Data_Set_ZLD') %save as .mat file (updated every iteration of code)

%files with time stamps (check how data is updated with each run of code and fallback for any errors in code iteration)
filename_data_out_time = [output_dir '\' ZLD_Data_File_Name time_stamp '.mat']; %.mat file that will be worked with
save(filename_data_out_time,'Well_Data_Set_ZLD') %save as .mat file

%save as .sv files for visual checks
T = struct2table(Well_Data_Set_ZLD,"AsArray",true);
filename_table_out_con = [output_dir '\ZLD_Analysis_Data_Table.csv']; %to be used with Microsoft Access
filename_table_out = [output_dir '\ZLD_Analysis_Data_Table_' time_stamp '.csv'];
writetable(T,filename_table_out);
writetable(T,filename_table_out_con);

disp('The output database files for structural data have been saved to the selected output directory.')
end

%% CONTRACTILITY DATA OUTPUT
Contract_data = find(contains(string(DataType_vec),'Cont')); %rows from Location_Code with contractility data
Num_Cdata = length(Contract_data); %total number of contractility data files

if Num_Cdata ~=0
    Film_Data_Set = Contractility_Data_Extraction_7_29_24(AnalysisID_vec,WellID_vec,StudyType_vec,MediaType_vec,CellType_vec,NRVM_vec,BMDM_vec,Protocol_vec,SeedDate_vec,DataType_vec,FoldNum_vec,WellLetter_vec,Pathfiles_vec,UDO_vec,Drive_num,Split_drive_path); %run function to extract film data 
    Film_Well_ID_vec = string({Film_Data_Set.WellID});
    Film_Side_vec = string({Film_Data_Set.Top_Bottom});
    Cond_vec = string({Film_Data_Set.Cond_Name});
    Film_Abs_vec = cell2mat({Film_Data_Set.Film_Abs_Num});
    Frequency_vec = cell2mat({Film_Data_Set.Frequency});
    Voltage_vec = cell2mat({Film_Data_Set.Voltage});
    PathFiles_Cont = string({Film_Data_Set.PathFiles});

    File_Name = 'Film_Num_Changes'; %name that will be used for the film number changes log file
    filename_film = [output_dir '\' File_Name '.mat']; %.mat file
    
    File_Name = 'UseData_Changes'; %name that will be used for the UseData changes log file
    filename_UseData = [output_dir '\' File_Name '.mat']; %.mat file
    
    File_Name = 'Notes_Changes'; %name that will be used for the Notes changes log file
    filename_Notes = [output_dir '\' File_Name '.mat']; %.mat file

    %%% LOAD LOGS OF CHANGES %%%%
    %Check if any changes have been previously made
    if exist(filename_film, 'file') == 2 %previous output exists
        load(filename_film); %load previous changes into workspace
        Well_ID_prev_film = {Film_Num_Changes.WellID};
        [temp, previous_counter_film_num] = size(Well_ID_prev_film); %determine the existing number of records
    else
        %file does not exist.
        previous_counter_film_num = 0; %no previous records of changes
    end
    film_num_changes_counter = previous_counter_film_num + 1;

    if exist(filename_UseData, 'file') == 2 %previous output exists
        load(filename_UseData); %load previous changes into workspace
        Well_ID_prev_UseData = {UseData_Changes.WellID};
        [temp, previous_counter_UseData] = size(Well_ID_prev_UseData); %determine the existing number of records
    else
        %file does not exist.
        previous_counter_UseData = 0; %no previous records of changes
    end
    UseData_changes_counter = previous_counter_UseData + 1;

    if exist(filename_Notes, 'file') == 2 %previous output exists
        load(filename_Notes); %load previous changes into workspace
        Well_ID_prev_Notes = {Notes_Changes.WellID};
        [temp, previous_counter_Notes] = size(Well_ID_prev_Notes); %determine the existing number of records
    else
        %file does not exist.
        previous_counter_Notes = 0; %no previous records of changes
    end
    Notes_changes_counter = previous_counter_Notes + 1;

    %%% UPDATE DATA SET WITH PREVIOUS CHANGES %%% %important as code is run from the top every time
    for i=1:previous_counter_film_num %cycle through previous changes made by user to relative film number
        RowsUpdate = find(strcmp(Film_Well_ID_vec,Film_Num_Changes(i).WellID) & Film_Side_vec == Film_Num_Changes(i).Top_Bottom & Film_Abs_vec == Film_Num_Changes(i).Film_Num_Abs & strcmp(PathFiles_Cont,Film_Num_Changes(i).FilePath)); %find all data rows for selected film and file
        for j=1:length(RowsUpdate)
            Film_Data_Set(RowsUpdate(j)).FilmNum_Side = Film_Num_Changes(i).FilmNum_Side_New;
            Film_Data_Set(RowsUpdate(j)).Film_ID = [char(Film_Data_Set(RowsUpdate(j)).Analysis_ID) '_' Film_Data_Set(RowsUpdate(j)).Cond_Name '_' char(Film_Data_Set(RowsUpdate(j)).Top_Bottom) '_' num2str(Film_Data_Set(RowsUpdate(j)).FilmNum_Side)];
            Film_Data_Set(RowsUpdate(j)).Adjusted_FilmNum = 1;
            if double(isempty(Film_Data_Set(RowsUpdate(j)).Notes)) == 1 && double(isempty(Film_Num_Changes(i).Notes_Added)) == 0 %notes column is empty
                Film_Data_Set(RowsUpdate(j)).Notes = Film_Num_Changes(i).Notes_Added;
            elseif double(isempty(Film_Data_Set(RowsUpdate(j)).Notes)) == 0 && double(isempty(Film_Num_Changes(i).Notes_Added)) == 0
                Film_Data_Set(RowsUpdate(j)).Notes = {Film_Data_Set(RowsUpdate(j)).Notes Film_Num_Changes(i).Notes_Added};
                Film_Data_Set(RowsUpdate(j)).Notes = strjoin(Film_Data_Set(RowsUpdate(j)).Notes, '. '); %combine currently entered text with previous text to avoid overwriting
            end
        end
    end
    
    for i=1:previous_counter_UseData %cycle through previous changes made by user to UseData designation
        RowsUpdate = find(strcmp(Film_Well_ID_vec,UseData_Changes(i).WellID) & strcmp(Cond_vec,UseData_Changes(i).Cond_Name) & Film_Side_vec == UseData_Changes(i).Top_Bottom & Film_Abs_vec == UseData_Changes(i).Film_Num_Abs & strcmp(PathFiles_Cont,UseData_Changes(i).FilePath)); %find data row
        Film_Data_Set(RowsUpdate).UseData = UseData_Changes(i).UseData_New;
        if double(isempty(Film_Data_Set(RowsUpdate).Notes)) == 1 && double(isempty(UseData_Changes(i).Notes_Added)) == 0 %notes column is empty
            Film_Data_Set(RowsUpdate).Notes = UseData_Changes(i).Notes_Added;
        elseif double(isempty(Film_Data_Set(RowsUpdate).Notes)) == 0 && double(isempty(UseData_Changes(i).Notes_Added)) == 0
            Film_Data_Set(RowsUpdate).Notes = {Film_Data_Set(RowsUpdate).Notes UseData_Changes(i).Notes_Added};
            Film_Data_Set(RowsUpdate).Notes = strjoin(Film_Data_Set(RowsUpdate).Notes, '. '); %combine currently entered text with previous text to avoid overwriting
        end
    end

    for i=1:previous_counter_Notes %cycle through previous changes made by user to UseData designation
        RowsUpdate = find(strcmp(Film_Well_ID_vec,Notes_Changes(i).WellID) & strcmp(Cond_vec,Notes_Changes(i).Cond_Name) & Film_Side_vec == Notes_Changes(i).Top_Bottom & Film_Abs_vec == Notes_Changes(i).Film_Num_Abs & strcmp(PathFiles_Cont,Notes_Changes(i).FilePath)); %find data row
        if double(isempty(Film_Data_Set(RowsUpdate).Notes)) == 1 && double(isempty(Notes_Changes(i).Notes_Added)) == 0 %notes column is empty
            Film_Data_Set(RowsUpdate).Notes = Notes_Changes(i).Notes_Added;
        elseif double(isempty(Film_Data_Set(RowsUpdate).Notes)) == 0 && double(isempty(Notes_Changes(i).Notes_Added)) == 0
            Film_Data_Set(RowsUpdate).Notes = {Film_Data_Set(RowsUpdate).Notes Notes_Changes(i).Notes_Added};
            Film_Data_Set(RowsUpdate).Notes = strjoin(Film_Data_Set(RowsUpdate).Notes, '. '); %combine currently entered text with previous text to avoid overwriting
        end
    end

    
    %Ask to change relative film numbers
    Film_Num_Action = input("Would you like to change the number designated for any film? 0=No, 1=Yes:");
    if Film_Num_Action == 1
        while Film_Num_Action == 1
            Table = struct2table(Film_Data_Set,"AsArray",true);
            disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries'); disp('Back in the editor, press continue to resume running the code, where you will be prompted to enter a row number')
            keyboard
            Film_Num_Row = input('Select a row of the film you want to change the number of.\nYOU ONLY NEED TO SELECT A SINGLE FILM ROW FOR A GIVEN FILM AND DATA FILE, ALL OTHER ROWS OF THAT FILM (WITHIN THE SAME DATA FILE) WILL BE CHANGED AUTOMATICALLY:');
            NotesTextFilmNum = input('Explain why you are changing the film number:',"s");
            Film_Num_ID = char(Film_Data_Set(Film_Num_Row).WellID); %Well ID of selected film
            Film_Num_Side = Film_Data_Set(Film_Num_Row).Top_Bottom; %film side designation of selected film
            Film_Num_Old = Film_Data_Set(Film_Num_Row).FilmNum_Side; %existing relative film number of selected film
            Film_Num_Abs = Film_Data_Set(Film_Num_Row).Film_Abs_Num; %absolute film number for selected film, use this for changes as it remains constant
            FilmNum_Set_Rows = find(strcmp(Film_Well_ID_vec,Film_Num_ID) & Film_Side_vec==Film_Num_Side & Film_Abs_vec==Film_Num_Abs); %find all data rows for selected film
            Film_Num_New = input('Enter the new relative number for this film:'); %new film number
            for k=1:length(FilmNum_Set_Rows) %cycle through each data row for selected film
                Film_Data_Set(FilmNum_Set_Rows(k)).FilmNum_Side = Film_Num_New;
                Film_Data_Set(FilmNum_Set_Rows(k)).Film_ID = [char(Film_Data_Set(FilmNum_Set_Rows(k)).Analysis_ID) '_' Film_Data_Set(FilmNum_Set_Rows(k)).Cond_Name '_' char(Film_Data_Set(FilmNum_Set_Rows(k)).Top_Bottom) '_' num2str(Film_Data_Set(FilmNum_Set_Rows(k)).FilmNum_Side)];
                Film_Data_Set(FilmNum_Set_Rows(k)).Adjusted_FilmNum = 1;
                if double(isempty(Film_Data_Set(FilmNum_Set_Rows(k)).Notes)) == 1 %notes column is empty
                    Film_Data_Set(FilmNum_Set_Rows(k)).Notes = NotesTextFilmNum;
                else
                    Film_Data_Set(FilmNum_Set_Rows(k)).Notes = {Film_Data_Set(FilmNum_Set_Rows(k)).Notes NotesTextFilmNum};
                    Film_Data_Set(FilmNum_Set_Rows(k)).Notes = strjoin(Film_Data_Set(FilmNum_Set_Rows(k)).Notes, '. '); %combine currently entered text with previous text to avoid overwriting
                end
            end
            %Keep log of changes
            Film_Num_Changes(film_num_changes_counter).WellID = Film_Num_ID;
            Film_Num_Changes(film_num_changes_counter).Top_Bottom = Film_Num_Side;
            Film_Num_Changes(film_num_changes_counter).Film_Num_Abs = Film_Num_Abs;
            Film_Num_Changes(film_num_changes_counter).FilmNum_Side_Old = Film_Num_Old;
            Film_Num_Changes(film_num_changes_counter).FilmNum_Side_New = Film_Num_New;
            Film_Num_Changes(film_num_changes_counter).FilePath = char(Film_Data_Set(Film_Num_Row).PathFiles);
            Film_Num_Changes(film_num_changes_counter).Notes_Added = NotesTextFilmNum;
            c = datetime;
            cc = datevec(c);
            time_stamp_film = [num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(round(cc(6)))];
            Film_Num_Changes(film_num_changes_counter).Timestamp = time_stamp_film;
            film_num_changes_counter = film_num_changes_counter + 1;

            Film_Num_Action = input('Are there any other films that you want to change the number for? 0=No, 1=Yes:');
        end
        save(filename_film,'Film_Num_Changes') %save as .mat file
    end

    %Final check for duplicates in Film ID (place before primacy assignment to avoid issues in primacy)
    clear B ib RowValuesb
    [B, ~, ib] = unique(string({Film_Data_Set.Film_ID}),'stable');
    RowValuesb = find(ismember(string({Film_Data_Set.Film_ID}), B(accumarray(ib,1)>1)));
    if double(isempty(RowValuesb)) == 1 %no match in film IDs detected
        disp('FINAL CHECK: There are no matches in the film IDs')
    else
        error('ERROR: There is a match in Film IDs. This may be caused by input errors in film number reassignment. Locate the error and rerun Data_Reading_Code.')
    end

    %Automatically adjust primacy, assumes same primary voltage for all conditions (ensure only a single set of data for a film and frequency is used for analysis)
    for k=1:length(Film_Data_Set)
        Freq_char = strrep(num2str(Film_Data_Set(k).Frequency),'.','_');
        Primacy_ID{k,:} = {[char(Film_Data_Set(k).WellID) '_' char(Film_Data_Set(k).Top_Bottom) '_' num2str(Film_Data_Set(k).FilmNum_Side) '_' Freq_char '_' num2str(Film_Data_Set(k).Primacy)]}; %create primacy ID for each row to be used in checks
    end
    Primary_Voltage = input('Please enter the primary voltage you would like to consider for analysis:');
    [Unique_Primacy, ~, ~] = unique(string(Primacy_ID),'stable');
    for i=1:length(Unique_Primacy)
        Repeat_Primacy = find(strcmp(string(Primacy_ID),Unique_Primacy(i)));
        if length(Repeat_Primacy) == 1 %no issues with primacy
        elseif length(Repeat_Primacy) > 1 %issues in primacy detected
            clear Voltage_Condition
            for n=1:length(Repeat_Primacy) %cycle through each match in primacy
                Voltage_Condition(n) = Film_Data_Set(Repeat_Primacy(n)).Voltage; %voltages associated with film and frequency causing primacy issues
            end
            Volt_Diff = abs(Primary_Voltage - Voltage_Condition);
            [~, min_index] = min(Volt_Diff,[],'omitnan'); %find row with voltage closest to user defined primary voltage
            Film_Data_Set(Repeat_Primacy(min_index)).Primacy = 1; %adjust primacy
            Not_Primary = find(Volt_Diff ~= Volt_Diff(min_index)); %find nonprimary set
            for k=1:length(Not_Primary)
                Film_Data_Set(Repeat_Primacy(Not_Primary(k))).Primacy = 0; %adjust primacy
            end
        else
        end
    end

    %Ask if user wants to change UseData designation
    UseDataAction = input('Are there any contractility records for which you would like to change the UseData designation? 0=No, 1=Yes:');
    if UseDataAction == 1
        while UseDataAction == 1 %allow user to loop through and select multiple rows
            Table = struct2table(Film_Data_Set,"AsArray",true);
            disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries'); disp('Back in the editor, press continue to resume running the code, where you will be prompted to enter a row number')
            keyboard
            UseDataChangeRow = input('Select the row of the entry you want to change the UseData designation for:');
            UseData_ID = char(Film_Data_Set(UseDataChangeRow).WellID); %Well ID of selected data row
            UseData_Side = Film_Data_Set(UseDataChangeRow).Top_Bottom; %film side designation of selected film
            UseData_Abs = Film_Data_Set(UseDataChangeRow).Film_Abs_Num; %absolute film number for selected film, use this for changes as it remains constant
            UseDataValue_Old = Film_Data_Set(UseDataChangeRow).UseData;
            UseDataValue_Cond = Film_Data_Set(UseDataChangeRow).Cond_Name; %to keep track of changes
            if UseDataValue_Old == 0
                Film_Data_Set(UseDataChangeRow).UseData = 1; %automatically flip UseData, without need for user input
                NotesTextDNU = {};
            elseif UseDataValue_Old == 1
                Film_Data_Set(UseDataChangeRow).UseData = 0; %automatically flip UseData, without need for user input
                NotesTextDNU = input('Explain why you do not want to use this data:',"s");
                if double(isempty(Film_Data_Set(UseDataChangeRow).Notes)) == 1 %notes column is empty
                    Film_Data_Set(UseDataChangeRow).Notes = NotesTextDNU;
                else
                    Film_Data_Set(UseDataChangeRow).Notes = {Film_Data_Set(UseDataChangeRow).Notes NotesTextDNU};
                    Film_Data_Set(UseDataChangeRow).Notes = strjoin(Film_Data_Set(UseDataChangeRow).Notes, '. '); %combine currently entered text with previous text to avoid overwriting
                end
            else
            end
            %Keep log of changes
            UseData_Changes(UseData_changes_counter).WellID = UseData_ID;
            UseData_Changes(UseData_changes_counter).Cond_Name = UseDataValue_Cond;
            UseData_Changes(UseData_changes_counter).Top_Bottom = UseData_Side;
            UseData_Changes(UseData_changes_counter).Film_Num_Abs = UseData_Abs;
            UseData_Changes(UseData_changes_counter).FilePath = char(Film_Data_Set(UseDataChangeRow).PathFiles);
            UseData_Changes(UseData_changes_counter).UseData_New = 1 - UseDataValue_Old;
            UseData_Changes(UseData_changes_counter).Notes_Added = NotesTextDNU;
            c = datetime;
            cc = datevec(c);
            time_stamp_UseData = [num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(round(cc(6)))];
            UseData_Changes(UseData_changes_counter).Timestamp = time_stamp_UseData;
            UseData_changes_counter = UseData_changes_counter + 1;

            UseDataAction = input('Are there any other records that you want to change the UseData designation for? 0=No, 1=Yes:');
        end
        save(filename_UseData,'UseData_Changes') %save as .mat file
    end

    %Ask if the user would like to add any notes/additional notes
    NotesAction = input('Would you like to enter notes/additional notes for any entry in the database? 0=No, 1=Yes:');
    if NotesAction == 1
        while NotesAction == 1 %allow user to loop through and select multiple rows
            Table = struct2table(Film_Data_Set,"AsArray",true);
            disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries'); disp('Back in the editor, press continue to resume running the code, where you will be prompted to enter a row number')
            keyboard
            NotesRow = input('Select the row of the entry you would like to enter notes for:');
            NotesText = input('Type in the text you would like to enter:',"s");
            Notes_ID = char(Film_Data_Set(NotesRow).WellID); %Well ID of selected data row
            Notes_Side = Film_Data_Set(NotesRow).Top_Bottom; %film side designation of selected data row
            Notes_Abs = Film_Data_Set(NotesRow).Film_Abs_Num; %absolute film number for selected data row, use this for changes as it remains constant
            Notes_Cond = Film_Data_Set(NotesRow).Cond_Name; %to keep track of changes
            if double(isempty(Film_Data_Set(NotesRow).Notes)) == 1 %notes column is empty
                Film_Data_Set(NotesRow).Notes = NotesText;
            else
                Film_Data_Set(NotesRow).Notes = {Film_Data_Set(NotesRow).Notes NotesText};
                Film_Data_Set(NotesRow).Notes = strjoin(Film_Data_Set(NotesRow).Notes, '. '); %combine currently entered text with previous text to avoid overwriting
            end
            %Keep log of changes
            Notes_Changes(Notes_changes_counter).WellID = Notes_ID;
            Notes_Changes(Notes_changes_counter).Cond_Name = Notes_Cond;
            Notes_Changes(Notes_changes_counter).Top_Bottom = Notes_Side;
            Notes_Changes(Notes_changes_counter).Film_Num_Abs = Notes_Abs;
            Notes_Changes(Notes_changes_counter).FilePath = char(Film_Data_Set(NotesRow).PathFiles);
            Notes_Changes(Notes_changes_counter).Notes_Added = NotesText;
            c = datetime;
            cc = datevec(c);
            time_stamp_notes = [num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(round(cc(6)))];
            Notes_Changes(Notes_changes_counter).Timestamp = time_stamp_notes;
            Notes_changes_counter = Notes_changes_counter + 1;

            NotesAction = input('Are there any other records that you would like to enter notes/additional notes for? 0=No, 1=Yes:');
        end
        save(filename_Notes,'Notes_Changes') %save as .mat file
    end

    %Generate outputs
    Film_Data_Set = rmfield(Film_Data_Set,'PathFiles');

    Contractility_Data_File_Name = 'Contractility_Data';
    filename_datac_out = [output_dir '\' Contractility_Data_File_Name '.mat']; %.mat file (updated every iteration of code)
    save(filename_datac_out,'Film_Data_Set') %save as .mat file (updated every iteration of code)

    %Files with time stamps (check how data is updated with each run of code and fallback for any errors in code iteration)
    filename_datac_out_time = [output_dir '\' Contractility_Data_File_Name time_stamp '.mat']; %.mat file with time stamp
    save(filename_datac_out_time,'Film_Data_Set') %save as .mat file

    %Save as .csv files for visual checks and to couple with Microsoft Access
    Tc = struct2table(Film_Data_Set,"AsArray",true);
    filename_tablec_out_con = [output_dir '\Contractility_Data_Table.csv'];
    filename_tablec_out = [output_dir '\Contractility_Data_Table_' time_stamp '.csv'];
    writetable(Tc,filename_tablec_out);
    writetable(Tc,filename_tablec_out_con);

    disp('The output files for contractility data have been saved to the selected output directory.')
end

