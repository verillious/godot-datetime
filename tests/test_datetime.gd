extends "res://addons/gut/test.gd"


func test_datetime():
	var datetime = DateTime.datetime()
	assert_eq(datetime.get_datetime_string(), "1st of january, 0001 00:00:00")


func test_datetime_from_date():
	var datetime = DateTime.datetime(30, 4, 12, 7, 1, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of january, 2022 12:04:30")


func test_datetime_from_now():
	var os_now = OS.get_datetime()
	var datetime = DateTime.now()

	assert_eq(datetime.second, os_now["second"], "second should match os.now")
	assert_eq(datetime.minute, os_now["minute"], "minute should match os.now")
	assert_eq(datetime.hour, os_now["hour"], "hour should match os.now")
	assert_eq(datetime.day, os_now["day"], "day should match os.now")
	assert_eq(datetime.month, os_now["month"], "month should match os.now")
	assert_eq(datetime.year, os_now["year"], "year should match os.now")


func test_datetime_day():
	var datetime = DateTime.datetime()
	datetime.add_time(0, 0, 0, 1, 0, 0)
	assert_eq(datetime._get_day_index(), 1)
	assert_eq(datetime.get_datetime_string(), "2nd of january, 0001 00:00:00")
	datetime.add_time(0, 0, 0, 2, 0, 0)
	assert_eq(datetime._get_day_index(), 3)
	assert_eq(datetime.get_datetime_string(), "4th of january, 0001 00:00:00")
	datetime.add_time(0, 0, 0, 3, 0, 0)
	assert_eq(datetime._get_day_index(), 6)
	assert_eq(datetime.get_datetime_string(), "7th of january, 0001 00:00:00")
	datetime.add_time(0, 0, 0, 24, 0, 0)
	assert_eq(datetime._get_day_index(), 30)
	assert_eq(datetime.get_datetime_string(), "31st of january, 0001 00:00:00")
	datetime.add_time(0, 0, 0, 1, 0, 0)
	assert_eq(datetime._get_day_index(), 31)
	assert_eq(datetime.get_datetime_string(), "1st of february, 0001 00:00:00")
	datetime.add_time(0, 0, 0, 27, 0, 0)
	assert_eq(datetime._get_day_index(), 58)
	assert_eq(datetime.get_datetime_string(), "28th of february, 0001 00:00:00")
	datetime.add_time(0, 0, 0, 30, 0, 0)
	assert_eq(datetime._get_day_index(), 88)
	assert_eq(datetime.get_datetime_string(), "30th of march, 0001 00:00:00")
	datetime.add_time(0, 0, 0, 364, 0, 0)
	assert_eq(datetime._get_day_index(), 364+88)
	assert_eq(datetime.get_datetime_string(), "30th of march, 0002 00:00:00")

func test_datetime_month():
	var datetime = DateTime.datetime()
	datetime.add_time(0, 0, 0, 0, 1, 0)
	assert_eq(datetime.get_datetime_string(), "1st of february, 0001 00:00:00")

	datetime = DateTime.datetime(30, 4, 12, 7, 1, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of january, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 2, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of february, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 3, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of march, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 4, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of april, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 5, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of may, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 6, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of june, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 7, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of july, 2022 12:04:30")
	assert_eq(datetime._get_day_index(), 738342)
	datetime = DateTime.datetime(30, 4, 12, 7, 8, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of august, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 9, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of september, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 10, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of october, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 11, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of november, 2022 12:04:30")
	datetime = DateTime.datetime(30, 4, 12, 7, 12, 2022)
	assert_eq(datetime.get_datetime_string(), "7th of december, 2022 12:04:30")



func test_datetime_year():
	var datetime = DateTime.datetime(0, 0, 0, 0, 0, 2022)
	assert_eq(datetime.year, 2022)
	assert_eq(datetime.get_date_string(), "1st of january, 2022")
	datetime.add_time(0, 0, 0, 0, 0, 2022)
	assert_eq(datetime.year, 4044)
	datetime.add_time(0, 0, 0, 0, 0, 2022)
	assert_eq(datetime.year, 6066)
	datetime.add_time(0, 0, 0, 0, 0, 2022)
	assert_eq(datetime.year, 8088)
	datetime.add_time(0, 0, 0, 1, 1, 2022)
	assert_eq(datetime.year, 10110)
	assert_eq(datetime.get_date_string(), "2nd of february, 10110")


func test_leap_year():
	assert_true(DateTime.leap_year(2004), "2004 is a leap year")
	assert_true(DateTime.leap_year(2032), "2032 is a leap year")
	assert_true(DateTime.leap_year(2072), "2072 is a leap year")
	assert_false(DateTime.leap_year(2003), "2003 is not a leap year")
	assert_false(DateTime.leap_year(1817), "1817 is not a leap year")
	assert_false(DateTime.leap_year(2089), "2089 is not a leap year")
