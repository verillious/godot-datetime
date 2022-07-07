extends "res://addons/gut/test.gd"


func test_datetime():
	var datetime = DateTime.datetime()
	assert_eq(datetime.get_datetime_string(), "1st of january, 1970 00:00:00")


func test_datetime_from_date():
	var datetime = DateTime.datetime(
		{"second": 30, "minute": 4, "hour": 12, "day": 7, "month": 1, "year": 2022}
	)
	assert_eq(datetime.get_datetime_string(), "7th of january, 2022 12:04:30")
	datetime = DateTime.datetime(
		{"second": 30, "minute": 4, "hour": 23, "day": 7, "month": 1, "year": 2022}
	)
	assert_eq(datetime.get_datetime_string(), "7th of january, 2022 23:04:30")


func test_datetime_from_now():
	var os_now = OS.get_datetime()
	var datetime = DateTime.now()
	assert_eq(datetime.second, os_now["second"], "second should match os.now")
	assert_eq(datetime.minute, os_now["minute"], "minute should match os.now")
	assert_eq(datetime.hour, os_now["hour"], "hour should match os.now")
	assert_eq(datetime.day, os_now["day"], "day should match os.now")
	assert_eq(datetime.month, os_now["month"], "month should match os.now")
	assert_eq(datetime.year, os_now["year"], "year should match os.now")


func test_datetime_minute():
	var datetime = DateTime.datetime()
	datetime.add_time({"minute": 1})
	assert_eq(datetime.get_datetime_string(), "1st of january, 1970 00:01:00")
	datetime.add_time({"minute": 59})
	assert_eq(datetime.get_datetime_string(), "1st of january, 1970 01:00:00")
	datetime.add_time({"minute": 59 * 24})
	assert_eq(datetime.get_datetime_string(), "2nd of january, 1970 00:36:00")


func test_datetime_hour():
	var datetime = DateTime.datetime()
	datetime.add_time({"hour": 1})
	assert_eq(datetime.get_datetime_string(), "1st of january, 1970 01:00:00")
	datetime.add_time({"hour": 2})
	assert_eq(datetime.get_datetime_string(), "1st of january, 1970 03:00:00")
	datetime.add_time({"hour": 24})
	assert_eq(datetime.get_datetime_string(), "2nd of january, 1970 03:00:00")
	datetime.add_time({"hour": 25})
	assert_eq(datetime.get_datetime_string(), "3rd of january, 1970 04:00:00")
	datetime.add_time({"hour": 27})
	assert_eq(datetime.get_datetime_string(), "4th of january, 1970 07:00:00")
	datetime.add_time({"hour": 30})
	assert_eq(datetime.get_datetime_string(), "5th of january, 1970 13:00:00")
	datetime.add_time({"hour": 364})
	assert_eq(datetime.get_datetime_string(), "20th of january, 1970 17:00:00")
	assert_eq(datetime.weekday_name, "tuesday")


func test_datetime_day():
	var datetime = DateTime.datetime()
	datetime.add_time({"day": 1})
	assert_eq(datetime.get_datetime_string(), "2nd of january, 1970 00:00:00")
	datetime.add_time({"day": 2})
	assert_eq(datetime.get_datetime_string(), "4th of january, 1970 00:00:00")
	datetime.add_time({"day": 3})
	assert_eq(datetime.get_datetime_string(), "7th of january, 1970 00:00:00")
	datetime.add_time({"day": 24})
	assert_eq(datetime.get_datetime_string(), "31st of january, 1970 00:00:00")
	datetime.add_time({"day": 25})
	assert_eq(datetime.get_datetime_string(), "25th of february, 1970 00:00:00")
	datetime.add_time({"day": 27})
	assert_eq(datetime.get_datetime_string(), "24th of march, 1970 00:00:00")
	datetime.add_time({"day": 30})
	assert_eq(datetime.get_datetime_string(), "23rd of april, 1970 00:00:00")
	datetime.add_time({"day": 364})
	assert_eq(datetime.get_datetime_string(), "22nd of april, 1971 00:00:00")


func test_datetime_month():
	var datetime = DateTime.datetime()
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of february, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of march, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of april, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of may, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of june, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of july, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of august, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of september, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of october, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of november, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of december, 1970 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "1st of january, 1971 00:00:00")

	datetime.add_time({"day": 30})
	assert_eq(datetime.get_datetime_string(), "31st of january, 1971 00:00:00")
	datetime.add_time({"month": 1})
	assert_eq(datetime.get_datetime_string(), "28th of february, 1971 00:00:00")


func test_datetime_year():
	var datetime = DateTime.datetime({"year": 2022})
	assert_eq(datetime.year, 2022)
	assert_eq(datetime.get_date_string(), "1st of january, 2022")
	datetime.add_time({"year": 2022})
	assert_eq(datetime.year, 4044)
	datetime.add_time({"year": 2022})
	assert_eq(datetime.year, 6066)
	datetime.add_time({"year": 2022})
	assert_eq(datetime.year, 8088)
	datetime.add_time({"year": 2022})
	assert_eq(datetime.year, 10110)
	assert_eq(datetime.get_date_string(), "1st of january, 10110")
	datetime.add_time({"year": -12079})
	assert_eq(datetime.get_date_string(), "1st of january, 0001")


func test_is_leap_year():
	assert_true(DateTime.is_leap_year(2004), "2004 is a leap year")
	assert_true(DateTime.is_leap_year(2032), "2032 is a leap year")
	assert_true(DateTime.is_leap_year(2072), "2072 is a leap year")
	assert_false(DateTime.is_leap_year(2003), "2003 is not a leap year")
	assert_false(DateTime.is_leap_year(1817), "1817 is not a leap year")
	assert_false(DateTime.is_leap_year(2089), "2089 is not a leap year")
