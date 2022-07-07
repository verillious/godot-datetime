class_name DateTime

var epoch := 0 setget set_epoch

var second := 0
var minute := 0
var hour := 0
var day := 0
var month := 0
var year := 0
var weekday := 0
var weekday_name := "monday"
var month_name := "january"
var dst := false


static func datetime(datetime: Dictionary = {"year": 1970}) -> DateTime:
	var cls = load("res://addons/datetime/datetime.gd").new()
	cls.epoch = OS.get_unix_time_from_datetime(datetime)
	cls.dst = datetime.get("dst", false)
	return cls


static func now() -> DateTime:
	var cls = load("res://addons/datetime/datetime.gd").new()
	cls.epoch = OS.get_unix_time()
	cls.dst = OS.get_datetime()["dst"]
	if cls.dst:
		cls.add_hours(1)
	return cls


static func is_leap_year(_year: int) -> bool:
	return !(_year % 4) and not (!(_year % 100) and (_year % 400))


static func days_in_year(_year: int) -> int:
	return 366 if is_leap_year(_year) else 365


static func to_month_name(_month: int) -> String:
	var name = ""
	match _month:
		1:
			name = "january"
		2:
			name = "february"
		3:
			name = "march"
		4:
			name = "april"
		5:
			name = "may"
		6:
			name = "june"
		7:
			name = "july"
		8:
			name = "august"
		9:
			name = "september"
		10:
			name = "october"
		11:
			name = "november"
		12:
			name = "december"
		_:
			name = "january"
	return name


static func to_weekday_name(_day: int) -> String:
	var name = ""
	match _day:
		1:
			name = "monday"
		2:
			name = "tuesday"
		3:
			name = "wednesday"
		4:
			name = "thurday"
		5:
			name = "friday"
		6:
			name = "saturday"
		7:
			name = "sunday"
		_:
			name = "monday"
	return name


static func days_in_month(_month: int, _year: int) -> int:
	match _month:
		1:
			return 31
		2:
			return 28 if not is_leap_year(_year) else 29
		3:
			return 31
		4:
			return 30
		5:
			return 31
		6:
			return 30
		7:
			return 31
		8:
			return 31
		9:
			return 30
		10:
			return 31
		11:
			return 30
		12:
			return 31
	return 0


static func ordinal(n: int) -> String:
	var suffix = ""
	var _n = n % 100
	if 4 <= _n and _n <= 20:
		suffix = "th"
	else:
		suffix = {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
	return str(n) + suffix


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
	month_name = to_month_name(self.month)
	weekday_name = to_weekday_name(self.weekday)


func add_years(years: int) -> void:
	if not years:
		return
	for year in range(abs(years)):
		var data = OS.get_datetime_from_unix_time(self.epoch)
		data["year"] = self.year + (1 * sign(years))
		set_epoch(OS.get_unix_time_from_datetime(data))


func add_months(months: int) -> void:
	if not months:
		return
	for month in range(abs(months)):
		var data = OS.get_datetime_from_unix_time(self.epoch)
		data["month"] = self.month + (1 * sign(months))
		if data["month"] % 12:
			data["year"] += data["month"] / 12
			data["month"] = data["month"] % 12
		if data["day"] > days_in_month(data["month"], data["year"]):
			data["day"] = days_in_month(data["month"], data["year"])
		set_epoch(OS.get_unix_time_from_datetime(data))


func add_days(days: int) -> void:
	if not days:
		return

	var new_day = days + self.day
	var new_month = self.month
	var new_year = self.year

	var days_in_current_month = days_in_month(new_month, new_year)
	while new_day > days_in_current_month:
		new_month += 1
		if new_month > 12:
			new_month = 1
			new_year += 1

		new_day -= days_in_current_month
		days_in_current_month = days_in_month(new_month, new_year)

	var data = OS.get_datetime_from_unix_time(self.epoch)

	data["day"] = new_day
	data["month"] = new_month
	data["year"] = new_year

	set_epoch(OS.get_unix_time_from_datetime(data))


func add_hours(hours: int) -> void:
	var new_hours = self.hour + hours
	if new_hours >= 24:
		add_days(new_hours / 24)
		new_hours = new_hours % 24
	var data = OS.get_datetime_from_unix_time(self.epoch)
	data["hour"] = new_hours
	set_epoch(OS.get_unix_time_from_datetime(data))


func add_minutes(minutes: int) -> void:
	var new_minutes = self.minute + minutes
	if new_minutes >= 60:
		add_hours(new_minutes / 60)
		new_minutes = new_minutes % 60
	var data = OS.get_datetime_from_unix_time(self.epoch)
	data["minute"] = new_minutes
	set_epoch(OS.get_unix_time_from_datetime(data))


func add_seconds(seconds: int) -> void:
	var new_seconds = self.second + seconds
	if new_seconds >= 60:
		add_minutes(new_seconds / 60)
		new_seconds = new_seconds % 60
	var data = OS.get_datetime_from_unix_time(self.epoch)
	data["second"] = new_seconds
	set_epoch(OS.get_unix_time_from_datetime(data))


func add_time(datetime: Dictionary) -> void:
	add_years(datetime.get("year", 0))
	add_months(datetime.get("month", 0))
	add_days(datetime.get("day", 0))
	add_hours(datetime.get("hour", 0))
	add_minutes(datetime.get("minute", 0))
	add_seconds(datetime.get("second", 0))


func get_time_string() -> String:
	return "%02d:%02d:%02d" % [self.hour, self.minute, self.second]


func get_date_string() -> String:
	return "%s of %s, %04d" % [ordinal(self.day), self.month_name, self.year]


func get_datetime_string() -> String:
	return "%s %s" % [get_date_string(), get_time_string()]
