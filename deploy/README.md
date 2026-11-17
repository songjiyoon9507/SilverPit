# 실행 / 배포 안내

설정은 **Spring 프로필**로 나뉘어 있고, 모두 jar 안에 포함됩니다. (`src/main/resources`)

| 파일 | 프로필 | 용도 |
|---|---|---|
| `application.properties` | 공통 | 모든 환경 공통 설정 (기본 프로필 = local) |
| `application-local.properties` | `local` | 로컬(Windows) - HTTP 80 |
| `application-prod.properties` | `prod` | 운영(Linux) - HTTPS 443 + 80→443 리다이렉트 |

- 로컬: `run.bat`, VS Code → `--spring.profiles.active=local`
- 운영: `run.sh` → `--spring.profiles.active=prod`
- 설정을 바꾸면 **jar 를 다시 빌드해서 올려야** 반영됩니다.

---

## 1. 로컬(내 PC, Windows) 실행

프로젝트 루트에서 아래 bat 파일을 더블클릭(또는 실행):

- `build.bat` : 실행 jar 만 새로 빌드
- `run.bat`   : local 프로필로 jar 실행 (jar 없으면 자동 빌드)

VS Code 에서는 실행 구성 **`SilverFitterPan (local)`** 로 실행합니다.

---

## 2. 서버(Linux) 배포

1. 내 PC에서 빌드
   ```
   build.bat
   ```
   → `build\libs\silver.jar` 생성

2. 서버의 실행 폴더(예: `/home/ubuntu/app`)에 아래 파일들을 **같은 폴더에** 올림
   - `build/libs/silver.jar`     (위에서 빌드한 jar - 운영 설정 포함)
   - `run.sh`, `stop.sh`         (프로젝트 최상위 폴더의 실행/종료 스크립트)
   - `deploy/certbot-deploy-hook.sh` (SSL 인증서 복사 스크립트, 아래 3번 - 최초 1회)

   ```
   /home/ubuntu/app/
   ├── silver.jar
   ├── run.sh
   └── stop.sh
   ```
   * 설정 파일(properties)은 모두 jar 안에 들어 있으므로 따로 올릴 필요 없음
   * 예전 방식의 `config.properties` 가 서버 폴더에 남아 있다면 삭제하세요. (더 이상 사용 안 함)

3. 서버에서 실행 (SSL 인증서가 먼저 준비돼 있어야 함 → 아래 3번)
   ```
   chmod +x run.sh stop.sh  # 최초 1회만
   ./run.sh                 # prod 프로필로 백그라운드 실행
   ./stop.sh                # 종료
   ```

> 서버에서 미리 준비돼 있어야 하는 것:
> - 로그 폴더:   `/home/ubuntu/log/`
> - SSL 키스토어: `/home/ubuntu/silverfit.p12` (alias `silverpit`, 아래 3번)
> - 방화벽(보안 목록 + `iptables`/`ufw`)에서 **80, 443** 포트 허용
> - **JDK 25** 설치 (아래 참고, jar 가 Java 25 로 빌드되므로 서버도 25 이상 필요)

### 서버 JDK 25 설치 (Ubuntu)
```
sudo apt update
sudo apt install -y openjdk-25-jdk-headless
java -version          # openjdk version "25..." 확인
```
`openjdk-25` 패키지가 없다고 나오면(구버전 Ubuntu) Eclipse Temurin 저장소로 설치:
```
sudo apt install -y wget apt-transport-https gpg
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(. /etc/os-release && echo $VERSION_CODENAME) main" | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update && sudo apt install -y temurin-25-jdk
```
기존 Java 17 이 남아 있으면 `sudo update-alternatives --config java` 로 25 를 선택하세요.
(80/443 포트용 `setcap` 을 썼다면, java 경로가 바뀌므로 25 의 java 에 다시 실행해야 합니다.)

---

## 3. SSL 인증서 (Let's Encrypt / certbot)

운영 설정은 **443(HTTPS)** 으로 뜨고, **80(HTTP)** 요청은 자동으로 HTTPS 로 리다이렉트됩니다.
인증서가 없으면 앱이 시작되지 않으므로 **최초 1회 발급을 먼저** 해야 합니다.

1. certbot 설치
   ```
   sudo apt update && sudo apt install -y certbot
   ```

2. deploy-hook 설치 (발급/갱신 시 인증서를 `/home/ubuntu/silverfit.p12` 로 변환)
   ```
   sudo cp certbot-deploy-hook.sh /etc/letsencrypt/renewal-hooks/deploy/silver.sh
   sudo chmod +x /etc/letsencrypt/renewal-hooks/deploy/silver.sh
   ```
   (`/etc/letsencrypt/renewal-hooks/deploy` 폴더가 없으면 `sudo mkdir -p` 로 먼저 생성)

3. 최초 발급 - certbot 이 80 포트를 직접 써야 하므로 **앱을 잠깐 중지**
   ```
   ./stop.sh
   sudo certbot certonly --standalone -d silverpt.o-r.kr \
     --pre-hook  "/home/ubuntu/app/stop.sh" \
     --post-hook "/home/ubuntu/app/run.sh"
   ```
   - `--pre-hook`/`--post-hook` 은 갱신 설정에 저장되어, 이후 **자동 갱신 때도 앱을 잠깐 내렸다 올립니다.**
   - 경로(`/home/ubuntu/app`)는 실제 실행 폴더에 맞게 바꾸세요.
   - 발급 후 `ls -l /home/ubuntu/silverfit.p12` 로 p12 파일이 생성됐는지 확인
   - 이미 인증서를 발급받은 상태라면 hook 만 한 번 직접 실행해서 p12 를 만들 수 있습니다:
     `sudo /etc/letsencrypt/renewal-hooks/deploy/silver.sh`

4. 자동 갱신 확인 (certbot 이 systemd timer 로 하루 2번 체크, 만료 30일 전 갱신)
   ```
   sudo certbot renew --dry-run
   ```

> 참고: 80/443 은 1024 미만 포트라 일반 사용자로는 열 수 없습니다.
> 지금처럼 `sudo` 로 실행하거나, `ubuntu` 계정으로 돌리려면
> `sudo setcap 'cap_net_bind_service=+ep' $(readlink -f $(which java))` 를 한 번 실행하세요.
> (post-hook 은 root 로 `run.sh` 를 실행하므로, 평소 `ubuntu` 로 실행한다면
>  post-hook 을 `"sudo -u ubuntu /home/ubuntu/app/run.sh"` 로 지정하세요.)
