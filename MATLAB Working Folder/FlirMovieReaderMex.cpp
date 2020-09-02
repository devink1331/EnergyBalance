#define _CRT_SECURE_NO_WARNINGS

#include "mex.h"
#include "tc.file/tc.file.h"
#include <typeinfo>

//	mex FlirMovieReaderMex.cpp -I%FILESDKDIR%include -L%FILESDKDIR%bin/x64/Release -ltc.lib -ltc.file.lib -ltc.reduce.lib

//	matlab data mashalling helper functions
template <typename kind> struct mxClassFromType;

template <> struct mxClassFromType<tc::Int8> { static const mxClassID value = mxINT8_CLASS; };
template <> struct mxClassFromType<tc::UInt8> { static const mxClassID value = mxUINT8_CLASS; };
template <> struct mxClassFromType<tc::Int16> { static const mxClassID value = mxINT16_CLASS; };
template <> struct mxClassFromType<tc::UInt16> { static const mxClassID value = mxUINT16_CLASS; };
template <> struct mxClassFromType<tc::Int32> { static const mxClassID value = mxINT32_CLASS; };
template <> struct mxClassFromType<tc::UInt32> { static const mxClassID value = mxUINT32_CLASS; };
template <> struct mxClassFromType<tc::Int64> { static const mxClassID value = mxINT64_CLASS; };
template <> struct mxClassFromType<tc::UInt64> { static const mxClassID value = mxUINT64_CLASS; };
template <> struct mxClassFromType<tc::Flt32> { static const mxClassID value = mxSINGLE_CLASS; };
template <> struct mxClassFromType<tc::Flt64> { static const mxClassID value = mxDOUBLE_CLASS; };
template <> struct mxClassFromType<int> { static const mxClassID value = mxINT32_CLASS; };
template <> struct mxClassFromType<unsigned int> { static const mxClassID value = mxUINT32_CLASS; };

template <typename kind>
mxArray *mxCreateNumericScalar(kind value)
{
	mxArray		*ret = mxCreateNumericMatrix(1, 1, mxClassFromType<kind>::value, mxREAL);

	*((kind *)mxGetData(ret)) = value;

	return ret;
}

template <typename kind>
mxArray *mxCreateNumericArray(kind *ar, size_t len)
{
	mxArray		*ret = mxCreateNumericMatrix(len, 1, mxClassFromType<kind>::value, mxREAL);

	memcpy(mxGetData(ret), ar, len * sizeof(kind));

	return ret;
}

mxArray *mxCreateLogicalArray(bool *ar, size_t len)
{
	mxArray		*ret = mxCreateLogicalMatrix(len, 1);

	memcpy(mxGetData(ret), ar, len * sizeof(bool));

	return ret;
}

template<typename kdest, typename ksrc>
void RowMajorToColMajor(kdest *dest, const ksrc *src, tc::UInt32 width, tc::UInt32 height) {
	tc::UInt32		x, y;

	for (y = 0; y < height; ++y) {
		for (x = 0; x < width; ++x) {
			dest[x * height + y] = (kdest)src[y * width + x];
		}
	}
}

