@echo off
REM ============================================================
REM  SilverFitterPan 로컬 실행 (Windows) - local 프로필
REM  - 로컬 설정(application-local.properties)으로 실행 (HTTP 80)
REM ============================================================
setlocal
chcp 65001 >nul
cd /d "%~dp0"

set "JAR=build\libs\silver.jar"

REM 실행할 jar 가 없으면 먼저 빌드
if not exist "%JAR%" (
    echo [빌드] 실행할 jar 가 없어 새로 빌드합니다...
    call "%~dp0gradlew.bat" clean bootJar
    if errorlevel 1 (
        echo [오류] 빌드에 실패했습니다.
        pause
        exit /b 1
    )
)

echo [실행] %JAR% (프로필: local)
java -jar "%JAR%" --spring.profiles.active=local

echo.
echo [종료] 애플리케이션이 종료되었습니다.
pause
endlocal
