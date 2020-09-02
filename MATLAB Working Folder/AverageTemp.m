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
%==========================================================================

%PART 1: CREATE MASK TO BE APPLIED TO THERMAL IMAGES

%create a subplot with the binary mask showing where leaves are and the
%thermal image that need to be drawn over so the use can have a decent idea
%where to draw the thermal mask. 
subplot(2,2,1); 
imshow(BW)      
subplot(2,2,2); 

[FileName,PathName] = uigetfile % lets user pick image. Select representative thermal image for data collection day to create mask from.
thermal_strFileName = [num2str(PathName), num2str(FileName)]; %stores the complete file path

TempMatrix = importr(thermal_strFileName); % run importr on selected image to obtain a matrix of temp data
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
%Use importr to oopen temp matrix for each time step then apply thermal mask to that matrix.
%Then, store the avearge of the nonzero elements in the masked thermal matrix to be used
%as time series average temp data for the energy balance IMAGES MUST BE SORTED
%CRONOLIGICALLY FROM BEGINNING TO DAY TO LAST
%==========================================================================




Image_Folder = [PathName] %



myFiles = dir(fullfile(Image_Folder,'*.jpg')); %gets all .jpg files. automatically reads them in by the name field. no need to sort.  

index_for_filling_time_series = 0;


for file = myFiles'
    full_image_path = [num2str(file.folder),'\',num2str(file.name)];
    Timage = importr(full_image_path);
    
    maskedThermalImage = Timage.* thermal_M;
    
    index_for_filling_time_series = index_for_filling_time_series +1;
    TimeSeriesAvgTemp(index_for_filling_time_series) = mean(nonzeros(maskedThermalImage));
end

%convert TimeSeriesAvgTemp to a column vector for export into excel 
Column_TimeSeriesAvgTemp = TimeSeriesAvgTemp'
