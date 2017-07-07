% LAB_WRITE_EDF Writes the given data into an EDF file.  (NOT EDF+ ; modified by Giorgio)
%
% @Synopsis
%   LAB_WRITE_EDF_NO_EVENTS(fileName, data, Header)
%     Does the above.
%
% @Input
%   fileName (required)
%     String with the file name without extension. Relative or absolute
%     pathnames are valid.
%
%   data (required)
%     An nSignals x nSamples matrix with the data.
%
%   Header (required)
%     Struct with the EDF conform information (see @Remarks) about the data to
%     be written. All string-fields must be US-ASCII coded and contain only
%     chars within the range of 33-126. Spaces (char 32) & other chars outside
%     this range are replaced by underscores. In fields referring to dates, the
%     year must be given as a whole number in its full form (e.g. yyyy-format).
%     The month must be a whole number between 1 and 12. The day must be a whole
%     number between 1 and 31. Be aware that this does not imply that invalid
%     dates are detected, as the function does not check if the month-day
%     combination is an actual day in the month (e.g. month=2, day=31 would be a
%     valid choice). So you have to do some sanity checking yourself. 
%     The following fields can/must be specified:
%       GENERAL FIELDS:
%       - Header.samplingrate (required)
%         Whole-numbered scalar with the sampling rate of the data in Hz. 
%       - Header.channels (required)
%         A nSignalsx1 cellstring with the signal labels. The individual labels
%         must not exceed 16 characters, otherwise they will be truncated.
%       - Header.year (required)
%         Whole-numbered scalar >=0 with the year of the recording. If the year
%         is <100 a 'YearYYFormat'-warning is thrown. It is assumed that the
%         year is erroneously given in yy-format and converted to 20yy if it is
%         <85 and to 19yy otherwise. Due to the specifications of EDF, year
%         values outside the range of 1985-2084 will also produce a warning as
%         the startdate field of the EDF file will be set to 'yy'.
%       - Header.month (required)
%         The month of the recording.
%       - Header.day (required)
%         The day of the month of the recording.
%       - Header.hour (optional; default: 0)
%         !!Not specifying this field is not recommended!!
%         Whole-numbered scalar between 0 and 23 with the hour of the recording
%         in 24h-format. Be aware that it is not possible to check if you
%         entered your hour in 12h-format (e.g. am/pm)!
%       - Header.minute (optional; default: 0)
%         !!Not specifying this field is not recommended!!
%         Whole-numbered scalar between 0 and 59 with the minute of the
%         recording.
%       - Header.second (optional; default: 0)
%         Scalar >=0 and <60 with the second of the recording. Currently,
%         sub-second fractions (e.g. 12.134123) will be clipped as using these
%         will always lead to EDF+ files (EDF does not specify the starttime
%         with sub-second precision).
%      LOCAL RECORDING IDENTIFICATION FIELDS: These fields contain strings and
%      will be merged into the according EDF field. Be aware that this field is
%      limited to 80 chars and very long strings in any of the fields below
%      might reach this limit. This will cause the string to be truncated at 80
%      chars and the remaining information will be lost.
%       - Header.ID (optional; default: 'X')
%         Hospital administration code of the investigation (e.g. EEG or PSG
%         number).
%       - Header.technician (optional; default: 'X')
%         A code specifying the responsible investigator/technician.
%       - Header.equipment (optional; default: 'X')
%         A code specifying the used equipment.
%      LOCAL PATIENT IDENTIFICATION FIELDS: These fields are passed in a
%      substruct of Header and will be merged into the according EDF field. Be
%      aware that the same limitation as for the local recording identification
%      EDF field apply.
%       - Header.subject.ID (optional; default: 'X')
%         String with the code by which patient is known in the hospital
%         administration.
%       - Header.subject.sex (optional; default: 'X')
%         Char with either 'M' or 'F' specifying the sex of the patient.
%       - Header.subject.name (optional; default: 'X')
%         String with the patients name.
%       - year  (optional; default: NaN)
%         month (optional; default: NaN)
%         day   (optional; default: NaN)
%         These values will be merged into the date-of-birth of the patient. If
%         any of the values is not specified, the default date-of-birth ('X') is
%         used.
%      EDF ANNOTATIONS: These fields are passed in a substruct of Header & will
%      result in an EDF+ file, if given. This is also code from the original
%      version and might not work properly.
%       - events.POS: kx1 vector; Sample ids of event starts.
%       - events.DUR: kx1 vector; Event durations in samples.
%       - events.TYP: kx1 cellstr; Event names.
%
% @Output
%   none (a file is created)
%
% @Remarks
%   - The relevant papers for the definition of the format are:
%     EDF : Kemp et al.: "A simple format for exchange of digitized polygraphic
%           recordings", Electroencephalography and clinical Neurophysiology,
%           82:391-3, 1992.
%     EDF+: Kemp & Olivan: "European data format 'plus' (EDF+), an EDF alike
%           standard format for the exchange of physiological data",
%           Clinical Neurophysiology, 114:1755-61, 1992
%   - HOW TO CONSTRUCT A HEADER: Let's say you have recorded an EEG on
%     August, 15th 2015, starting at 19:53:02 from 10 electrodes (c3/4, f3/4,
%     p3/4, t3/4 and earlobes a1/2; data stored in this order) vs. ground. Your
%     recording lasted for 2 seconds at a sampling rate of 500 Hz. Then your
%     data should be a 10x1000 matrix and the header with the (recommended)
%     minimal information using the site labeling suggested in Kemp2003 can be
%     constructed by:
%{
        Header = struct();
        Header.samplingrate = 500;
        Header.channels     = strcat('EEG ',{'c3';'c4';'f3';'f4';'p3';'p4';'t3';'t4';'a1';'a2'},'-Ref');
        Header.year         = 2015;
        Header.month        = 8;
        Header.day          = 15;
        Header.hour         = 19;
        Header.minute       = 53;
        Header.second       = 2;
%}
%     Let's say you also know the something about your subject/patient. He's
%     male, was born on August, 16th 1920 and is named Henry C. Bukowski. He was
%     admitted to the hospital under the id 3-423-12386-9, then the subject
%     substruct in the Header will look like this:
%{
        Header.subject.ID    = '3-423-12386-9';
        Header.subject.sex   = 'M';
        Header.subject.name  = 'Bukowski, Henry C.';
        Header.subject.year  = 1920;
        Header.subject.month = 8;
        Header.subject.day   = 16;
%}
%     The spaces in the name field will be silently replaced by underscores,
%     whereas the comma and the dot are valid.
%
% @Dependencies
%   none
%
% ML-FEX ID: #61189 (original code #36530)
%
% @Changelog
%   2010-XX-XX (Stefan Klanke): Original release.
%   2012-04-26 (F. Hatz Neurology Basel): [ADD] Support for EDF+
%   2017-01-04 (DJM): [FIX] Code updates by Gil Fuchs (14 Oct 2014) and Thijs
%     Boeree (08 Nov 2016) 
%   2017-01-10 (DJM): [MOD] Revamped the code of the original LAB_WRITE_EDF.
%   2017-01-19 (DJM):
%     - [MOD] Some minor mods on the code.
%     - [ADD] Extended header + examples & more precise struct field
%       descriptions.
%
function lab_write_edf(fileName, data, Header)

