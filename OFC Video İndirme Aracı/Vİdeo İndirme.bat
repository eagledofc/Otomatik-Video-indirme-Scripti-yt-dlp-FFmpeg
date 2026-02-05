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
set "ARIA2_URL=https://github.com/aria2/aria2/releases/latest/download/aria2-1.37.0-win-64bit-build1.zip"
set "ARIA2_DIR=%APPDIR%\aria2"
set "ARIA2_EXE=%ARIA2_DIR%\aria2c.exe"
set "POWERSHELL_EXE=powershell"

if not exist "%APPDIR%" mkdir "%APPDIR%"
cd /d "%APPDIR%"

where curl >nul 2>&1 || (
    echo HATA: curl bulunamadi. Windows 10/11 guncel surum gerekiyor.
    pause
    exit /b
)
where "%POWERSHELL_EXE%" >nul 2>&1 || (
    echo HATA: PowerShell bulunamadi. Windows 10/11 guncel surum gerekiyor.
    pause
    exit /b
)

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
    "%POWERSHELL_EXE%" -NoProfile -Command "Expand-Archive -LiteralPath '%APPDIR%\\ffmpeg.zip' -DestinationPath '%APPDIR%\\ffmpeg' -Force"
    del ffmpeg.zip
)

:: aria2c kontrol/güncelle
if not exist "%ARIA2_EXE%" (
    curl -L -o aria2.zip "%ARIA2_URL%"
    mkdir "%ARIA2_DIR%"
    "%POWERSHELL_EXE%" -NoProfile -Command "Expand-Archive -LiteralPath '%APPDIR%\\aria2.zip' -DestinationPath '%APPDIR%\\aria2' -Force"
    del aria2.zip
    for /d %%D in ("%ARIA2_DIR%\aria2-*") do (
        if exist "%%D\aria2c.exe" (
            move /Y "%%D\aria2c.exe" "%ARIA2_DIR%\aria2c.exe" >nul
            rmdir /S /Q "%%D"
        )
    )
)

echo.
<nul set /p="YouTube URL'sini yapıştır: "
set /P URL=
if "%URL%"=="" (
    echo URL girilmedi. Çıkılıyor...
    pause
    exit /b
)

:: Tarih damgası ekle (YılAyGün-SaatDakika)
for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm"') do set "TIMESTAMP=%%I"

set "FORMAT=bv*+ba/bestvideo+bestaudio/best"
set "OUTPUT_TEMPLATE=%%(title)s_%TIMESTAMP%.mp4"
set "EXTRA_ARGS="
set "JS_RUNTIME_ARGS="

where node >nul 2>&1 && set "JS_RUNTIME_ARGS=--js-runtimes nodejs,deno"

cd /D "%OUTDIR%"

echo.
echo Indirme basliyor... (Otomatik en iyi kalite + hizli mod)

set "BASE_ARGS=--no-mtime --ffmpeg-location ""%FFMPEG_DIR%"" --restrict-filenames --downloader aria2c --downloader-args ""aria2c:-x16 -s16 -k1M"" -f ""%FORMAT%"" --merge-output-format mp4 --concurrent-fragments 10 --retries 10 --fragment-retries 10 --retry-sleep 5 --socket-timeout 30 --postprocessor-args ""ffmpeg:-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 160k -movflags +faststart"" -o ""%OUTPUT_TEMPLATE%"""

call "%YT_DLP_EXE%" !BASE_ARGS! --cookies-from-browser chrome !JS_RUNTIME_ARGS! !EXTRA_ARGS! "%URL%"

if errorlevel 1 (
    echo.
    echo Chrome cookies ile basarisiz oldu. Edge ile tekrar denenecek...
    call "%YT_DLP_EXE%" !BASE_ARGS! --cookies-from-browser edge !JS_RUNTIME_ARGS! !EXTRA_ARGS! "%URL%"
)

if errorlevel 1 (
    echo.
    echo HATA: Indirme basarisiz oldu. YouTube bot kontrolu nedeniyle cookies gerekebilir.
    echo Manuel cookies icin: yt-dlp --cookies "C:\path\cookies.txt" "%URL%"
    echo Format listesi görmek için: yt-dlp -F "%URL%"
)

echo.
echo İNDİRME TAMAMLANDI - Dosya konumu: %OUTDIR%
pause
exit /b
