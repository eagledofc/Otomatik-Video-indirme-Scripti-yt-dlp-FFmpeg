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

:: Klasör varsa geç, yoksa oluştur
if not exist "%APPDIR%" mkdir "%APPDIR%"
cd /d "%APPDIR%"

:: yt-dlp yoksa indir
if not exist "%YT_DLP_EXE%" (
    echo yt-dlp indiriliyor...
    curl -L -o yt-dlp.exe "%YTDLP_URL%"
) else (
    echo yt-dlp güncellemeleri kontrol ediliyor...
    "%YT_DLP_EXE%" -U >nul
)

:: ffmpeg yoksa indir
if not exist "%FFMPEG_EXE%" (
    echo ffmpeg indiriliyor...
    curl -L -o ffmpeg.zip "%FFMPEG_ZIP_URL%"
    mkdir ffmpeg
    tar -xf ffmpeg.zip -C ffmpeg
    del ffmpeg.zip
)

:: URL al
echo.
<nul set /p="Video URL'sini yapıştır: "
set /P URL=
if "%URL%"=="" (
    echo URL girilmedi. Çıkılıyor...
    pause
    exit /b
)

cd /D "%OUTDIR%"

:: Video + ses indir ve mp4 olarak birleştir
"%YT_DLP_EXE%" ^
 --ffmpeg-location "%FFMPEG_DIR%" ^
 -f "bv*+ba/bestvideo+bestaudio/best" ^
 --merge-output-format mp4 ^
 -o "%%(title)s.%%(ext)s" ^
 "%URL%"

if errorlevel 1 (
    echo.
    echo İndirme başarısız oldu. Format uyumsuzluğu olabilir.
    echo Formatları görmek için şu komutu çalıştırabilirsiniz:
    echo yt-dlp -F "%URL%"
)

pause
exit /b
