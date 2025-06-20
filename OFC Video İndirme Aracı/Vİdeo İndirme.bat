@echo off
REM === Gelişmiş Video+Ses İndirici ve FFmpeg Birleştirici ===

REM Kullanıcıdan URL ve tercih sor
set /p URL="Lütfen video URL'sini yapıştır: "
echo.
echo Ne indirmek istiyorsun?
echo [1] Sadece Video
echo [2] Sadece Ses
echo [3] Video + Ses (birleştir)
set /p CHOICE="Seçiminizi girin (1/2/3): "

REM Geçici klasör
set TMPDIR=%~dp0tmp
if not exist %TMPDIR% mkdir %TMPDIR%

REM Çıktı dosya ismi
set FILENAME=output_%RANDOM%

REM İndir ve işlem yap
if "%CHOICE%"=="1" (
    echo === SADECE VIDEO İNDİRİLİYOR ===
    yt-dlp -f "bestvideo[ext=mp4]+bestaudio/best[ext=mp4]/best" -o "%FILENAME%.mp4" %URL%
) else if "%CHOICE%"=="2" (
    echo === SADECE SES İNDİRİLİYOR ===
    yt-dlp -f "bestaudio" -o "%FILENAME%.m4a" %URL%
) else if "%CHOICE%"=="3" (
    echo === VIDEO + SES İNDİRİLİYOR ve BİRLEŞTİRİLİYOR ===
    yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]" -o "%TMPDIR%\video.%%(ext)s" %URL%
    yt-dlp -f "bestaudio[ext=m4a]" -o "%TMPDIR%\audio.%%(ext)s" %URL%
    echo === FFmpeg Birleştirme Başlıyor ===
    ffmpeg -i "%TMPDIR%\video.mp4" -i "%TMPDIR%\audio.m4a" -c copy "%FILENAME%.mp4"
    echo === Geçici dosyalar siliniyor ===
    del "%TMPDIR%\video.mp4"
    del "%TMPDIR%\audio.m4a"
)

echo.
echo === İŞLEM TAMAMLANDI! Çıktı dosyası: %FILENAME% ===
pause
