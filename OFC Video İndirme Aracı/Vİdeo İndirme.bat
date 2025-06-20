@echo off
REM === FINAL AUTO yt-dlp + ffmpeg WITHOUT ZIP EXTRACT ===

setlocal enabledelayedexpansion

REM === FILE NAMES ===
set "YT_DLP=yt-dlp.exe"
set "FFMPEG=ffmpeg.exe"
set "VIDEOFILE=video_temp.mp4"
set "AUDIOFILE=audio_temp.m4a"
set "OUTPUTVIDEO=output_video.mp4"
set "OUTPUTAUDIO=output_audio.m4a"
set "OUTPUTMERGED=output.mp4"
set "TMPDIR=%~dp0tmp"

REM === CHECK yt-dlp ===
if not exist "%~dp0%YT_DLP%" (
    echo yt-dlp.exe not found. Downloading latest version...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe' -OutFile '%YT_DLP%'"
    if not exist "%~dp0%YT_DLP%" (
        echo ERROR: yt-dlp.exe failed to download. Exiting.
        pause
        exit /b
    )
)

REM === CHECK ffmpeg ===
if not exist "%~dp0%FFMPEG%" (
    echo ffmpeg.exe not found. Downloading lightweight static version...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip' -OutFile 'ffmpeg.zip'"
    powershell -Command "Expand-Archive -Force 'ffmpeg.zip' 'ffmpeg_temp'"
    if exist "ffmpeg_temp" (
        for /r "%~dp0ffmpeg_temp" %%i in (ffmpeg.exe) do (
            copy "%%i" "%~dp0%FFMPEG%"
            goto :found_ffmpeg
        )
        :found_ffmpeg
        rmdir /s /q ffmpeg_temp
        del ffmpeg.zip
    ) else (
        echo ERROR: Could not extract ffmpeg.zip.
        echo Please download ffmpeg.exe manually and place it in this folder.
        pause
        exit /b
    )
)

REM === ASK FOR URL ===
set /p VIDEO_URL="Enter the video URL: "

REM === ASK FOR MODE ===
echo.
echo What do you want to download?
echo [1] Video Only
echo [2] Audio Only
echo [3] Video + Audio (Merge)
set /p CHOICE="Choose an option (1/2/3): "

REM === CREATE TEMP ===
if not exist "%TMPDIR%" mkdir "%TMPDIR%"

REM === DOWNLOAD & PROCESS ===
if "%CHOICE%"=="1" (
    echo === Downloading Video Only ===
    "%YT_DLP%" -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" --merge-output-format mp4 -o "%OUTPUTVIDEO%" %VIDEO_URL%
)

if "%CHOICE%"=="2" (
    echo === Downloading Audio Only ===
    "%YT_DLP%" -f "bestaudio[ext=m4a]" -o "%OUTPUTAUDIO%" %VIDEO_URL%
)

if "%CHOICE%"=="3" (
    echo === Downloading Video Stream ===
    "%YT_DLP%" -f "bestvideo[ext=mp4]" -o "%TMPDIR%\%VIDEOFILE%" %VIDEO_URL%

    echo === Downloading Audio Stream ===
    "%YT_DLP%" -f "bestaudio[ext=m4a]" -o "%TMPDIR%\%AUDIOFILE%" %VIDEO_URL%

    echo === Merging with ffmpeg ===
    "%FFMPEG%" -y -i "%TMPDIR%\%VIDEOFILE%" -i "%TMPDIR%\%AUDIOFILE%" -c copy "%OUTPUTMERGED%"

    echo === Cleaning temp files ===
    del "%TMPDIR%\%VIDEOFILE%"
    del "%TMPDIR%\%AUDIOFILE%"
)

echo.
echo === DONE! ===
if "%CHOICE%"=="1" echo File saved as: %OUTPUTVIDEO%
if "%CHOICE%"=="2" echo File saved as: %OUTPUTAUDIO%
if "%CHOICE%"=="3" echo File saved as: %OUTPUTMERGED%
pause
