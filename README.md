# Dynamik
Dynamik (/dīˈnamik/) allows you to easily set your iOS device's wallpaper(s) from custom sources on Reddit.
[View the video demo](https://youtu.be/_JtgyiCz_84).

[![Banner](https://github.com/JeffResc/Dynamik/raw/master/_assets/Banner/Banner.png)](#)

Compatible with iOS 11 - 13.

This project is the unofficial successor of [Stellae](https://repo.packix.com/package/com.lacertosusrepo.stellae/). I've reached out to the original developer who stated they were no longer interested in maintaining the original project and that a new tweak could be made. Thank you to Lacertosus Deus for Stellae and I hope Dynamik can hold the same standards it did.

Suggested Subreddits:
- [r/EarthPorn](https://www.reddit.com/r/EarthPorn)
- [r/SpacePorn](https://www.reddit.com/r/SpacePorn)
- [r/CityPorn](https://www.reddit.com/r/CityPorn)
- [r/SkyPorn](https://www.reddit.com/r/SkyPorn)
- [r/WeatherPorn](https://www.reddit.com/r/WeatherPorn)
- [r/Amoledbackgrounds](https://www.reddit.com/r/Amoledbackgrounds)
- [r/MobileWallpaper](https://www.reddit.com/r/MobileWallpaper)

Features:
- Set where the image is applied to (homescreen, lockscreen, or both)
- Set the parallax to on or off
- An optional timer to automatically update the wallpaper at a certain time every 24 hours
- An advanced command line interface to customize how and when to update the wallpaper (see Advanced Usage)
- Set the number of hot posts to grab (up to 10)
- Set a custom subreddit to grab posts from
- Easily filter NSFW posts
- If you really like that wallpaper you got, save it with the button in settings
- Manually update the wallpaper if you like

## Downloading and Installing
You can either [Download Dynamik for Free from Packix](https://repo.packix.com/package/com.jeffresc.dynamik/), or download and install it manually using the .deb file, which can be downloaded from the [GitHub releases section](https://github.com/JeffResc/Dynamik/releases).

# Advanced Usage
### Command Usage
By design, this package comes bundled with an advanced command line interface for setting the wallpaper from various sources. It can be invoked from the terminal by typing the following command:
```bash
dynamikcli --help
```
### Command Options
This command line interface comes with several options as depicted below:
| Option | Description                        | Requires Argument? | Required?                                                |
|--------|------------------------------------|--------------------|----------------------------------------------------------|
| -s     | Set the subreddit                  | Yes                | Yes                                                      |
| -m     | # of hot posts to grab             | Yes                | Yes                                                      |
| -l     | Set only the lock screen wallpaper | No                 | No, but must use -h or -b instead, but not more than one |
| -h     | Set only the home screen wallpaper | No                 | No, but must use -l or -b instead, but not more than one |
| -b     | Set both wallpapers                | No                 | No, but must use -l or -h instead, but not more than one |
| -p     | Enable parallax                    | No                 | No, off by default                                       |
| -n     | Enable NSFW Filter                 | No                 | No, off by default                                       |
| -q     | Enable High-Quality Filter         | No                 | No, off by default                                       |
### Command Examples
Set the wallpaper from the "r/SpacePorn" subreddit with 5 hot posts to both the lockscreen and homescreen, with the NSFW Filter on
```bash
dynamikcli -s spaceporn -m 5 -b -n
```
Set the wallpaper from the "r/EarthPorn" subreddit with 10 hot posts to homescreen with parallax enabled and the High-Quality filter enabled
```bash
dynamikcli -s earthporn -m 10 -h -p -q
```

# Changelog
The changelog has been moved to the [releases tab](https://github.com/JeffResc/Dynamik/releases).

# Donating
Donations are never expected, but always appreciated. You can donate [to my PayPal account](http://paypal.me/JeffRescignano).
