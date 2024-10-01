%CONTRACTILITY DATA OUTPUT FUNCTION
%updated from Contractility_Data_Extraction_7_24_29 - added options to account for user defined orientation choice 
function Film_Data_Set = Contractility_Data_Extraction_7_29_24(AnalysisID_vec,WellID_vec,StudyType_vec,MediaType_vec,CellType_vec,NRVM_vec,BMDM_vec,Protocol_vec,SeedDate_vec,DataType_vec,FoldNum_vec,WellLetter_vec,Pathfiles_vec,UDO_vec,Drive_num,Split_drive_path)
Contract_data = find(contains(string(DataType_vec),'Cont')); %rows from Location_Code output with contractility data
Num_Cdata = length(Contract_data);
data_set_counter = 1; %initialize data counter 
Primary_Voltage = 20; %primary voltage for primacy designation

%Cycle through each data file selected in Location_Code
for i=1:Num_Cdata
    clear Analysis_ID Well_ID Study_Type Media_Type Cell_Type NRVM_Count BMDM_Count Protocol Seed_Date Well_Letter Data_Type Data_Fold_Num DoNotUse NoContraction Notes
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
    UDO = cell2mat(UDO_vec(Contract_data(i)));

    Partial_path = char(Pathfiles_vec(Contract_data(i))); %path without drive letter
    Current_directory = pwd;
    Current_drive = split(Current_directory,':'); %split drive letter and the rest of the path

    file_exist = exist([Current_drive{1} ':' Partial_path],'file'); %check if data file is in current drive
    if file_exist == 0 %change directory if file does not exist
    for d=1:Drive_num
        cd([Split_drive_path{d}{1} ':'])
        file_exist = exist([Split_drive_path{d}{1} ':' Partial_path],'file'); %check if data file exists in next drive
        if file_exist == 2 %file exists
            Current_directory = pwd;
            Current_drive = split(Current_directory,':');
            break %do not cycle through other drives if the file exists
        else
        end
    end
    else %continue with code if file exists
    end
    load(Partial_path); %load data file into workspace

    NoContraction_exist = exist('NoContraction','var'); %use NoContraction from Summary_Auto.mat (if available) to define NoContraction
    DoNotUse_exist = exist('DoNotUse','var'); %use DoNotUse from Summary_Auto.mat (if available) to define UseData
    Notes_exist = exist('Notes','var'); %use Notes from Summary_Auto.mat (if available) to define Notes
    ssKPa = getfield(load(Partial_path,'ss'),'ss'); %rename ss variable to avoid confusion with MATLAB function
    
    if UDO == 1 %user-defined orientation from Location_Code
        if NumFilms_top == 0 && NumFilms_bottom ~= 0
            NumFilms_top = NumFilms_bottom;
            NumFilms_bottom = 0;
            OrientationUpdated = "The film side designation for this file has been updated from bottom to top by the Data Reading Code. The films were originally in the top row on the coverslip, but incorrectly recorded as bottom films in SummaryAuto.mat during MTF analysis.";
            save(Partial_path,'NumFilms_top','NumFilms_bottom','OrientationUpdated',"-append")
        else %do not append file if it has already been corrected
        end
    elseif UDO == 3 || UDO == 4
        if NumFilms_bottom == 0 && NumFilms_top ~= 0
            NumFilms_bottom = NumFilms_top;
            NumFilms_top = 0;
            if UDO == 3
                OrientationUpdated = "The film side designation for this file has been updated from top to bottom by the Data Reading Code. The films were originally on the bottom row of the coverslip but were flipped to top by the user during MTF measurement. The designation in SummaryAuto.mat was also top. However, it was flipped from top to bottom by Data_Reading_Code to match the coverslip.";
            else
                OrientationUpdated = "The film side designation for this file has been updated from top to bottom by the Data Reading Code. The films were originally in the bottom row on the coverslip, but incorrectly recorded as top films in SummaryAuto.mat during MTF analysis.";
            end
            save(Partial_path,'NumFilms_top','NumFilms_bottom','OrientationUpdated',"-append")
        else %do not append file if it has already been corrected
        end
    end
    NumberTopFilm = NumFilms_top; %total top films in data file
    NumberBotFilm = NumFilms_bottom; %total bottom films in data file
    NumberFilm_Tot = NumberTopFilm+NumberBotFilm; %total number of film in data file
    NumberConditions = NumCond; %total number of pacing conditions in data file
    Freq_tot = []; %initialize for primacy
    Volt_tot = []; %initialize for primacy
    clear UseData_matrix
    [~, columns] = size(DoNotUse);
    if columns == 2 %data file has both top and bottom films 
        for m=1:NumCond %cycle through each condition
            UseData_matrix(m,:) = 1 - [reshape(DoNotUse{m,1},1,length(DoNotUse{m,1})), reshape(DoNotUse{m,2},1,length(DoNotUse{m,2}))];
        end
    else %data file has either top or bottom films
        for m=1:NumCond %cycle through each condition
            UseData_matrix(m,:) = 1 - [reshape(DoNotUse{m,1},1,length(DoNotUse{m,1}))];
        end
    end
    clear NoContraction_matrix
    [~, columns] = size(NoContraction);
    if columns == 2 %data file has both top and bottom films 
        for m=1:NumCond %cycle through each condition
            NoContraction_matrix(m,:) = [reshape(NoContraction{m,1},1,length(NoContraction{m,1})), reshape(NoContraction{m,2},1,length(NoContraction{m,2}))];
        end
    else %data file has either top or bottom films
        for m=1:NumCond %cycle through each condition
            NoContraction_matrix(m,:) = [reshape(NoContraction{m,1},1,length(NoContraction{m,1}))];
        end
    end

    for j=1:NumberConditions %cycle through each pacing condition
        Cond_Name = deblank(condname_str(j,:)); %remove spaces in condition name
        if double(contains(Cond_Name,'spont')) == 1 
            Frequency = 0;
            Voltage = 0;
        else
            Frequency = str2double(strrep(extractBefore(Cond_Name,'Hz'),'-','.')); %extract frequency from condition string
            Voltage = str2double(strrep(extractBetween(Cond_Name,'Hz','V'),'-','.')); %extract voltage from condition string
        end
        Freq_tot = vertcat(Freq_tot,Frequency); %frequency vector for all conditions (updated every run of for loop)
        Volt_tot = vertcat(Volt_tot,Voltage); %voltage vector for all conditions (updated every run of for loop)

        Primacy = zeros(size(Voltage)); %initialize frequency primacy vector

        Primacy_tot = zeros(size(Volt_tot)); %initialize frequency primacy vector
        [Unique_Frequency, ~, ~] = unique(Freq_tot,'stable'); %find unique frequencies for the selected data file

        for ff=1:length(Unique_Frequency)
            V_u = Volt_tot(ismember(Freq_tot,Unique_Frequency(ff))); %the associated voltage
            DeltaV = abs(V_u - Primary_Voltage); %the difference between the voltages for a unique frequency and primary voltage
            [~, min_V_ind] = min(DeltaV,[],'omitnan'); %find index with voltage closest to primary
            indmem = find(ismember(Freq_tot,Unique_Frequency(ff))); %indices with specific frequency
            Primacy_tot(indmem(min_V_ind)) = 1; %set condition with voltage closest to primary voltage as primary set for the frequency
        end
        Prim_cell = num2cell(Primacy_tot);
        Primacy_vec = vertcat(Prim_cell{:});

        if Notes_exist == 1
            [rows,columns] = size(Notes);
            if rows == NumberConditions && columns == 1
                Notes_text = Notes{j};
            else
                Notes_text = {};
            end
        else
            Notes_text = {};
        end

        for fb = 1:NumberBotFilm %cycle through all bottom films in data file
            Top_Bottom = 'bottom'; %film designation
            FilmNum_Side = fb; %relative film number
            Film_Abs_Num = fb; %absolute film number

            %Extract Data for this film (matrix formatted as rows = pacing conditions and columns = films)
            Active_Stress_kPa = as(j,Film_Abs_Num);
            Sys_Stress_kPa = ssKPa(j,Film_Abs_Num);
            Dias_Stress_kPa = ds(j,Film_Abs_Num);
            freq_dias_Hz = freq(j,Film_Abs_Num);
            freq_sys_Hz = freq_sys(j,Film_Abs_Num);
            freq_period_Hz = period_freq(j,Film_Abs_Num);
            if DoNotUse_exist == 1 %DoNotUse designation exists in Summary_Auto.mat
                UseData = UseData_matrix(j,Film_Abs_Num);
            else
                UseData = 1; %can be changed later in Data_Reading_Code
            end
            
            if NoContraction_exist == 1 %NoContraction designation exists in Summary_Auto.mat
                No_Contraction = NoContraction_matrix(j,Film_Abs_Num);
            else
                No_Contraction = 0; %can be changed later in Data_Reading_Code
            end

            if Notes_exist == 1
                [rows,columns] = size(Notes);
                if rows == NumberConditions && columns == NumberFilm_Tot
                    Notes_text = Notes{j,Film_Abs_Num};
                else
                end
            else
            end

            %Filename with the rise time and fall time data
            [Data_folder_path_bottom, ~, ~] = fileparts(Partial_path); %split file into path, filename, and extension
            if UDO == 2 || UDO == 3
                Stress_data_file_bottom = [char(Data_folder_path_bottom) '\' char(cond_label(j)) '_top_xProjDatafile_StressDatafile_analyzed.mat'];
            else
                Stress_data_file_bottom = [char(Data_folder_path_bottom) '\' char(cond_label(j)) '_bottom_xProjDatafile_StressDatafile_analyzed.mat'];
            end

            load(Stress_data_file_bottom)
            Fall_time_sec = mean_fall_time(FilmNum_Side);
            Rise_time_sec = mean_rise_time(FilmNum_Side);
            
            %Record the data for this file
            Film_ID = [char(Analysis_ID) '_' Cond_Name '_' char(Top_Bottom) '_' num2str(FilmNum_Side)];
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
            Film_Data_Set(data_set_counter).Relaxation_Rate = Active_Stress_kPa/Fall_time_sec;
            Film_Data_Set(data_set_counter).Contraction_Velocity = Active_Stress_kPa/Rise_time_sec;
            Film_Data_Set(data_set_counter).Primacy = Primacy_vec(j);
            Film_Data_Set(data_set_counter).Top_Bottom = Top_Bottom;
            Film_Data_Set(data_set_counter).FilmNum_Side = FilmNum_Side;
            Film_Data_Set(data_set_counter).Film_Abs_Num = Film_Abs_Num;
            Film_Data_Set(data_set_counter).UseData = UseData;
            Film_Data_Set(data_set_counter).No_Contraction = No_Contraction;
            Film_Data_Set(data_set_counter).UDO = UDO;
            if UDO == 2 || UDO == 3
                Film_Data_Set(data_set_counter).Flip = 1;
            else
                Film_Data_Set(data_set_counter).Flip = 0;
            end
            Film_Data_Set(data_set_counter).Notes = Notes_text;
            Film_Data_Set(data_set_counter).PathFiles = Partial_path;

            data_set_counter = data_set_counter+1; %update for next iteration of loop (next film for current condition)
        end

        for ft = 1:NumberTopFilm %cycle through all top films
            Top_Bottom = 'top'; %film side designation
            FilmNum_Side = ft; %relative film number
            Film_Abs_Num = NumberBotFilm+ft; %absolute film number
            
            %Extract Data for this film
            Active_Stress_kPa = as(j,Film_Abs_Num);
            Sys_Stress_kPa = ssKPa(j,Film_Abs_Num);
            Dias_Stress_kPa = ds(j,Film_Abs_Num);
            freq_dias_Hz = freq(j,Film_Abs_Num);
            freq_sys_Hz = freq_sys(j,Film_Abs_Num);
            freq_period_Hz = period_freq(j,Film_Abs_Num);
            if DoNotUse_exist == 1 %DoNotUse designation exists in Summary_Auto.mat
                UseData = UseData_matrix(j,Film_Abs_Num);
            else
                UseData = 1; %can be changed later in Data_Reading_Code
            end

            if NoContraction_exist == 1 %NoContraction designation exists in Summary_Auto.mat
                No_Contraction = NoContraction_matrix(j,Film_Abs_Num);
            else
                No_Contraction = 0; %can be changed later in Data_Reading_Code
            end
            
            if Notes_exist == 1
                [rows,columns] = size(Notes);
                if rows == NumberConditions && columns == NumberFilm_Tot
                    Notes_text = Notes{j,Film_Abs_Num};
                else
                end
            else
            end

            %Filename with the condition stress data
            [Data_folder_path_top, ~, ~] = fileparts(Partial_path);
            Stress_data_file_top = [char(Data_folder_path_top) '\' char(cond_label(j)) '_top_xProjDatafile_StressDatafile_analyzed.mat'];
            
            load(Stress_data_file_top)
            Fall_time_sec = mean_fall_time(FilmNum_Side);
            Rise_time_sec = mean_rise_time(FilmNum_Side);
            
            %Record the data for this film
            Film_ID = [char(Analysis_ID) '_' Cond_Name '_' char(Top_Bottom) '_' num2str(FilmNum_Side)];
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
            Film_Data_Set(data_set_counter).Relaxation_Rate = Active_Stress_kPa/Fall_time_sec;
            Film_Data_Set(data_set_counter).Contraction_Velocity = Active_Stress_kPa/Rise_time_sec;
            Film_Data_Set(data_set_counter).Primacy = Primacy_vec(j);
            Film_Data_Set(data_set_counter).Top_Bottom = Top_Bottom;
            Film_Data_Set(data_set_counter).FilmNum_Side = FilmNum_Side;
            Film_Data_Set(data_set_counter).Film_Abs_Num = Film_Abs_Num;
            Film_Data_Set(data_set_counter).UseData = UseData;
            Film_Data_Set(data_set_counter).No_Contraction = No_Contraction;
            Film_Data_Set(data_set_counter).UDO = UDO;
            Film_Data_Set(data_set_counter).Flip = 0;
            Film_Data_Set(data_set_counter).Adjusted_FilmNum = 0;
            Film_Data_Set(data_set_counter).Notes = Notes_text;
            Film_Data_Set(data_set_counter).PathFiles = Partial_path;
            
            
            data_set_counter = data_set_counter+1; %update counter for next iteration of loop (next film for current condition)
        end
    end   
end
end