% This script generates figures with several of the images used for data
% processing

clear %clear wrokspace to make way for the workspace from the data colleciton day of interest
disp('Load workspace for day you want to create figures for.') %instruction for user
[FileName,PathName] = uigetfile; % lets user pick .mat file containing temp matrix. 
filenameANDpath = [num2str(PathName), num2str(FileName)]; %stores the complete file path
load(filenameANDpath)

subplot(3,2,1); imshow(pic); title('Colored Image'); %display the orignial colored image for the day

subplot(3,2,2);imshow(inputImage); title('Cropped Colored Image'); %display the cropped colored image 

subplot(3,2,3);imshow(maskedRGBImage); title('"Green" Pixels'); %display the cropped colored image after thresholding. 

 
subplot(3,2,4); image(TempMatrix,'CDataMapping','scaled'); colormap('hot'); title('Thermal Image Used to Create Mask'); %plot representative thermal image

subplot(3,2,5); image(thermal_M,'CDataMapping','scaled'); colormap('hot'); title('Thermal Mask'); % plots thermal mask

subplot(3,2,6); image(maskedThermalImage,'CDataMapping','scaled'); colormap('jet'); title('Thermal Matrix of Interest'); %plots final thermal matrix 

% BELOW ARE JUST A BUNCH OF PLOT FUNCTIONS I WAS LEARNING TO USE. 
% imshow(R,map)
% imtool(TI)
% imshow(R)
% image(R)
% image(R,'CDataMapping','scaled')
% imtool(image(R,'CDataMapping','scaled')
% im =image(R,'CDataMapping','scaled')
% imtool(im)
% imread(im)
% im
% R
% im
% image = image(R)
% image
% imshow(image)
% imshow(R)
% imshow(R,map)
% imshow(R,'gray')
% im
% disp(im)
% image(R,[0,255])
% imshow(R,[0,255])
% imread(R,[0,255])
% Colormap(jet)
% colormap(jet)
% colormap(jet);image(R,'CDataMapping','scaled')
% image(R,'CDataMapping','scaled')
% colormap jet
% image(R);colormap(jet)
% image(R,'CDataMapping','scaled'));colormap(jet)
% image(R,'CDataMapping','scaled');colormap(jet)
% GreenArea('
% GreenArea('FLIR.0006.jpg')
% GreenArea
% image(R,'CDataMapping','scaled');colormap(jet)
% load('matlab.mat')
% image(BW)
% image(R,'CDataMapping','scaled');colormap(jet)
% imshow(BW)
% image(R,'CDataMapping','scaled');colormap(jet)
% imshow(BW)
% subplot(1,2,1);
% imshow(BW);
% subplot(1,2,2);
% image(R,'CDataMapping','scaled');colormap(jet)
% image(R,'CDataMapping','scaled');colormap(jet)
% im =  image(R,'CDataMapping','scaled');colormap(jet)
% im
% im =  image(R,'CDataMapping','scaled');colormap(jet)
% imshow(im)
% imshow(R)
% imshow(R);colormap jet
% DisplayTImage