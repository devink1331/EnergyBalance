% FlirMovieReader MATLAB class for reading flir file formats
classdef FlirMovieReader < handle
	properties (SetAccess = private, Hidden = true)
		impl;					% Handle to class implemented in mex
	end
	properties
		unit;					% Unit to output (counts, radianceUser, temperatureUser, objectSignal, radianceFactory, temperatureFactory)
		temperatureType;		% Temperature type to output (celsius, fahrenheit, kelvin, rankine)
		applyNuc;				% Apply non-uniformity correction
		applyBadPixels;			% Apply bad pixel replacement
		applySuperfame;			% Collapse subframes into a superframe
		objectParameters;		% Object Parameter structure
	end
	properties (SetAccess = private)
		frameIndex;				% Index of the last frame read
	end
	methods
		% Create a FlirMovieReader objectds
		function obj = FlirMovieReader(varargin)
			obj.impl = FlirMovieReaderMex('new', varargin{:});
		end

		% Delete the object
		function delete(obj)
			FlirMovieReaderMex('delete', obj.impl);
		end

		% Read the next frame from the movie
		function varargout = step(obj, varargin)
			% yes step and read have the same implementation, so you could step(index)
			[varargout{1:nargout}] = FlirMovieReaderMex('step', obj.impl, varargin{:});
		end

		% Read the given frame, or the next frame if no frame number given
		function varargout = read(obj, varargin)
			% yes step and read have the same implementation, so you could step(index)
			[varargout{1:nargout}] = FlirMovieReaderMex('step', obj.impl, varargin{:});
		end

		% Get info about the movie
		function ret = info(obj)
			ret = FlirMovieReaderMex('getInfo', obj.impl);
		end

		% Step takes 0 inputs
		function ret = getNumInputs(obj)
			ret = 0;
		end

		% Step can return up to 3 outputs, image data, meta data, status
		function ret = getNumOutputs(obj)
			ret = 3;
		end

		% Check if all frames from the movie have been read
		function ret = isDone(obj)
			ret = FlirMovieReaderMex('getIsDone', obj.impl);
		end

		% Rewind to the first frame in the movie
		function reset(obj)
			FlirMovieReaderMex('reset', obj.impl);
		end

		% Revert back object parameters specified in the file
		function resetObjectParameters(obj)
			FlirMovieReaderMex('resetObjectParameters', obj.impl);
		end

		% get the frame, metadata, status from the last frame read
		function ret = getFinal(obj)
			ret = FlirMovieReaderMex('getFinal', obj.impl);
		end

		function ret = getMetaData(obj)
			ret = FlirMovieReaderMex('getMetaData', obj.impl);
		end

		function ret = getStatus(obj)
			ret = FlirMovieReaderMex('getStatus', obj.impl);
		end

		% property accessor/mutator
		function ret = get.unit(obj)
			ret = FlirMovieReaderMex('getUnit', obj.impl);
		end

		function obj = set.unit(obj, value)
			FlirMovieReaderMex('setUnit', obj.impl, value);
		end

		function ret = get.temperatureType(obj)
			ret = FlirMovieReaderMex('getTemperatureType', obj.impl);
		end

		function obj = set.temperatureType(obj, value)
			FlirMovieReaderMex('setTemperatureType', obj.impl, value);
		end

		function ret = get.applyNuc(obj)
			ret = FlirMovieReaderMex('getApplyNuc', obj.impl);
		end

		function obj = set.applyNuc(obj, value)
			FlirMovieReaderMex('setApplyNuc', obj.impl, value);
		end

		function ret = get.applyBadPixels(obj)
			ret = FlirMovieReaderMex('getApplyBadPixels', obj.impl);
		end

		function obj = set.applyBadPixels(obj, value)
			FlirMovieReaderMex('aetApplyBadPixels', obj.impl, value);
		end

		function ret = get.applySuperfame(obj)
			ret = FlirMovieReaderMex('getApplySuperfame', obj.impl);
		end

		function obj = set.applySuperfame(obj, value)
			FlirMovieReaderMex('setApplySuperfame', obj.impl, value);
		end

		function ret = get.objectParameters(obj)
			ret = FlirMovieReaderMex('getObjectParameters', obj.impl);
		end

		function obj = set.objectParameters(obj, value)
			FlirMovieReaderMex('setObjectParameters', obj.impl, value);
		end

		function ret = get.frameIndex(obj)
			ret = FlirMovieReaderMex('getFrameIndex', obj.impl);
		end
	end
end
