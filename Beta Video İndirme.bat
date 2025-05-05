@echo off
chcp 65001>nul
setlocal

:: — 0) Self-install / kalıcı kurulum dizini —
set "APPDIR=%LOCALAPPDATA%\VideoDownloader"
set "SELF=%~f0" & set "SELFNAME=%~nx0"
if /I not "%~dp0"=="%APPDIR%\" (
    mkdir "%APPDIR%" 2>nul
    copy "%SELF%" "%APPDIR%\%SELFNAME%" >nul
    start "" "%APPDIR%\%SELFNAME%"
    exit /b
)

:: — 1) yt-dlp.exe (ilk sefer) —
if not exist "%APPDIR%\yt-dlp.exe" (
    echo [1/2] Downloading yt-dlp.exe...
    curl -L -o "%APPDIR%\yt-dlp.exe" ^
      "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
)

:: — 2) ffmpeg.zip indir & tar ile aç (ilk sefer) —
if not exist "%APPDIR%\ffmpeg\ffmpeg-master-latest-win64-gpl-shared\bin\ffmpeg.exe" (
    echo [2/2] Downloading ffmpeg ZIP...
    curl -L -o "%APPDIR%\ffmpeg.zip" ^
      "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip"
    echo Extracting ffmpeg...
    mkdir "%APPDIR%\ffmpeg"
    tar -xf "%APPDIR%\ffmpeg.zip" -C "%APPDIR%\ffmpeg"
    del "%APPDIR%\ffmpeg.zip"
)

:: — 3) ffmpeg.exe’nin bulunduğu klasör —
set "FFMPEG_DIR=%APPDIR%\ffmpeg\ffmpeg-master-latest-win64-gpl-shared\bin"
echo Using ffmpeg at: %FFMPEG_DIR%

:: — 4) Windows İndirilenler’e geç —
set "OUTDIR=%USERPROFILE%\Downloads"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"
cd /D "%OUTDIR%"

:: — 5) URL al & kesin MP4 indir —
<nul set /p ="Paste video URL and press Enter: " & set /P URL=
if "%URL%"=="" (
  echo No URL provided. Exiting...
  pause
  exit /b
)

echo.
echo Downloading MP4 into %OUTDIR%...
"%APPDIR%\yt-dlp.exe" --ffmpeg-location "%FFMPEG_DIR%" ^
  -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best" ^
  --merge-output-format mp4 ^
  -o "%%(title)s.%%(ext)s" "%URL%"

echo.
echo Done! Check your Downloads folder:
echo   %OUTDIR%
pause
exit /b
