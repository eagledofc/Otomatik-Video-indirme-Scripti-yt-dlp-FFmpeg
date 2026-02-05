 @echo off
 chcp 65001 >nul
 setlocal enabledelayedexpansion
 
 set "APPDIR=%LOCALAPPDATA%\VideoDownloader"
 set "YT_DLP_EXE=%APPDIR%\yt-dlp.exe"
 set "FFMPEG_DIR=%APPDIR%\ffmpeg\ffmpeg-master-latest-win64-gpl-shared\bin"
-set "FFMPEG_EXE=%FFMPEG_DIR%\ffmpeg.exe"
-set "OUTDIR=%USERPROFILE%\Downloads"
-set "YTDLP_URL=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
-set "FFMPEG_ZIP_URL=https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl-shared.zip"
+set "FFMPEG_EXE=%FFMPEG_DIR%\ffmpeg.exe"
+set "OUTDIR=%USERPROFILE%\Downloads"
+set "YTDLP_URL=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
+set "FFMPEG_ZIP_URL=https://github.com/BtbN/FFmpeg-Builds/releases/latest/download/ffmpeg-master-latest-win64-gpl-shared.zip"
+set "ARIA2_URL=https://github.com/aria2/aria2/releases/latest/download/aria2-1.37.0-win-64bit-build1.zip"
+set "ARIA2_DIR=%APPDIR%\aria2"
+set "ARIA2_EXE=%ARIA2_DIR%\aria2c.exe"
 
-if not exist "%APPDIR%" mkdir "%APPDIR%"
-cd /d "%APPDIR%"
-
-:: yt-dlp kontrol/güncelle
-if exist "%YT_DLP_EXE%" (
-    "%YT_DLP_EXE%" -U >nul
-) else (
-    curl -L -o yt-dlp.exe "%YTDLP_URL%"
+if not exist "%APPDIR%" mkdir "%APPDIR%"
+cd /d "%APPDIR%"
+
+where curl >nul 2>&1 || (
+    echo HATA: curl bulunamadi. Windows 10/11 guncel surum gerekiyor.
+    pause
+    exit /b
+)
+where tar >nul 2>&1 || (
+    echo HATA: tar bulunamadi. Windows 10/11 guncel surum gerekiyor.
+    pause
+    exit /b
+)
+
+:: yt-dlp kontrol/güncelle
+if exist "%YT_DLP_EXE%" (
+    "%YT_DLP_EXE%" -U >nul
+) else (
+    curl -L -o yt-dlp.exe "%YTDLP_URL%"
 )
 
 :: ffmpeg kontrol/güncelle
-if not exist "%FFMPEG_EXE%" (
-    curl -L -o ffmpeg.zip "%FFMPEG_ZIP_URL%"
-    mkdir ffmpeg
-    tar -xf ffmpeg.zip -C ffmpeg
-    del ffmpeg.zip
-)
-
-echo.
-<nul set /p="Video URL'sini yapıştır: "
-set /P URL=
-if "%URL%"=="" (
+if not exist "%FFMPEG_EXE%" (
+    curl -L -o ffmpeg.zip "%FFMPEG_ZIP_URL%"
+    mkdir ffmpeg
+    tar -xf ffmpeg.zip -C ffmpeg
+    del ffmpeg.zip
+)
+
+:: aria2c kontrol/güncelle
+if not exist "%ARIA2_EXE%" (
+    curl -L -o aria2.zip "%ARIA2_URL%"
+    mkdir "%ARIA2_DIR%"
+    tar -xf aria2.zip -C "%ARIA2_DIR%"
+    del aria2.zip
+    for /d %%D in ("%ARIA2_DIR%\aria2-*") do (
+        if exist "%%D\aria2c.exe" (
+            move /Y "%%D\aria2c.exe" "%ARIA2_DIR%\aria2c.exe" >nul
+            rmdir /S /Q "%%D"
+        )
+    )
+)
+
+echo.
+<nul set /p="Video URL'sini yapıştır: "
+set /P URL=
+if "%URL%"=="" (
     echo URL girilmedi. Çıkılıyor...
     pause
     exit /b
 )
 
-:: Tarih damgası ekle (YılAyGün-SaatDakika)
-for /f "tokens=2 delims==." %%I in ('"wmic os get localdatetime /value"') do set ldt=%%I
-set "TIMESTAMP=%ldt:~0,4%-%ldt:~4,2%-%ldt:~6,2%_%ldt:~8,2%-%ldt:~10,2%"
+:: Tarih damgası ekle (YılAyGün-SaatDakika)
+for /f %%I in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd_HH-mm"') do set "TIMESTAMP=%%I"
+
+echo.
+echo Indirme modu sec:
+echo 1^) En hizli + en iyi kalite (onerilen)
+echo 2^) 1080p (eger mevcutsa)
+echo 3^) 720p (eger mevcutsa)
+echo 4^) Sadece ses (mp3)
+<nul set /p="Secim (1-4): "
+set /P MODE=
+if "%MODE%"=="" set "MODE=1"
+
+set "FORMAT=bv*+ba/bestvideo+bestaudio/best"
+set "OUTPUT_TEMPLATE=%%(title)s_%TIMESTAMP%.mp4"
+set "EXTRA_ARGS="
+set "COOKIE_ARGS="
+set "JS_RUNTIME_ARGS="
+if "%MODE%"=="2" (
+    set "FORMAT=bv*[height<=1080]+ba/best[height<=1080]/best"
+) else if "%MODE%"=="3" (
+    set "FORMAT=bv*[height<=720]+ba/best[height<=720]/best"
+) else if "%MODE%"=="4" (
+    set "FORMAT=ba/best"
+    set "OUTPUT_TEMPLATE=%%(title)s_%TIMESTAMP%.mp3"
+    set "EXTRA_ARGS=--extract-audio --audio-format mp3 --audio-quality 0"
+)
+
+echo.
+echo Cookie modu sec (YouTube bazen giris ister):
+echo 1^) Yok (onerilen degil - bazi videolarda hata verebilir)
+echo 2^) Chrome'dan cookies al (onerilen)
+echo 3^) Edge'den cookies al
+<nul set /p="Secim (1-3): "
+set /P COOKIE_MODE=
+if "%COOKIE_MODE%"=="" set "COOKIE_MODE=2"
+
+if "%COOKIE_MODE%"=="2" (
+    set "COOKIE_ARGS=--cookies-from-browser chrome"
+) else if "%COOKIE_MODE%"=="3" (
+    set "COOKIE_ARGS=--cookies-from-browser edge"
+)
+
+where node >nul 2>&1 && set "JS_RUNTIME_ARGS=--js-runtimes nodejs,deno"
 
 cd /D "%OUTDIR%"
 
