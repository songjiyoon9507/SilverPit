#!/bin/bash
# ============================================================
#  SilverFitterPan 서버 종료 (Linux)
# ============================================================
cd "$(dirname "$0")"

JAR="silver.jar"
PIDS=$(pgrep -f "$JAR")

if [ -z "$PIDS" ]; then
    echo "[안내] 실행 중인 프로세스가 없습니다."
    exit 0
fi

echo "[종료] PID: $PIDS 종료 중..."
kill $PIDS

# 최대 10초 대기 후 안 죽으면 강제 종료
for i in $(seq 1 10); do
    if ! pgrep -f "$JAR" > /dev/null; then
        echo "[완료] 정상 종료되었습니다."
        exit 0
    fi
    sleep 1
done

echo "[경고] 정상 종료되지 않아 강제 종료(kill -9)합니다."
kill -9 $(pgrep -f "$JAR")
echo "[완료] 강제 종료되었습니다."