mxArray *MarshalImage(tc::STypedData data, tc::UInt32 width, tc::UInt32 height)
{
	mxArray		*ret(NULL);

	switch (data.Type) {
		case tc::dtInt8:
			ret = mxCreateNumericMatrix(height, width, mxINT8_CLASS, mxREAL);
			RowMajorToColMajor((tc::Int8 *)mxGetData(ret), data.pInt8, width, height);
			break;
		case tc::dtUInt8:
			ret = mxCreateNumericMatrix(height, width, mxUINT8_CLASS, mxREAL);
			RowMajorToColMajor((tc::UInt8 *)mxGetData(ret), data.pUInt8, width, height);
			break;
		case tc::dtInt16:
			ret = mxCreateNumericMatrix(height, width, mxINT16_CLASS, mxREAL);
			RowMajorToColMajor((tc::Int16 *)mxGetData(ret), data.pInt16, width, height);
			break;
		case tc::dtUInt16:
			ret = mxCreateNumericMatrix(height, width, mxUINT16_CLASS, mxREAL);
			RowMajorToColMajor((tc::UInt16 *)mxGetData(ret), data.pUInt16, width, height);
			break;
		case tc::dtInt32:
			ret = mxCreateNumericMatrix(height, width, mxINT32_CLASS, mxREAL);
			RowMajorToColMajor((tc::Int32 *)mxGetData(ret), data.pInt32, width, height);
			break;
		case tc::dtUInt32:
			ret = mxCreateNumericMatrix(height, width, mxUINT32_CLASS, mxREAL);
			RowMajorToColMajor((tc::UInt32 *)mxGetData(ret), data.pUInt32, width, height);
			break;
		case tc::dtInt64:
			ret = mxCreateNumericMatrix(height, width, mxINT64_CLASS, mxREAL);
			RowMajorToColMajor((tc::Int64 *)mxGetData(ret), data.pInt64, width, height);
			break;
		case tc::dtUInt64:
			ret = mxCreateNumericMatrix(height, width, mxUINT64_CLASS, mxREAL);
			RowMajorToColMajor((tc::Int64 *)mxGetData(ret), data.pInt64, width, height);
			break;
		case tc::dtFlt32:
			ret = mxCreateNumericMatrix(height, width, mxSINGLE_CLASS, mxREAL);
			RowMajorToColMajor((tc::Flt32 *)mxGetData(ret), data.pFlt32, width, height);
			break;
		case tc::dtFlt64:
			ret = mxCreateNumericMatrix(height, width, mxDOUBLE_CLASS, mxREAL);
			RowMajorToColMajor((tc::Flt64 *)mxGetData(ret), data.pFlt64, width, height);
			break;
		case tc::dtRGB24:
		case tc::dtRGB48:
		default:
			mexErrMsgTxt("Unsupported image data format.");
			break;
	}

	return ret;
}

mxArray *MarshalImage(tc::ITypedBufferPtr data, tc::UInt32 width, tc::UInt32 height)
{
	if (data == NULL)
		mexErrMsgTxt("Bad pointer.");

	return MarshalImage(data->typedData(), width, height);
}

inline tc::CStringA mxGetString(const mxArray *ar)
{
	if (!mxIsChar(ar))
		mexErrMsgTxt("String expected");
	//	unknown if mxGetChars return is null terminated, assuming it's not and using number of elements as string length

	tc::CStringA	ret;

	ret.Copy(mxGetChars(ar), mxGetNumberOfElements(ar));

	return ret;
}

inline bool mxGetLogical(const mxArray *ar)
{
	if (!mxIsLogical(ar))
		mexErrMsgTxt("Logical expected");
	//	unknown if mxGetChars return is null terminated, assuming it's not and using number of elements as string length

	return (*mxGetLogicals(ar) != 0);
}

template <typename kind>
kind mxGetNumeric(const mxArray *ar)
{
	kind		ret;
	mxClassID	type;

	if (mxIsComplex(ar))
		mexErrMsgTxt("Must not be complex.");

	type = mxGetClassID(ar);

	switch (type) {
		case mxINT8_CLASS:
			ret = (kind)(*((tc::Int8 *)mxGetData(ar)));
			break;
		case mxUINT8_CLASS:
			ret = (kind)(*((tc::UInt8 *)mxGetData(ar)));
			break;
		case mxINT16_CLASS:
			ret = (kind)(*((tc::Int16 *)mxGetData(ar)));
			break;
		case mxUINT16_CLASS:
			ret = (kind)(*((tc::UInt16 *)mxGetData(ar)));
			break;
		case mxINT32_CLASS:
			ret = (kind)(*((tc::Int32 *)mxGetData(ar)));
			break;
		case mxUINT32_CLASS:
			ret = (kind)(*((tc::UInt32 *)mxGetData(ar)));
			break;
		case mxINT64_CLASS:
			ret = (kind)(*((tc::Int64 *)mxGetData(ar)));
			break;
		case mxUINT64_CLASS:
			ret = (kind)(*((tc::UInt64 *)mxGetData(ar)));
			break;
		case mxSINGLE_CLASS:
			ret = (kind)(*((tc::Flt32 *)mxGetData(ar)));
			break;
		case mxDOUBLE_CLASS:
			ret = (kind)(*((tc::Flt64 *)mxGetData(ar)));
			break;
		default:
			mexErrMsgTxt("Unsupported type.");
			break;
	}

	return ret;
}

