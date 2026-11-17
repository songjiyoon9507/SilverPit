#!/bin/bash
# ============================================================
#  SilverFitterPan 서버 실행 (Linux) - 백그라운드 실행, prod 프로필
#  - 이 스크립트와 같은 폴더에 silver.jar 가 있어야 합니다.
#  - 운영 설정(application-prod.properties)은 jar 안에 들어 있습니다.
#
#  * 앱 로그(진짜 로그)는 logback 설정에 따라 /home/ubuntu/log/silver.log 에 쌓입니다.
#  * 아래 console.out 은 부팅 실패/콘솔 출력 백업용입니다. (silver.log 와 다른 파일)
#  * SSH(모바엑스텀) 창을 닫아도 앱은 계속 돌아갑니다.
# ============================================================
cd "$(dirname "$0")"

JAR="silver.jar"
PROFILE="prod"

# 이미 실행 중이면 중복 실행 방지
if pgrep -f "$JAR" > /dev/null; then
    echo "[안내] 이미 실행 중입니다. (중지: ./stop.sh 또는 kill \$(pgrep -f $JAR))"
    echo "       현재 PID: $(pgrep -f "$JAR" | tr '\n' ' ')"
    exit 1
fi

# 백그라운드 실행 (SSH 창을 닫아도 유지됨)
#  - silver.log 는 logback 이 직접 관리하므로 여기서 건드리지 않습니다.
#  - console.out 에는 부팅 로그/콘솔 출력만 백업합니다.
nohup java -jar "$JAR" --spring.profiles.active="$PROFILE" > console.out 2>&1 &

echo "[실행] 백그라운드로 시작했습니다. PID=$!  (프로필: $PROFILE)"
echo "       앱 로그  : /home/ubuntu/log/silver.log   (tail -f 로 확인)"
echo "       콘솔 백업: console.out                    (부팅 실패 시 확인)"
