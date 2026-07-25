# 🏔️ 스타공인중개사 토지 중개 플랫폼 (StarRealtor-Land)

> **대한민국 전 지역 토지 매물 수집, 360° 파노라마 VR 가상투어, Canvas 기반 공적장부 보안 뷰어 및 Google Meet 화상상담 자동 매칭 웹서버 플랫폼**

---

## 📌 주요 특징 및 요구사항 구현 (Key Features)

### 1. 회원가입 및 로그인 (Auth & Google OAuth)
* **'로그인' 및 '회원가입' 버튼 완전 분리**: 탑 헤더에 로그인과 회원가입 버튼을 독립적으로 배치하여 사용자 직관성을 극대화하였습니다.
* **Google OAuth 연동**: 회원(Member), 중개보조원(Staff), 개업공인중개사(Owner), 웹서버관리자(Admin)는 Google Gmail 계정으로 빠르게 로그인할 수 있습니다.
* **Admin 자동 인증**: Render Cloud 환경 변수 `Admin_ID` (또는 `ADMIN_ID`)로 설정된 Gmail과 Google 로그인 이메일이 일치할 경우 Admin 권한이 자동 검증 및 부여됩니다.

### 2. 토지 매물, 쇼핑카드 & Google Meet 화상 상담 매칭
* **매물 수집 및 노출**: 중개사무소 소속 중개보조원(Staff)이 수집/등록한 28개 지목별 토지 매물 정보를 누구나 탐색할 수 있습니다.
* **관심 매물(쇼핑카드)**: 회원(Member)은 관심 토지 매물을 관심 매물(카트)에 담고 결제 단계로 진행할 수 있습니다.
* **Google Meet 일의 일정 매칭**: 결제 완료 시 담당 중개보조원(Staff)과 회원(Member) 간 Google Meet 화상 회의실 접속 주소가 자동 발행되어 일정이 매칭됩니다.

### 3. YouTube 드론 영상 & Canvas 기반 공적장부(PDF 3종) 보안 뷰어
* **현장 영상 공개**: 비회원(Guest)을 포함한 누구나 현장 드론/소개 YouTube 영상을 열람할 수 있습니다.
* **공적장부 접근 격리**: 토지이용계획확인원(LURIS), 토지대장(Ledger), 지적도(Cadastral) PDF 문서는 **로그인한 자(Member, Staff, Owner, Admin)에게만 노출**되며, 비회원(Guest)에게는 차단 안내문 및 로그인 버튼이 표시됩니다.
* **Canvas 보안 뷰어**: DOM에 원본 PDF 객체를 노출하지 않고 HTML5 Canvas로 픽셀 래스터라이징하여 드로잉하며, **회원 이메일, IP 주소, 접근 일시**가 투명 워터마크로 사선 인쇄됩니다. (Ctrl+P, Ctrl+S 및 마우스 우클릭 인쇄 차단 적용)

### 4. 대한민국 전 지역 대상 & 3대 고위험 규제 구역 원천 차단
* 특정 지역 제한 없이 대한민국 전국 토지를 대상으로 합니다.
* **3대 규제 구역 차단**: **군사보호지역(군사기지 및 군사시설보호구역)**, **농업진흥구역(절대농지)**, **개발제한구역(그린벨트)** 토지 매물은 등록 시 백엔드/프론트엔드 유효성 검사를 통해 자동으로 등록 거절(400 Bad Request) 처리됩니다.

### 5. 결제 처리 & 마이페이지 일정/환불/취소 관리
* 포트원(PortOne / Iamport) 신용카드 결제 모의/실제 검증 완료 후 미팅 일정이 확정됩니다.
* 회원(Member) 마이페이지에서 확정 및 완료된 Google Meet 일정 정보(담당 중개보조원 Staff 정보 포함)를 조회하고, **결제 환불 신청, 미팅 취소 및 내역 삭제**가 가능합니다.

### 6. 중개보조원(Staff) 전용 대시보드 & 회원이름 마스킹 보안 격리
* **개인정보 및 매물 관리**: Staff는 개인정보(닉네임, 연락처)를 수정하고 자신이 수집한 매물을 등록/수정할 수 있습니다.
* **미팅 스케줄 제어**: 결제 완료된 Google Meet 미팅 일정을 보고 확정/변경할 수 있으며 일자별/회원ID별로 지난 미팅 내역을 조회할 수 있습니다.
* **개인정보 보안 격리**: **Staff는 회원의 아이디(ID)와 별명 외에 회원의 어떠한 개인정보(실명, 전화번호, 이메일 주소)도 열람할 수 없도록 마스킹 처리**됩니다.

### 7. 개업공인중개사(Owner) 종합 포털
* 개업공인중개사(Owner)는 회원(Member)의 모든 개인정보(실명, 이메일, 전화번호, 가입일), 토지매물정보, Staff의 개인정보를 종합 조회 및 감독할 수 있습니다.

### 8. 웹서버 관리자(Admin) 권한 & 설정
* 회원(Member), 중개보조원(Staff), 개업공인중개사(Owner)의 개인정보를 조회, 등록, 수정, 삭제(CRUD)할 수 있습니다.
* 개업공인중개사(Owner) 메타데이터를 직접 관리합니다.

