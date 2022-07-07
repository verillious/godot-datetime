class_name DateTime

signal new_tick(ticks)
signal new_minute(minute)
signal new_hour(hour)
signal new_day(day)

var second := 0 setget , get_second
var minute := 0 setget , get_minute
var hour := 0 setget , get_hour
var day := 1 setget , get_day
var month := 1 setget , get_month
var year := 1 setget , get_year

var ticks := 0
var ticks_per_minute := 6000


static func datetime(
	seconds := 0, minutes := 0, hours := 0, days := 1, months := 1, years := 1
) -> DateTime:
	var datetime = load("res://addons/datetime/datetime.gd").new()
	datetime.add_time(seconds, minutes, hours, days - 1, months - 1, years - 1)
	return datetime


static func now() -> DateTime:
	var datetime = load("res://addons/datetime/datetime.gd").new()
	var os_time = OS.get_datetime()

	datetime.add_time(
		os_time["second"],
		os_time["minute"],
		os_time["hour"],
		os_time["day"] - 1,
		os_time["month"] - 1,
		os_time["year"] - 1
	)
	return datetime


func year_delta(years := 0) -> int:
	var day_offset = 0
	var current_year = get_year()
	for i in range(years):
		day_offset += (days_in_year(current_year + i) - 1)
	return day_delta(day_offset)


func month_delta(months := 0) -> int:
	var day_offset = -1 * (self.day - 1)
	var delta_ticks = ticks

	for i in range(months):
		var current_month = _get_month_index(delta_ticks) + 1
		var current_year = _get_year_index(delta_ticks) + 1
		day_offset += days_in_month(current_month, current_year)
		delta_ticks = ticks + day_delta(day_offset)

	var final_month = _get_month_index(delta_ticks) + 1
	var final_year = _get_year_index(delta_ticks) + 1
	day_offset += min(self.day - 1, days_in_month(final_month, final_year) - 1)
	return day_delta(day_offset)


func day_delta(days := 0) -> int:
	return hour_delta(days * 24)


func hour_delta(hours:=0) -> int:
	return minute_delta(hours * 60)


func minute_delta(minutes:=0) -> int:
	return minutes * ticks_per_minute


func second_delta(seconds:=0) -> int:
	return seconds * (ticks_per_minute / 60)


func tick(to_tick := ticks_per_minute / 60) -> void:
	ticks += to_tick
	emit_signal("new_tick", ticks)

	if not ticks % ticks_per_minute:
		emit_signal("new_minute", get_minute())
		minute = get_minute()

		if not self.minute % 60:
			emit_signal("new_hour", get_hour())
			hour = get_hour()

		if not self.hour % 24:
			emit_signal("new_day", get_day())
			day = get_day()


func _get_second_index(index_ticks := ticks) -> int:
	return index_ticks / (ticks_per_minute / 60)


func _get_minute_index(index_ticks := ticks) -> int:
	return index_ticks / ticks_per_minute


func _get_hour_index(index_ticks := ticks) -> int:
	return _get_minute_index(index_ticks) / 60


func _get_day_index(index_ticks := ticks) -> int:
	# warning-ignore:integer_division
	return _get_hour_index(index_ticks) / 24


func _get_month_index(index_ticks := ticks) -> int:
	var _day = _get_day_index(index_ticks) - _get_year_day_offset()

	var _day_cutoff := 0
	for i in range(0, 12):
		_day_cutoff += days_in_month(i + 1)
		if _day < _day_cutoff:
			return i
	return -1


func _get_year_index(index_ticks := ticks) -> int:
	#warning-ignore:integer_division

	var index_days = _get_day_index(index_ticks)
	var leaps = int((index_days / 4) / 364)
	var years = int(index_days / 364)
	var remaining_days = index_days % 364

	return years - (leaps / 364) + (remaining_days / 364)


func _get_year_day_offset(index_ticks := ticks) -> int:
	var day_offset = 0
	for year in range(_get_year_index()):
		var check_year = year+1
		day_offset += (days_in_year(check_year) - 1)

	return day_offset


func get_second() -> int:
	return self.ticks % ticks_per_minute / (ticks_per_minute / 60)


func get_minute() -> int:
	# warning-ignore:integer_division
	return _get_minute_index() - (_get_hour_index() * 60)


func get_hour() -> int:
	# warning-ignore:integer_division
	return _get_hour_index() - _get_day_index() * 24


func get_day() -> int:
	var day_in_year := (_get_day_index()) - _get_year_day_offset()
	var _day := (day_in_year + 1)
	for i in range(0, 12):
		var _day_cutoff = days_in_month(i + 1)
		if _day > _day_cutoff:
			_day -= _day_cutoff
		else:
			break
	return _day


func get_month() -> int:
	return _get_month_index() + 1


func get_year() -> int:
	return _get_year_index() + 1


func add_time(seconds := 0, minutes := 0, hours := 0, days := 0, months := 0, years := 0) -> void:
	# print("TimeDelta: adding time > years: %s, months: %s, days: %s, hours: %s, minutes: %s, seonds: %s" % [years,months,days,hours,minutes,seconds])

	if seconds:
		tick(second_delta(seconds))
	if minutes:
		tick(minute_delta(minutes))
	if hours:
		tick(hour_delta(hours))
	if days:
		tick(day_delta(days))
	if months:
		tick(month_delta(months))
	if years:
		tick(year_delta(years))




func get_time_string() -> String:
	return "%02d:%02d:%02d" % [self.hour, self.minute, self.second]


func get_date_string() -> String:
	return "%s of %s, %04d" % [_ord(get_day()), get_month_name(), get_year()]


func get_datetime_string() -> String:
	return "%s %s" % [get_date_string(), get_time_string()]


func days_in_month(_month: int, year := self.year) -> int:
	match _month:
		1:
			return 31
		2:
			return 28 if not leap_year(year) else 29
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


func get_month_name() -> String:
	return to_month_name(get_month())


func to_month_name(_month: int) -> String:
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


static func leap_year(year: int) -> bool:
	return !(year % 4) and not (!(year % 100) and (year % 400))


static func days_in_year(year: int) -> int:
	return 366 if leap_year(year) else 365


func _ord(n):
	var suffix = ""
	var _n = n % 100
	if 4 <= _n and _n <= 20:
		suffix = "th"
	else:
		suffix = {1: "st", 2: "nd", 3: "rd"}.get(n % 10, "th")
	return str(n) + suffix
