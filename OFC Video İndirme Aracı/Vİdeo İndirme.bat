@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "APPDIR=%LOCALAPPDATA%\VideoDownloader"
set "YT_DLP_EXE=%APPDIR%\yt-dlp.exe"
set "FFMPEG_DIR=%APPDIR%\ffmpeg\ffmpeg-master-latest-win64-gpl-shared\bin"
set "FFMPEG_EXE=%FFMPEG_DIR%\ffmpeg.exe"
set "OUTDIR=%USERPROFILE%\Downloads"
set "YTDLP_URL=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
set "FFMPEG_ZIP_URL=https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl-shared.zip"

if not exist "%APPDIR%" mkdir "%APPDIR%"
cd /d "%APPDIR%"

:: yt-dlp kontrol/güncelle
if exist "%YT_DLP_EXE%" (
    "%YT_DLP_EXE%" -U >nul
) else (
    curl -L -o yt-dlp.exe "%YTDLP_URL%"
)

:: ffmpeg kontrol/güncelle
if not exist "%FFMPEG_EXE%" (
    curl -L -o ffmpeg.zip "%FFMPEG_ZIP_URL%"
    mkdir ffmpeg
    tar -xf ffmpeg.zip -C ffmpeg
    del ffmpeg.zip
)

echo.
<nul set /p="Video URL'sini yapıştır: "
set /P URL=
if "%URL%"=="" (
    echo URL girilmedi. Çıkılıyor...
    pause
    exit /b
)

cd /D "%OUTDIR%"

:: Video + ses indir, Windows uyumlu MP4 oluştur (MP3 sesli)
"%YT_DLP_EXE%" ^
 --ffmpeg-location "%FFMPEG_DIR%" ^
 -f "bv*+ba/bestvideo+bestaudio/best" ^
 --merge-output-format mp4 ^
 --postprocessor-args "ffmpeg:-c:v libx264 -preset fast -crf 23 -c:a libmp3lame -b:a 192k" ^
 -o "%%(title)s.mp4" ^
 "%URL%"

if errorlevel 1 (
    echo.
    echo HATA: İndirme veya dönüştürme işlemi başarısız oldu.
    echo Format listesi görmek için: yt-dlp -F "%URL%"
)

echo.
echo İNDİRME TAMAMLANDI - Dosya konumu: %OUTDIR%
pause
exit /b
