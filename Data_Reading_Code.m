%Author: Nida Qayyum
%Data reading code for conditions and locations output from Location_Code

%The outputs of this code are .mat and .csv files named ZLD_Analysis_Date with a time stamp to keep track of the database changes with each code run

%The file 'ZLD_Analysis_Data' (without time stamp) contains the most recently
%updated information

%Date updated: 08/31/23

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

%STRUCTURAL DATA OUTPUT (Z-LINE DETECT)
Struct_data = find(contains(string(DataType_vec),'ZLDet')); %rows from Well_Data_Loc_Set with structural data 
Num_Sdata = length(Struct_data);

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
    load(char(Pathfiles_vec(Struct_data(j))),'CS_results','settings'); %load data file into workspace
    Well_Data_Set_ZLD(j).Zline_Fraction = CS_results.CS_zlinefrac;
    Well_Data_Set_ZLD(j).Zline_OOP = CS_results.CS_OOPs;
    Well_Data_Set_ZLD(j).Zline_Angle_Count = CS_results.angle_count;
    Well_Data_Set_ZLD(j).Actin_OOP = CS_results.ACTINCS_OOPs;
    Well_Data_Set_ZLD(j).Actin_Angle_Count = CS_results.ACTINangle_count;
    avg_sarcd = mean(vertcat(CS_results.FOV_sarcdistance{:}));
    Well_Data_Set_ZLD(j).Average_Sarcdistance = avg_sarcd;
    Well_Data_Set_ZLD(j).ContL_Median = CS_results.CS_medians;
    Well_Data_Set_ZLD(j).ContL_Mean = CS_results.CS_means;
    [TotalPixels, TotalPixels_AA] = pixelcount_mCherry(CS_results);
    Well_Data_Set_ZLD(j).Total_Pixels = TotalPixels;
    Well_Data_Set_ZLD(j).AA_Pixels = TotalPixels_AA;
    Well_Data_Set_ZLD(j).AA_Confluency = (TotalPixels_AA/TotalPixels)*100;
    %Well_Data_Set_ZLD(j).Diffuse_AA_Fraction = 1-(CS_results.angle_count*settings.pix2um*avg_sacrd/TotalPixels_AA);
    [Overlay_int, AA_int] = Diffusefrac_mCherry(CS_results);
    shadow = 1; %shadow of signal around zline in microns
    Well_Data_Set_ZLD(j).Diffuse_AA_Fraction = 1-(Overlay_int*shadow*settings.pix2um/AA_int);
    Well_Data_Set_ZLD(j).Threshold = CS_results.CS_thresholds;
    Well_Data_Set_ZLD(j).Gridsize = CS_results.CS_gridsizes;

    clear CS_results TotalPixels TotalPixels_AA avg_sarcd settings Overlay_int AA_int %clear each file and variable after recording data to save memory
end

ZLD_Data_File_Name = 'ZLD_Analysis_Data';
filename_data_out = [output_dir ZLD_Data_File_Name '.mat']; %mat file that will be worked with (updated every iteration of code)
save(filename_data_out,'Well_Data_Set_ZLD') %save as mat file (updated every iteration of code)

%files with time stamps (check how data is updated with each run of code
%and fallback for any errors in code iteration)
filename_data_out_time = [output_dir ZLD_Data_File_Name time_stamp '.mat']; %mat file that will be worked with
save(filename_data_out_time,'Well_Data_Set_ZLD') %save as mat file

%save the table as a csv file for visual checks
T = struct2table(Well_Data_Set_ZLD,"AsArray",true);
filename_table_out_con = [output_dir '\ZLD_Analysis_Data_Table.csv'];
filename_table_out = [output_dir '\ZLD_Analysis_Data_Table_' time_stamp '.csv'];
writetable(T,filename_table_out_con);
writetable(T,filename_table_out);

disp('The code has finished running, and the output files have been saved to the selected directory.')