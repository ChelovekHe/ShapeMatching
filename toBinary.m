function [bw] = toBinary(bw)
% ImageCollection preprocessor.
% We need this because the bit depths of gif B&W images can be either 1 
% or 8. Therefore `im2bw` could fail sometimes.
% 
% Explicit conversion depending on bit depths is OK:
% 
%     info = imfinfo(imagePath);
%     if info.BitDepth == 1
%         ...
%     else if info.BitDepth == 8
%         ...
%     end
% 
% However, direcly converting to binary files is easier.

	bw = bw > 0;
end