### 9. 공인중개사법 제18조의2 법적 공시 동적 헤더 & 푸터 바인딩
* **상단 Header**: Admin이 입력한 Owner의 **사무소 사업장명**과 **유선전화번호** 노출.
* **하단 Footer**: Admin이 입력한 Owner의 **사무소 사업장명, 사업장 주소, 사업자등록번호, 영업허가번호, 무선전화번호, 팩스번호, 개인 이메일** 노출.
* Admin 대시보드에서 수정 시 플랫폼 전역에 실시간으로 동적 바인딩됩니다.

---

## 🛠️ 기술 스택 (Tech Stack)

* **Backend**: Node.js, Express.js, TypeScript (tsx), JSONWebToken, Bcrypt, Multer, AWS S3 SDK, Google Auth Library, PDF-Lib
* **Database**: PostgreSQL (pg pool) / In-Memory Fallback Store
* **Frontend**: HTML5, Tailwind CSS, JavaScript (ES6+), PDF.js, FontAwesome v6, PortOne Payments SDK
* **Build Tools**: Vite, esbuild

---

## 📁 프로젝트 파일 구조 (Project Structure)

```
.
├── index.html          # 메인 프론트엔드 UX/UI (Tailwind + Canvas Security PDF + 360° VR)
├── server.js           # Express API 웹서버 (Auth, Listings, Cart, Meetings, Config, PDF)
├── package.json        # NPM 패키지 정의 및 실행 스크립트
├── schema.sql          # PostgreSQL 물리적 DDL 스키마 (10개 테이블 & 초기 시드 데이터)
├── README.md           # 프로젝트 안내 및 Render Cloud 배포 가이드
├── tsconfig.json       # TypeScript 설정
└── vite.config.ts      # Vite 번들러 설정
```

---

## 🚀 Render Cloud 배포 가이드 (Render Cloud Deployment)

### Step 1. GitHub 저장소 준비
이 5개 파일 (`index.html`, `server.js`, `package.json`, `schema.sql`, `README.md`)이 포함된 코드를 GitHub 저장소에 푸시합니다.

```bash
git init
git add .
git commit -m "Feat: PropTech Land Brokerage Platform v4 release"
git remote add origin https://github.com/ohseyokr/StarRealtor-land.git
git push -u origin main
```

### Step 2. Render Cloud에서 PostgreSQL 데이터베이스 생성
1. [Render Dashboard](https://dashboard.render.com/) 접속 후 **New +** -> **PostgreSQL** 선택
2. Name: `land-db` 입력
3. Database: 'land-db'
4. 데이터베이스가 생성되면 **Internal Database URL** 및 **External Database URL**을 복사합니다.
5. Render PostgreSQL의 **Connect** -> **PSQL Command**를 이용하거나 DBeaver / pgAdmin을 연결하여 `schema.sql` 구문을 실행하여 테이블 및 초기 시드 데이터를 적재합니다.

```bash
psql <YOUR_EXTERNAL_DATABASE_URL> -f schema.sql
```

### Step 3. Render Cloud Web Service 생성
1. Render Dashboard에서 **New +** -> **Web Service** 선택
2. GitHub 저장소(`StarRealtor-land`) 연동
3. 주요 설정값 입력:
   * **Name**: `StarRealtor-land-service`
   * **Environment**: `Node`
   * **Region**: Oregon 또는 Singapore
   * **Branch**: `main`
   * **Build Command**: `npm install && npm run build`
   * **Start Command**: `npm start`

4. **Environment Variables (환경 변수)** 설정:

| Key | Value 예시 | 설명 |
|---|---|---|
| `Admin_ID` | `ohseyokr@gmail.com` | Google OAuth 로그인 시 Admin 권한을 자동 부여할 관리자 Gmail |
| `DATABASE_URL` | `postgres://user:pass@ep-xxxx.render.com/land_db` | Render PostgreSQL 연결 URI |
| `JWT_SECRET` | `your_secure_jwt_secret_key_2026` | JWT 토큰 암호화 키 |
| `GOOGLE_CLIENT_ID` | `your-google-oauth-client-id` | Google OAuth 클라이언트 ID |
| `GOOGLE_CLIENT_SECRET` | `your-google-oauth-client-secret` | Google OAuth 클라이언트 시크릿 |
| `PORT` | `10000` | Render 웹서버 수신 포트 |

### Step 4. 배포 및 가동 확인
* **Create Web Service** 클릭 시 Render가 저장소를 빌드하고 서비스를 시작합니다.
* 배포가 완료되면 제공된 `https://proptech-land-service.onrender.com` 주소로 접속하여 360° VR 가상투어, Canvas 보안 PDF 뷰어, Google Meet 화상미팅 매칭 및 법적 공시 헤더/푸터 바인딩 동작을 확인합니다!

---

## 💡 기본 테스트 계정 정보 (Initial Test Accounts)

| 역할군 | 이메일 (Gmail/ID) | 초기 비밀번호 | 특이사항 |
|---|---|---|---|
| **웹서버관리자 (Admin)** | `ohseyokr@gmail.com` | `admin123` | `Admin_ID` 환경 변수 동기화 및 전역 제어 |
| **개업공인중개사 (Owner)** | `owner@proptech-land.co.kr` | `admin123` | 회원 전체 개인정보 및 사무소 통제 |
| **중개보조원 (Staff)** | `staff1@gmail.com` | `admin123` | 매물 수집 등록 및 미팅 주재 (회원 개인정보 마스킹) |
| **회원 (Member)** | `member1@gmail.com` | `admin123` | 관심 매물 결제 및 Google Meet 예약 |
