@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "APPDIR=%LOCALAPPDATA%\VideoDownloader"
set "YT_DLP_EXE=%APPDIR%\yt-dlp.exe"
set "FFMPEG_DIR=%APPDIR%\ffmpeg\bin"
set "FFMPEG_EXE=%FFMPEG_DIR%\ffmpeg.exe"
set "OUTDIR=%USERPROFILE%\Downloads"
set "YTDLP_URL=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
set "FFMPEG_ZIP_URL=https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

if not exist "%APPDIR%" mkdir "%APPDIR%"
cd /d "%APPDIR%"

:: yt-dlp kontrol/güncelle
if exist "%YT_DLP_EXE%" (
    "%YT_DLP_EXE%" -U >nul
) else (
    curl -L -o yt-dlp.exe "%YTDLP_URL%"
)

:: ffmpeg kontrol/güncelle (daha küçük ve hızlı paket)
if not exist "%FFMPEG_EXE%" (
    curl -L -o ffmpeg.zip "%FFMPEG_ZIP_URL%"
    tar -xf ffmpeg.zip
    for /d %%i in (ffmpeg-*) do set "FFMPEG_DIR=%APPDIR%\%%i\bin"
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

:: Video + ses indir, hızlı birleştir, kopyalama tercih et (re-encode yok!)
"%YT_DLP_EXE%" ^
 --ffmpeg-location "%FFMPEG_DIR%" ^
 -f "bv*+ba/bestvideo+bestaudio/best" ^
 --merge-output-format mp4 ^
 --remux-video mp4 ^
 --compat-options no-youtube-unavailable-videos ^
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