//	enum parsing utility functions and enum definitions
struct SEnumInfo
{
	const char	*name;
	int			value;
};

int ParseEnum(SEnumInfo info[], const char *name)
{
	int		i = 0;

	while (info[i].name != NULL) {
		if (_stricmp(info[i].name, name) == 0)
			return info[i].value;
		++i;
	}

	return info[i].value;
}

const char *EnumToString(SEnumInfo info[], int value)
{
	int		i = 0;

	while (info[i].name != NULL) {
		if (info[i].value == value)
			return info[i].name;
		++i;
	}

	return "error";
}

SEnumInfo	UnitEnumInfo[] = {
	{ "counts",					tc::unitCounts },
	{ "radianceUser",			tc::unitRadianceUser },
	{ "temperatureUser",		tc::unitTemperatureUser },
	{ "objectSignal",			tc::unitObjectSignal },
	{ "radianceFactory",		tc::unitRadianceFactory },
	{ "temperatureFactory",		tc::unitTemperatureFactory },
	{ "rgb24",					tc::unitRGB24 },
	{ "rgb48",					tc::unitRGB48 },
	{ "redChannel",				tc::unitRedChannel },
	{ "greenChannel",			tc::unitGreenChannel },
	{ "blueChannel",			tc::unitBlueChannel },
	{ "rgbAverage",				tc::unitRGBAverage },
	{ NULL,						tc::unitError },
};

SEnumInfo	TemperatureTypeEnumInfo[] = {
	{ "celsius",				tc::ttCelsius },
	{ "fahrenheit",				tc::ttFahrenheit },
	{ "kelvin",					tc::ttKelvin },
	{ "rankine",				tc::ttRankine },
	{ NULL,						tc::ttError },
};

SEnumInfo	DataTypeEnumInfo[] = {
	{ "int8",					tc::dtInt8 },
	{ "uint8",					tc::dtUInt8 },
	{ "int16",					tc::dtInt16 },
	{ "uint16",					tc::dtUInt16 },
	{ "int32",					tc::dtInt32 },
	{ "uint32",					tc::dtUInt32 },
	{ "int64",					tc::dtInt64 },
	{ "uint64",					tc::dtUInt64 },
	{ "single",					tc::dtFlt32 },
	{ "double",					tc::dtFlt64 },
	{ "rgb24",					tc::dtRGB24 },
	{ "rgb48",					tc::dtRGB48 },
	{ NULL,						tc::dtError },
};

//	the matlab file sdk wrapper
class CMatImagerFile
{
private:
	tc::file::CImagerFile		mFile;
	tc::Int64					mFrameNumber;
	tc::UInt32					mNextFrameNumber;
	tc::EUnit					mUnit;
	tc::ETempType				mTempType;
	bool						mApplyBadPixels;
	bool						mApplyNuc;
	bool						mApplySuperframe;

public:
	CMatImagerFile(tc::CStringA filename) :
		mFrameNumber(-1),
		mNextFrameNumber(0),
		mApplySuperframe(false)
	{
		if (!mFile.Open(tc::fileSystem(), tc::CString(filename)))
			mexErrMsgTxt(tc::CStringA::FromFormat("Failed to open file: %s.", filename.c_str()).c_str());

		mUnit = mFile.baseUnit();
		mTempType = mFile.baseTempType();
		mApplyNuc = mFile.hasNUC();
		mApplyBadPixels = mFile.hasBP();
	}

