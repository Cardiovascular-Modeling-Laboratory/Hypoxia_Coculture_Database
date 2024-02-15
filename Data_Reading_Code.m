%Author: Nida Qayyum
%Data reading code for conditions and locations output from Location_Code

%The outputs of this code are .mat and .csv files named ZLD_Analysis_Data and Contractility_Data with a time stamp to keep track of the database changes with each code run

%The files 'ZLD_Analysis_Data' and 'Contractility_Data' (without time stamp) contain the most recently
%updated information

%Date updated: 02/06/24 (updated version of 'Data_Reading_Code_11_8', added check for primacy)

clear; clc;

%Generate a time stamp for the file name
c = datetime;
cc = datevec(c);
time_stamp = [num2str(cc(1)) '_' num2str(cc(2)) '_' num2str(cc(3)) '_' num2str(cc(4)) '_' num2str(cc(5)) '_' num2str(round(cc(6)))];

[filename_loc, loc_path] = ...
    uigetfile('*.mat','Select the .mat file with the condition and location data (i.e. Data_Locations)','C:\Users\Grosberg CML\Documents\Nida_Database');
filename_well_out = [loc_path filename_loc]; %mat file to be loaded into workspace
path_base = loc_path; %set the previous folder to be the current base folder
output_dir = uigetdir(path_base,'Please pick an output directory with your data base files (i.e. Data_Locations, etc)...');

load(filename_well_out) %load condition and path data into workspace

%Add all data storage drives to MATLAB path
Drive_num = input('How many drives are your data analysis files (Z-line detect summary files, images, contractility data, etc.) stored on?');
for d=1:Drive_num
    clear Display_string
    Display_string = ['Select the root path (drive and parent folder) for Drive ' num2str(d)];
    Root_path{d} = uigetdir([],Display_string);
    Split_drive_path{d} = split(Root_path{d},':');
    addpath(genpath(Root_path{d}))
end

%extract condition data
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

%% STRUCTURAL DATA OUTPUT (Z-LINE DETECT)
Struct_data = find(contains(string(DataType_vec),'ZLDet')); %rows from Well_Data_Loc_Set with structural data 
Num_Sdata = length(Struct_data);

if Num_Sdata ~=0
for j=1:Num_Sdata %loop through each entry with structural data 
    %Populate structure with condition data 
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
    Well_Data_Set_ZLD(j).Data_Type = DataType_vec(Struct_data(j));
    Well_Data_Set_ZLD(j).DataFold_Num = FoldNum_vec(Struct_data(j));
    Well_Data_Set_ZLD(j).UseData = UseData_vec(Struct_data(j));
    Well_Data_Set_ZLD(j).Notes = Notes_vec(Struct_data(j));

    %Populate structure with analysis data 
    Partial_path = char(Pathfiles_vec(Struct_data(j))); %path without drive letter
    Current_directory = pwd;
    Current_drive = split(Current_directory,':');

    %load(char(Pathfiles_vec(Struct_data(j))),'CS_results','settings'); %load data file into workspace
    file_exist = exist([Current_drive{1} ':' Partial_path],'file');
    if file_exist == 0 %change directory if file does not exist
    for d=1:Drive_num
        cd([Split_drive_path{d}{1} ':'])
        file_exist = exist([Split_drive_path{d}{1} ':' Partial_path],'file');
        if file_exist == 2
            Current_directory = pwd;
            Current_drive = split(Current_directory,':');
            break
        else
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
    
    [Image_folder_path, ~, ~] = fileparts(Partial_path); 
    Image_Analysis_Output = [Current_drive{1} ':' Image_folder_path '\Image_Analysis_Outputs.mat']; %filename for image analysis output
    if exist(Image_Analysis_Output,'file') == 0 %file with saved image analysis outputs does not exist
        [TotalPixels, TotalPixels_AA] = Confluency_background(CS_results,Current_drive{1},char(Pathfiles_vec(Struct_data(j))));
        Well_Data_Set_ZLD(j).Total_Pixels = TotalPixels;
        Well_Data_Set_ZLD(j).AA_Pixels = TotalPixels_AA;
        AA_Confluency = (TotalPixels_AA/TotalPixels)*100;
        Well_Data_Set_ZLD(j).AA_Confluency = AA_Confluency;
        [Overlay_int, AA_int] = Diffusefrac_mCherry(CS_results,Current_drive{1},char(Pathfiles_vec(Struct_data(j))));
        shadow = 1; %shadow of signal around zline in microns
        Diffuse_AA_Fraction = 1-(Overlay_int*shadow*settings.pix2um/AA_int);
        Well_Data_Set_ZLD(j).Diffuse_AA_Fraction = Diffuse_AA_Fraction;
        save(Image_Analysis_Output,'TotalPixels','TotalPixels_AA','AA_Confluency','Overlay_int','AA_int','Diffuse_AA_Fraction');
    else
        load(Image_Analysis_Output);
        Well_Data_Set_ZLD(j).Total_Pixels = TotalPixels;
        Well_Data_Set_ZLD(j).AA_Pixels = TotalPixels_AA;
        Well_Data_Set_ZLD(j).AA_Confluency = AA_Confluency;
        Well_Data_Set_ZLD(j).Diffuse_AA_Fraction = Diffuse_AA_Fraction;
    end
    
    Well_Data_Set_ZLD(j).Threshold = CS_results.CS_thresholds;
    Well_Data_Set_ZLD(j).Gridsize = CS_results.CS_gridsizes;

    clear CS_results TotalPixels TotalPixels_AA AA_Confluency avg_sarcd settings Overlay_int AA_int Partial_path Image_Analysis_Output Diffuse_AA_Fraction Image_folder_path %clear each file and variable after recording data to save memory
