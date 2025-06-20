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

:: Tarih damgası ekle (YılAyGün-SaatDakika)
for /f "tokens=2 delims==." %%I in ('"wmic os get localdatetime /value"') do set ldt=%%I
set "TIMESTAMP=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2%_%ldt:~8,2%-%ldt:~10,2%"

cd /D "%OUTDIR%"

echo.
echo En iyi kalite + en hızlı mod başlıyor...

"%YT_DLP_EXE%" ^
 --ffmpeg-location "%FFMPEG_DIR%" ^
 -f "bv*+ba/bestvideo+bestaudio/best" ^
 --merge-output-format mp4 ^
 --concurrent-fragments 10 ^
 --postprocessor-args "ffmpeg:-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 160k -movflags +faststart" ^
 -o "%%(title)s_%TIMESTAMP%.mp4" ^
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
