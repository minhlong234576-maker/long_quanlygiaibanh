-- QUAN_LY_BONG_DA - Lược đồ đầy đủ (SQLite) cho webapp Quản lý Giải VĐQG Bóng đá (V-League)
-- 13 bảng nghiệp vụ + NHAN_SU & TAI_KHOAN theo đề tài. PK/FK theo ERD đã duyệt.

PRAGMA foreign_keys = ON;

-- ================= CÁN BỘ BAN TỔ CHỨC =================
CREATE TABLE IF NOT EXISTS NHAN_SU (
    MaNhanSu     INTEGER PRIMARY KEY AUTOINCREMENT,
    HoTen        TEXT NOT NULL,
    GioiTinh     TEXT CHECK (GioiTinh IN ('Nam','Nữ','Khác')),
    NgaySinh     TEXT,
    SoDienThoai  TEXT,
    Email        TEXT UNIQUE,
    ChucVu       TEXT,
    TrangThaiLamViec INTEGER NOT NULL DEFAULT 1   -- 1: đang làm việc, 0: nghỉ
);

-- ================= TÀI KHOẢN ĐĂNG NHẬP =================
CREATE TABLE IF NOT EXISTS TAI_KHOAN (
    MaTaiKhoan   INTEGER PRIMARY KEY AUTOINCREMENT,
    MaNhanSu     INTEGER NOT NULL UNIQUE,
    TenDangNhap  TEXT NOT NULL UNIQUE,
    MatKhau      TEXT NOT NULL,                    -- hash pbkdf2
    QuyenHan     TEXT NOT NULL DEFAULT 'XEM' CHECK (QuyenHan IN ('ADMIN','CAPNHAT','XEM')),
    TrangThaiHoatDong INTEGER NOT NULL DEFAULT 1,  -- 1: hoạt động, 0: khóa
    FOREIGN KEY (MaNhanSu) REFERENCES NHAN_SU(MaNhanSu)
);

-- ================= GIẢI ĐẤU (mùa giải) =================
CREATE TABLE IF NOT EXISTS GIAI_DAU (
    MaGiaiDau    INTEGER PRIMARY KEY AUTOINCREMENT,
    TenGiai      TEXT NOT NULL,
    NamBatDau    INTEGER NOT NULL,
    NamKetThuc   INTEGER,
    NgayKhaiMac  TEXT,
    NgayBeMac    TEXT,
    TrangThai    TEXT NOT NULL DEFAULT 'ĐANG DIỄN RA'
                 CHECK (TrangThai IN ('CHƯA BẮT ĐẦU','ĐANG DIỄN RA','ĐÃ KẾT THÚC'))
);

-- ================= SÂN VẬN ĐỘNG =================
CREATE TABLE IF NOT EXISTS SAN_VAN_DONG (
    MaSanVD      INTEGER PRIMARY KEY AUTOINCREMENT,
    TenSan       TEXT NOT NULL,
    SucChua      INTEGER,
    DiaChi       TEXT
);

-- ================= TRỌNG TÀI =================
CREATE TABLE IF NOT EXISTS TRONG_TAI (
    MaTrongTai   INTEGER PRIMARY KEY AUTOINCREMENT,
    HoTen        TEXT NOT NULL,
    CapDo        TEXT CHECK (CapDo IN ('FIFA','Quốc gia','Cấp 1','Cấp 2'))
);

-- ================= VÒNG ĐẤU =================
CREATE TABLE IF NOT EXISTS VONG_DAU (
    MaVongDau    INTEGER PRIMARY KEY AUTOINCREMENT,
    MaGiaiDau    INTEGER NOT NULL,
    TenVong      TEXT NOT NULL,
    GiaiDoan     TEXT CHECK (GiaiDoan IN ('Lượt đi','Lượt về','Tranh vô địch','Trụ hạng')),
    FOREIGN KEY (MaGiaiDau) REFERENCES GIAI_DAU(MaGiaiDau)
);

