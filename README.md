# 🕰️ Godot Date Time
[![Made with Godot](https://img.shields.io/badge/Made%20with-Godot%203.4-478CBF?style=flat&logo=godot%20engine&logoColor=white)](https://godotengine.org)
![Pulse](https://img.shields.io/github/commit-activity/m/verillious/godot-datetime)
![Checks](https://github.com/verillious/godot-datetime/actions/workflows/godot-tests.yml/badge.svg)

> Datetime utils for Godot


## 🖊️ Usage

[:books: API Documentation](../../wiki/DateTime)

```gdscript
var datetime = DateTime.now()
print(datetime.strftime("%D of %B, %Y %H:%M:%S"))
> "7th of january, 2022 12:04:30"

var tomorrow = datetime.add_days(1).day
print(tomorrow)
> 8

var next_month = datetime.add_months(1).month_name
print(next_month)
> "february"

var two_months_and_a_day = datetime.add_time({"day": 1, "month": 2})
print(two_months_and_a_day)
> "2022-03-08 12:04:30"
```

## 😢 Limitations

Currently not supported:
 - Timezones
 - Units smaller than a second
 - `DateTime.from_isoformat()` with ISOFormat date strings that don't look like `YYYY-MM-DDTHH:MM:SS` or `YYYY-MM-DD HH:MM:SS` (you can parse them using `DateTime.strptime()` if you know how they're formatted, though.)

## 🙏 Credits

🍪 This project was created with [cookiecutter](https://github.com/audreyr/cookiecutter) and the [verillious/cookiecutter-godot](https://github.com/verillious/cookiecutter-godot) project template.

🎨 <a href="https://www.flaticon.com/free-icons/number" title="number icons">Icon created by Freepik - Flaticon</a>