	mxArray *info()
	{
		tc::TArray<const char *>	fields;
		mxArray						*info;

		fields[0] = "width";
		fields[1] = "height";
		fields[2] = "numFrames";
		fields[3] = "dataType";
		fields[4] = "baseUnit";
		fields[5] = "baseTemperatureType";
		fields[6] = "isAbated";
		fields[7] = "availablePresets";
		fields[8] = "abatedPresets";
		fields[9] = "initialPreset";
		fields[10] = "hasNuc";
		fields[11] = "hasBpm";
		fields[12] = "availableUnits";
		fields[13] = "isSuperframing";
		fields[14] = "canChangeObjectParameters";
		fields[15] = "numPresets";

		info = mxCreateStructMatrix(1, 1, fields.size(), fields.data());

		mxSetFieldByNumber(info, 0, 0, mxCreateNumericScalar(mFile.width()));
		mxSetFieldByNumber(info, 0, 1, mxCreateNumericScalar(mFile.height()));
		mxSetFieldByNumber(info, 0, 2, mxCreateNumericScalar(mFile.numFrames()));
		mxSetFieldByNumber(info, 0, 3, mxCreateString(EnumToString(DataTypeEnumInfo, mFile.dataType())));
		mxSetFieldByNumber(info, 0, 4, mxCreateString(EnumToString(UnitEnumInfo, mFile.baseUnit())));
		mxSetFieldByNumber(info, 0, 5, mxCreateString(EnumToString(TemperatureTypeEnumInfo, mFile.baseTempType())));
		mxSetFieldByNumber(info, 0, 6, mxCreateLogicalScalar(mFile.isAbated()));
		bool		avail[tc::psCount] = { false };
		if (!mFile.GetAvailablePresets(avail))
			memset(avail, 0, sizeof(avail));
		mxSetFieldByNumber(info, 0, 7, mxCreateLogicalArray(avail, tc::psCount));
		bool		abated[tc::psCount] = { false };
		if (!mFile.GetAbatedPresets(abated))
			memset(abated, 0, sizeof(abated));
		mxSetFieldByNumber(info, 0, 8, mxCreateLogicalArray(abated, tc::psCount));
		mxSetFieldByNumber(info, 0, 9, mxCreateNumericScalar(mFile.GetInitialPreset()));
		mxSetFieldByNumber(info, 0, 10, mxCreateLogicalScalar(mFile.hasNUC()));
		mxSetFieldByNumber(info, 0, 11, mxCreateLogicalScalar(mFile.hasBP()));
		tc::TArray<const char *>	unitStrings;
		tc::TArray<tc::EUnit>		units;
		if (!mFile.GetUnits(units))
			mexErrMsgTxt("GetUnits failed.");
		for (tc::UInt32 i = 0; i < units.size(); ++i)
			unitStrings.push_back(EnumToString(UnitEnumInfo, units[i]));
		mxSetFieldByNumber(info, 0, 12, mxCreateCharMatrixFromStrings(unitStrings.size(), unitStrings.data()));
		mxSetFieldByNumber(info, 0, 13, mxCreateLogicalScalar(mFile.isSuperframing()));
		mxSetFieldByNumber(info, 0, 14, mxCreateLogicalScalar(mFile.canChangeObjectParameters()));
		mxSetFieldByNumber(info, 0, 15, mxCreateNumericScalar(mFile.numPresets()));

		return info;
	}

	mxArray *final()
	{
		return MarshalImage(mFile.final(), mFile.width(), mFile.height());
	}

	mxArray *status()
	{
		return MarshalImage(mFile.status(), mFile.width(), mFile.height());
	}

