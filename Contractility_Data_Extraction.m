%CONTRACTILITY DATA OUTPUT 
function Film_Data_Set = Contractility_Data_Extraction(AnalysisID_vec,WellID_vec,StudyType_vec,MediaType_vec,CellType_vec,NRVM_vec,BMDM_vec,Protocol_vec,SeedDate_vec,DataType_vec,FoldNum_vec,WellLetter_vec,Pathfiles_vec, Drive_num,Split_drive_path)
Contract_data = find(contains(string(DataType_vec),'Cont')); %rows from Well_Data_Loc_Set with contractility data
Num_Cdata = length(Contract_data);
data_set_counter = 1; %initialize data counter 
Primary_V = 20; %considered primary voltage

%Cycle through each cell condition
for i=1:Num_Cdata
    %Extract the information for the cell condition
    clear Analysis_ID Well_ID Study_Type Media_Type Cell_Type NRVM_Count BMDM_Count Protocol Seed_Date Well_Letter Data_Type Data_Fold_Num
    Analysis_ID = AnalysisID_vec(Contract_data(i));
    Well_ID = WellID_vec(Contract_data(i));
    Study_Type = StudyType_vec{Contract_data(i)};
    Media_Type = MediaType_vec{Contract_data(i)};
    Cell_Type = CellType_vec{Contract_data(i)};
    NRVM_Count = NRVM_vec{Contract_data(i)};
    BMDM_Count = BMDM_vec{Contract_data(i)};
    Protocol = Protocol_vec{Contract_data(i)};
    Seed_Date = SeedDate_vec{Contract_data(i)};
    Well_Letter = WellLetter_vec(Contract_data(i));
    Data_Type = DataType_vec(Contract_data(i));
    Data_Fold_Num = FoldNum_vec(Contract_data(i));

    Partial_path = char(Pathfiles_vec(Contract_data(i))); %path without drive letter
    Current_directory = pwd;
    Current_drive = split(Current_directory,':');

    file_exist = exist([Current_drive{1} ':' Partial_path],'file');
    if file_exist == 0 %change directory if file does not exist
    for d=1:Drive_num
        cd([Spilt_drive_path{d}{1} ':'])
        file_exist = exist([Spilt_drive_path{d}{1} ':' Partial_path],'file');
        if file_exist == 2
            Current_directory = pwd;
            Current_drive = split(Current_directory,':');
            break
        else
        end
    end
    else %continue with code if file exists
    end
    load(Partial_path); %load data file into workspace

    ssKPa = getfield(load(Partial_path,'ss'),'ss'); %rename ss variable to avoid confusion with MATLAB function
    NumberTopFilm = NumFilms_top;
    NumberBotFilm = NumFilms_bottom;
    NumberFilm_Tot = NumberTopFilm+NumberBotFilm;
    NumberConditions = NumCond;  
    Freq_tot = [];
    Volt_tot = [];
    
    for j=1:NumberConditions %cycle through each condition
        Cond_Name = deblank(condname_str(j,:));
        if double(contains(Cond_Name,'spont')) == 1
            Frequency = 0;
            Voltage = 0;
        else
            Frequency = str2double(strrep(extractBefore(Cond_Name,'Hz'),'-','.'));
            Voltage = str2double(strrep(extractBetween(Cond_Name,'Hz','V'),'-','.'));
        end
        Freq_tot = vertcat(Freq_tot,Frequency);
        Volt_tot = vertcat(Volt_tot,Voltage);

        Primacy = zeros(size(Voltage)); %initialize frequency primacy matrix

        Primacy_tot = zeros(size(Volt_tot));
        [Unique_Frequency, index_U, index_vec] = unique(Freq_tot,'stable');

        for ff=1:length(Unique_Frequency)
            V_u = Volt_tot(ismember(Freq_tot,Unique_Frequency(ff))); %the associated voltage
            DeltaV = abs(V_u - Primary_V); %the difference between the voltage and primary voltage
            [temp, min_V_ind] = min(DeltaV,[],'omitnan');
            indmem = find(ismember(Freq_tot,Unique_Frequency(ff)));
            Primacy_tot(indmem(min_V_ind)) = 1;
        end
        Prim_cell = num2cell(Primacy_tot);
        Primacy_vec = vertcat(Prim_cell{:});

        for fb = 1:NumberBotFilm
            Top_Bottom = 'bottom';
            FilmNum_Side = fb;
            Film_Abs_Num = fb;

            %Extract Data for this film
            Active_Stress_kPa = as(j,Film_Abs_Num);
            Sys_Stress_kPa = ssKPa(j,Film_Abs_Num);
            Dias_Stress_kPa = ds(j,Film_Abs_Num);
            freq_dias_Hz = freq(j,Film_Abs_Num);
            freq_sys_Hz = freq_sys(j,Film_Abs_Num);
            freq_period_Hz = period_freq(j,Film_Abs_Num);
            
            %Filename with the condition stress data
            [Data_folder_path_bottom, ~, ~] = fileparts(Partial_path);
            Stress_data_file_bottom = [char(Data_folder_path_bottom) '\' char(cond_label(j)) '_bottom_xProjDatafile_StressDatafile_analyzed.mat'];
            
            load(Stress_data_file_bottom)
            Fall_time_sec = mean_fall_time(FilmNum_Side);
            Rise_time_sec = mean_rise_time(FilmNum_Side);
            
            %Record the data for this file
            Film_ID = [char(Analysis_ID) '_' Cond_Name '_' num2str(Film_Abs_Num)];
            Film_Data_Set(data_set_counter).Film_ID = Film_ID;
            Film_Data_Set(data_set_counter).Analysis_ID = Analysis_ID;
            Film_Data_Set(data_set_counter).WellID = Well_ID;
            Film_Data_Set(data_set_counter).Study_Type = Study_Type; 
            Film_Data_Set(data_set_counter).Media_Type = Media_Type;
            Film_Data_Set(data_set_counter).Cell_Type = Cell_Type;
            Film_Data_Set(data_set_counter).NRVM_Count = NRVM_Count;
            Film_Data_Set(data_set_counter).BMDM_Count = BMDM_Count;
            Film_Data_Set(data_set_counter).Protocol = Protocol;
            Film_Data_Set(data_set_counter).Seed_Date = Seed_Date;
            Film_Data_Set(data_set_counter).Well_Letter = Well_Letter;
            Film_Data_Set(data_set_counter).Data_Type = string(Data_Type);
            Film_Data_Set(data_set_counter).DataFold_Num = Data_Fold_Num;
            Film_Data_Set(data_set_counter).Cond_Name = Cond_Name;
            Film_Data_Set(data_set_counter).Frequency = Frequency;
            Film_Data_Set(data_set_counter).Voltage = Voltage;
            Film_Data_Set(data_set_counter).Active_Stress_kPa = Active_Stress_kPa;
            Film_Data_Set(data_set_counter).Sys_Stress_kPa = Sys_Stress_kPa;
            Film_Data_Set(data_set_counter).Dias_Stress_kPa = Dias_Stress_kPa;
            Film_Data_Set(data_set_counter).freq_dias_Hz = freq_dias_Hz;
            Film_Data_Set(data_set_counter).freq_sys_Hz = freq_sys_Hz;
            Film_Data_Set(data_set_counter).freq_period_Hz = freq_period_Hz;
            Film_Data_Set(data_set_counter).Fall_time_sec = Fall_time_sec;
            Film_Data_Set(data_set_counter).Rise_time_sec = Rise_time_sec;
            Film_Data_Set(data_set_counter).Primacy = Primacy_vec(j);
            Film_Data_Set(data_set_counter).Top_Bottom = Top_Bottom;
            Film_Data_Set(data_set_counter).FilmNum_Side = FilmNum_Side;
            Film_Data_Set(data_set_counter).Film_Abs_Num = Film_Abs_Num;
            Film_Data_Set(data_set_counter).UseData = 1;
            Film_Data_Set(data_set_counter).Notes = {};
            
            
            data_set_counter = data_set_counter+1;
        end
        for ft = 1:NumberTopFilm
            Top_Bottom = 'top';
            FilmNum_Side = ft;
            Film_Abs_Num = NumberBotFilm+ft;
            
            %Extract Data for this film
            Active_Stress_kPa = as(j,Film_Abs_Num);
            Sys_Stress_kPa = ssKPa(j,Film_Abs_Num);
            Dias_Stress_kPa = ds(j,Film_Abs_Num);
            freq_dias_Hz = freq(j,Film_Abs_Num);
            freq_sys_Hz = freq_sys(j,Film_Abs_Num);
            freq_period_Hz = period_freq(j,Film_Abs_Num);
            
            %Filename with the condition stress data
            [Data_folder_path_top, ~, ~] = fileparts(Partial_path);
            Stress_data_file_top = [char(Data_folder_path_top) '\' char(cond_label(j)) '_top_xProjDatafile_StressDatafile_analyzed.mat'];
            
            load(Stress_data_file_top)
            Fall_time_sec = mean_fall_time(FilmNum_Side);
            Rise_time_sec = mean_rise_time(FilmNum_Side);
            
            %Record the data for this film
            Film_ID = [char(Analysis_ID) '_' Cond_Name '_' num2str(Film_Abs_Num)];
            Film_Data_Set(data_set_counter).Film_ID = Film_ID;
            Film_Data_Set(data_set_counter).Analysis_ID = Analysis_ID;
            Film_Data_Set(data_set_counter).WellID = Well_ID;
            Film_Data_Set(data_set_counter).Study_Type = Study_Type; 
            Film_Data_Set(data_set_counter).Media_Type = Media_Type;
            Film_Data_Set(data_set_counter).Cell_Type = Cell_Type;
            Film_Data_Set(data_set_counter).NRVM_Count = NRVM_Count;
            Film_Data_Set(data_set_counter).BMDM_Count = BMDM_Count;
            Film_Data_Set(data_set_counter).Protocol = Protocol;
            Film_Data_Set(data_set_counter).Seed_Date = Seed_Date;
            Film_Data_Set(data_set_counter).Well_Letter = Well_Letter;
            Film_Data_Set(data_set_counter).Data_Type = Data_Type;
            Film_Data_Set(data_set_counter).DataFold_Num = Data_Fold_Num;
            Film_Data_Set(data_set_counter).Cond_Name = Cond_Name;
            Film_Data_Set(data_set_counter).Frequency = Frequency;
            Film_Data_Set(data_set_counter).Voltage = Voltage;
            Film_Data_Set(data_set_counter).Active_Stress_kPa = Active_Stress_kPa;
            Film_Data_Set(data_set_counter).Sys_Stress_kPa = Sys_Stress_kPa;
            Film_Data_Set(data_set_counter).Dias_Stress_kPa = Dias_Stress_kPa;
            Film_Data_Set(data_set_counter).freq_dias_Hz = freq_dias_Hz;
            Film_Data_Set(data_set_counter).freq_sys_Hz = freq_sys_Hz;
            Film_Data_Set(data_set_counter).freq_period_Hz = freq_period_Hz;
            Film_Data_Set(data_set_counter).Fall_time_sec = Fall_time_sec;
            Film_Data_Set(data_set_counter).Rise_time_sec = Rise_time_sec;
            Film_Data_Set(data_set_counter).Primacy = Primacy_vec(j);
            Film_Data_Set(data_set_counter).Top_Bottom = Top_Bottom;
            Film_Data_Set(data_set_counter).FilmNum_Side = FilmNum_Side;
            Film_Data_Set(data_set_counter).Film_Abs_Num = Film_Abs_Num;
            Film_Data_Set(data_set_counter).UseData = 1;
            Film_Data_Set(data_set_counter).Notes = {};
            
            
            data_set_counter = data_set_counter+1;
        end
    end   
end
end