end

cd(output_dir) %switch to output directory

ZLD_Data_File_Name = 'ZLD_Analysis_Data';
filename_data_out = [output_dir '\' ZLD_Data_File_Name '.mat']; %mat file that will be worked with (updated every iteration of code)
save(filename_data_out,'Well_Data_Set_ZLD') %save as mat file (updated every iteration of code)

%files with time stamps (check how data is updated with each run of code
%and fallback for any errors in code iteration)
filename_data_out_time = [output_dir '\' ZLD_Data_File_Name time_stamp '.mat']; %mat file that will be worked with
save(filename_data_out_time,'Well_Data_Set_ZLD') %save as mat file

%save the table as a csv file for visual checks
T = struct2table(Well_Data_Set_ZLD,"AsArray",true);
filename_table_out_con = [output_dir '\ZLD_Analysis_Data_Table.csv'];
filename_table_out = [output_dir '\ZLD_Analysis_Data_Table_' time_stamp '.csv'];
writetable(T,filename_table_out);
writetable(T,filename_table_out_con);

disp('The output files for structural data have been saved to the selected output directory.')
end

%% CONTRACTILITY DATA OUTPUT
Contract_data = find(contains(string(DataType_vec),'Cont')); %rows from Well_Data_Loc_Set with contractility data
Num_Cdata = length(Contract_data);

if Num_Cdata ~=0
Film_Data_Set = Contractility_Data_Extraction(AnalysisID_vec,WellID_vec,StudyType_vec,MediaType_vec,CellType_vec,NRVM_vec,BMDM_vec,Protocol_vec,SeedDate_vec,DataType_vec,FoldNum_vec,WellLetter_vec,Pathfiles_vec, Drive_num,Split_drive_path);
Film_Well_ID_vec = string({Film_Data_Set.WellID});
Frequency_vec = cell2mat({Film_Data_Set.Frequency});
Voltage_vec = cell2mat({Film_Data_Set.Voltage});
%Check for primacy (ensure values for pacing at unique frequency for each
%set of films)
for k=1:length(Film_Data_Set)
    Freq_char = strrep(num2str(Film_Data_Set(k).Frequency),'.','_');
    Primacy_ID{k,:} = {[char(Film_Data_Set(k).WellID) '_' Freq_char '_' num2str(Film_Data_Set(k).Film_Abs_Num) '_' num2str(Film_Data_Set(k).Primacy)]}; 
end
%Find matches in non-unique frequency sets
[B, ~, ib] = unique(string(Primacy_ID),'stable'); 
RowValuesb = find(ismember(string(Primacy_ID), B(accumarray(ib,1)>1))); %rows with replicates
if double(isempty(RowValuesb)) == 1 %no match in file paths detected
    disp('CHECK: There are no issues with primacy.')
else
    Entry_Row = RowValuesb;
    WellID_Row = [{Film_Data_Set(Entry_Row).WellID}]';
    Frequency_Row = [{Film_Data_Set(Entry_Row).Frequency}]';
    Voltage_Row = [{Film_Data_Set(Entry_Row).Voltage}]';
    Primacy_Row = [{Film_Data_Set(Entry_Row).Primacy}]';
    Path_File_Row = [{Well_Data_Loc_Set(Entry_Row).PathFiles}]';
    clear Combo_For_Disp
    Combo_For_Disp = table(Entry_Row,string(WellID_Row),cell2mat(Frequency_Row),cell2mat(Voltage_Row),cell2mat(Primacy_Row),string(Path_File_Row));
    Combo_For_Disp = renamevars(Combo_For_Disp,["Var2","Var3","Var4","Var5","Var6"],["Well_ID","Frequency","Voltage","Primacy","Path_File"]);
    Combo_For_Disp
    Primacy_choice = input('Choose the a row with the voltage condition that you would like to define as the primary set for the shown well and frequency. All other conditions of this well with the same frequency will be set to a primacy of 0.\nYOU ONLY NEED TO SELECT A SINGLE FILM ROW, ALL OTHERS WILL BE CHANGED AUTOMATICALLY:');
    Primacy_choice_ID = char(Film_Data_Set(Primacy_choice).WellID);
    Primacy_choice_freq = Film_Data_Set(Primacy_choice).Frequency;
    Primacy_choice_volt = Film_Data_Set(Primacy_choice).Voltage;
    Primacy_set_rows = find(strcmp(Film_Well_ID_vec,Primacy_choice_ID) & Frequency_vec==Primacy_choice_freq & Voltage_vec==Primacy_choice_volt); %find rows which need to be set to a primacy of 1
    for h=1:length(Primacy_set_rows)
    Film_Data_Set(Primacy_set_rows(h)).Primacy = 1;
    end
    Primacy_change_rows = find(strcmp(Film_Well_ID_vec,Primacy_choice_ID) & Frequency_vec==Primacy_choice_freq & Voltage_vec~=Primacy_choice_volt); %find rows which need to be set to a primacy of 1
    for n=1:length(Primacy_change_rows)
    Film_Data_Set(Primacy_change_rows(n)).Primacy = 0;
    end
end

%Ask if user wants to change the primacy for a well
PrimacyAction = input('Would you like to change the primacy setting for a pacing condition of a particular well? 0=No, 1=Yes');
while PrimacyAction == 1 %allow user to loop through and select multiple rows
    Table = struct2table(Film_Data_Set,"AsArray",true);
    disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries (this is an intermediate output, and rows to be deleted will have deleted_directory in the PathFiles column)'); disp('Back in the editor, press continue to resume running of the code, where you will be prompted to enter a row number')
    keyboard
    Primacy_choice = input('Choose the row with the voltage condition that you would like to define as the primary set for a certain well and frequency. All other conditions of this well with the same frequency will be set to a primacy of 0.\nYOU ONLY NEED TO SELECT A SINGLE FILM ROW, ALL OTHERS WILL BE CHANGED AUTOMATICALLY:');
    Primacy_choice_ID = char(Film_Data_Set(Primacy_choice).WellID);
    Primacy_choice_freq = Film_Data_Set(Primacy_choice).Frequency;
    Primacy_choice_volt = Film_Data_Set(Primacy_choice).Voltage;
    Primacy_set_rows = find(strcmp(Film_Well_ID_vec,Primacy_choice_ID) & Frequency_vec==Primacy_choice_freq & Voltage_vec==Primacy_choice_volt); %find rows which need to be set to a primacy of 1
    for h=1:length(Primacy_set_rows)
    Film_Data_Set(Primacy_set_rows(h)).Primacy = 1;
    end
    Primacy_change_rows = find(strcmp(Film_Well_ID_vec,Primacy_choice_ID) & Frequency_vec==Primacy_choice_freq & Voltage_vec~=Primacy_choice_volt); %find rows which need to be set to a primacy of 1
    for n=1:length(Primacy_change_rows)
    Film_Data_Set(Primacy_change_rows(n)).Primacy = 0;
    end
    PrimacyAction = input('Are there any other pacing conditions that you want to change the primacy for? 0=No, 1=Yes:');
end

%Ask if there are any records that cannot be used
UseDataAction = input('Are there any contractility records for which you would like to change the UseData designation? 0=No, 1=Yes:');
while UseDataAction == 1 %allow user to loop through and select multiple rows
    Table = struct2table(Film_Data_Set,"AsArray",true);
    disp('Control will now be given to the user'); disp('In the MATLAB workspace, double click on the value of Table to see the updated list of entries (this is an intermediate output, and rows to be deleted will have deleted_directory in the PathFiles column)'); disp('Back in the editor, press continue to resume running of the code, where you will be prompted to enter a row number')
    keyboard
    UseDataChangeRow = input('Select the row of the entry you want to change the UseData designation for:');
    UseDataValue = input('Would you like to set UseData to 0 or 1?');
    if UseDataValue == 1
        Film_Data_Set(UseDataChangeRow).UseData = 1;
    elseif UseDataValue == 0
        Film_Data_Set(UseDataChangeRow).UseData = 0;
        NotesTextDNU = input('Explain why you do not want to use this data:',"s");
        if double(isempty(Film_Data_Set(UseDataChangeRow).Notes)) == 1 %notes column is empty
            Film_Data_Set(UseDataChangeRow).Notes = NotesTextDNU;
        else
            Film_Data_Set(UseDataChangeRow).Notes = {Film_Data_Set(UseDataChangeRow).Notes NotesTextDNU};
            Film_Data_Set(UseDataChangeRow).Notes = strjoin(Film_Data_Set(UseDataChangeRow).Notes, '. '); %combine currently entered text with previous text to avoid overwriting
        end
    else
    end
    UseDataAction = input('Are there any other records that you want to change the UseData designation for? 0=No, 1=Yes:');
end

%Final check for duplicates in Film ID
clear B ib RowValuesb
[B, ~, ib] = unique(string({Film_Data_Set.Film_ID}),'stable');
RowValuesb = find(ismember(string({Film_Data_Set.Film_ID}), B(accumarray(ib,1)>1)));
if double(isempty(RowValuesb)) == 1 %no match in film IDs detected
    disp('FINAL CHECK: There are no matches in the film IDs')
else
    disp('ERROR: There is a match in film IDs. Analyze output file to locate the error and erase from the database.')
end

%Generate outputs
Contractility_Data_File_Name = 'Contractility_Data';
filename_datac_out = [output_dir '\' Contractility_Data_File_Name '.mat']; %mat file that will be worked with (updated every iteration of code)
save(filename_datac_out,'Film_Data_Set') %save as mat file (updated every iteration of code)

%files with time stamps (check how data is updated with each run of code
%and fallback for any errors in code iteration)
filename_datac_out_time = [output_dir '\' Contractility_Data_File_Name time_stamp '.mat']; %mat file that will be worked with
save(filename_datac_out_time,'Film_Data_Set') %save as mat file

%save the table as a csv file for visual checks
Tc = struct2table(Film_Data_Set,"AsArray",true);
filename_tablec_out_con = [output_dir '\Contractility_Data_Table.csv'];
filename_tablec_out = [output_dir '\Contractility_Data_Table_' time_stamp '.csv'];
writetable(Tc,filename_tablec_out);
writetable(Tc,filename_tablec_out_con);

disp('The output files for contractility data have been saved to the selected output directory.')
end