-- ================= CLB =================
CREATE TABLE IF NOT EXISTS CLB (
    MaCLB        INTEGER PRIMARY KEY AUTOINCREMENT,
    TenCLB       TEXT NOT NULL,
    TenVietTom   TEXT,
    Logo         TEXT,                              -- URL/emoji logo
    MaSanNha     INTEGER NOT NULL,
    FOREIGN KEY (MaSanNha) REFERENCES SAN_VAN_DONG(MaSanVD)
);

-- ================= CẦU THỦ (MaCLB NULL: chưa có CLB) =================
CREATE TABLE IF NOT EXISTS CAU_THU (
    MaCauThu     INTEGER PRIMARY KEY AUTOINCREMENT,
    HoTen        TEXT NOT NULL,
    NgaySinh     TEXT,
    QuocTich     TEXT NOT NULL DEFAULT 'Việt Nam',
    LoaiCauThu   TEXT NOT NULL DEFAULT 'Nội binh'
                 CHECK (LoaiCauThu IN ('Nội binh','Ngoại binh','Nhập tịch')),
    ViTriSoTruong TEXT,
    MaCLB        INTEGER,
    FOREIGN KEY (MaCLB) REFERENCES CLB(MaCLB)
);

-- ================= BAN HUẤN LUYỆN =================
CREATE TABLE IF NOT EXISTS BAN_HUAN_LUYEN (
    MaHLV        INTEGER PRIMARY KEY AUTOINCREMENT,
    HoTen        TEXT NOT NULL,
    QuocTich     TEXT,
    ChucVu       TEXT,
    BangCap      TEXT,
    MaCLB        INTEGER NOT NULL,
    FOREIGN KEY (MaCLB) REFERENCES CLB(MaCLB)
);

-- ================= ĐĂNG KÝ CẦU THỦ THEO MÙA GIẢI =================
CREATE TABLE IF NOT EXISTS DANG_KY_CAU_THU (
    MaDangKy     INTEGER PRIMARY KEY AUTOINCREMENT,
    MaGiaiDau    INTEGER NOT NULL,
    MaCLB        INTEGER NOT NULL,
    MaCauThu     INTEGER NOT NULL,
    SoAo         INTEGER,
    ViTriDangKy  TEXT,
    TrangThai    TEXT NOT NULL DEFAULT 'ĐANG HOẠT ĐỘNG'
                 CHECK (TrangThai IN ('ĐANG HOẠT ĐỘNG','NGỪNG ĐĂNG KÝ')),
    FOREIGN KEY (MaGiaiDau) REFERENCES GIAI_DAU(MaGiaiDau),
    FOREIGN KEY (MaCLB)     REFERENCES CLB(MaCLB),
    FOREIGN KEY (MaCauThu)  REFERENCES CAU_THU(MaCauThu),
    UNIQUE (MaGiaiDau, MaCLB, MaCauThu)
);

-- ================= BẢNG XẾP HẠNG (lưu theo vòng đấu) =================
CREATE TABLE IF NOT EXISTS BANG_XEP_HANG (
    MaBXH        INTEGER PRIMARY KEY AUTOINCREMENT,
    MaVongDau    INTEGER NOT NULL,
    MaCLB        INTEGER NOT NULL,
    SoTranDaDau  INTEGER NOT NULL DEFAULT 0,
    SoTranThang  INTEGER NOT NULL DEFAULT 0,
    SoTranHoa    INTEGER NOT NULL DEFAULT 0,
    SoTranThua   INTEGER NOT NULL DEFAULT 0,
    TongBanThang INTEGER NOT NULL DEFAULT 0,
    TongBanThua  INTEGER NOT NULL DEFAULT 0,
    DiemFairPlay INTEGER NOT NULL DEFAULT 0,        -- trừ theo thẻ phạt
    ThuHang      INTEGER,
    FOREIGN KEY (MaVongDau) REFERENCES VONG_DAU(MaVongDau),
    FOREIGN KEY (MaCLB)     REFERENCES CLB(MaCLB),
    UNIQUE (MaVongDau, MaCLB)
);

