%==========================================================================
%This script allows the user to select a colored image, threshold that
%image for a certain group of colors to create a binary mask, and then crop
%the original colored image to the mask created via color thresholding.
%Then, the user is able to spatially calibrate the image by measuring the
%pixel length of an object of known length in the image to determine the
%area of each pixel. The area of each pixel is mulitiplied by the number of
%pixels left after color thresholding to get the total area of wahtever
%color group the user has selected. 
%==========================================================================
clear

mydlg = msgbox('Select the colored image you want to obtain leaf area of.', 'Instruction');
[FileName,PathName] = uigetfile % lets user pick image
color_strFileName = [num2str(PathName), num2str(FileName)]; %stores the complete file path

pic = imread(color_strFileName); %reads the image into a graphical object called pic

%This next section crops the image based on a user drawn Region of Interest
imshow(pic); %display the pic

color_roi = imfreehand; %user draws ROI
color_MM = color_roi.createMask(); %creates logical matrix where the pixels inside the ROI are set to 1 and others are set to 0
maskedRgbImage = pic.*cast(color_MM,'like',pic);
    
%     maskedRgbImage = bsxfun(@times, pic, cast(M, 'like', pic)); % from here https://www.mathworks.com/matlabcentral/answers/38547-masking-out-image-area-using-binary-mask
                                                                  % I just
                                                                  % used maskedRgbImage = pic.*cast(M,'like',pic);
                                                                  
% in colorThresholder get rid of as much that isnt leaf area as
% possible using the HSV pixel wheel and export the results as inputImage, maskedRGBImage, and
% BW. 
colorThresholder(maskedRgbImage)

%This is just so that the next functions don't get called prematurely 
mydlg = warndlg('MOVE THIS TO THE SIDE AND PPRESS "OKAY" ONLY AFTER YOU HAVE HAVE EXPORTED THE RESULTS OF THE COLOR THRESHOLDER', 'WAIT!');
waitfor(mydlg);


disp('Number of green pixels = ') % this will be used to determing the leaf area in real life
display(nnz(BW))
subplot(2,2,1), imshow(pic) 
subplot(2,2,2),imshow(inputImage)
subplot(2,2,3), imshow(maskedRGBImage)
subplot(2,2,4), imshow(BW)

close all
%=============================================================================================
%Next, determine the length of each pixel and use it along with nnz(BW) to
%determine actual area of each pixel and eventually, actual leaf green
%area. 
%=============================================================================================

RulerCrop = imcrop(pic);
close all

imtool(RulerCrop)
Ruler_or_brick = input('Which object did you measure? Enter "ruler" for ruler or "brick" for brick: ', 's');
ObjectLength_pixels = input('How many pixels long is the object? ')
ActualRulerLength = 7.425;
ActualBrickWidth = 3.84375;

if Ruler_or_brick == 'ruler'
    Inches_per_Pixel = ActualRulerLength / ObjectLength_pixels;
end 

if Ruler_or_brick == 'brick'
    Inches_per_Pixel = ActualBrickWidth / ObjectLength_pixels;
end   


ActualArea_of_Pixel = Inches_per_Pixel^2
Green_Area = ActualArea_of_Pixel * nnz(BW)
disp('in^2')
disp('Make sure to save model workspace to appropriate folder for next image processing steps.')