	mxArray *metaData()
	{
		mxArray									*meta;
		tc::reduce::CFrameInfoReduceObjectPtr	frameInfo;
		tc::TArray<tc::CStringA>				fieldNames;
		tc::TArray<const char *>				fieldStrings;

		frameInfo = mFile.reduceObjects().GetFrameInfo(mFile.preset());

		if (frameInfo == NULL)
			mexErrMsgTxt("GetFrameInfo failed.");

		for (tc::UInt32 i = 0; i < frameInfo->NumEntries(); ++i) {
			fieldNames.push_back(tc::CStringA(frameInfo->GetNameAt(i)));
			fieldStrings.push_back(fieldNames[i].c_str());
		}

		meta = mxCreateStructMatrix(1, 1, fieldStrings.size(), fieldStrings.data());

		for (tc::UInt32 i = 0; i < frameInfo->NumEntries(); ++i) {
			tc::CString		type, unit;
			mxClassID		dataType;

			type = frameInfo->GetAt(i).type;
			unit = frameInfo->GetAt(i).unit;

			if (type.length() == 0) {
				//	guess from unit
				if (unit.EqualsNoCase(L"IRIG")) {
					dataType = mxCHAR_CLASS;
				} else if (unit.EqualsNoCase(L"Flag")) {
					dataType = mxLOGICAL_CLASS;
				} else if (unit.EqualsNoCase(L"Counter")) {
					dataType = mxUINT64_CLASS;
				} else if (unit.EqualsNoCase(L"int") || unit.EqualsNoCase(L"integer")) {
					dataType = mxINT64_CLASS;
				} else if (unit.EqualsNoCase(L"float") || unit.EqualsNoCase(L"seconds")) {
					dataType = mxDOUBLE_CLASS;
				} else {
					dataType = mxCHAR_CLASS;
				}
			} else {
				if (type.EqualsNoCase(L"int") || type.EqualsNoCase(L"integer")) {
					dataType = mxINT64_CLASS;
				} else if (type.EqualsNoCase(L"float")) {
					dataType = mxDOUBLE_CLASS;
				} else {
					if (unit.EqualsNoCase(L"Flag")) {
						dataType = mxLOGICAL_CLASS;
					} else {
						dataType = mxCHAR_CLASS;
					}
				}
			}

			switch (dataType) {
				case mxUINT64_CLASS:
					mxSetFieldByNumber(meta, 0, i, mxCreateNumericScalar(tc::CUInt64::Parse(frameInfo->GetValueAt(i))));
					break;
				case mxINT64_CLASS:
					mxSetFieldByNumber(meta, 0, i, mxCreateNumericScalar(tc::CInt64::Parse(frameInfo->GetValueAt(i))));
					break;
				case mxDOUBLE_CLASS:
					mxSetFieldByNumber(meta, 0, i, mxCreateDoubleScalar(tc::CFlt64::Parse(frameInfo->GetValueAt(i))));
					break;
				case mxLOGICAL_CLASS:
					mxSetFieldByNumber(meta, 0, i, mxCreateLogicalScalar(tc::CBool::Parse(frameInfo->GetValueAt(i))));
					break;
				default:
					mxSetFieldByNumber(meta, 0, i, mxCreateString(frameInfo->GetValueAt(i).GetUTF8()));
					break;
			}
		}

		return meta;
	}

	tc::Int64 frameIndex()
	{
		return mFrameNumber;
	}

	bool Seek(tc::UInt32 frame)
	{
		mNextFrameNumber = frame;
		return true;
	}

	bool Step()
	{
		if (mApplySuperframe) {
			bool		eof;

			if (!mFile.GetSuperframe(mNextFrameNumber))
				return false;

			mFrameNumber = mNextFrameNumber;
			if (!mFile.NextFrame(mNextFrameNumber, tc::psSuperframe, mNextFrameNumber, eof)) {
				if (eof)
					mNextFrameNumber = 0xFFFFFFFF;
				else
					return false;
			}
		} else {
			if (!mFile.GetFrame(mNextFrameNumber))
				return false;

			mFrameNumber = mNextFrameNumber;
			++mNextFrameNumber;
			if (mNextFrameNumber >= mFile.numFrames())
				mNextFrameNumber = 0xFFFFFFFF;
		}

		return true;
	}

	bool isDone()
	{
		return (mNextFrameNumber == 0xFFFFFFFF);
	}

	void Reset()
	{
		mFrameNumber = -1;
		mNextFrameNumber = 0;
	}

	void ResetObjectParameters()
	{
		mFile.DefaultObjectParameters();
	}

	const char *unit()
	{
		return EnumToString(UnitEnumInfo, mUnit);
	}

	bool setUnit(const char *_value)
	{
		tc::EUnit	value = (tc::EUnit)ParseEnum(UnitEnumInfo, _value);

		if (!mFile.SetUnit(value, mTempType))
			return false;

		mUnit = value;
	}

	const char *temperatureType()
	{
		return EnumToString(TemperatureTypeEnumInfo, mTempType);
	}

	bool setTemperatureType(const char *_value)
	{
		tc::ETempType	value = (tc::ETempType)ParseEnum(TemperatureTypeEnumInfo, _value);

		if (!mFile.SetUnit(mUnit, value))
			return false;

		mTempType = value;
	}

