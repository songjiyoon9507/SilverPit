@echo off
REM ============================================================
REM  SilverFitterPan 빌드 (Windows)
REM  - build\libs\silver.jar 를 생성
REM  - 서버 배포 시 이 jar 를 서버로 올리면 됩니다.
REM ============================================================
setlocal
chcp 65001 >nul
cd /d "%~dp0"

echo [빌드] gradlew clean bootJar 실행...
call "%~dp0gradlew.bat" clean bootJar
if errorlevel 1 (
    echo [오류] 빌드에 실패했습니다.
    pause
    exit /b 1
)

echo [완료] build\libs 폴더에 실행 jar 가 생성되었습니다.
pause
endlocal
