%% Loads dataset
knn = 40;
pathMPEG7 = './dataset/MPEG7';
imc = ImageCollection('root', pathMPEG7, 'filePattern', '*.gif', ...
	'preprocessor', @toBinary);

gtLabels = classesFromNames(imc.database, '(\w+)(?=-\d+\.gif$)');
nClasses = numel(unique(gtLabels));
nImages = imc.nImages;

%% Computes features
addpath('./shapeContexts');
% scCalculator = shapeContextsCalculator('K', 800);
% shapemes = scCalculator.computeShapemes(imc);
% shapeContexts = scCalculator.shapeContextsFFactory(shapemes);

printInPlace = printUtility('Processing %d images: #', nImages);

nPoints = 100;
nRadius = 5;
nTheta = 12;
scFeat = zeros(nImages, nRadius * nTheta * nPoints);

for i = 1:nImages
	printInPlace(i);
	bw = imc.at(i);
	boundary = getBoundary(bw);

	if size(boundary, 1) < nPoints * 1.75
		scale = nPoints * 2 / size(boundary, 1);
		boundary = getBoundary(imresize(bw, scale));
	end

	boundary = downsampleBoundary(boundary, nPoints);
	SC = calcShapeContexts(boundary, nRadius, nTheta);
	SC = SC';
	scFeat(i, :) = SC(:)';
end

%% Matching
matcher = ExhaustiveSearcher(scFeat);
[nearInd, ~] = knnsearch(matcher, scFeat, 'K', knn);
sameClass = bsxfun(@eq, gtLabels(nearInd), gtLabels);
% calculates the bull's eye score
percentage = sum(sum(sameClass)) / (nImages / nClasses * nImages);
fprintf('Score = %f\n', percentage);