%% Init
% Integer class for signal values.
INT_CLASS = 'int16';

% Specifications from Kemp1992.
DATA_RECORD_DURATION_IN_SEC = 1; %keep this at 1 to conform to EDF.
LABEL_LENGTH_REQUIRED = 16;
% ...length of local patient/recording info fields.
LOCAL_INFO_LENGTH_REQUIRED = 80;

% Specifikations from Kemp2003...
% ...separator for local patient/recording info fields.
SEPARATOR = ' ';
% ...min/max year for startdate to avoid Y2K problem.
YEAR_MIN = 1985;
YEAR_MAX = 2084;
% ...date format (as used in DATETIME's Format property). Applied to birthdate
% in patient info & start date in local recording identification.
DATE_FORMAT = 'dd-MMM-yyyy';
% ...char encoding for the file (as used in UNICODE2NATIVE & FOPEN).
ENCODING = 'US-ASCII';
% ...machine format of the file (as used by FOPEN).
MACHINE_FORMAT = 'ieee-le';

%% Check inputs
warning('off','backtrace');
[fileName, Header, data] ...
	= parseInputs(fileName, Header, data, LABEL_LENGTH_REQUIRED, YEAR_MIN, ...
		DATE_FORMAT, ENCODING);
warning('on','backtrace');

%% Prepare data
[data, Header.physicalMins, Header.physicalMaxs] = scaleToInt(data,INT_CLASS);

% Holds, since duration is fixed to 1 sec).
Header.nDataRecords = ceil(Header.nSamples/Header.samplingrate);

