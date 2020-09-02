% The purpose of this script is to run the FAO Penman Monteith equaiton on
% each data collection day and put the resutls in a the workbook for that
% day. the formulation of all equaitons is found in the 9.24 EB workbook.
% First I ask for a spreadsheet, then clear a range in that spreadsheet,
% then fill a some cells with constants to use in the PM equation. Then the
% table of meteorological data is brought in as a matrix after finding out
% how many rows of data were collected for that day. Then, through very
% brute force coding methods, a matrix is filled with the parameteres needed
% to run the PM equaiton and then calcualte it for each time step. The final matrix is written to the excel sheet
% summary statistics are taken from that matrix and written to the workbook. 
%THE ONLY DIFFERENCE BETWEEN THIS AND THE GRASS ONE IS THE COEFFICIENTS IN
%THE PM EQUATION. I USED A REFERENCE CROP HEIGHT OF .5 M TO CALCULATE THEM
%BEFORE I REALIZED THATS WHAT THE TALL REFERENCE CROP FOR THE ASCE EQUATION
%WAS. 

clear
mydlg = msgbox('Select Excel File to use to Calcualte FAO PM and Statistics', 'Instruction');
[FileName,PathName] = uigetfile; % lets user pick an excel workbook. store the file name and path name as strings
FullFileName = [num2str(PathName), num2str(FileName)]; %stores the complete file path as a string

addpath(PathName); % adds the specified folders to the top of the search path for the current MATLAB® session
xlRange = 'AT1:CB2000'; %defines an excel range 



xlswrite(FullFileName,{''},1,xlRange) % puts the empty string in the excel range


xlswrite(FullFileName,{'Constants for PM'},1,'AV5'); % place the given item, or list of items as in below, starting at cell AV5 
xlswrite(FullFileName,{'1 MJ/m^2/d = 11.6 W/m^2',11.6},1,'AV6');
xlswrite(FullFileName,{'alpha, canopy reflection',.19},1,'AV7');
xlswrite(FullFileName,{'cp, specific heat capacity (MJ/kg/DegC)',0.0010130},1,'AV8');
xlswrite(FullFileName,{'epsilon, ratio molecular weight of water vapour/dry air',0.622},1,'AV9');
xlswrite(FullFileName,{'lambda, latent heat of vaporization (MJ/kg)',2.45},1,'AV10');
xlswrite(FullFileName,{'elevation (m)',126.1872},1,'AV11');
xlswrite(FullFileName,{'P, atm pressure (kPa)',99.81725374},1,'AV12');
xlswrite(FullFileName,{'z, height of wind measurement (m)',1.1049},1,'AV13');

Full_table = xlsread(FullFileName, 'E6:AR2000'); %define a matrix to be the specified cells from the given excel file
F = find(~isnan(Full_table(:,1))); %find all the elements in the first column of Full_table that are not nan values and return a vector containing thier indicies in that column. That vector, F, then has size equal to the number of data points for that day.
first_nz_cell_in_table = size(F,1) + 6; % the met data needed for the ET0 calcs start at E6 so the first NAN value is found by adding 6 to the size of F
Last_row_in_matrix = size(F,1); %used to stop the loops below at appropriate index. Could have just used the size of any row of Met_Data below
Met_Data = xlsread(FullFileName, ['E6:AW',num2str(first_nz_cell_in_table)]);
Last_col = 15; % 15 values need to be calculated and tabulated to calculate the FAO PM equation. used to stop the for loop. 