	bool applyNuc()
	{
		return mApplyNuc;
	}

	bool setApplyNuc(bool value)
	{
		if (!mFile.EnableNUC(value, mApplyBadPixels))
			return false;

		mApplyNuc = value;
	}

	bool applyBadPixels()
	{
		return mApplyBadPixels;
	}

	bool setApplyBadPixels(bool value)
	{
		if (!mFile.EnableNUC(mApplyNuc, value))
			return false;

		mApplyBadPixels = value;
	}

	bool applySuperframe()
	{
		return mApplySuperframe;
	}

	bool setApplySuperframe(bool value)
	{
		mApplySuperframe = value;
		return true;
	}

	mxArray *objectParameters()
	{
		tc::TArray<const char *>						fields;
		mxArray											*ret;
		tc::reduce::CObjectParametersReduceObjectPtr	objPar;

		objPar = mFile.reduceObjects().GetObjectParameters();

		if (objPar == NULL)
			mexErrMsgTxt("GetObjectParameters failed.");

		fields[0] = "emissivity";
		fields[1] = "distance";
		fields[2] = "reflectedTemp";
		fields[3] = "atmosphereTemp";
		fields[4] = "extOpticsTemp";
		fields[5] = "extOpticsTransmission";
		fields[6] = "estAtmosphericTransmission";
		fields[7] = "atmosphericTransmission";
		fields[8] = "relativeHumidity";

		ret = mxCreateStructMatrix(1, 1, fields.size(), fields.data());

		mxSetFieldByNumber(ret, 0, 0, mxCreateDoubleScalar(objPar->emissivity));
		mxSetFieldByNumber(ret, 0, 1, mxCreateDoubleScalar(objPar->distance));
		mxSetFieldByNumber(ret, 0, 2, mxCreateDoubleScalar(objPar->reflectedTemp));
		mxSetFieldByNumber(ret, 0, 3, mxCreateDoubleScalar(objPar->atmosphereTemp));
		mxSetFieldByNumber(ret, 0, 4, mxCreateDoubleScalar(objPar->extOpticsTemp));
		mxSetFieldByNumber(ret, 0, 5, mxCreateDoubleScalar(objPar->extOpticsTransmission));
		mxSetFieldByNumber(ret, 0, 6, mxCreateDoubleScalar(objPar->estAtmosphericTransmission));
		mxSetFieldByNumber(ret, 0, 7, mxCreateDoubleScalar(objPar->atmosphericTransmission));
		mxSetFieldByNumber(ret, 0, 8, mxCreateDoubleScalar(objPar->relativeHumidity));

		return ret;
	}

	bool setObjectParameters(const mxArray *value)
	{
		if (!mxIsStruct(value))
			mexErrMsgTxt("Expected struct.");

		tc::reduce::CObjectParametersReduceObjectPtr	objParInit;

		objParInit = mFile.reduceObjects().GetObjectParameters();

		if (objParInit == NULL)
			mexErrMsgTxt("GetObjectParameters failed.");

		tc::reduce::CObjectParametersReduceObject		objPar(*objParInit.ptr());
		mxArray											*field;
		bool											set = false;

		if ((field = mxGetField(value, 0, "emissivity")) != NULL) {
			objPar.emissivity = mxGetScalar(field);
			set = true;
		}

		if ((field = mxGetField(value, 0, "distance")) != NULL) {
			objPar.distance = mxGetScalar(field);
			set = true;
		}

		if ((field = mxGetField(value, 0, "reflectedTemp")) != NULL) {
			objPar.reflectedTemp = mxGetScalar(field);
			set = true;
		}

		if ((field = mxGetField(value, 0, "atmosphereTemp")) != NULL) {
			objPar.atmosphereTemp = mxGetScalar(field);
			set = true;
		}

		if ((field = mxGetField(value, 0, "extOpticsTemp")) != NULL) {
			objPar.extOpticsTemp = mxGetScalar(field);
			set = true;
		}

		if ((field = mxGetField(value, 0, "extOpticsTransmission")) != NULL) {
			objPar.extOpticsTransmission = mxGetScalar(field);
			set = true;
		}

		if ((field = mxGetField(value, 0, "estAtmosphericTransmission")) != NULL) {
			objPar.estAtmosphericTransmission = mxGetScalar(field);
			set = true;
		}

		if ((field = mxGetField(value, 0, "atmosphericTransmission")) != NULL) {
			objPar.atmosphericTransmission = mxGetScalar(field);
			set = true;
		}

		if ((field = mxGetField(value, 0, "relativeHumidity")) != NULL) {
			objPar.relativeHumidity = mxGetScalar(field);
			set = true;
		}

		if (set)
			mFile.SetObjectParameters(objPar);

		return true;
	}
};