% Get start date of recording.
Header.DateOfRecording = datetime([Header.year, Header.month , Header.day, ...
                                   Header.hour, Header.minute, Header.second]);
Header = rmfield(Header,{'year','month','day','hour','minute','second'});

% Add zeros at end of data (data-length must be multiple of a second)
nAdd = Header.nDataRecords*Header.samplingrate - size(data,2);
data(:,end+1:end+nAdd) = 0;
clearvars nAdd;

% Reshape data.
data = reshape(data,size(data,1),Header.samplingrate,Header.nDataRecords);
data = permute(data,[2 1 3]);
data = reshape(data,size(data,1)*size(data,2),size(data,3));

%% Add events signal
if Header.hasEvents
	Header.physicalMins(end+1,1) = cast(intmin(INT_CLASS), ...
												'like',Header.physicalMins);
	Header.physicalMaxs(end+1,1) = cast(intmax(INT_CLASS), ...
												'like',Header.physicalMins);
	[eventChannel,Header] = createEventChannel(Header, ENCODING);
	data = [data;eventChannel];
	clearvars eventChannel;
end

%% Create local patient & recording info
% As defined in Kemp2003.

Header.localPatientInfo = assertLocalInfoFieldLength(...
										[Header.subject.ID        SEPARATOR ...
										 Header.subject.sex       SEPARATOR ...
										 Header.subject.birthdate SEPARATOR ...
										 Header.subject.name], ...
										'Local patient info', LOCAL_INFO_LENGTH_REQUIRED);

Header.DateOfRecording.Format = DATE_FORMAT;
Header.localRecordingInfo = assertLocalInfoFieldLength(...
										['Startdate'                         SEPARATOR ...
                               upper(char(Header.DateOfRecording)) SEPARATOR ...
										 Header.ID                           SEPARATOR ...
										 Header.technician                   SEPARATOR ...
										 Header.equipment], ...
										'Local recording info', LOCAL_INFO_LENGTH_REQUIRED);

Header = rmfield(Header,{'subject','ID','technician','equipment'});

%% Finally write the EDF file
fileId = fopen(fileName, 'w', MACHINE_FORMAT, ENCODING);

try
	writeEdf(fileId, data, Header, DATA_RECORD_DURATION_IN_SEC, INT_CLASS, ...
		YEAR_MIN, YEAR_MAX);
	fclose(fileId);
catch Err
	fclose(fileId);
	rethrow(Err);
end

end % MAINFUNCTION



%% SUBFUNCTION: parseInputs
function [fileName, Header, data] ...
	= parseInputs(fileName, Header, data, requiredLabelLength, yearMin, ...
		dateFormat, encoding)
% Check the input arguments. Default values for the header can be specified
% here.

%% >SUB: Init
[Header.nSignals, Header.nSamples] = size(data); %Will be modified later.
Header.hasEvents = isfield(Header,'events');

%% >SUB: Init
FILE_EXTENSION = '.edf';

% Max. number of signals & samples per signals.
N_SIGNALS_MAX = 9999;     %4 chars entry limitation -> 10^4-1.
N_SAMPLES_MAX = 99999999; %8 chars entry limitation -> 10^8-1.

% Set of valid chars as given in Kemp2003 without space (32).
VALID_CHARS      = native2unicode(33:126, encoding);
REPLACEMENT_CHAR = '_';
DEFAULT_CHAR     = 'X';

VALID_SEXES = {'F','M'}; % As specified in Kemp2003.

STRUCT_NAME = 'Header';

%% >SUB: Check file name
% Append extension if necessary.
if ~strcmpi(fileName(end-2:end),FILE_EXTENSION)
	fileName = [fileName FILE_EXTENSION];
end

% Make sure file separator is correct.
fileName = fullfile(fileName);

%% >SUB: Check header -> samplingrate & signal labels
% Abuse validateHeaderDateTimeField to check the samplingrate (given, valid &
% integer).
Header = validateHeaderDateTimeField(Header, 'samplingrate', [], @(x)x>0, ...
				STRUCT_NAME);

