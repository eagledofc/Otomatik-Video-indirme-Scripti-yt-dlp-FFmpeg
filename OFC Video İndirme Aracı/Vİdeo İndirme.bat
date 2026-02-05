@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ==========================================
:: AYARLAR VE YOL TANIMLAMALARI
:: ==========================================
set "APPDIR=%LOCALAPPDATA%\VideoDownloader"
set "YT_DLP_EXE=%APPDIR%\yt-dlp.exe"
set "FFMPEG_ROOT=%APPDIR%\ffmpeg"
set "FFMPEG_BIN=%FFMPEG_ROOT%\bin"
set "FFMPEG_EXE=%FFMPEG_BIN%\ffmpeg.exe"
set "OUTDIR=%USERPROFILE%\Downloads"

:: İndirme Linkleri
set "YTDLP_URL=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
set "FFMPEG_ZIP_URL=https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl-shared.zip"

:: Klasör kontrolü
if not exist "%APPDIR%" mkdir "%APPDIR%"
cd /d "%APPDIR%"

:: ==========================================
:: BAĞIMLILIK KONTROLLERİ (OTOMATİK KURULUM)
:: ==========================================
echo Sistem kontrol ediliyor...

:: 1. yt-dlp Kontrol/Güncelleme
if exist "%YT_DLP_EXE%" (
    "%YT_DLP_EXE%" -U >nul 2>&1
) else (
    echo yt-dlp indiriliyor...
    curl -L -o yt-dlp.exe "%YTDLP_URL%"
)

:: 2. ffmpeg Kontrol/Kurulum
if not exist "%FFMPEG_EXE%" (
    echo ffmpeg indiriliyor ve kuruluyor (bu bir kez yapilir)...
    if exist ffmpeg.zip del ffmpeg.zip
    if exist "%FFMPEG_ROOT%" rmdir /s /q "%FFMPEG_ROOT%"
    
    curl -L -o ffmpeg.zip "%FFMPEG_ZIP_URL%"
    
    :: Zip içeriğini geçici klasöre çıkar
    mkdir temp_ffmpeg
    tar -xf ffmpeg.zip -C temp_ffmpeg
    
    :: İçindeki asıl klasörü bul ve adını değiştirip taşı
    for /d %%I in ("temp_ffmpeg\*") do (
        move "%%I" "%FFMPEG_ROOT%"
    )
    rmdir /s /q temp_ffmpeg
    del ffmpeg.zip
)

:: ==========================================
:: KULLANICI GİRİŞİ VE İNDİRME
:: ==========================================
:INPUT_URL
cls
echo ========================================================
echo   SUPER HIZLI VIDEO INDIRICI (Optimize Edilmis Surum)
echo   Dosyalar suraya inecek: %OUTDIR%
echo ========================================================
echo.
set /P "URL=Video URL'sini yapistir: "

if "%URL%"=="" goto INPUT_URL

:: Windows 11 Uyumlu Tarih Damgası (WMIC yerine PowerShell)
for /f "usebackq tokens=1-5 delims=-: " %%a in (`powershell -Command "Get-Date -Format 'yyyy-MM-dd_HH-mm' "`) do set "TIMESTAMP=%%a"

cd /D "%OUTDIR%"

echo.
echo [1/2] Baglanti analiz ediliyor...

:: Normal İndirme Denemesi (Süper Hızlı Mod - Re-encode YOK)
"%YT_DLP_EXE%" ^
 --no-mtime ^
 --ffmpeg-location "%FFMPEG_BIN%" ^
 -f "bv*+ba/best" ^
 --merge-output-format mp4 ^
 --concurrent-fragments 4 ^
 --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36" ^
 -o "%%(title)s_%%(id)s_%TIMESTAMP%.mp4" ^
 "%URL%"

:: Eğer hata verirse (Bot Koruması / Sign-in required)
if errorlevel 1 (
    echo.
    echo [!] HATA: YouTube bot korumasina takildi.
    echo [!] Merak etme, tarayici cerezleri deneniyor...
    goto BROWSER_FIX
) else (
    goto SUCCESS
)

:BROWSER_FIX
echo.
echo Lutfen kullandigin tarayiciyi sec (Arkadasin icin onemli):
echo [1] Google Chrome
echo [2] Microsoft Edge
echo [3] Firefox
echo [4] Opera / Opera GX
echo.
set /p "BROWSER_CHOICE=Secimin (1-4): "

set "BROWSER_ARG="
if "%BROWSER_CHOICE%"=="1" set "BROWSER_ARG=chrome"
if "%BROWSER_CHOICE%"=="2" set "BROWSER_ARG=edge"
if "%BROWSER_CHOICE%"=="3" set "BROWSER_ARG=firefox"
if "%BROWSER_CHOICE%"=="4" set "BROWSER_ARG=opera"

if "%BROWSER_ARG%"=="" (
    echo Gecersiz secim. Tekrar deneyin.
    goto BROWSER_FIX
)

echo.
echo [%BROWSER_ARG%] cerezleri kullanilarak tekrar deneniyor...
"%YT_DLP_EXE%" ^
 --no-mtime ^
 --ffmpeg-location "%FFMPEG_BIN%" ^
 --cookies-from-browser %BROWSER_ARG% ^
 -f "bv*+ba/best" ^
 --merge-output-format mp4 ^
 -o "%%(title)s_%%(id)s_%TIMESTAMP%.mp4" ^
 "%URL%"

if errorlevel 1 (
    echo.
    echo MAALESEF: Tarayicidan cerez alinirken de hata olustu.
    echo Tarayicinin kapali oldugundan veya o tarayicida YouTube'a giris yapildigindan emin ol.
    pause
    goto INPUT_URL
)

:SUCCESS
echo.
echo ==========================================
echo ISLEM TAMAMLANDI! 
echo Dosya: %OUTDIR% klasorunde.
echo ==========================================
pause
goto INPUT_URL
