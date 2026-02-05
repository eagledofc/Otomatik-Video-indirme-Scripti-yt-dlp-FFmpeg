@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: KLASÖR AYARLARI
set "APPDIR=%LOCALAPPDATA%\VideoDownloader"
set "YT_DLP_EXE=%APPDIR%\yt-dlp.exe"
set "FFMPEG_BIN=%APPDIR%\ffmpeg\bin"
set "OUTDIR=%USERPROFILE%\Downloads"

if not exist "%APPDIR%" mkdir "%APPDIR%"
cd /d "%APPDIR%"

:: BAĞIMLILIK KONTROLLERİ
echo Sistem kontrol ediliyor, lutfen bekleyin...

if not exist "%YT_DLP_EXE%" (
    echo yt-dlp indiriliyor...
    curl -L -o yt-dlp.exe "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
)

if not exist "%FFMPEG_BIN%\ffmpeg.exe" (
    echo ffmpeg indiriliyor... (Bu biraz zaman alabilir)
    curl -L -o ffmpeg.zip "https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl-shared.zip"
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath 'temp_ff' -Force"
    mkdir "%APPDIR%\ffmpeg" 2>nul
    for /d %%i in (temp_ff\*) do xcopy "%%i\*" "%APPDIR%\ffmpeg\" /E /Y /H
    rmdir /s /q temp_ff
    del ffmpeg.zip
)

:INPUT_URL
cls
echo ======================================================
echo          YOUTUBE VIDEO INDIRICI (SÜPER HIZLI)
echo ======================================================
echo.
set "URL="
set /P "URL=Video URL'sini buraya yapistir: "

if "%URL%"=="" (
    echo.
    echo HATA: Bir URL girmediniz!
    timeout /t 3
    goto INPUT_URL
)

:: Tarih Damgası (Hata vermemesi için en basit hali)
set "TS=%DATE:~10,4%-%DATE:~4,2%-%DATE:~7,2%_%TIME:~0,2%-%TIME:~3,2%"
set "TS=%TS: =0%"

cd /D "%OUTDIR%"

echo.
echo [!] Indirme basliyor... (Re-encode yapilmadan, en hizli mod)

:: ASIL INDIRME KOMUTU
"%YT_DLP_EXE%" ^
 --no-mtime ^
 --ffmpeg-location "%FFMPEG_BIN%" ^
 -f "bv*+ba/best" ^
 --merge-output-format mp4 ^
 --concurrent-fragments 5 ^
 -o "%%(title)s_%TS%.mp4" ^
 "%URL%"

:: EGER BOT HATASI VERIRSE (OTOMATIK CÖZÜM DENEMESI)
if errorlevel 1 (
    echo.
    echo [!] Bot korumasi algilandi! Cerezlerle tekrar deneniyor...
    "%YT_DLP_EXE%" --no-mtime --ffmpeg-location "%FFMPEG_BIN%" --cookies-from-browser chrome -f "bv*+ba/best" --merge-output-format mp4 -o "%%(title)s_%TS%_FIXED.mp4" "%URL%"
)

if errorlevel 1 (
    echo.
    echo [!] Hala hata aliniyor. Lutfen tarayicinizi (Chrome/Edge) kapatin ve tekrar deneyin.
) else (
    echo.
    echo [+] Basariyla indirildi! Dosya: %OUTDIR%
)

echo.
echo Yeni bir video indirmek icin bir tusa basin...
pause >nul
goto INPUT_URL