Header = validateHeaderSignalLabels(Header, requiredLabelLength);

%% >SUB: Check data
% This has to be done after checking the labels, as this function will add the
% event signal thus changing Header.nChannels.
assert(Header.nSignals <= N_SIGNALS_MAX, 'EDF:IOError', ['Cannot write more' ...
	' than %d signals to an EDF file.'], N_SIGNALS_MAX);
assert(Header.nSamples <= N_SAMPLES_MAX, 'EDF:IOError', ['Cannot write more' ...
	' than %d data records (=samples) to an EDF file.'], N_SAMPLES_MAX);
assert(isreal(data), 'EDF:IOError', 'Cannot write complex-valued data.');

%% >SUB: Check header -> date/time fields
% Check date.
Header = validateHeaderDateTimeField(Header, 'year' , [], ...
				@(x)x>=0            , STRUCT_NAME);
Header = validateHeaderDateTimeField(Header, 'month', [], ...
				@(x)ismember(x,1:12), STRUCT_NAME);
Header = validateHeaderDateTimeField(Header, 'day'  , [], ...
				@(x)ismember(x,1:31), STRUCT_NAME);

% Check if year is given as YY instead of YYYY, which is problematic.
if Header.year < 100
	yearYY = Header.year;
	if yearYY < mod(yearMin,100) %yearMin to YY format.
		Header.year = 1900 + yearYY;
	else
		Header.year = 2000 + yearYY;
	end
	warning('EDF:YearYYFormat', ['Header.year (%d) is ambiguous in ' ...
		'the YYYY-format. Has been converted to %d! This can SEVERLY screw ' ...
		'up your data if not checked!'], yearYY, Header.year);
end

% Check time.
Header = validateHeaderDateTimeField(Header, 'hour'  , 0, ...
				@(x)ismember(x,0:23), STRUCT_NAME);
Header = validateHeaderDateTimeField(Header, 'minute', 0, ...
				@(x)ismember(x,0:59), STRUCT_NAME);
Header = validateHeaderDateTimeField(Header, 'second', 0, ...
				@(x)x>=0&x<60       , STRUCT_NAME);

%% >SUB: Check header -> recording info
for field = {'ID','technician','equipment'}
	Header = validateHeaderStringField(Header, field{:}, DEFAULT_CHAR, ...
					VALID_CHARS, REPLACEMENT_CHAR, STRUCT_NAME);
end

%% >SUB: Check header -> patient info
Header = validateHeaderPatientInfo(fileName, Header, DEFAULT_CHAR, ...
				VALID_CHARS, REPLACEMENT_CHAR, VALID_SEXES, dateFormat);
end % PARSEINPUTS



%% SUBFUNCTION: validateHeaderSignalLabels
function [Header, isTruncatedChannelLabel] ...
	= validateHeaderSignalLabels(Header, requiredLabelLength)
% Checks Header.channels & truncates them if necessary. Also converts the labels
% to char.

%% >SUB: Check if valid
assert(isfield(Header,'channels'), 'EDF:IOError', ...
	'Header.channels was not specified!');

assert(~any(cellfun(@isempty,Header.channels)), 'EDF:IOError', ...
	'Signal labels in Header.channels must not be empty!');

assert(length(Header.channels)==Header.nSignals, 'EDF:IOError', ['Number of '...
	'signals from data did not match number of signal labels from ' ...
	'Header.channels!']);

%% >SUB: Reformat labels to char
if ~iscell(Header.channels)
	Header.channels = {Header.channels};
end

if Header.hasEvents
	Header.channels(end+1,1) = {'EDF Annotations'};
	Header.nSignals = Header.nSignals + 1;
end

% Remove leading spaces.
Header.channels = regexprep(Header.channels,'^[ ]*(.)*$','$1');

% Convert to char for the write.
Header.channels = char(Header.channels);

% Find too long labels (works also if labels are short enough as ALL([])==true).
isTruncatedChannelLabel ...
	= ~all(Header.channels(:,requiredLabelLength+1:end)==' ',2);

