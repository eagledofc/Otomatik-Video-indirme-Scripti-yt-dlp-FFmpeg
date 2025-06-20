@echo off
REM === FINAL yt-dlp ONLY SCRIPT — NO FFMPEG ===

setlocal

REM === File Names ===
set "YT_DLP=yt-dlp.exe"
set "OUTPUTVIDEO=output_video.mp4"
set "OUTPUTAUDIO=output_audio.m4a"
set "OUTPUTMERGED=output.mp4"

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
set /p VIDEO_URL="Enter the video URL: "

REM === Ask for Mode ===
echo.
echo What do you want to download?
echo [1] Video Only
echo [2] Audio Only
echo [3] Video + Audio (Merged by yt-dlp, no ffmpeg)
set /p CHOICE="Choose an option (1/2/3): "

REM === Download ===
if "%CHOICE%"=="1" (
    echo === Downloading Video Only ===
    "%YT_DLP%" -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "%OUTPUTVIDEO%" %VIDEO_URL%
)

if "%CHOICE%"=="2" (
    echo === Downloading Audio Only ===
    "%YT_DLP%" -f "bestaudio" -o "%OUTPUTAUDIO%" %VIDEO_URL%
)

if "%CHOICE%"=="3" (
    echo === Downloading Video + Audio (yt-dlp auto merge) ===
    "%YT_DLP%" -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "%OUTPUTMERGED%" %VIDEO_URL%
)

echo.
echo === DONE! ===
if "%CHOICE%"=="1" echo File saved as: %OUTPUTVIDEO%
if "%CHOICE%"=="2" echo File saved as: %OUTPUTAUDIO%
if "%CHOICE%"=="3" echo File saved as: %OUTPUTMERGED%
pause