//	wraps a c++ object into a matlab array
struct SMatWrapper
{
	intptr_t	ptr;
	size_t		typeLen;
	char		typeName[];
};

template <class kind>
mxArray *WrapObject(kind *obj)
{
	const char	*typeName = typeid(kind).name();
	size_t		typeLen = strlen(typeName) + 1;
	mxArray		*ret;
	SMatWrapper	*wrapper;

	ret = mxCreateNumericMatrix(1, sizeof(SMatWrapper) + typeLen, mxUINT8_CLASS, mxREAL);
	wrapper = (SMatWrapper *)mxGetData(ret);

	wrapper->ptr = (intptr_t)obj;
	wrapper->typeLen = typeLen;
	strcpy(wrapper->typeName, typeName);

	mexLock();

	return ret;
}

template <class kind>
kind *GetObject(const mxArray *ar)
{
	const char	*typeName = typeid(kind).name();
	size_t		typeLen = strlen(typeName) + 1;
	SMatWrapper	*wrapper;

	if (mxGetNumberOfElements(ar) != sizeof(SMatWrapper) + typeLen || mxGetClassID(ar) != mxUINT8_CLASS || mxIsComplex(ar))
		mexErrMsgTxt("Invalid handle.");

	wrapper = (SMatWrapper *)mxGetData(ar);

	if (wrapper->typeLen != typeLen || strcmp(wrapper->typeName, typeName) != 0)
		mexErrMsgTxt("Invalid handle.");

	return (kind *)wrapper->ptr;
}

template <class kind>
void UnwrapObject(const mxArray *ar)
{
	const char	*typeName = typeid(kind).name();
	size_t		typeLen = strlen(typeName) + 1;
	SMatWrapper	*wrapper;

	if (mxGetNumberOfElements(ar) != sizeof(SMatWrapper) + typeLen || mxGetClassID(ar) != mxUINT8_CLASS || mxIsComplex(ar))
		mexErrMsgTxt("Invalid handle.");

	wrapper = (SMatWrapper *)mxGetData(ar);

	if (wrapper->typeLen != typeLen || strcmp(wrapper->typeName, typeName) != 0)
		mexErrMsgTxt("Invalid handle.");

	memset(mxGetData(ar), 0, sizeof(SMatWrapper) + typeLen);
	mexUnlock();
}

