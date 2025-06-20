@echo off
REM === ULTRA SIMPLE VIDEO/AUDIO DOWNLOADER ===

set "YT_DLP=yt-dlp.exe"
set "OUTPUTFILE=output.%%(ext)s"

REM === Check yt-dlp ===
if not exist "%~dp0%YT_DLP%" (
    echo yt-dlp.exe not found. Downloading latest version...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile '%YT_DLP%'"
    if not exist "%~dp0%YT_DLP%" (
        echo ERROR: yt-dlp.exe failed to download. Exiting.
        pause
        exit /b
    )
)

REM === Ask for URL ===
set /p VIDEO_URL="Paste video URL: "

REM === Download ===
echo Downloading best quality...
"%YT_DLP%" -f best --merge-output-format mp4 -o "%OUTPUTFILE%" %VIDEO_URL%

echo.
echo === DONE! File saved as output.*
pause
