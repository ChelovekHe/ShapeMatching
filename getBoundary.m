function boundary = getBoundary(bw)
% Gets the boundary of a binary image.
% bw: binary image
	boundaries = bwboundaries(bw, 8);
	boundary = vertcat(boundaries{:});
end