if any(isTruncatedChannelLabel)
	% Truncate long labels.
	truncatedLabels = Header.channels(isTruncatedChannelLabel,:); %#ok<NASGU>
	Header.channels = Header.channels(:,1:requiredLabelLength);
	warning('EDF:LabelsModified', ['Signal labels must not exceed %d ' ...
		'characters! Truncated label(s):\n%s\b'], requiredLabelLength, ...
		evalc('disp(char(strcat({''  -> ''}, truncatedLabels)));'));
elseif size(Header.channels,2) < requiredLabelLength
	% Assure the labels are not too short.
	Header.channels(:,end+1:requiredLabelLength) = ' ';
end
end % VALIDATEHEADERSIGNALLABELS



%% SUBFUNCTION: validateHeaderPatientInfo
function Header ...
	= validateHeaderPatientInfo(fileName, Header, defaultChar, ...
			validChars, replaceChar, validSexes, dateFormat)
% Checks if the if the ID, sex, year/month/day & name subfields of the subject
% field of the header are given & valid. This functions removes the
% year/month/day fields and adds the merged birthdate field

%% >SUB: Init
STRUCT_NAME = 'Header.subject';

%% >SUB: Check if given & return if not
if ~isfield(Header,'subject');
	Header.subject = struct('ID',defaultChar, 'sex',defaultChar, ...
							'name',defaultChar, 'birthdate',defaultChar);
	fprintf(['Info: Local patient identification fields were not given. Will' ...
		' use default (%s) for all fields.\n'], defaultChar);
	return;
end

%% >SUB: Check ID
[Header.subject,isDefault] ...
	= validateHeaderStringField(Header.subject, 'ID', defaultChar, validChars, ...
		replaceChar, STRUCT_NAME);
if isDefault
	try
		Header.subject.ID = parseSubjectIdFromFileName(fileName);
	catch Err
		Header.subject.ID = defaultChar;
		warning('EDF:HeaderFormat', ['%s.ID was empty or ' ...
			'not given! To assign it automatically, provide a ''IdString = ' ...
			'parseSubjectIdFromFileName(fileNameString)'' function which ' ...
			'parses the ID from the file name.\n Error message from ' ...
			'parseSubjectIdFromFileName-call:\n\t%s'], STRUCT_NAME, Err.message);
	end
end

%% >SUB: Check sex
[Header.subject,isDefault] ...
	= validateHeaderStringField(Header.subject, 'sex', defaultChar, ...
		validChars, replaceChar, STRUCT_NAME);
if ~isDefault 
	Header.subject.sex = upper(Header.subject.sex);
	if ~any(strcmp(Header.subject.sex,validSexes))
		Header.subject.sex = defaultChar;
		warning('EDF:HeaderFormat', '%s.sex %s was not valid ( %s)!', ...
			STRUCT_NAME, Header.subject.sex, sprintf('%s ', validSexes{:}));
	end
end

%% >SUB: Check birthdate
[Header.subject,isDefault   ] = validateHeaderDateTimeField(Header.subject, ...
											'year' , 0, @(x)x>=0, STRUCT_NAME);
[Header.subject,isDefault(2)] = validateHeaderDateTimeField(Header.subject, ...
											'month', 0, @(x)ismember(x,1:12), STRUCT_NAME);
[Header.subject,isDefault(3)] = validateHeaderDateTimeField(Header.subject, ...
											'day'  , 0, @(x)ismember(x,1:31), STRUCT_NAME);
if ~any(isDefault)
	Header.subject.birthdate = upper(char(datetime([Header.subject.year, ...
	                                                Header.subject.month, ...
																	Header.subject.day], ...
														'Format',dateFormat)));
else
	Header.subject.birthdate = defaultChar;
	warning('EDF:HeaderDateTimeFormat', ['The year/month/date field of ' ...
		'%s were not specified or invalid! Cannot construct a valid ' ...
		'birthdate!'], STRUCT_NAME);
end

Header.subject = rmfield(Header.subject,{'year','month','day'});

%% >SUB: Check name
% Spaces are ok in name.
if ~ismember(' ',validChars)
	Header.subject.name = strrep(Header.subject.name,' ',replaceChar);
end
Header.subject = validateHeaderStringField(Header.subject, 'name', ...
							defaultChar, validChars, replaceChar, STRUCT_NAME);
end % VALIDATEHEADERPATIENTINFO



