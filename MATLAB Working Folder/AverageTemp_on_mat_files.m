%==========================================================================
%This script firsts asks the user to draw an area of interest over a
%thermal image in order to create a binary mask that will be applied to
%all other thermal images for that data collection day. The goal is to draw
%a regeion of interest that only contains leaf area. Then, that mask is
%applied to all images for the data collection day to obtain matricies for
%each 10 second time step containing temperature data for an area only
%containing leaves. The average of each matrix is obtained (excluding the
%zeros) and saved into a vector that will serve as the time sereis average
%leaf temperature for that day. 
%RUN IN WORKING FOLDER: C:\FLIR Systems\A3374
%THIS VERSOIN IS MODIFIED FORM AVERAGETEMP.M TO USE .MAT FILES DIRECLTY
%INSTEAD OF CONVERTING A THERMAL IMAGE USING IMPORTR TO OBTAIN A TEMP
%MATRIX
%==========================================================================

%PART 1: CREATE MASK TO BE APPLIED TO THERMAL IMAGES

%create a subplot with the binary mask showing where leaves are and the
%thermal image that need to be drawn over so the use can have a decent idea
%where to draw the thermal mask. 
subplot(2,2,1); 
imshow(BW)      
subplot(2,2,2); 

[FileName,PathName] = uigetfile % lets user pick .mat file containing temp matrix. Select representative .mat file for data collection day to create mask from.
thermal_strFileName = [num2str(PathName), num2str(FileName)]; %stores the complete file path

load(thermal_strFileName); % Loads the matlab structure contianing the thermal matrix
TempMatrix = Timage1; %define TempMatrix to be the field in the chosen structure that contains the therma matrix
image(TempMatrix,'CDataMapping','scaled'); %show thermal image in subplot(2,2,2)
colormap('jet')
thermal_roi = imfreehand; %user draws ROI. Do this by taking a look at the binary mask for that day and only included greened area. 
thermal_M = thermal_roi.createMask(); %creates logical matrix where the pixels inside the ROI are set to 1 and others are set to 0

close all %closes the figures used for previous step 

imshow(thermal_M) %shows the user the mask they just created

mydlg = warndlg('Click okay when you are ready to use the same folde  and use the mask behind this dialog box to make a time series of average leaf temperature data', 'WAIT!');
waitfor(mydlg); %wiat for user to pressy "OK"
close all % clsoes figures again. 

%PART 2: APPLY MASK TO ALL THERMAL IMAGES AND STORE AVERAGE LEAF
%TEMPERATURE FOR EACH 10 SECOND TIME STEP OF THE DATA COLLECTION DAY. 

%==========================================================================
%obtain thermal matrix for each time step then apply thermal mask to that matrix.
%Then, store the average of the nonzero elements in the masked thermal matrix to be used
%as time series average temp data for the energy balance IMAGES MUST BE SORTED
%CRONOLIGICALLY FROM BEGINNING TO DAY TO LAST
%==========================================================================




Image_Folder = [PathName] %



myFiles = dir(fullfile(Image_Folder,'*.MAT')); %gets all .MAT files. Need to be sorted by increasing number. Matlab sorts by ASCII character which is not wehat we want
Sorted_myFiles = natsortfiles({myFiles.name})'; %sorts the values in the name field of the myFiles struct and stores them in a cell array



for i = 1 : size(Sorted_myFiles,1) %from i = 1 to the size of SortedmyFiles
    full_image_path = [PathName,Sorted_myFiles{i}];
    MATfile = load(full_image_path); %load the structure in the directory specified by PathName and with file name given by Sorted_myFiles at i
    
    Cell_Array_of_Field_Names = fieldnames(MATfile); %defines a cell array containing the field names of MATfile

    Tmatrix = getfield(MATfile,Cell_Array_of_Field_Names{1}); %get field retrieves the field of a structure with the specified field name. We know we want what is in the first field
    
    maskedThermalImage = Tmatrix.* thermal_M; %apply mask to Tmatrix
    
    TimeSeriesAvgTemp(i) = mean(nonzeros(maskedThermalImage)); %store in in array to be used as time series data. 
end


%convert TimeSeriesAvgTemp to a column vector for export into excel 
Column_TimeSeriesAvgTemp = TimeSeriesAvgTemp' %transpose to make column array. 
disp('Remember, data obtained from AverageTemp_on_mat_files.m is already in Kelvin.')
