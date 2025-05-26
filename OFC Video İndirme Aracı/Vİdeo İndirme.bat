@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: === 0) Kalıcı klasör ===
set "APPDIR=%LOCALAPPDATA%\VideoDownloader"
set "SELF=%~f0"
set "SELFNAME=%~nx0"

if /I not "%~dp0"=="%APPDIR%\" (
    mkdir "%APPDIR%" 2>nul
    copy "%SELF%" "%APPDIR%\%SELFNAME%" >nul
    start "" "%APPDIR%\%SELFNAME%"
    exit /b
)

:: === 1) yt-dlp indir ===
if not exist "%APPDIR%\yt-dlp.exe" (
    echo [1/3] yt-dlp indiriliyor...
    curl -L -o "%APPDIR%\yt-dlp.exe" ^
      "https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
)

:: === 2) ffmpeg indir ve çıkar ===
set "FFMPEG_DIR=%APPDIR%\ffmpeg\ffmpeg-master-latest-win64-gpl-shared\bin"
if not exist "%FFMPEG_DIR%\ffmpeg.exe" (
    echo [2/3] ffmpeg indiriliyor...
    curl -L -o "%APPDIR%\ffmpeg.zip" ^
      "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-master-latest-win64-gpl-shared.zip"
    mkdir "%APPDIR%\ffmpeg"
    tar -xf "%APPDIR%\ffmpeg.zip" -C "%APPDIR%\ffmpeg"
    del "%APPDIR%\ffmpeg.zip"
)

:: === 3) Güncelleme seçeneği sun ===
echo.
<nul set /p=yt-dlp güncellensin mi? (E/H): 
set /P CHOICE=
if /I "!CHOICE!"=="E" (
    "%APPDIR%\yt-dlp.exe" -U
)

:: === 4) URL al ===
echo.
<nul set /p="İndirmek istediğiniz video URL'sini yapıştırın: "
set /P URL=
if "%URL%"=="" (
    echo URL girilmedi. Çıkılıyor...
    pause
    exit /b
)

:: === 5) Format seçimi ===
echo.
echo [1] Video (MP4)
echo [2] Sadece Ses (MP3)
<nul set /p="Seçiminizi girin (1/2): "
set /P FORMAT_CHOICE=

if "%FORMAT_CHOICE%"=="2" (
    set "FORMAT_OPTS=-f bestaudio --extract-audio --audio-format mp3 --audio-quality 0"
) else (
    set "FORMAT_OPTS=-f bestvideo[ext=mp4]+bestaudio[ext=m4a]/best --merge-output-format mp4"
)

:: === 6) İndirme ===
echo.
echo [3/3] İndirme işlemi başlatılıyor...
set "OUTDIR=%USERPROFILE%\Downloads"
cd /D "%OUTDIR%"

"%APPDIR%\yt-dlp.exe" --ffmpeg-location "%FFMPEG_DIR%" %FORMAT_OPTS% ^
  -o "%%(title)s.%%(ext)s" "%URL%" || (
    echo.
    echo ⚠ İndirme sırasında bir hata oluştu.
    echo Hata detaylarını kontrol edin veya --list-formats komutunu deneyin.
)

echo.
echo ✔ İndirme tamamlandı. Dosyalar: %OUTDIR%
pause
exit /b
