-- ====================================================================
-- StarRealtor Land Brokerage Platform (스타공인중개사 토지 중개 플랫폼) v5
-- PostgreSQL Relational Database Physical Schema
-- Supported Target: PostgreSQL v14+ / Render Cloud PostgreSQL
-- ====================================================================

-- Drop existing tables if re-initializing
DROP TABLE IF EXISTS TB_AUDIT_LOG CASCADE;
DROP TABLE IF EXISTS TB_RESTRICTED_ZONE_LOG CASCADE;
DROP TABLE IF EXISTS TB_VWORLD_API_LOG CASCADE;
DROP TABLE IF EXISTS TB_PDF_DOWNLOAD_LOG CASCADE;
DROP TABLE IF EXISTS TB_STAFF_PROFILE CASCADE;
DROP TABLE IF EXISTS TB_MEET_SCHEDULE CASCADE;
DROP TABLE IF EXISTS TB_PAYMENT_LOG CASCADE;
DROP TABLE IF EXISTS TB_CART CASCADE;
DROP TABLE IF EXISTS TB_LAND_LISTING CASCADE;
DROP TABLE IF EXISTS TB_USER CASCADE;
DROP TABLE IF EXISTS TB_OWNER_CONFIG CASCADE;

-- 1. Owner Legal Metadata Table (공인중개사법 제18조의2 헤더/푸터 동적 공시 및 VWORLD 오피셜 개발키 관리)
CREATE TABLE TB_OWNER_CONFIG (
    config_id VARCHAR(50) PRIMARY KEY DEFAULT 'cfg-1',
    office_name VARCHAR(150) NOT NULL DEFAULT '스타공인중개사사무소',
    owner_name VARCHAR(50) NOT NULL DEFAULT '홍길동',
    address VARCHAR(255) NOT NULL DEFAULT '서울특별시 서초구 반포대로 100, 4층',
    business_reg_num VARCHAR(50) NOT NULL DEFAULT '120-12-12345',
    license_num VARCHAR(50) NOT NULL DEFAULT '제11650-2026-00001호',
    mobile_phone VARCHAR(30) NOT NULL DEFAULT '010-9876-5432',
    landline_phone VARCHAR(30) NOT NULL DEFAULT '02-1234-5678',
    fax_num VARCHAR(30) NOT NULL DEFAULT '02-1234-5679',
    email VARCHAR(100) NOT NULL DEFAULT 'owner@starrealtor-land.co.kr',
    vworld_api_key VARCHAR(100) NOT NULL DEFAULT 'CE2C1488-301B-303A-8673-E2E0D4B2D8E3',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. Users Table (Member, Staff, Owner, Admin)
CREATE TABLE TB_USER (
    user_id VARCHAR(50) PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) DEFAULT '',
    nickname VARCHAR(50) NOT NULL,
    name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(30) DEFAULT '',
    role VARCHAR(20) NOT NULL CHECK (role IN ('MEMBER', 'STAFF', 'OWNER', 'ADMIN')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Land Listings Table (28개 지목, 승인워크플로우, PDF/YouTube 및 VWORLD 좌표 지원)
CREATE TABLE TB_LAND_LISTING (
    listing_id VARCHAR(50) PRIMARY KEY,
    assistant_id VARCHAR(50) REFERENCES TB_USER(user_id) ON DELETE SET NULL,
    title VARCHAR(200) NOT NULL,
    address VARCHAR(255) NOT NULL,
    jimok_official VARCHAR(30) NOT NULL, -- 전, 답, 과, 목, 임, 광, 염, 대, 장, 학, 차, 주, 창, 도, 철, 제, 천, 구, 유, 양, 수, 공, 체, 원, 종, 사, 묘, 잡 (28개 지목)
    area_sqm NUMERIC(12, 2) NOT NULL DEFAULT 0,
    price NUMERIC(18, 0) NOT NULL DEFAULT 0,
    zoning_district VARCHAR(100) NOT NULL,
    road_access VARCHAR(100) DEFAULT '지적도상 도로 접함',
    youtube_url VARCHAR(255) DEFAULT '',
    doc_luris_pdf_url TEXT DEFAULT '',
    doc_ledger_pdf_url TEXT DEFAULT '',
    doc_cadastral_pdf_url TEXT DEFAULT '',
    listing_status VARCHAR(20) DEFAULT 'ACTIVE' CHECK (listing_status IN ('ACTIVE', 'PENDING', 'SOLD', 'INACTIVE')),
    approval_status VARCHAR(30) DEFAULT 'APPROVED' CHECK (approval_status IN ('APPROVED', 'PENDING_REGISTRATION', 'PENDING_MODIFICATION', 'PENDING_DELETION', 'REJECTED')),
    approval_requests JSONB DEFAULT '[]'::jsonb,
    lat NUMERIC(10, 6) DEFAULT 37.6651,
    lng NUMERIC(10, 6) DEFAULT 128.7182,
    pnu_code VARCHAR(30) DEFAULT '4276033022200450002',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Shopping Cart Table (회원 관심 토지)
CREATE TABLE TB_CART (
    cart_id VARCHAR(50) PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL REFERENCES TB_USER(user_id) ON DELETE CASCADE,
    listing_id VARCHAR(50) NOT NULL REFERENCES TB_LAND_LISTING(listing_id) ON DELETE CASCADE,
    added_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_member_listing UNIQUE (member_id, listing_id)
);

-- 5. Payment Log Table (포트원/신용카드 결제 로그)
CREATE TABLE TB_PAYMENT_LOG (
    payment_id VARCHAR(50) PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL REFERENCES TB_USER(user_id) ON DELETE CASCADE,
    amount NUMERIC(12, 0) NOT NULL,
    imp_uid VARCHAR(100) DEFAULT '',
    merchant_uid VARCHAR(100) DEFAULT '',
    status VARCHAR(20) DEFAULT 'PAID' CHECK (status IN ('PAID', 'REFUNDED', 'CANCELLED')),
    paid_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. Google Meet Meetings Schedule Table (화상 미팅 일정 및 히스토리 로그)
CREATE TABLE TB_MEET_SCHEDULE (
    meeting_id VARCHAR(50) PRIMARY KEY,
    listing_id VARCHAR(50) REFERENCES TB_LAND_LISTING(listing_id) ON DELETE CASCADE,
    member_id VARCHAR(50) NOT NULL REFERENCES TB_USER(user_id) ON DELETE CASCADE,
    assistant_id VARCHAR(50) REFERENCES TB_USER(user_id) ON DELETE SET NULL,
    google_event_id VARCHAR(100) DEFAULT '',
    meet_link TEXT NOT NULL,
    start_time VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'CONFIRMED',
    amount NUMERIC(12, 0) DEFAULT 50000,
    payment_id VARCHAR(50) REFERENCES TB_PAYMENT_LOG(payment_id) ON DELETE SET NULL,
    history JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. Staff Profile Details Table
CREATE TABLE TB_STAFF_PROFILE (
    profile_id VARCHAR(50) PRIMARY KEY,
    staff_id VARCHAR(50) UNIQUE REFERENCES TB_USER(user_id) ON DELETE CASCADE,
    office_branch VARCHAR(100) DEFAULT '본사 토지팀',
    bio TEXT DEFAULT '',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. PDF Download Audit Log Table
CREATE TABLE TB_PDF_DOWNLOAD_LOG (
    log_id VARCHAR(50) PRIMARY KEY,
    member_id VARCHAR(50) REFERENCES TB_USER(user_id) ON DELETE CASCADE,
    listing_id VARCHAR(50) REFERENCES TB_LAND_LISTING(listing_id) ON DELETE CASCADE,
    doc_type VARCHAR(30) NOT NULL,
    ip_address VARCHAR(45) NOT NULL,
    downloaded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. VWORLD 14개 전체 Open API Mypage 조회 및 다운로드 감사 로그 Table
CREATE TABLE TB_VWORLD_API_LOG (
    log_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) REFERENCES TB_USER(user_id) ON DELETE CASCADE,
    user_role VARCHAR(20) NOT NULL,
    target_address VARCHAR(255) NOT NULL,
    pnu_code VARCHAR(30) DEFAULT '',
    api_categories_queried TEXT DEFAULT '3D지도,2D지도,WMS연속지적,WMTS위성,Geocoder,2D데이터,StaticMap',
    report_downloaded BOOLEAN DEFAULT FALSE,
    accessed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. Restricted Zone Attempt Log Table (3대 고위험 규제 지역 시도)
CREATE TABLE TB_RESTRICTED_ZONE_LOG (
    log_id VARCHAR(50) PRIMARY KEY,
    attempted_address VARCHAR(255) NOT NULL,
    attempted_zoning VARCHAR(100) NOT NULL,
    rejected_reason VARCHAR(255) NOT NULL,
    attempted_by VARCHAR(50) REFERENCES TB_USER(user_id) ON DELETE CASCADE,
    attempted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 11. Audit Log Table
CREATE TABLE TB_AUDIT_LOG (
    audit_id VARCHAR(50) PRIMARY KEY,
    user_id VARCHAR(50) REFERENCES TB_USER(user_id) ON DELETE CASCADE,
    action_type VARCHAR(50) NOT NULL,
    description TEXT DEFAULT '',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- INDEXES FOR PERFORMANCE
-- ====================================================================
CREATE INDEX IF NOT EXISTS idx_user_email ON TB_USER(email);
CREATE INDEX IF NOT EXISTS idx_user_role ON TB_USER(role);
CREATE INDEX IF NOT EXISTS idx_listing_jimok ON TB_LAND_LISTING(jimok_official);
CREATE INDEX IF NOT EXISTS idx_listing_status ON TB_LAND_LISTING(listing_status);
CREATE INDEX IF NOT EXISTS idx_listing_approval ON TB_LAND_LISTING(approval_status);
CREATE INDEX IF NOT EXISTS idx_cart_member ON TB_CART(member_id);
CREATE INDEX IF NOT EXISTS idx_meet_member ON TB_MEET_SCHEDULE(member_id);
CREATE INDEX IF NOT EXISTS idx_meet_assistant ON TB_MEET_SCHEDULE(assistant_id);
CREATE INDEX IF NOT EXISTS idx_vworld_log_user ON TB_VWORLD_API_LOG(user_id);

-- ====================================================================
-- INITIAL SEED DATA
-- ====================================================================

-- 1. Default Owner Config
INSERT INTO TB_OWNER_CONFIG (config_id, office_name, owner_name, address, business_reg_num, license_num, mobile_phone, landline_phone, fax_num, email, vworld_api_key)
VALUES ('cfg-1', '스타공인중개사사무소', '홍길동', '서울특별시 서초구 반포대로 100, 4층', '120-12-12345', '제11650-2026-00001호', '010-9876-5432', '02-1234-5678', '02-1234-5679', 'owner@starrealtor-land.co.kr', 'CE2C1488-301B-303A-8673-E2E0D4B2D8E3')
ON CONFLICT (config_id) DO NOTHING;

-- 2. Seed Users (Disabled)
-- INSERT INTO TB_USER (user_id, email, password_hash, nickname, name, phone_number, role) VALUES
-- ('u-admin-1', 'ohseyokr@gmail.com', '$2b$10$wT8Zz.xR7K8qH9.u8Y9pOOZk/Z5M/V6Jb/TqK6V5l4O6J1R8u0J1e', '최고관리자', '시스템관리자', '010-1111-2222', 'ADMIN'),
-- ('u-owner-1', 'owner@starrealtor-land.co.kr', '$2b$10$wT8Zz.xR7K8qH9.u8Y9pOOZk/Z5M/V6Jb/TqK6V5l4O6J1R8u0J1e', '대표중개사', '홍길동', '010-9876-5432', 'OWNER'),
-- ('u-staff-1', 'staff1@gmail.com', '$2b$10$wT8Zz.xR7K8qH9.u8Y9pOOZk/Z5M/V6Jb/TqK6V5l4O6J1R8u0J1e', '김보조원', '김철수', '010-3333-4444', 'STAFF'),
-- ('u-member-1', 'member1@gmail.com', '$2b$10$wT8Zz.xR7K8qH9.u8Y9pOOZk/Z5M/V6Jb/TqK6V5l4O6J1R8u0J1e', '토지투자왕', '이영희', '010-5555-6666', 'MEMBER')
-- ON CONFLICT (user_id) DO NOTHING;

-- 3. Seed Land Listings (Disabled)
-- INSERT INTO TB_LAND_LISTING (listing_id, assistant_id, title, address, jimok_official, area_sqm, price, zoning_district, road_access, youtube_url, doc_luris_pdf_url, doc_ledger_pdf_url, doc_cadastral_pdf_url, listing_status) VALUES
-- ('lnd-101', 'u-staff-1', '강원도 평창군 대관령면 수하리 청정 임야 매물', '강원특별자치도 평창군 대관령면 수하리 산 45-2', '임', 3305, 350000000, '보전관리지역', '2차선 포장도로 접함', 'https://www.youtube.com/embed/dQw4w9WgXcQ', '/sample-luris.pdf', '/sample-ledger.pdf', '/sample-cadastral.pdf', 'ACTIVE'),
-- ('lnd-102', 'u-staff-1', '충남 당진시 신평면 금천리 도로 접한 넓은 밭(전)', '충청남도 당진시 신평면 금천리 123-5', '전', 1652, 180000000, '계획관리지역', '4m 마을 농로 구거 접함', 'https://www.youtube.com/embed/dQw4w9WgXcQ', '/sample-luris.pdf', '/sample-ledger.pdf', '/sample-cadastral.pdf', 'ACTIVE'),
-- ('lnd-103', 'u-staff-1', '경기 용인시 처인구 양지면 대지 (즉시 건축 가능)', '경기도 용인시 처인구 양지면 양지리 78-1', '대', 660, 820000000, '제1종일반주거지역', '6m 지적도상 도로 완비', 'https://www.youtube.com/embed/dQw4w9WgXcQ', '/sample-luris.pdf', '/sample-ledger.pdf', '/sample-cadastral.pdf', 'ACTIVE'),
-- ('lnd-104', 'u-staff-1', '(임야) 경기도 포천시 창수면 가양리 369-6', '경기도 포천시 창수면 가양리 369-6', '임', 4958, 290000000, '계획관리지역', '4m 포장도로 접함', 'https://www.youtube.com/embed/dQw4w9WgXcQ', '/sample-luris.pdf', '/sample-ledger.pdf', '/sample-cadastral.pdf', 'ACTIVE'),
-- ('lnd-105', 'u-staff-1', '(대지) 경기도 양주시 고암동 603-7', '경기도 양주시 고암동 603-7', '대', 495, 650000000, '제1종일반주거지역', '6m 진입도로 완비', 'https://www.youtube.com/embed/dQw4w9WgXcQ', '/sample-luris.pdf', '/sample-ledger.pdf', '/sample-cadastral.pdf', 'ACTIVE'),
-- ('lnd-106', 'u-staff-1', '(공장용지) 경기도 포천시 내촌면 마명리 337', '경기도 포천시 내촌면 마명리 337', '장', 2314, 1250000000, '계획관리지역', '8m 대로변 접함', 'https://www.youtube.com/embed/dQw4w9WgXcQ', '/sample-luris.pdf', '/sample-ledger.pdf', '/sample-cadastral.pdf', 'ACTIVE')
-- ON CONFLICT (listing_id) DO NOTHING;