for j = 1:Last_row_in_matrix %construct a matrix (PM_array) full of parameters needed to calculate the FAO PM ET0 equation for each time step and calculate

     %cacluates delta
     PM_array(j,1) =  (4098*(0.6108*exp((17.27*Met_Data(j,22))/(Met_Data(j,22)+237.3))))  /  (Met_Data(j,22)+237.3)^2;
     
     %convert Rs in W/m^2 to MJ/m^2/d
     PM_array(j,2) =  Met_Data(j,1)/Met_Data(1,45); 

     %convert Rs in MJ/m^2/d to MJ/m^2/hr
     PM_array(j,3) =  PM_array(j,2)/24;

     %calculates net solar radiation Rns
     PM_array(j,4) =  (1-Met_Data(2,45))*PM_array(j,3);

     %calcualtes Rnl and converts it from W/m^2 to MJ/m^2/d
     PM_array(j,5) =  (Met_Data(j,14) - Met_Data(j,13)) / Met_Data(1,45);

     %converts Rnl from MJ/m^2/d to MJ/m^2/hr
     PM_array(j,6) =  PM_array(j,5)/24;
    
     %calcualtes Rn
     PM_array(j,7) =  PM_array(j,4) - PM_array(j,6);

     %calcualtes G
     PM_array(j,8) =  .1*PM_array(j,7);

     %calcualtes the constant gamma
     PM_array(1,9) = Met_Data(3,45) * Met_Data(7,45) / (Met_Data(4,45) * Met_Data(5,45));

     %pulls the temp over from the Met_data matrix
     PM_array(j,10) =  Met_Data(j,22);

     %calculates wind speed adjusted to 2m above ground
     PM_array(j,11) =  Met_Data(j,17)  *  (4.87 / log(67.8*Met_Data(8,45) - 5.42));

     %calculates the saturation vapor pressure enot(T)
     PM_array(j,12) =  0.6108*exp(17.27*PM_array(j,10) / (PM_array(j,10)+237.3));
    
     %calculates vapor pressure, ea
     PM_array(j,13) =  PM_array(j,12)*Met_Data(j,16)/100;

     %calculates ET0 in mm/hr for each 10 second time step
     PM_array(j,14) =  (0.408*PM_array(j,1)*(PM_array(j,7)-PM_array(j,8))   +  PM_array(1,9)*(76/(PM_array(j,10)+273))*PM_array(j,11)*(PM_array(j,12)-PM_array(j,13)))   /   (PM_array(j,1)+PM_array(1,9)*(1+0.15*PM_array(j,11)));

     %converts ET in mm/hr to mm per 10 second time step
     PM_array(j,15) =  PM_array(j,14) / 60 / 6;

    
end

PM_array(Last_row_in_matrix +3,15) = sum(PM_array(:,15)); % sum up ET0 of each time step
xlswrite(FullFileName, PM_array,1,'AX6') %right PM_array to excel to do further analysis


%getting min, max, and average parameters for the ET0 and
%energy balance 
%calcualtions and writing them to the excel sheet. 
xlswrite(FullFileName,{'Energy Balance'},1,'AT8');
QSWin = {'Min',min(Met_Data(:,24)); 'Max',max(Met_Data(:,24)); 'Average',mean(Met_Data(:,24))};
xlswrite(FullFileName,QSWin,1,'AT9');
QTIRin = {'Min',min(Met_Data(:,30)); 'Max',max(Met_Data(:,30)); 'Average',mean(Met_Data(:,30))};
xlswrite(FullFileName,QTIRin,1,'AT13');
QTIRout = {'Min',min(Met_Data(:,34)); 'Max',max(Met_Data(:,34)); 'Average',mean(Met_Data(:,34))};
xlswrite(FullFileName,QTIRout,1,'AT17');
Qcout = {'Min',min(Met_Data(:,36)); 'Max',max(Met_Data(:,36)); 'Average',mean(Met_Data(:,36))};
xlswrite(FullFileName,Qcout,1,'AT21');

xlswrite(FullFileName,{'FAO PM'},1,'AT25');
delta = {'Min',min(nonzeros(PM_array(:,1))); 'Max',max(PM_array(:,1)); 'Average',mean(PM_array(:,1))};
xlswrite(FullFileName,delta,1,'AT27');
Rn = {'Min',min(nonzeros(PM_array(:,7))); 'Max',max(PM_array(:,7)); 'Average',mean(PM_array(:,7))};
xlswrite(FullFileName,Rn,1,'AT31');
G = {'Min',min(nonzeros(PM_array(:,8))); 'Max',max(PM_array(:,8)); 'Average',mean(PM_array(:,8))};
xlswrite(FullFileName,G,1,'AT35');
Thr = {'Min',min(nonzeros(PM_array(:,10))); 'Max',max(PM_array(:,10)); 'Average',mean(PM_array(:,10))};
xlswrite(FullFileName,Thr,1,'AT39');
U2 = {'Min',min(nonzeros(PM_array(:,11))); 'Max',max(PM_array(:,11)); 'Average',mean(PM_array(:,11))};
xlswrite(FullFileName,U2,1,'AT43');
enot = {'Min',min(nonzeros(PM_array(:,12))); 'Max',max(PM_array(:,12)); 'Average',mean(PM_array(:,12))};
xlswrite(FullFileName,enot,1,'AT47');
ea = {'Min',min(nonzeros(PM_array(:,13))); 'Max',max(PM_array(:,13)); 'Average',mean(PM_array(:,13))};
xlswrite(FullFileName,ea,1,'AT51');

%right column headings for ET0 parameters 
xlswrite(FullFileName,{'delta kPa/DegC','Rs Mj/m^2/d','Rs Mj/m^2/hr','Rns Mj/m^2/hr','Rnl Mj/m^2/d','Rnl Mj/m^2/hr','Rn Mj/m^2/hr','G Mj/m^2/hr','gamma kPa/DegC','Thr DegC','u2 m/s','enot(T) kPa','ea kPa', 'ET0 mm/hr','ET0 mm'},1,'AX3') 