%% SUBFUNCTION: validateHeaderDateTimeField
% VALIDATEHEADERDATETIMEFIELD Checks if the specified date/time field of the
% header is given & valid. For year/month/day/hour/minute, the field has to be
% whole-numbered (integer).
%
% @Input
%   defaultValue (required)
%     Default date or time value if the field is not given or invalid. If
%     isempty(defaultValue)==true, an error is thrown instead of simple message
%     if the field is not given or invalid. Default value can be different from
%     the valid range defined in the validationFun!
%   validationFun (required)
%     Function handle evaluating to true if the field value of the header is
%     valid.
%   structNameForWarnings (required)
%     A string with the name of the struct on which the field has to be tested
%     (e.g. the name of the variable of the input Header).
%
function [Header, isDefault] ...
	= validateHeaderDateTimeField(Header, fieldName, defaultValue, ...
			validationFun, structNameForWarnings)

%% >SUB: Init
MSG_ID = 'EDF:HeaderDateTimeFormat';

%% >SUB: Check given & valid
if isfield(Header,fieldName)
	% Check if it is integer (only seconds may have fractions). Do this before
	% the validation to avoid rounding errors.
	if ~(strcmp(fieldName,'second') || mod(Header.(fieldName),1) == 0)
		Header.(fieldName) = round(Header.(fieldName));
		warning(MSG_ID, '%s.%s has to be integer. Value was rounded!', ...
			structNameForWarnings, fieldName);
	end
	isDefault = ~validationFun(Header.(fieldName));
	msg = sprintf('invalid (%d)',Header.(fieldName));
else
	isDefault = true;
	msg = 'not specified';
end

%% >SUB: Throw warning/error if defaulted
if isDefault
	msg = sprintf('%s.%s was %s!',structNameForWarnings,fieldName,msg);
	if ~isempty(defaultValue)
		Header.(fieldName) = defaultValue;
		fprintf(['Info: ' msg ' Will use default (%.g).\n'],  Header.(fieldName));
	else
		error(MSG_ID, msg); %#ok<SPERR>
	end
end
end % VALIDATEHEADERDATETIMEFIELD



%% SUBFUNCTION: validateHeaderStringField
% VALIDATEHEADERSTRINGFIELD Checks if the specified string field of the header
% is given & contains only valid characters.
%
function [Header,isDefault,isModified] ...
	= validateHeaderStringField(Header, fieldName, defaultChar, validChars, ...
			replaceChar, structNameForWarnings)

isDefault = ~isfield(Header,fieldName) || isempty(Header.(fieldName));
isModified  = false;
if isDefault
	Header.(fieldName) = defaultChar;
	fprintf(['Info: %s.%s was not specified or empty! Will use default ' ...
		'(%s).\n'], structNameForWarnings, fieldName, Header.(fieldName));
else
	isInvalidChar = ~ismember(Header.(fieldName),validChars);
	if any(isInvalidChar)
		isModified = true;
		Header.(fieldName)(isInvalidChar) = replaceChar;
		warning('EDF:HeaderFormat', ...
			'Invalid characters in %s.%s have been replaced with ''%s''!', ...
			structNameForWarnings, fieldName, replaceChar);
	end
end
end % VALIDATEHEADERSTRINGFIELD



%% SUBFUNCTION: scale2int
% SCALEINT Scale & cast the data to integer.
%
function [dataScaledInt, physMins, physMaxs] = scaleToInt(data, intClass)

%% >SUB: Init
%Get min/max int and cast to double to avoid computation errors.
INT_MIN = cast(intmin(intClass),'like',data);
INT_MAX = cast(intmax(intClass),'like',data);

%% >SUB: Get min & max
% Rounds max-min to the highest nearest int. Works for most of the cases, but we
% should consider using scientific notation for very little values.
physMins = floor(min(data, [], 2));
physMaxs = ceil(max(data, [], 2)); 

% Physical max can't be equal to physical min.
isEqual = physMaxs==physMins; 
physMaxs(isEqual) = physMaxs(isEqual) + 1;

%% >SUB: Do the rest
%Scale & offset.
scales = (INT_MAX-INT_MIN)./(physMaxs-physMins);
dataScaledInt = bsxfun(@minus,data         ,physMins);
dataScaledInt = bsxfun(@times,dataScaledInt,scales);
dataScaledInt = dataScaledInt + INT_MIN;