-echo.
-echo En iyi kalite + en hızlı mod başlıyor...
-
-"%YT_DLP_EXE%" ^
- --no-mtime ^
- --ffmpeg-location "%FFMPEG_DIR%" ^
- -f "bv*+ba/bestvideo+bestaudio/best" ^
- --merge-output-format mp4 ^
- --concurrent-fragments 10 ^
- --postprocessor-args "ffmpeg:-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 160k -movflags +faststart" ^
- -o "%%(title)s_%TIMESTAMP%.mp4" ^
- "%URL%"
+echo.
+echo Indirme basliyor... (Desteklenen siteler: yt-dlp destekli bircok video sitesi)
+
+"%YT_DLP_EXE%" ^
+ --no-mtime ^
+ --ffmpeg-location "%FFMPEG_DIR%" ^
+ --restrict-filenames ^
+ --downloader aria2c ^
+ --downloader-args "aria2c:-x16 -s16 -k1M" ^
+ -f "%FORMAT%" ^
+ --merge-output-format mp4 ^
+ --concurrent-fragments 10 ^
+ --postprocessor-args "ffmpeg:-c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 160k -movflags +faststart" ^
+ %COOKIE_ARGS% ^
+ %JS_RUNTIME_ARGS% ^
+ %EXTRA_ARGS% ^
+ -o "%OUTPUT_TEMPLATE%" ^
+ "%URL%"
 
 if errorlevel 1 (
     echo.
     echo HATA: İndirme veya dönüştürme işlemi başarısız oldu.
     echo Format listesi görmek için: yt-dlp -F "%URL%"
 )
 
 echo.
 echo İNDİRME TAMAMLANDI - Dosya konumu: %OUTDIR%
 pause
 exit /b
 
EOF
)
