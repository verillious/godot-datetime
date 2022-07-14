class_name DateTime

const _TIME_RE = preload("res://addons/datetime/_time_re.gd")

const _DAY_NAMES := [
	"", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"
]

const _MONTH_NAMES := [
	"",
	"january",
	"february",
	"march",
	"april",
	"may",
	"june",
	"july",
	"august",
	"september",
	"october",
	"november",
	"december"
]
const _DAYS_IN_MONTH := [-1, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

# The [unix timestamp](https://www.unixtimestamp.com/) (time in seconds since the 1st of Jan 1970, 00:00:00)
var epoch := 0 setget set_epoch

# The second in the current minute
var second := 0

# The minute in the current hour
var minute := 0

# The hour in the current day
var hour := 0

# The day in the current month
var day := 0

# The day in the current year
var julian := 0

# The month in the current year
var month := 0

# The current year
var year := 0

# The day in the current week
var weekday := 0

# The name of the current weekday
var weekday_name := "monday"

# The name of the current month
var month_name := "january"

# Whether or not this datetime is using daylight savings time
var dst := false


# Construct a DateTime object from the current unix timestamp
static func now() -> DateTime:
	return from_timestamp(OS.get_unix_time(), OS.get_datetime()["dst"])


# Construct a DateTime object from a unix timestamp
# **Args:**
#
# - timestamp (`int`): The new [unix timestamp](https://www.unixtimestamp.com/) to use.
#   (time in seconds since the 1st of Jan 1970, 00:00:00)
# - dst (`bool`) (default: `false`): Whether the datetime object should use daylight savings time
static func from_timestamp(timestamp: int, dst := false) -> DateTime:
	var cls = load("res://addons/datetime/datetime.gd").new()
	cls.epoch = timestamp
	cls.dst = dst
	if cls.dst:
		cls = cls.add_hours(1)
	return cls


# Construct a DateTime object from a data dictionary
# **Args:**
#
# - datetime: A Dictionary of datetime information.
#   Accepts the following keys:
#
#   - `year`:   The datetime year
#   - `month`:  The datetime month
#   - `day`:    The datetime day of the month
#   - `hour`:   The datetime hour (24hr clock)
#   - `minute`: The datetime minute
#   - `second`: The datetime second
#   - `dst`:    Whether the datetime uses daylight saving time
static func datetime(datetime: Dictionary) -> DateTime:
	var day = datetime.get("day", 1)
	var month = datetime.get("month", 1)
	var days_in_month = _days_in_month(month, datetime.get("year", 1970))

	if day < 1 or day > days_in_month:
		push_error(
			(
				"Invalid day value of: %s. It should be comprised between 1 and %s for month %s."
				% [day, days_in_month, month]
			)
		)
		return null

	if month < 1 or month > 12:
		push_error("Invalid month value of: %s. It should be comprised between 1 and 12." % month)
		return null

	return from_timestamp(OS.get_unix_time_from_datetime(datetime), datetime.get("dst", false))


# Construct a DateTime object from a string
#
# **Args:**
#
# - date_string (`String`): The datetime string
# - format (`String`) (default: `"%a %b %d %H:%M:%S %Y"`): String representing how to parse the datetime.
#
#   Accepts the following tokens:
#
#   - `%a`: Weekday name abbreviated (mon, tue ...)
#   - `%A`: Weekday full name (monday, tuesday ...)
#   - `%w`: Weekday as a decimal number, where 0 is Sunday and 6 is Saturday.
#   - `%d`: Day of the month as a zero-padded decimal number. (01, 31 ...)
#   - `%D`: Day of the month as an ordinal. (1st, 23rd ...)
#   - `%b`: Month name abbreviated (jan, feb ...)
#   - `%B`: Month full name (january, february ...)
#   - `%m`: Month as a zero-padded decimal number (01, 02 ...)
#   - `%y`: Year without century as a zero-padded decimal number (22, 99 ...)
#   - `%Y`: Year with century as a decimal number (2022, 1996 ...)
#   - `%H`: Hour (24-hour clock) as a zero-padded decimal number (00, 24 ...)
#   - `%I`: Hour (12-hour clock) as a zero-padded decimal number (12, 01 ...)
#   - `%p`: AM or PM
#   - `%M`: Minute as a zero-padded decimal number (01, 59 ...)
#   - `%S`: Second as a zero-padded decimal number (03, 45 ...)
#   - `%j`: Day of the year as a zero-padded decimal number (001, 234 ...)
#   - `%U`: Week number of the year (Sunday as the first day of the week) as a zero-padded decimal number.
#     All days in a new year preceding the first Sunday are considered to be in week 0 (01, 53 ...)
#   - `%W`: Week number of the year (Monday as the first day of the week) as a zero-padded decimal number.
#     All days in a new year preceding the first Monday are considered to be in week 0 (01, 53 ...)
#   - `%%`: A literal '%' character.
static func strptime(date_string: String, format = "%a %b %d %H:%M:%S %Y") -> DateTime:
	var re = _TIME_RE.new().compile(format)
	var matches = re.search_all(date_string.to_lower())
	if not matches:
		push_error("DateTime data %r does not match format %r" % [date_string, format])
		return null

	matches = matches[0]

	var found_dict = matches.names

	var year = null
	var month = null
	var day = null
	var hour = null
	var minute = null
	var second = null

	var julian = null
	var weekday = null
	var week_of_year = null
	var week_of_year_start = null
	var week_starts_Mon = null

	for group_key in found_dict.keys():
		if group_key == "y":
			year = int(matches.get_string("y"))
			# Open Group specification for strptime() states that a %y
			# value in the range of [00, 68] is in the century 2000, while
			# [69,99] is in the century 1900
			if year <= 68:
				year += 2000
			else:
				year += 1900
		elif group_key == "Y":
			year = int(matches.get_string("Y"))
		elif group_key == "m":
			month = int(matches.get_string("m"))
		elif group_key == "B":
			month = _MONTH_NAMES.find(matches.get_string("B").to_lower())
		elif group_key == "b":
			month = Array(_TIME_RE.month_names_short()).find(matches.get_string("b").to_lower()) + 1
		elif group_key == "D":
			day = int(matches.get_string("D"))
		elif group_key == "d":
			day = int(matches.get_string("d"))
		elif group_key == "H":
			hour = int(matches.get_string("H"))
		elif group_key == "I":
			hour = int(matches.get_string("I"))
			var ampm = matches.get_string("p").lower()
			# If there was no AM/PM indicator, we'll treat this like AM
			if ampm in ["", "am"]:
				# We're in AM so the hour is correct unless we're
				# looking at 12 midnight.
				# 12 midnight == 12 AM == hour 0
				if hour == 12:
					hour = 0
			elif ampm == "pm":
				# We're in PM so we need to add 12 to the hour unless
				# we're looking at 12 noon.
				# 12 noon == 12 PM == hour 12
				if hour != 12:
					hour += 12
		elif group_key == "M":
			minute = int(matches.get_string("M"))
		elif group_key == "S":
			second = int(matches.get_string("S"))
		elif group_key == "A":
			weekday = _DAY_NAMES.find(matches.get_string("B").to_lower())
		elif group_key == "a":
			weekday = Array(_TIME_RE.day_names_short()).find(matches.get_string("a").to_lower()) + 1
		elif group_key == "w":
			weekday = int(matches.get_string("w"))
			if weekday == 0:
				weekday = 6
			else:
				weekday -= 1
		elif group_key == "j":
			julian = int(matches.get_string("j"))
		elif group_key in ["U", "W"]:
			week_of_year = int(found_dict[group_key])
			week_of_year_start = 0
			if group_key == "U":
				# U starts week on Sunday.
				week_of_year_start = 6

	hour = hour or 0
	minute = minute or 0
	second = second or 0

	if not year:
		month = month if month != null else 1
		day = day if day != null else 1
		var cls = load("res://addons/datetime/datetime.gd").new()
		return cls.datetime(
			{"month": month, "day": day, "hour": hour, "minute": minute, "second": second}
		)

	if month and day:
		var cls = load("res://addons/datetime/datetime.gd").new()
		return cls.datetime(
			{
				"year": year,
				"month": month,
				"day": day,
				"hour": hour,
				"minute": minute,
				"second": second
			}
		)
	elif julian:
		var cls = load("res://addons/datetime/datetime.gd").new()
		var dt = cls.datetime({"year": year})
		dt.add_days(julian - 1)
		return dt
	elif week_of_year:
		var cls = load("res://addons/datetime/datetime.gd").new()
		week_starts_Mon = true if week_of_year_start == 0 else false
		julian = _calc_julian(year, week_of_year, weekday, week_starts_Mon)
		var dt = cls.datetime({"year": year})
		dt.add_days(julian - 1)
		return dt

	var datetime = {
		"year": 1970, "month": 1, "day": 1, "hour": hour, "minute": minute, "second": second
	}
	return from_timestamp(OS.get_unix_time_from_datetime(datetime))


# Construct a datetime from an ISO format string
#
# Accepts the following format: `YYYY-MM-DD[*HH[:MM[:SS]]`,
# where '\*' is any single character (including whitespace)
#
# **Args:**
#
# - date_string (`String`): The iso-formatted string to parse
static func from_isoformat(date_string: String) -> DateTime:
	if len(date_string) < 10:
		push_error("Invalid isoformat string: %s" % date_string)
		return null

	var date_component = date_string.left(10)
	var time_component = date_string.right(11)

	date_component = _parse_isoformat_date(date_component)

	if not date_component:
		push_error("Invalid isoformat string: %s" % date_string)
		return null

	if time_component:
		time_component = _parse_isoformat_time(time_component)
		if not time_component:
			push_error("Invalid isoformat string: %s" % date_string)
			return null
	else:
		time_component = {"hour": 0, "minute": 0, "second": 0}

	var cls = load("res://addons/datetime/datetime.gd")
	return cls.datetime(
		{
			"second": time_component["second"],
			"minute": time_component["minute"],
			"hour": time_component["hour"],
			"day": date_component["day"],
			"month": date_component["month"],
			"year": date_component["year"]
		}
	)


# Update the the current epoch of the DateTime object
#
# **Args:**
#
# - new_epoch (`int`): The new [unix timestamp](https://www.unixtimestamp.com/) epoch
#   (time in seconds since the 1st of Jan 1970, 00:00:00)
func set_epoch(new_epoch: int) -> void:
	epoch = new_epoch
	var info = OS.get_datetime_from_unix_time(epoch)

	second = info["second"]
	minute = info["minute"]
	hour = info["hour"]
	day = info["day"]
	month = info["month"]
	year = info["year"]
	weekday = info["weekday"]
	month_name = _MONTH_NAMES[self.month]
	weekday_name = _DAY_NAMES[self.weekday]
	julian = _get_day_of_year()


# Return a copy of this DateTime with the given timedelta dictionary _added_ to it
#
# **Args:**
#
# - delta (`Dictionary`): A dictionary of date and time deltas
#   Accepts the following keys:
#
#   - `year`:   The datetime year
#   - `month`:  The datetime month
#   - `day`:    The datetime day of the month
#   - `hour`:   The datetime hour (24hr clock)
#   - `minute`: The datetime minute
#   - `second`: The datetime second
func add_time(delta: Dictionary) -> DateTime:
	var dt = self
	dt = dt.add_years(delta.get("year", 0))
	dt = dt.add_months(delta.get("month", 0))
	dt = dt.add_days(delta.get("day", 0))
	dt = dt.add_hours(delta.get("hour", 0))
	dt = dt.add_minutes(delta.get("minute", 0))
	dt = dt.add_seconds(delta.get("second", 0))
	return dt


# Return a copy of this DateTime with values _replaced_ by ones from the given data Dictionary
#
# **Args:**
#
# - data (`Dictionary`): A dictionary of values to replace on the DateTime copy.
#   Accepts the following keys:
#
#   - `year`:   The datetime year
#   - `month`:  The datetime month
#   - `day`:    The datetime day of the month
#   - `hour`:   The datetime hour (24hr clock)
#   - `minute`: The datetime minute
#   - `second`: The datetime second
func replace(data := {}) -> DateTime:
	for key in ["year", "month", "day", "hour", "minute", "second"]:
		data[key] = data.get(key, self.get(key))
	return datetime(data)


# Return a copy of this DateTime with a given number of years added to it
#
# **Args:**
#
# - years (`int`): The number of years to add to the DateTime copy
func add_years(years: int) -> DateTime:
	var data = OS.get_datetime_from_unix_time(self.epoch)
	if years == 0:
		return from_timestamp(OS.get_unix_time_from_datetime(data))

	data["year"] = data["year"] + years

	if data["day"] > _days_in_month(data["month"], data["year"]):
		data["day"] = _days_in_month(data["month"], data["year"])
	return from_timestamp(OS.get_unix_time_from_datetime(data))


# Return a copy of this DateTime with a given number of months added to it
#
# **Args:**
#
# - months (`int`): The number of months to add to the DateTime copy
func add_months(months: int) -> DateTime:
	var data = OS.get_datetime_from_unix_time(self.epoch)
	if not months:
		return from_timestamp(OS.get_unix_time_from_datetime(data))

	for month in range(abs(months)):
		data["month"] = data["month"] + (1 * sign(months))
		if data["month"] % 12:
			data["year"] += data["month"] / 12
			data["month"] = data["month"] % 12
		if data["day"] > _days_in_month(data["month"], data["year"]):
			data["day"] = _days_in_month(data["month"], data["year"])
	return from_timestamp(OS.get_unix_time_from_datetime(data))


# Return a copy of this DateTime with a given number of days added to it
#
# **Args:**
#
# - days (`int`): The number of days to add to the DateTime copy
func add_days(days: int) -> DateTime:
	var data = OS.get_datetime_from_unix_time(self.epoch)
	if not days:
		return from_timestamp(OS.get_unix_time_from_datetime(data))

	var new_day = days + self.day
	var new_month = self.month
	var new_year = self.year

	var days_in_current_month = _days_in_month(new_month, new_year)
	while new_day > days_in_current_month:
		new_month += 1
		if new_month > 12:
			new_month = 1
			new_year += 1

		new_day -= days_in_current_month
		days_in_current_month = _days_in_month(new_month, new_year)

	data["day"] = new_day
	data["month"] = new_month
	data["year"] = new_year

	return from_timestamp(OS.get_unix_time_from_datetime(data))


# Return a copy of this DateTime with a given number of hours added to it
#
# **Args:**
#
# - hours (`int`): The number of hours to add to the DateTime copy
func add_hours(hours: int) -> DateTime:
	var dt = self
	var new_hours = dt.hour + hours
	if new_hours >= 24:
		dt = dt.add_days(new_hours / 24)
		new_hours = new_hours % 24
	var data = OS.get_datetime_from_unix_time(dt.epoch)
	data["hour"] = new_hours
	return from_timestamp(OS.get_unix_time_from_datetime(data))


# Return a copy of this DateTime with a given number of minutes added to it
#
# **Args:**
#
# - minutes (`int`): The number of minutes to add to the DateTime copy
func add_minutes(minutes: int) -> DateTime:
	var dt = self
	var new_minutes = dt.minute + minutes
	if new_minutes >= 60:
		dt = dt.add_hours(new_minutes / 60)
		new_minutes = new_minutes % 60
	var data = OS.get_datetime_from_unix_time(dt.epoch)
	data["minute"] = new_minutes
	return from_timestamp(OS.get_unix_time_from_datetime(data))


# Return a copy of this DateTime with a given number of seconds added to it
#
# **Args:**
#
# - seconds (`int`): The number of seconds to add to the DateTime copy
func add_seconds(seconds: int) -> DateTime:
	var dt = self
	var new_seconds = self.second + seconds
	if new_seconds >= 60:
		dt = dt.add_minutes(new_seconds / 60)
		new_seconds = new_seconds % 60
	var data = OS.get_datetime_from_unix_time(dt.epoch)
	data["second"] = new_seconds
	return from_timestamp(OS.get_unix_time_from_datetime(data))


# Construct a string representing the datetime with a given format string
#
# **Args:**
#
# - format (`String`) (default: `"%a %b %d %H:%M:%S %Y"`): String representing how to format the string.
#
#   Accepts the following tokens:
#
#   - `%a`: Weekday name abbreviated (mon, tue ...)
#   - `%A`: Weekday full name (monday, tuesday ...)
#   - `%w`: Weekday as a decimal number, where 0 is Sunday and 6 is Saturday.
#   - `%d`: Day of the month as a zero-padded decimal number. (01, 31 ...)
#   - `%D`: Day of the month as an ordinal. (1st, 23rd ...)
#   - `%b`: Month name abbreviated (jan, feb ...)
#   - `%B`: Month full name (january, february ...)
#   - `%m`: Month as a zero-padded decimal number (01, 02 ...)
#   - `%y`: Year without century as a zero-padded decimal number (22, 99 ...)
#   - `%Y`: Year with century as a decimal number (2022, 1996 ...)
#   - `%H`: Hour (24-hour clock) as a zero-padded decimal number (00, 24 ...)
#   - `%I`: Hour (12-hour clock) as a zero-padded decimal number (12, 01 ...)
#   - `%p`: AM or PM
#   - `%M`: Minute as a zero-padded decimal number (01, 59 ...)
#   - `%S`: Second as a zero-padded decimal number (03, 45 ...)
#   - `%j`: Day of the year as a zero-padded decimal number (001, 234 ...)
#   - `%U`: Week number of the year (Sunday as the first day of the week) as a zero-padded decimal number.
#     All days in a new year preceding the first Sunday are considered to be in week 0 (01, 53 ...)
#   - `%W`: Week number of the year (Monday as the first day of the week) as a zero-padded decimal number.
#     All days in a new year preceding the first Monday are considered to be in week 0 (01, 53 ...)
#   - `%%`: A literal '%' character.
func strftime(format: String = "%a %b %d %H:%M:%S %Y") -> String:
	var weekday_name_short = self.weekday_name.left(3)
	var month_name_short = self.month_name.left(3)

	var twelve_hour = self.hour if self.hour <= 12 else self.hour % 12
	var am_pm = "AM" if self.hour < 12 else "PM"

	var return_string = format
	return_string = return_string.replace("%A", self.weekday_name)
	return_string = return_string.replace("%a", weekday_name_short)
	return_string = return_string.replace("%B", self.month_name)
	return_string = return_string.replace("%b", month_name_short)
	return_string = return_string.replace("%w", wrapi(self.weekday - 6, 0, 6))
	return_string = return_string.replace("%D", _ordinal(self.day))
	return_string = return_string.replace("%d", "%02d" % self.day)
	return_string = return_string.replace("%m", "%02d" % self.month)
	return_string = return_string.replace("%y", ("%04d" % self.year).right(2))
	return_string = return_string.replace("%Y", "%04d" % self.year)
	return_string = return_string.replace("%H", "%02d" % self.hour)
	return_string = return_string.replace("%I", "%02d" % twelve_hour)
	return_string = return_string.replace("%p", am_pm)
	return_string = return_string.replace("%M", "%02d" % self.minute)
	return_string = return_string.replace("%S", "%02d" % self.second)
	return_string = return_string.replace("%j", self._get_day_of_year())
	return_string = return_string.replace("%U", self._get_week_of_year(false))
	return_string = return_string.replace("%W", self._get_week_of_year())

	return return_string


# Return a string representing the date and time in ISO 8601 format
#
# **Args:**
#
# - sep (`String`): The seperator to use between the date and time components
# - timespec (`String`) (default: `"seconds"`): The number of components of the time to include.
#   Accepted values are `"hours"`, `"minutes"`, `"seconds"`
func isoformat(sep := "T", timespec := "seconds") -> String:
	return (
		self.strftime("%Y-%m-%d%s%s")
		% [sep, _format_time(self.hour, self.minute, self.second, timespec)]
	)


static func _calc_julian(year: int, week_of_year: int, day_of_week: int, week_starts_Mon := true) -> int:
	var cls = load("res://addons/datetime/datetime.gd").new()
	var first_weekday = cls.datetime({"year": year}).weekday()

	if not week_starts_Mon:
		first_weekday = (first_weekday + 1) % 7
		day_of_week = (day_of_week + 1) % 7
	var week_0_length = (7 - first_weekday) % 7
	if week_of_year == 0:
		return 1 + day_of_week - first_weekday
	else:
		var days_to_week = week_0_length + (7 * (week_of_year - 1))
		return 1 + days_to_week + day_of_week


static func _parse_isoformat_date(date_string: String) -> Dictionary:
	if len(date_string) != 10 or date_string[4] != "-" or date_string[7] != "-":
		push_error("Invalid isoformat string: %s" % date_string)
		return {}

	for c in date_string:
		if not (_is_ascii_digit(c) or c == "-"):
			push_error("Invalid isoformat character: '%s' in %s" % [c, date_string])
			return {}

	var year = int(date_string.left(4))
	var month = int(date_string.substr(5, 2))
	var day = int(date_string.substr(8, 2))

	return {"year": year, "month": month, "day": day}


static func _parse_isoformat_time(time_string: String) -> Dictionary:
	var string_length = len(time_string)

	if (
		not string_length in [2, 5, 8]
		or (string_length > 2 and time_string[2] != ":")
		or (string_length > 5 and time_string[5] != ":")
	):
		push_error("Invalid isoformat time string: %s" % time_string)
		return {}

	var time_comps = time_string.split(":")
	time_comps.resize(3)

	return {
		"hour": int(time_comps[0]),
		"minute": int(time_comps[1]),
		"second": int(time_comps[2]),
	}


static func _is_ascii_digit(c: String) -> bool:
	return c in "0123456789"


static func _is_leap_year(_year: int) -> bool:
	return !(_year % 4) and not (!(_year % 100) and (_year % 400))


static func _days_in_month(month: int, year: int) -> int:
	assert(month >= 1 and month <= 12)
	if month == 2 and _is_leap_year(year):
		return 29
	return _DAYS_IN_MONTH[month]


static func _ordinal(n: int) -> String:
	var suffix = ""
	var _n = n % 100
	if 4 <= _n and _n <= 20:
		suffix = "th"
	else:
		suffix = {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
	return str(n) + suffix


static func _format_time(hh, mm, ss, timespec = "seconds"):
	var specs = {
		"hours": "{hour}", "minutes": "{hour}:{minute}", "seconds": "{hour}:{minute}:{second}"
	}
	return specs[timespec].format(
		{"hour": "%02d" % hh, "minute": "%02d" % mm, "second": "%02d" % ss}
	)


func _to_string():
	return isoformat(" ")


func _get_day_of_year() -> int:
	var day_of_year = self.day
	for month in range(1, self.month):
		day_of_year += _days_in_month(month, self.year)
	return day_of_year


func _get_week_of_year(week_starts_Mon := true) -> int:
	var cls = load("res://addons/datetime/datetime.gd").new()
	var julian = self._get_day_of_year()
	var first_weekday = wrapi(cls.datetime({"year": year}).weekday - 6, 0, 6)

	var week_of_year = (julian + 6) / 7
	if wrapi(self.weekday - 6, 0, 6) < first_weekday:
		week_of_year += 1
	return week_of_year
