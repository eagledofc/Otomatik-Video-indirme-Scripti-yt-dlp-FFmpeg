@echo off
REM === SUPER SIMPLE yt-dlp ONLY DOWNLOADER ===

REM === Config ===
set "YT_DLP=yt-dlp.exe"
set "OUTPUT=output.%%(ext)s"

REM === Check yt-dlp ===
if not exist "%YT_DLP%" (
    echo yt-dlp.exe not found. Downloading latest version...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile '%YT_DLP%'"
    if not exist "%YT_DLP%" (
        echo ERROR: yt-dlp.exe failed to download!
        pause
        exit /b
    )
)

REM === Ask URL ===
set /p URL="Enter the video URL: "

REM === Download ===
echo.
echo Downloading...
"%YT_DLP%" -f best --merge-output-format mp4 -o "%OUTPUT%" %URL%

echo.
echo === DONE! ===
echo Saved as: %OUTPUT%
pause