%Cast to int.
dataScaledInt = cast(dataScaledInt, intClass);
end % SCALEINT



%% SUBFUNCTION: createEventChannel
% CREATEEVENTCHANNEL Creates the EDF annotation event signal. The events.POS,
% events.DUR & events.TYP fields of the header are removed and the new
% events.signalLength field is added. Bytes are represented by UINT8. This is
% still close to the original code. Not sure if it worked as intended at all.
% 
% @Input
%   encoding (required): Char encoding of the labels as used by UNICODE2NATIVE.
%
function [eventChannel,Header] = createEventChannel(Header, encoding)

%% >SUB: Init
% As defined in Kemp2003.
MARKERS.separator    = uint8(20);
MARKERS.onsetEnd     = uint8(21);
MARKERS.onsetPrecede = unicode2native('-', encoding)';
MARKERS.onsetFollow  = unicode2native('+', encoding)';
MARKERS.talEnd       = uint8(0);

%% >SUB: Compute the event signal
recordstmp   = zeros(  1,Header.nDataRecords);
eventChannel = zeros(240,Header.nDataRecords, 'uint8'); %240 = 2^8-2^4, but why?
for i = 1:Header.nDataRecords
	tmp = [MARKERS.onsetFollow;...
          unicode2native(int2str(i-1), encoding)';...
			 MARKERS.separator;...
			 MARKERS.separator;...
			 MARKERS.talEnd];
	recordstmp(1,i) = length(tmp);
	eventChannel(1:recordstmp(1,i),i) = tmp;
end

for i = 1:size(Header.events.POS,2);
	tmpPOS = round(double(Header.events.POS(1,i))/Header.samplingrate, 3);
	tmpDUR = round(double(Header.events.DUR(1,i))/Header.samplingrate, 3);
	tmpPOS = unicode2native(num2str(tmpPOS), encoding)';
	tmpDUR = unicode2native(num2str(tmpDUR), encoding)';
	tmpTYP = unicode2native(Header.events.TYP{1,i}, encoding)';
	tmpEventSignal = [MARKERS.onsetFollow;...
							tmpPOS;
							MARKERS.onsetEnd;...
							tmpDUR;...
							MARKERS.separator;...
							tmpTYP;...
							MARKERS.separator;...
							MARKERS.talEnd];

	j = ceil(double(Header.events.POS(1,i)) / Header.samplingrate);
	idEnd = recordstmp(1,j) + length(tmpEventSignal);
	eventChannel(recordstmp(1,j)+1:idEnd, j) ...
		= tmpEventSignal;
	recordstmp(1,j) = idEnd;
end
Header.events = rmfield(Header.events,{'POS','DUR','TYP'});

Header.events.signalLength = size(eventChannel,1) / 2;
if mod(Header.events.signalLength,2) ~= 0
	eventChannel = cat(1, eventChannel, zeros(1,Header.nDataRecords, 'uint8'));
	Header.events.signalLength = Header.events.signalLength+1;
