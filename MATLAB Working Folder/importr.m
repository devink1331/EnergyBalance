function [data, info, metadata] = importr(varargin) % to call this funciton on a photo without selecting it via uigetfile just pass the file name as the argument like importr('full path to file')
%importRadio
%   Use this function to browse for a file and import it into MatLab
%   workspace using the File SDK
%   If no file name is given, the function will open the file browser.
%   The data is imported as a three dimensional matrix of values

% add the necessary libraries and dll's
addpath("File SDK libraries")

% this loop checks if a file is parsed in the code. If not, then it will
% open a browser dialog so you can select the file you want to import
if nargin == 0
    [FileName,PathName] = uigetfile({'*.seq', '*.ats', '*.csq', '*jpg';...
        'sequence files', 'ats files', 'compressed sequence files', 'radiometric jpeg'}',...
        'Select the sequence to read') ;
    strFileName = [num2str(PathName), num2str(FileName)];
     v = FlirMovieReader(strFileName);
    
else
    v = FlirMovieReader(varargin{1});
    
end

% set units to degrees Celsius
v.unit = 'temperatureFactory'; 
v.temperatureType = 'celsius';

% get info from file header
info = v.info();

% change some the desired object parameters
% NOTE: object parameters must be changed in this way since it is a struct 
v.objectParameters = struct('emissivity', 1.0,...
    'estAtmosphericTransmission', 1.0,...
    'extOpticsTransmission', 1.0);

% import data and metadata for each frame
data = zeros(info.height, info.width, info.numFrames);
i = 1;
while ~isDone(v)
    data(:,:,i) = step(v); 
    metadata(i) = getMetaData(v);
    i = i+1;
end

%xlswrite("C:\Users\Owner\OneDrive\Villanova\Masters\IR imaging\data\thermography\(8-29-19) Full\Images.xlsx",ans,'Sheet1','A1')

end