-- ================= TRẬN ĐẤU =================
CREATE TABLE IF NOT EXISTS TRAN_DAU (
    MaTranDau    INTEGER PRIMARY KEY AUTOINCREMENT,
    MaVongDau    INTEGER NOT NULL,
    MaDoiNha     INTEGER NOT NULL,
    MaDoiKhach   INTEGER NOT NULL,
    MaSanVD      INTEGER NOT NULL,
    NgayGioThiDau TEXT,
    TrangThai    TEXT NOT NULL DEFAULT 'CHƯA ĐÁ'
                 CHECK (TrangThai IN ('CHƯA ĐÁ','ĐANG ĐÁ','ĐÃ KẾT THÚC','HOÃN')),
    FOREIGN KEY (MaVongDau)  REFERENCES VONG_DAU(MaVongDau),
    FOREIGN KEY (MaDoiNha)   REFERENCES CLB(MaCLB),
    FOREIGN KEY (MaDoiKhach) REFERENCES CLB(MaCLB),
    FOREIGN KEY (MaSanVD)    REFERENCES SAN_VAN_DONG(MaSanVD),
    CHECK (MaDoiNha <> MaDoiKhach)
);

-- ================= ĐỘI HÌNH RA SÂN =================
CREATE TABLE IF NOT EXISTS DOI_HINH_TRAN_DAU (
    MaDoiHinh    INTEGER PRIMARY KEY AUTOINCREMENT,
    MaTranDau    INTEGER NOT NULL,
    MaCauThu     INTEGER NOT NULL,
    LoaiRaSan    TEXT NOT NULL DEFAULT 'Đá chính' CHECK (LoaiRaSan IN ('Đá chính','Dự bị')),
    DaiDoTruong  INTEGER NOT NULL DEFAULT 0,        -- 1: mang băng đội trưởng
    FOREIGN KEY (MaTranDau) REFERENCES TRAN_DAU(MaTranDau),
    FOREIGN KEY (MaCauThu)  REFERENCES CAU_THU(MaCauThu),
    UNIQUE (MaTranDau, MaCauThu)
);

-- ================= SỰ KIỆN TRẬN ĐẤU (MaCauThuPhu NULL được phép) =================
CREATE TABLE IF NOT EXISTS SU_KIEN_TRAN_DAU (
    MaSuKien     INTEGER PRIMARY KEY AUTOINCREMENT,
    MaTranDau    INTEGER NOT NULL,
    LoaiSuKien   TEXT NOT NULL CHECK (LoaiSuKien IN ('BÀN THẮNG','THẺ VÀNG','THẺ ĐỎ','THAY NGƯỜI')),
    Phut         INTEGER,
    MaCauThuChinh INTEGER NOT NULL,
    MaCauThuPhu  INTEGER,                           -- kiến tạo / người bị thay / NULL
    FOREIGN KEY (MaTranDau)     REFERENCES TRAN_DAU(MaTranDau),
    FOREIGN KEY (MaCauThuChinh) REFERENCES CAU_THU(MaCauThu),
    FOREIGN KEY (MaCauThuPhu)   REFERENCES CAU_THU(MaCauThu)
);

-- ================= PHÂN CÔNG TRỌNG TÀI =================
CREATE TABLE IF NOT EXISTS PHAN_CONG_TRONG_TAI (
    MaPhanCong   INTEGER PRIMARY KEY AUTOINCREMENT,
    MaTranDau    INTEGER NOT NULL,
    MaTrongTai   INTEGER NOT NULL,
    NhiemVu      TEXT NOT NULL CHECK (NhiemVu IN ('TRỌNG TÀI CHÍNH','BIÊN','BÀN','VAR')),
    FOREIGN KEY (MaTranDau)   REFERENCES TRAN_DAU(MaTranDau),
    FOREIGN KEY (MaTrongTai)  REFERENCES TRONG_TAI(MaTrongTai),
    UNIQUE (MaTranDau, MaTrongTai)
);
