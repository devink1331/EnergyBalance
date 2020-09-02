%This function takes an arraw of size 348x464 and converts it from K to C.
%Could easily adapt to work with matrix of any size
function [CMatrix] = KtoC(KMatrix)

ConversionMatrix(1:348, 1:464)= 273.15
CMatrix = KMatrix - ConversionMatrix

end


