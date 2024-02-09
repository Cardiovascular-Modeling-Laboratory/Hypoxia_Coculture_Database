# Hypoxia_Coculture_Database
This repository contains the codes to generate a database structure with file locations for each data set (obtained from analyzing images with Z-line Detect and MTF contraction videos with MTF Analysis code) and extracting data from the analysis files. Helper tables are also included. The output .csv files are to be used with Microsoft Access.
# Procedure
1. Run the Location_Code to generate a unique ID for each analysis, to store the path of each data file, and to run checks for duplicates in the database.
2. Run the Data_Reading_Code (used with its required functions) to extract data from each data file to generate a database
3. The output .csv file of the Data_Reading_Code can be coupled with Microsoft Access to sort/filter data
