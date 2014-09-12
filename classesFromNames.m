function [labels] = classesFromNames(names, rePattern)
% Finds ground truth class labels from file names.
% 
% Input:
%   names: n-by-1 cell array of file names;
%   rePattern: regexp pattern to extract information;
% 
% Output:
%   labels: n-by-1 array of labels
% 
% Example:
%   % MPEG-7, look-ahead regexp matching
%   labels = classesFromNames(names, '(\w+-)(?=\d+\.gif$)');

	prefix = 'C_';  % valid field names should not start with numbers
	classNames = regexp(names, rePattern, 'match');
	classNames = strcat(prefix, vertcat(classNames{:}));
	nSamples = numel(classNames);
	nClasses = 0;

	classDict = struct();
	labels = zeros(nSamples, 1);

	for i = 1:nSamples
		if isfield(classDict, classNames{i})
			labels(i) = classDict.(classNames{i});
		else
			nClasses = nClasses + 1;
			classDict.(classNames{i}) = nClasses;
			labels(i) = nClasses;
		end
	end
end
