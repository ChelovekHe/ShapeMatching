classdef ImageCollection < handle
	properties
	nImages;
	root;
	database;  % relative paths of images in the database
	preprocessor;
	postprocessor;
	end

	methods
	function obj = ImageCollection(varargin)
		p = inputParser;
		addParamValue(p, 'root', '', @isstr);
		addParamValue(p, 'database', {}, @iscell);
		addParamValue(p, 'maxImages', Inf, @isnumeric);
		addParamValue(p, 'filePattern', '*', @isstr);
		addParamValue(p, 'preprocessor', @deal, @(x) isa(x, 'function_handle'));
		addParamValue(p, 'postprocessor', @deal, @(x) isa(x, 'function_handle'));
		parse(p, varargin{:});

		obj.root = p.Results.root;
		if isempty(p.Results.database)
			if isempty(obj.root)
				error('Invalid arguments');
			end
			obj.database = retrieveFiles(p.Results.root, p.Results.filePattern, ...
				0, p.Results.maxImages);
		else
			obj.database = p.Results.database;
		end

		obj.nImages = size(obj.database, 1);
		if obj.nImages > p.Results.maxImages
			obj.database = obj.database(1:maxImages);
		end

		obj.preprocessor = p.Results.preprocessor;
		obj.postprocessor = p.Results.postprocessor;
	end

	function bw = at(obj, ind)
		imagePath = fullfile(obj.root, obj.database{ind});
		im = imread(imagePath);

		if ~isequal(obj.preprocessor, @deal)
			im = obj.preprocessor(im);
		end

		if ~islogical(im)
			bw = im2bw(im);
		else
			bw = im;
		end

		if ~isequal(obj.postprocessor, @deal)
			bw = obj.postprocessor(bw);
		end
	end
	end
end