end
eventChannel = reshape(eventChannel,1,[]);
eventChannel = cast(eventChannel', 'int16')'; %2 bytes per entry.
eventChannel = reshape(eventChannel,Header.events.signalLength*2,[]);
end % CREATEEVENTCHANNEL



%% SUBFUNCTION: assertLocalInfoFieldLength
% ASSERTLOCALINFOFIELDLENGTH Asserts that the specified field has the given
% length. Pads with spaces if too short, truncates & warns if too long.
%
function fieldValue ...
	= assertLocalInfoFieldLength(fieldValue, fieldName, requiredFieldLength)

nChars = length(fieldValue);
if nChars > requiredFieldLength
	warning('EDF:FieldLengthExceeded', ['%s was too long ' ...
		'(%d chars)!. Will be truncated to %d chars!'], fieldName, nChars, ...
		requiredFieldLength);
	fieldValue = fieldValue(1:requiredFieldLength);
else
	fieldValue(end+1:requiredFieldLength) = ' ';
end
end % ASSERTLOCALINFOFIELDLENGTH



%% SUBFUNCTION: writeEdf
% WRITEEDF Writes the edf to a file.
%
function writeEdf(fileId, data, Header, durationPerDataRecordInSec, ...
				intClass, yearMin, yearMax)

%% >SUB: Init
% Check for Y2k problem in the start of recording entry of the old EDF.
if year(Header.DateOfRecording) >= yearMin ...
&& year(Header.DateOfRecording) <= yearMax
	startDateFormat = 'dd.MM.yy';
else %Set year to 'yy'.
	startDateFormat = 'dd.MM.''yy''';
	warning('EDF:HeaderDateTimeFormat', ['Header.year (%d) is outside the ' ...
		'valid range %d-%d! EDF''s startdate field will be set to ''yy''!'], ...
		year(Header.DateOfRecording), yearMin, yearMax);
end

%% TODO: Implement inputs for Physical dimensions, Prefilter & Transducer fields
% Create physdim-info (uV for all signals).
PHYSICAL_DIMENSIONS = repmat(sprintf('%-8s','uV')',1,Header.nSignals);
PREFILTER           = repmat(' ',80,Header.nSignals);
TRANSDUCER_TYPE     = repmat(' ',80,Header.nSignals);

%% >SUB: Setup
% The entry of the 1st reserved field will be different for EDF+. Since we
% currently consider only continous recordings, the EDF+C flag is only set if we
% have annotations (which are allowed only in EDF+). Otherwise we leave this
% field empty to be conform with EDF.
if Header.hasEvents
    edfPlusFlag = 'EDF+C';
else
    edfPlusFlag = ' ';
end

%% >SUB: Write header record
% Version (1 byte).
fprintf(fileId, '%-8i',0);

% Local patient & recording identification (have been assured to be 80 chars).
fwrite(fileId, Header.localPatientInfo  , 'char*1');
fwrite(fileId, Header.localRecordingInfo, 'char*1');

% Start date of recording (8 chars).
Header.DateOfRecording.Format = startDateFormat;
fprintf(fileId, '%-8s', char(Header.DateOfRecording));

% Start time of recording (8 chars).
Header.DateOfRecording.Format = 'hh.mm.ss';
fprintf(fileId, '%-8s', char(Header.DateOfRecording));

% Number of bytes in header record (8 chars); 256 for header + 256 for each data
% header (Kemp1992).
fprintf(fileId, '%-8i', 256*(1+Header.nSignals));

% 1st reserved field (44 chars).
fprintf(fileId, '%-44s', edfPlusFlag);

% Number of data records (-1 if unknown; 8 chars).
fprintf(fileId, '%-8i', Header.nDataRecords);

% Duration of a data record, in seconds (8 chars).
fprintf(fileId, '%8f', durationPerDataRecordInSec);

% Number of signals (8 chars).
fprintf(fileId, '%-4i', Header.nSignals);

%% >SUB: Write data record header
% Labels (have been assured to be 16 chars long).
fwrite(fileId, Header.channels', 'char*1');

% Transducer type (has been assured to be 80 chars).
fwrite(fileId, TRANSDUCER_TYPE, 'char*1');

% Physical dimension (has been assured to be 8 chars).
% fprintf(fileId, '%-8s', PHYSICAL_DIMENSIONS);
fwrite(fileId, PHYSICAL_DIMENSIONS, 'char*1');

% Physical min/max (assure 8 chars).
fwrite(fileId, sprintf('%-8i', Header.physicalMins)', 'char*1');
fwrite(fileId, sprintf('%-8i', Header.physicalMaxs)', 'char*1');

% Digital min/max (assure 8 chars).
fprintf(fileId, repmat(sprintf('%-8i',intmin(intClass))',1,Header.nSignals));
fprintf(fileId, repmat(sprintf('%-8i',intmax(intClass))',1,Header.nSignals));

% Prefiltering (has been assured to be 80 chars long).
fwrite(fileId, PREFILTER, 'char*1');

% Samples per record (= samplingrate @ 1 sec duration)...
for k=1:Header.nSignals-double(Header.hasEvents)
	fprintf(fileId, '%-8i', Header.samplingrate);
end
% ...for annotations per record.
if Header.hasEvents
	fprintf(fileId, '%-8i', Header.events.signalLength);
end

% Reserverd (32 spaces / signal).
fwrite(fileId, repmat(' ',32,Header.nSignals), 'char*1');

%% >SUB: Write data record
fwrite(fileId, data, intClass);
end % WRITEEDF