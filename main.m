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

% 1. Original; 2. Left/right flipped; 3. Up/down flipped
scFeats = cell(3, 1);
for j = 1:3
	scFeats{j} = zeros(nImages, nRadius * nTheta * nPoints);
end

for i = 1:nImages
	printInPlace(i);
	bw = cell(3, 1);
	bw{1} = imc.at(i);
	bw{2} = fliplr(bw{1});
	bw{3} = flipud(bw{1});

	for j = 1:3
		boundary = getBoundary(bw{j});
		if size(boundary, 1) < nPoints * 1.75
			scale = nPoints * 2 / size(boundary, 1);
			boundary = getBoundary(imresize(bw{j}, scale));
		end

		boundary = downsampleBoundary(boundary, nPoints);
		SC = calcShapeContexts(boundary, nRadius, nTheta);
		SC = SC';
		scFeats{j}(i, :) = SC(:)';
	end
end

%% Matching
for j = 3:-1:1
	matcher = ExhaustiveSearcher(scFeats{j});
	[nearInd{j}, dists{j}] = knnsearch(matcher, scFeats{1}, 'K', knn);
end

printInPlace = printUtility('Processing %d images: #', nImages);
nearestOfAll = zeros(nImages, knn);

for i = 1:nImages
	printInPlace(i);
	best = inf(nImages, 1);
	for j = 1:3
		near = nearInd{j}(i, :)';
		dst = dists{j}(i, :)';
		best(near) = min(best(near), dst);
	end

	[~, ind] = sort(best);
	nearestOfAll(i, :) = ind(1:knn)';
end

sameClass = bsxfun(@eq, gtLabels(nearestOfAll), gtLabels);
% calculates the bull's eye score
percentage = sum(sum(sameClass)) / (nImages / nClasses * nImages);
fprintf('Score = %f\n', percentage);