//	the mex entry point
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	char			command[64];
	CMatImagerFile	*file;

	if (nrhs < 1 || mxGetString(prhs[0], command, sizeof(command)) != 0)
		mexErrMsgTxt("First argument must be a command string.");

	if (strcmp(command, "new") == 0) {
		if (nlhs != 1)
			mexErrMsgTxt("Must have one return value.");
		if (nrhs != 2)
			mexErrMsgTxt("Must specify file to open.");
		file = new CMatImagerFile(mxGetString(prhs[1]));
		plhs[0] = WrapObject(file);
		return;
	}

	if (nrhs < 2)
		mexErrMsgTxt("Second argument must be a handle.");

	file = GetObject<CMatImagerFile>(prhs[1]);		//	won't get past here if GetObject fails

	if (strcmp(command, "delete") == 0) {
		UnwrapObject<CMatImagerFile>(prhs[1]);
		delete file;
	//	functions that act like accessors
	} else if (strcmp(command, "getInfo") == 0) {
		if (nlhs != 1)
			mexErrMsgTxt("Must have one return value.");

		plhs[0] = file->info();
	} else if (strcmp(command, "getIsDone") == 0) {
		if (nlhs != 1)
			mexErrMsgTxt("Must have one return value.");

		plhs[0] = mxCreateLogicalScalar(file->isDone());
	} else if (strcmp(command, "getMetaData") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = file->metaData();
	} else if (strcmp(command, "getFinal") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = file->final();
	} else if (strcmp(command, "getStatus") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = file->status();
	//	accessor/mutators
	} else if (strcmp(command, "getUnit") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = mxCreateString(file->unit());
	} else if (strcmp(command, "setUnit") == 0) {
		if (nlhs != 0 || nrhs != 3)
			mexErrMsgTxt("Must have 3 inputs and 0 outputs.");
		if (!file->setUnit(mxGetString(prhs[2])))
			mexErrMsgTxt("Failed.");
	} else if (strcmp(command, "getTemperatureType") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = mxCreateString(file->temperatureType());
	} else if (strcmp(command, "setTemperatureType") == 0) {
		if (nlhs != 0 || nrhs != 3)
			mexErrMsgTxt("Must have 3 inputs and 0 outputs.");
		if (!file->setTemperatureType(mxGetString(prhs[2])))
			mexErrMsgTxt("Failed.");
	} else if (strcmp(command, "getApplyNuc") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = mxCreateLogicalScalar(file->applyNuc());
	} else if (strcmp(command, "setApplyNuc") == 0) {
		if (nlhs != 0 || nrhs != 3)
			mexErrMsgTxt("Must have 3 inputs and 0 outputs.");
		if (!file->setApplyNuc(mxGetLogical(prhs[2])))
			mexErrMsgTxt("Failed.");
	} else if (strcmp(command, "getApplyBadPixels") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = mxCreateLogicalScalar(file->applyBadPixels());
	} else if (strcmp(command, "setApplyBadPixels") == 0) {
		if (nlhs != 0 || nrhs != 3)
			mexErrMsgTxt("Must have 3 inputs and 0 outputs.");
		if (!file->setApplyBadPixels(mxGetLogical(prhs[2])))
			mexErrMsgTxt("Failed.");
	} else if (strcmp(command, "getApplySuperfame") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = mxCreateLogicalScalar(file->applySuperframe());
	} else if (strcmp(command, "setApplySuperfame") == 0) {
		if (nlhs != 0 || nrhs != 3)
			mexErrMsgTxt("Must have 3 inputs and 0 outputs.");
		if (!file->setApplySuperframe(mxGetLogical(prhs[2])))
			mexErrMsgTxt("Failed.");
	} else if (strcmp(command, "getObjectParameters") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = file->objectParameters();
	} else if (strcmp(command, "setObjectParameters") == 0) {
		if (nlhs != 0 || nrhs != 3)
			mexErrMsgTxt("Must have 3 inputs and 0 outputs.");
		if (!file->setObjectParameters(prhs[2]))
			mexErrMsgTxt("Failed.");
	} else if (strcmp(command, "getFrameIndex") == 0) {
		if (nlhs != 1 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 1 outputs.");
		plhs[0] = mxCreateNumericScalar(file->frameIndex());
	//	methods
	} else if (strcmp(command, "step") == 0) {
		if ((nlhs < 0 || nlhs > 3) || (nrhs < 2 || nrhs > 3))
			mexErrMsgTxt("Must have 2-3 inputs and 0-3 outputs.");
		if (nrhs > 2)
			file->Seek(mxGetNumeric<tc::UInt32>(prhs[2]));
		if (!file->Step())
			mexErrMsgTxt("Step failed.");
		if (nlhs > 0)
			plhs[0] = file->final();
		if (nlhs > 1)
			plhs[1] = file->metaData();
		if (nlhs > 2)
			plhs[2] = file->status();
	} else if (strcmp(command, "reset") == 0) {
		if (nlhs != 0 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 0 outputs.");
		file->Reset();
	} else if (strcmp(command, "resetObjectParameters") == 0) {
		if (nlhs != 0 || nrhs != 2)
			mexErrMsgTxt("Must have 2 inputs and 0 outputs.");
		file->ResetObjectParameters();
	} else {
		mexErrMsgTxt("Unknown command.");
	}
}
