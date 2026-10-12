-- =====================================================================
-- QUAN_LY_BONG_DA - Script SQL Server (TAI TAO TU LIVE DB)
-- Quan ly Giai vo dich Bong da Quoc gia (V-League) - 15 bang
-- Noi dung tieng Viet trong file nay la UNICODE chuan.
-- Chay: sqlcmd -S localhost -E -f 65001 -i QUAN_LY_BONG_DA_SQLServer.sql
--   (-f 65001 BAT BUOC de giu tieng Viet; neu chay sai encoding se
--    sinh mojibake nhu truoc day. SSMS: mo file (co BOM) roi Execute.)
-- =====================================================================

IF DB_ID('QUAN_LY_BONG_DA') IS NULL
    CREATE DATABASE QUAN_LY_BONG_DA;
GO
USE QUAN_LY_BONG_DA;
GO

-- =====================================================================
-- PHAN 1: TAO BANG
-- =====================================================================

-- ================= NHAN_SU =================
IF OBJECT_ID('dbo.NHAN_SU', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.NHAN_SU (
        MaNhanSu INT IDENTITY(1,1) NOT NULL,
        HoTen NVARCHAR(100) NOT NULL,
        GioiTinh NVARCHAR(10) NULL,
        NgaySinh DATE NULL,
        SoDienThoai NVARCHAR(20) NULL,
        Email NVARCHAR(100) NULL,
        ChucVu NVARCHAR(100) NULL,
        TrangThaiLamViec INT NOT NULL CONSTRAINT DF__NHAN_SU__TrangTh__57DD0BE4 DEFAULT ((1))
    );
END;
GO

-- ================= TAI_KHOAN =================
IF OBJECT_ID('dbo.TAI_KHOAN', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TAI_KHOAN (
        MaTaiKhoan INT IDENTITY(1,1) NOT NULL,
        MaNhanSu INT NOT NULL,
        TenDangNhap NVARCHAR(50) NOT NULL,
        MatKhau NVARCHAR(255) NOT NULL,
        QuyenHan NVARCHAR(10) NOT NULL CONSTRAINT DF__TAI_KHOAN__Quyen__5CA1C101 DEFAULT ('XEM'),
        TrangThaiHoatDong INT NOT NULL CONSTRAINT DF__TAI_KHOAN__Trang__5E8A0973 DEFAULT ((1))
    );
END;
GO

-- ================= GIAI_DAU =================
IF OBJECT_ID('dbo.GIAI_DAU', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.GIAI_DAU (
        MaGiaiDau INT IDENTITY(1,1) NOT NULL,
        TenGiai NVARCHAR(200) NOT NULL,
        NamBatDau INT NOT NULL,
        NamKetThuc INT NULL,
        NgayKhaiMac DATE NULL,
        NgayBeMac DATE NULL,
        TrangThai NVARCHAR(30) NOT NULL CONSTRAINT DF__GIAI_DAU__TrangT__625A9A57 DEFAULT (N'ĐANG DIỄN RA')
    );
END;
GO

-- ================= SAN_VAN_DONG =================
IF OBJECT_ID('dbo.SAN_VAN_DONG', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SAN_VAN_DONG (
        MaSanVD INT IDENTITY(1,1) NOT NULL,
        TenSan NVARCHAR(200) NOT NULL,
        SucChua INT NULL,
        DiaChi NVARCHAR(300) NULL
    );
END;
GO

-- ================= TRONG_TAI =================
IF OBJECT_ID('dbo.TRONG_TAI', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TRONG_TAI (
        MaTrongTai INT IDENTITY(1,1) NOT NULL,
        HoTen NVARCHAR(100) NOT NULL,
        CapDo NVARCHAR(20) NULL
    );
END;
GO

-- ================= VONG_DAU =================
IF OBJECT_ID('dbo.VONG_DAU', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.VONG_DAU (
        MaVongDau INT IDENTITY(1,1) NOT NULL,
        MaGiaiDau INT NOT NULL,
        TenVong NVARCHAR(100) NOT NULL,
        GiaiDoan NVARCHAR(30) NULL
    );
END;
GO

-- ================= CLB =================
IF OBJECT_ID('dbo.CLB', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CLB (
        MaCLB INT IDENTITY(1,1) NOT NULL,
        TenCLB NVARCHAR(200) NOT NULL,
        Logo NVARCHAR(100) NULL,
        MaSanNha INT NOT NULL,
        TenVietTom NVARCHAR(20) NULL
    );
END;
GO

-- ================= CAU_THU =================
IF OBJECT_ID('dbo.CAU_THU', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.CAU_THU (
        MaCauThu INT IDENTITY(1,1) NOT NULL,
        HoTen NVARCHAR(100) NOT NULL,
        NgaySinh DATE NULL,
        QuocTich NVARCHAR(50) NOT NULL CONSTRAINT DF__CAU_THU__QuocTic__719CDDE7 DEFAULT (N'Việt Nam'),
        LoaiCauThu NVARCHAR(20) NOT NULL CONSTRAINT DF__CAU_THU__LoaiCau__72910220 DEFAULT (N'Nội binh'),
        ViTriSoTruong NVARCHAR(50) NULL,
        MaCLB INT NULL
    );
END;
GO

-- ================= BAN_HUAN_LUYEN =================
IF OBJECT_ID('dbo.BAN_HUAN_LUYEN', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BAN_HUAN_LUYEN (
        MaHLV INT IDENTITY(1,1) NOT NULL,
        HoTen NVARCHAR(100) NOT NULL,
        QuocTich NVARCHAR(50) NULL,
        ChucVu NVARCHAR(100) NULL,
        BangCap NVARCHAR(100) NULL,
        MaCLB INT NOT NULL
    );
END;
GO

-- ================= DANG_KY_CAU_THU =================
IF OBJECT_ID('dbo.DANG_KY_CAU_THU', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DANG_KY_CAU_THU (
        MaDangKy INT IDENTITY(1,1) NOT NULL,
        MaGiaiDau INT NOT NULL,
        MaCLB INT NOT NULL,
        MaCauThu INT NOT NULL,
        SoAo INT NULL,
        ViTriDangKy NVARCHAR(50) NULL,
        TrangThai NVARCHAR(30) NOT NULL CONSTRAINT DF__DANG_KY_C__Trang__7B264821 DEFAULT (N'ĐANG HOẠT ĐỘNG')
    );
END;
GO

-- ================= BANG_XEP_HANG =================
IF OBJECT_ID('dbo.BANG_XEP_HANG', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.BANG_XEP_HANG (
        MaBXH INT IDENTITY(1,1) NOT NULL,
        MaVongDau INT NOT NULL,
        MaCLB INT NOT NULL,
        SoTranDaDau INT NOT NULL CONSTRAINT DF__BANG_XEP___SoTra__02C769E9 DEFAULT ((0)),
        SoTranThang INT NOT NULL CONSTRAINT DF__BANG_XEP___SoTra__03BB8E22 DEFAULT ((0)),
        SoTranHoa INT NOT NULL CONSTRAINT DF__BANG_XEP___SoTra__04AFB25B DEFAULT ((0)),
        SoTranThua INT NOT NULL CONSTRAINT DF__BANG_XEP___SoTra__05A3D694 DEFAULT ((0)),
        TongBanThang INT NOT NULL CONSTRAINT DF__BANG_XEP___TongB__0697FACD DEFAULT ((0)),
        TongBanThua INT NOT NULL CONSTRAINT DF__BANG_XEP___TongB__078C1F06 DEFAULT ((0)),
        DiemFairPlay INT NOT NULL CONSTRAINT DF__BANG_XEP___DiemF__0880433F DEFAULT ((0)),
        ThuHang INT NULL,
        DiemSo INT NOT NULL CONSTRAINT DF__BANG_XEP___DiemS__28ED12D1 DEFAULT ((0)),
        HieuSo INT NOT NULL CONSTRAINT DF__BANG_XEP___HieuS__29E1370A DEFAULT ((0))
    );
END;
GO

-- ================= TRAN_DAU =================
IF OBJECT_ID('dbo.TRAN_DAU', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TRAN_DAU (
        MaTranDau INT IDENTITY(1,1) NOT NULL,
        MaVongDau INT NOT NULL,
        MaDoiNha INT NOT NULL,
        MaDoiKhach INT NOT NULL,
        MaSanVD INT NOT NULL,
        NgayGioThiDau DATETIME NULL,
        TrangThai NVARCHAR(30) NOT NULL CONSTRAINT DF__TRAN_DAU__TrangT__0D44F85C DEFAULT (N'CHƯA ĐÁ'),
        BanThangDoiNha INT NULL CONSTRAINT DF__TRAN_DAU__BanTha__2704CA5F DEFAULT ((0)),
        BanThangDoiKhach INT NULL CONSTRAINT DF__TRAN_DAU__BanTha__27F8EE98 DEFAULT ((0))
    );
END;
GO

-- ================= DOI_HINH_TRAN_DAU =================
IF OBJECT_ID('dbo.DOI_HINH_TRAN_DAU', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.DOI_HINH_TRAN_DAU (
        MaDoiHinh INT IDENTITY(1,1) NOT NULL,
        MaTranDau INT NOT NULL,
        MaCauThu INT NOT NULL,
        LoaiRaSan NVARCHAR(20) NOT NULL CONSTRAINT DF__DOI_HINH___LoaiR__16CE6296 DEFAULT (N'Đá chính'),
        DaiDoTruong INT NOT NULL CONSTRAINT DF__DOI_HINH___DaiDo__18B6AB08 DEFAULT ((0))
    );
END;
GO

-- ================= SU_KIEN_TRAN_DAU =================
IF OBJECT_ID('dbo.SU_KIEN_TRAN_DAU', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.SU_KIEN_TRAN_DAU (
        MaSuKien INT IDENTITY(1,1) NOT NULL,
        MaTranDau INT NOT NULL,
        LoaiSuKien NVARCHAR(20) NOT NULL,
        Phut INT NULL,
        MaCauThuChinh INT NOT NULL,
        MaCauThuPhu INT NULL
    );
END;
GO

-- ================= PHAN_CONG_TRONG_TAI =================
IF OBJECT_ID('dbo.PHAN_CONG_TRONG_TAI', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PHAN_CONG_TRONG_TAI (
        MaPhanCong INT IDENTITY(1,1) NOT NULL,
        MaTranDau INT NOT NULL,
        MaTrongTai INT NOT NULL,
        NhiemVu NVARCHAR(30) NOT NULL
    );
END;
GO

-- =====================================================================
-- PHAN 2: KHOA CHINH / UNIQUE / KHOA NGOAI / CHECK
-- =====================================================================

ALTER TABLE dbo.NHAN_SU ADD CONSTRAINT PK__NHAN_SU__E5B2F0B67EAA0991 PRIMARY KEY (MaNhanSu);
GO
ALTER TABLE dbo.NHAN_SU ADD CONSTRAINT UQ__NHAN_SU__A9D10534AAC51204 UNIQUE (Email);
GO
ALTER TABLE dbo.TAI_KHOAN ADD CONSTRAINT PK__TAI_KHOA__AD7C6529F9AA7A4B PRIMARY KEY (MaTaiKhoan);
GO
ALTER TABLE dbo.TAI_KHOAN ADD CONSTRAINT UQ__TAI_KHOA__55F68FC03495413E UNIQUE (TenDangNhap);
GO
ALTER TABLE dbo.TAI_KHOAN ADD CONSTRAINT UQ__TAI_KHOA__E5B2F0B7657C9291 UNIQUE (MaNhanSu);
GO
ALTER TABLE dbo.GIAI_DAU ADD CONSTRAINT PK__GIAI_DAU__0B811B64E0FE82AF PRIMARY KEY (MaGiaiDau);
GO
ALTER TABLE dbo.SAN_VAN_DONG ADD CONSTRAINT PK__SAN_VAN___AA6E6A138181D76C PRIMARY KEY (MaSanVD);
GO
ALTER TABLE dbo.TRONG_TAI ADD CONSTRAINT PK__TRONG_TA__A79DE416D58D3412 PRIMARY KEY (MaTrongTai);
GO
ALTER TABLE dbo.VONG_DAU ADD CONSTRAINT PK__VONG_DAU__14725552E35264D1 PRIMARY KEY (MaVongDau);
GO
ALTER TABLE dbo.CLB ADD CONSTRAINT PK__CLB__3DCE036936BD10E1 PRIMARY KEY (MaCLB);
GO
ALTER TABLE dbo.CAU_THU ADD CONSTRAINT PK__CAU_THU__18362CB8962462A4 PRIMARY KEY (MaCauThu);
GO
ALTER TABLE dbo.BAN_HUAN_LUYEN ADD CONSTRAINT PK__BAN_HUAN__3C9029D8059244E4 PRIMARY KEY (MaHLV);
GO
ALTER TABLE dbo.DANG_KY_CAU_THU ADD CONSTRAINT PK__DANG_KY___BA90F02D3516EBD9 PRIMARY KEY (MaDangKy);
GO
ALTER TABLE dbo.DANG_KY_CAU_THU ADD CONSTRAINT UQ_DK_Giai_CLB_CT UNIQUE (MaGiaiDau, MaCLB, MaCauThu);
GO
ALTER TABLE dbo.BANG_XEP_HANG ADD CONSTRAINT PK__BANG_XEP__35202A7FDA1C7867 PRIMARY KEY (MaBXH);
GO
ALTER TABLE dbo.BANG_XEP_HANG ADD CONSTRAINT UQ_BXH_Vong_CLB UNIQUE (MaVongDau, MaCLB);
GO
ALTER TABLE dbo.TRAN_DAU ADD CONSTRAINT PK__TRAN_DAU__1B2FFCF3696F5627 PRIMARY KEY (MaTranDau);
GO
ALTER TABLE dbo.DOI_HINH_TRAN_DAU ADD CONSTRAINT PK__DOI_HINH__23F37FDA7517F6A4 PRIMARY KEY (MaDoiHinh);
GO
ALTER TABLE dbo.DOI_HINH_TRAN_DAU ADD CONSTRAINT UQ_DH_Tran_CT UNIQUE (MaTranDau, MaCauThu);
GO
ALTER TABLE dbo.SU_KIEN_TRAN_DAU ADD CONSTRAINT PK__SU_KIEN___C164599ECDE23A44 PRIMARY KEY (MaSuKien);
GO
ALTER TABLE dbo.PHAN_CONG_TRONG_TAI ADD CONSTRAINT PK__PHAN_CON__C279D91670855461 PRIMARY KEY (MaPhanCong);
GO
ALTER TABLE dbo.PHAN_CONG_TRONG_TAI ADD CONSTRAINT UQ_PC_Tran_TT UNIQUE (MaTranDau, MaTrongTai);
GO
ALTER TABLE dbo.BANG_XEP_HANG ADD CONSTRAINT FK_BXH_CLB FOREIGN KEY (MaCLB) REFERENCES dbo.CLB(MaCLB);
GO
ALTER TABLE dbo.BANG_XEP_HANG ADD CONSTRAINT FK_BXH_VongDau FOREIGN KEY (MaVongDau) REFERENCES dbo.VONG_DAU(MaVongDau);
GO
ALTER TABLE dbo.CAU_THU ADD CONSTRAINT FK_CauThu_CLB FOREIGN KEY (MaCLB) REFERENCES dbo.CLB(MaCLB);
GO
ALTER TABLE dbo.CLB ADD CONSTRAINT FK_CLB_SanNha FOREIGN KEY (MaSanNha) REFERENCES dbo.SAN_VAN_DONG(MaSanVD);
GO
ALTER TABLE dbo.DOI_HINH_TRAN_DAU ADD CONSTRAINT FK_DH_CauThu FOREIGN KEY (MaCauThu) REFERENCES dbo.CAU_THU(MaCauThu);
GO
ALTER TABLE dbo.DOI_HINH_TRAN_DAU ADD CONSTRAINT FK_DH_TranDau FOREIGN KEY (MaTranDau) REFERENCES dbo.TRAN_DAU(MaTranDau);
GO
ALTER TABLE dbo.DANG_KY_CAU_THU ADD CONSTRAINT FK_DK_CauThu FOREIGN KEY (MaCauThu) REFERENCES dbo.CAU_THU(MaCauThu);
GO
ALTER TABLE dbo.DANG_KY_CAU_THU ADD CONSTRAINT FK_DK_CLB FOREIGN KEY (MaCLB) REFERENCES dbo.CLB(MaCLB);
GO
ALTER TABLE dbo.DANG_KY_CAU_THU ADD CONSTRAINT FK_DK_GiaiDau FOREIGN KEY (MaGiaiDau) REFERENCES dbo.GIAI_DAU(MaGiaiDau);
GO
ALTER TABLE dbo.BAN_HUAN_LUYEN ADD CONSTRAINT FK_HLV_CLB FOREIGN KEY (MaCLB) REFERENCES dbo.CLB(MaCLB);
GO
ALTER TABLE dbo.PHAN_CONG_TRONG_TAI ADD CONSTRAINT FK_PC_TranDau FOREIGN KEY (MaTranDau) REFERENCES dbo.TRAN_DAU(MaTranDau);
GO
ALTER TABLE dbo.PHAN_CONG_TRONG_TAI ADD CONSTRAINT FK_PC_TrongTai FOREIGN KEY (MaTrongTai) REFERENCES dbo.TRONG_TAI(MaTrongTai);
GO
ALTER TABLE dbo.SU_KIEN_TRAN_DAU ADD CONSTRAINT FK_SK_Chinh FOREIGN KEY (MaCauThuChinh) REFERENCES dbo.CAU_THU(MaCauThu);
GO
ALTER TABLE dbo.SU_KIEN_TRAN_DAU ADD CONSTRAINT FK_SK_Phu FOREIGN KEY (MaCauThuPhu) REFERENCES dbo.CAU_THU(MaCauThu);
GO
ALTER TABLE dbo.SU_KIEN_TRAN_DAU ADD CONSTRAINT FK_SK_TranDau FOREIGN KEY (MaTranDau) REFERENCES dbo.TRAN_DAU(MaTranDau);
GO
ALTER TABLE dbo.TRAN_DAU ADD CONSTRAINT FK_TD_DoiKhach FOREIGN KEY (MaDoiKhach) REFERENCES dbo.CLB(MaCLB);
GO
ALTER TABLE dbo.TRAN_DAU ADD CONSTRAINT FK_TD_DoiNha FOREIGN KEY (MaDoiNha) REFERENCES dbo.CLB(MaCLB);
GO
ALTER TABLE dbo.TRAN_DAU ADD CONSTRAINT FK_TD_San FOREIGN KEY (MaSanVD) REFERENCES dbo.SAN_VAN_DONG(MaSanVD);
GO
ALTER TABLE dbo.TRAN_DAU ADD CONSTRAINT FK_TD_VongDau FOREIGN KEY (MaVongDau) REFERENCES dbo.VONG_DAU(MaVongDau);
GO
ALTER TABLE dbo.TAI_KHOAN ADD CONSTRAINT FK_TK_NhanSu FOREIGN KEY (MaNhanSu) REFERENCES dbo.NHAN_SU(MaNhanSu);
GO
ALTER TABLE dbo.VONG_DAU ADD CONSTRAINT FK_VD_GiaiDau FOREIGN KEY (MaGiaiDau) REFERENCES dbo.GIAI_DAU(MaGiaiDau);
GO
ALTER TABLE dbo.CAU_THU ADD CONSTRAINT CK__CAU_THU__LoaiCau__73852659 CHECK ([LoaiCauThu]=N'Nhập tịch' OR [LoaiCauThu]=N'Ngoại binh' OR [LoaiCauThu]=N'Nội binh');
GO
ALTER TABLE dbo.DANG_KY_CAU_THU ADD CONSTRAINT CK__DANG_KY_C__Trang__7C1A6C5A CHECK ([TrangThai]=N'NGỪNG ĐĂNG KÝ' OR [TrangThai]=N'ĐANG HOẠT ĐỘNG');
GO
ALTER TABLE dbo.DOI_HINH_TRAN_DAU ADD CONSTRAINT CK__DOI_HINH___LoaiR__17C286CF CHECK ([LoaiRaSan]=N'Dự bị' OR [LoaiRaSan]=N'Đá chính');
GO
ALTER TABLE dbo.GIAI_DAU ADD CONSTRAINT CK__GIAI_DAU__TrangT__634EBE90 CHECK ([TrangThai]=N'ĐÃ KẾT THÚC' OR [TrangThai]=N'ĐANG DIỄN RA' OR [TrangThai]=N'CHƯA BẮT ĐẦU');
GO
ALTER TABLE dbo.NHAN_SU ADD CONSTRAINT CK__NHAN_SU__GioiTin__56E8E7AB CHECK ([GioiTinh]=N'Khác' OR [GioiTinh]=N'Nữ' OR [GioiTinh]=N'Nam');
GO
ALTER TABLE dbo.PHAN_CONG_TRONG_TAI ADD CONSTRAINT CK__PHAN_CONG__Nhiem__24285DB4 CHECK ([NhiemVu]=N'VAR' OR [NhiemVu]=N'BÀN' OR [NhiemVu]=N'BIÊN' OR [NhiemVu]=N'TRỌNG TÀI CHÍNH');
GO
ALTER TABLE dbo.SU_KIEN_TRAN_DAU ADD CONSTRAINT CK__SU_KIEN_T__LoaiS__1D7B6025 CHECK ([LoaiSuKien]=N'THAY NGƯỜI' OR [LoaiSuKien]=N'THẺ ĐỎ' OR [LoaiSuKien]=N'THẺ VÀNG' OR [LoaiSuKien]=N'BÀN THẮNG');
GO
ALTER TABLE dbo.TAI_KHOAN ADD CONSTRAINT CK__TAI_KHOAN__Quyen__5D95E53A CHECK ([QuyenHan]='XEM' OR [QuyenHan]='CAPNHAT' OR [QuyenHan]='ADMIN');
GO
ALTER TABLE dbo.TRAN_DAU ADD CONSTRAINT CK__TRAN_DAU__TrangT__0E391C95 CHECK ([TrangThai]=N'HOÃN' OR [TrangThai]=N'ĐÃ KẾT THÚC' OR [TrangThai]=N'ĐANG ĐÁ' OR [TrangThai]=N'CHƯA ĐÁ');
GO
ALTER TABLE dbo.TRONG_TAI ADD CONSTRAINT CK__TRONG_TAI__CapDo__681373AD CHECK ([CapDo]=N'Cấp 2' OR [CapDo]=N'Cấp 1' OR [CapDo]=N'Quốc gia' OR [CapDo]=N'FIFA');
GO
ALTER TABLE dbo.VONG_DAU ADD CONSTRAINT CK__VONG_DAU__GiaiDo__6AEFE058 CHECK ([GiaiDoan]=N'Trụ hạng' OR [GiaiDoan]=N'Tranh vô địch' OR [GiaiDoan]=N'Lượt về' OR [GiaiDoan]=N'Lượt đi');
GO
ALTER TABLE dbo.TRAN_DAU ADD CONSTRAINT CK_TD_KhacDoi CHECK ([MaDoiNha]<>[MaDoiKhach]);
GO

-- =====================================================================
-- PHAN 3: TRIGGER
-- =====================================================================

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_BangXepHang_KhongTrungLap
ON dbo.BANG_XEP_HANG
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT bxh.MaVongDau, bxh.MaCLB
        FROM dbo.BANG_XEP_HANG bxh
        INNER JOIN inserted i
            ON  bxh.MaVongDau = i.MaVongDau
            AND bxh.MaCLB     = i.MaCLB
            AND bxh.MaBXH    <> i.MaBXH
    )
    BEGIN
        RAISERROR(N'Lỗi: CLB đã có trong bảng xếp hạng của vòng đấu này.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_CLB_XoaCLB_CapNhatCauThu
ON dbo.CLB
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Đặt MaCLB = NULL cho cầu thủ của CLB bị xóa (chuyển sang tự do)
    UPDATE dbo.CAU_THU
    SET MaCLB = NULL
    WHERE MaCLB IN (SELECT MaCLB FROM deleted);

    -- Xóa ban huấn luyện
    DELETE FROM dbo.BAN_HUAN_LUYEN
    WHERE MaCLB IN (SELECT MaCLB FROM deleted);

    -- Xóa đăng ký cầu thủ
    DELETE FROM dbo.DANG_KY_CAU_THU
    WHERE MaCLB IN (SELECT MaCLB FROM deleted);

    -- Xóa bảng xếp hạng
    DELETE FROM dbo.BANG_XEP_HANG
    WHERE MaCLB IN (SELECT MaCLB FROM deleted);

    -- Xóa các bảng con của trận đấu liên quan đến CLB
    DELETE FROM dbo.SU_KIEN_TRAN_DAU
    WHERE MaTranDau IN (
        SELECT MaTranDau FROM dbo.TRAN_DAU
        WHERE MaDoiNha IN (SELECT MaCLB FROM deleted)
           OR MaDoiKhach IN (SELECT MaCLB FROM deleted)
    );

    DELETE FROM dbo.DOI_HINH_TRAN_DAU
    WHERE MaTranDau IN (
        SELECT MaTranDau FROM dbo.TRAN_DAU
        WHERE MaDoiNha IN (SELECT MaCLB FROM deleted)
           OR MaDoiKhach IN (SELECT MaCLB FROM deleted)
    );

    DELETE FROM dbo.PHAN_CONG_TRONG_TAI
    WHERE MaTranDau IN (
        SELECT MaTranDau FROM dbo.TRAN_DAU
        WHERE MaDoiNha IN (SELECT MaCLB FROM deleted)
           OR MaDoiKhach IN (SELECT MaCLB FROM deleted)
    );

    DELETE FROM dbo.TRAN_DAU
    WHERE MaDoiNha IN (SELECT MaCLB FROM deleted)
       OR MaDoiKhach IN (SELECT MaCLB FROM deleted);

    -- Cuối cùng, xóa CLB
    DELETE FROM dbo.CLB
    WHERE MaCLB IN (SELECT MaCLB FROM deleted);
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_DangKyCauThu_CauThuChiDKMotCLBTrongGiai
ON dbo.DANG_KY_CAU_THU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.DANG_KY_CAU_THU dk
        INNER JOIN inserted i
            ON  dk.MaGiaiDau = i.MaGiaiDau
            AND dk.MaCauThu  = i.MaCauThu
            AND dk.MaCLB    <> i.MaCLB
    )
    BEGIN
        RAISERROR(N'Lỗi: Cầu thủ chỉ được đăng ký cho một CLB duy nhất trong mỗi mùa giải.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_DangKyCauThu_KhongTrungLap
ON dbo.DANG_KY_CAU_THU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT dk.MaGiaiDau, dk.MaCLB, dk.MaCauThu
        FROM dbo.DANG_KY_CAU_THU dk
        INNER JOIN inserted i
            ON  dk.MaGiaiDau = i.MaGiaiDau
            AND dk.MaCLB     = i.MaCLB
            AND dk.MaCauThu  = i.MaCauThu
            AND dk.MaDangKy <> i.MaDangKy
    )
    BEGIN
        RAISERROR(N'Lỗi: Cầu thủ đã được đăng ký cho CLB này trong mùa giải này.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_DangKyCauThu_KhongTrungSoAoTrongCLB
ON dbo.DANG_KY_CAU_THU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.DANG_KY_CAU_THU dk
        INNER JOIN inserted i
            ON  dk.MaGiaiDau = i.MaGiaiDau
            AND dk.MaCLB     = i.MaCLB
            AND dk.SoAo      = i.SoAo
            AND dk.MaDangKy <> i.MaDangKy
        WHERE i.SoAo IS NOT NULL
    )
    BEGIN
        RAISERROR(N'Lỗi: Số áo đã được đăng ký bởi cầu thủ khác của CLB trong mùa giải này.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_DoiHinhTranDau_CauThuPhaiThuocDoiThiDau
ON dbo.DOI_HINH_TRAN_DAU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.CAU_THU ct ON i.MaCauThu = ct.MaCauThu
        INNER JOIN dbo.TRAN_DAU td ON i.MaTranDau = td.MaTranDau
        WHERE ct.MaCLB IS NULL
           OR (ct.MaCLB <> td.MaDoiNha AND ct.MaCLB <> td.MaDoiKhach)
    )
    BEGIN
        RAISERROR(N'Lỗi: Cầu thủ trong đội hình phải thuộc một trong hai đội thi đấu (đội nhà hoặc đội khách).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_DoiHinhTranDau_KhongTrungLap
ON dbo.DOI_HINH_TRAN_DAU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT dh.MaTranDau, dh.MaCauThu
        FROM dbo.DOI_HINH_TRAN_DAU dh
        INNER JOIN inserted i
            ON  dh.MaTranDau = i.MaTranDau
            AND dh.MaCauThu  = i.MaCauThu
            AND dh.MaDoiHinh <> i.MaDoiHinh
    )
    BEGIN
        RAISERROR(N'Lỗi: Cầu thủ này đã có trong danh sách đội hình trận đấu này.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

CREATE TRIGGER dbo.trg_DoiHinhTranDau_ToiDaMotDoiTruongMoiDoi
ON dbo.DOI_HINH_TRAN_DAU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT dh.MaTranDau, ct.MaCLB
        FROM dbo.DOI_HINH_TRAN_DAU dh
        INNER JOIN dbo.CAU_THU ct ON dh.MaCauThu = ct.MaCauThu
        WHERE dh.DaiDoTruong = 1
          AND dh.MaTranDau IN (SELECT MaTranDau FROM inserted WHERE DaiDoTruong = 1)
        GROUP BY dh.MaTranDau, ct.MaCLB
        HAVING COUNT(*) > 1
    )
    BEGIN
        RAISERROR(N'Mỗi đội bóng trong trận đấu chỉ được phép có duy nhất 1 đội trưởng.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_PhanCongTrongTai_KhongTrungLap
ON dbo.PHAN_CONG_TRONG_TAI
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT pc.MaTranDau, pc.MaTrongTai
        FROM dbo.PHAN_CONG_TRONG_TAI pc
        INNER JOIN inserted i
            ON  pc.MaTranDau  = i.MaTranDau
            AND pc.MaTrongTai = i.MaTrongTai
            AND pc.MaPhanCong <> i.MaPhanCong
    )
    BEGIN
        RAISERROR(N'Lỗi: Trọng tài này đã được phân công cho trận đấu này.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_SuKienTranDau_CauThuChinhPhaiThuocDoiThiDau
ON dbo.SU_KIEN_TRAN_DAU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN dbo.CAU_THU ct ON i.MaCauThuChinh = ct.MaCauThu
        INNER JOIN dbo.TRAN_DAU td ON i.MaTranDau = td.MaTranDau
        WHERE ct.MaCLB IS NULL
           OR (ct.MaCLB <> td.MaDoiNha AND ct.MaCLB <> td.MaDoiKhach)
    )
    BEGIN
        RAISERROR(N'Lỗi: Cầu thủ chính của sự kiện phải thuộc một trong hai đội thi đấu.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_SuKienTranDau_KiemTraPhutHopLe
ON dbo.SU_KIEN_TRAN_DAU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE Phut < 1 OR Phut > 130
    )
    BEGIN
        RAISERROR(N'Lỗi: Phút diễn ra sự kiện không hợp lệ (phải từ phút 1 đến 130).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_SuKienTranDau_TuDongCapNhatTySo
ON dbo.SU_KIEN_TRAN_DAU
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Lấy danh sách các trận đấu bị ảnh hưởng bởi sự kiện
    DECLARE @DanhSachTran TABLE (MaTranDau INT PRIMARY KEY);

    INSERT INTO @DanhSachTran (MaTranDau)
    SELECT DISTINCT MaTranDau FROM inserted
    UNION
    SELECT DISTINCT MaTranDau FROM deleted;

    -- Cập nhật lại số bàn thắng cho từng trận đấu
    UPDATE td
    SET 
        BanThangDoiNha = ISNULL((
            SELECT COUNT(sk.MaSuKien)
            FROM dbo.SU_KIEN_TRAN_DAU sk
            INNER JOIN dbo.CAU_THU ct ON sk.MaCauThuChinh = ct.MaCauThu
            WHERE sk.MaTranDau = td.MaTranDau
              AND ct.MaCLB = td.MaDoiNha
              AND (sk.LoaiSuKien LIKE N'%BÀN THẮNG%' OR sk.LoaiSuKien LIKE N'%BAN THANG%' OR sk.LoaiSuKien LIKE N'%PENALTY%')
        ), 0),
        BanThangDoiKhach = ISNULL((
            SELECT COUNT(sk.MaSuKien)
            FROM dbo.SU_KIEN_TRAN_DAU sk
            INNER JOIN dbo.CAU_THU ct ON sk.MaCauThuChinh = ct.MaCauThu
            WHERE sk.MaTranDau = td.MaTranDau
              AND ct.MaCLB = td.MaDoiKhach
              AND (sk.LoaiSuKien LIKE N'%BÀN THẮNG%' OR sk.LoaiSuKien LIKE N'%BAN THANG%' OR sk.LoaiSuKien LIKE N'%PENALTY%')
        ), 0)
    FROM dbo.TRAN_DAU td
    INNER JOIN @DanhSachTran ds ON td.MaTranDau = ds.MaTranDau;
END;
GO

-- (da sua mojibake trong thong bao loi)
CREATE TRIGGER dbo.trg_TranDau_KhongTrungDoi
ON dbo.TRAN_DAU
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM inserted
        WHERE MaDoiNha = MaDoiKhach
    )
    BEGIN
        RAISERROR(N'Lỗi: Đội nhà và đội khách không được là cùng một CLB.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

CREATE TRIGGER dbo.trg_VongDau_XoaVongDau_Cascade
ON dbo.VONG_DAU
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.BANG_XEP_HANG
    WHERE MaVongDau IN (SELECT MaVongDau FROM deleted);

    DELETE FROM dbo.SU_KIEN_TRAN_DAU
    WHERE MaTranDau IN (
        SELECT MaTranDau FROM dbo.TRAN_DAU
        WHERE MaVongDau IN (SELECT MaVongDau FROM deleted)
    );

    DELETE FROM dbo.DOI_HINH_TRAN_DAU
    WHERE MaTranDau IN (
        SELECT MaTranDau FROM dbo.TRAN_DAU
        WHERE MaVongDau IN (SELECT MaVongDau FROM deleted)
    );

    DELETE FROM dbo.PHAN_CONG_TRONG_TAI
    WHERE MaTranDau IN (
        SELECT MaTranDau FROM dbo.TRAN_DAU
        WHERE MaVongDau IN (SELECT MaVongDau FROM deleted)
    );

    DELETE FROM dbo.TRAN_DAU
    WHERE MaVongDau IN (SELECT MaVongDau FROM deleted);

    DELETE FROM dbo.VONG_DAU
    WHERE MaVongDau IN (SELECT MaVongDau FROM deleted);
END;
GO

-- =====================================================================
-- PHAN 4: DU LIEU THAT V-LEAGUE 2024/25
-- =====================================================================

SET IDENTITY_INSERT dbo.NHAN_SU ON;
INSERT INTO dbo.NHAN_SU (MaNhanSu, HoTen, GioiTinh, NgaySinh, SoDienThoai, Email, ChucVu, TrangThaiLamViec) VALUES
(1, N'Nguyễn Văn A', N'Nam', '1980-05-12', N'0905111222', N'admin@vleague.vn', N'Trưởng ban tổ chức', 1),
(2, N'Trần Thị B', N'Nữ', '1988-09-21', N'0905333444', N'kyluat@vleague.vn', N'Trưởng ban kỷ luật', 1),
(3, N'Lê Văn C', N'Nam', '1990-01-30', N'0905555666', N'giaisat@vleague.vn', N'Giám sát trận đấu', 1),
(4, N'Phạm Minh D', N'Nam', '1995-07-07', N'0905777888', N'view@vleague.vn', N'Nhân viên văn phòng', 1);
SET IDENTITY_INSERT dbo.NHAN_SU OFF;
GO

SET IDENTITY_INSERT dbo.TAI_KHOAN ON;
INSERT INTO dbo.TAI_KHOAN (MaTaiKhoan, MaNhanSu, TenDangNhap, MatKhau, QuyenHan, TrangThaiHoatDong) VALUES
(1, 1, N'admin', N'scrypt:32768:8:1$9rTn8MHqeWSliT8f$cc35d3ca8dd02d4aad0bae8088f9c38e4d728f518899ed8fedc63862b988c64a1c817be6a58c6fcac01ffd4f284734fca96eadfc4264dda4a6279dd87c4e013a', N'ADMIN', 1),
(2, 2, N'kyluat', N'scrypt:32768:8:1$9rTn8MHqeWSliT8f$cc35d3ca8dd02d4aad0bae8088f9c38e4d728f518899ed8fedc63862b988c64a1c817be6a58c6fcac01ffd4f284734fca96eadfc4264dda4a6279dd87c4e013a', N'CAPNHAT', 1),
(4, 4, N'xem', N'scrypt:32768:8:1$9rTn8MHqeWSliT8f$cc35d3ca8dd02d4aad0bae8088f9c38e4d728f518899ed8fedc63862b988c64a1c817be6a58c6fcac01ffd4f284734fca96eadfc4264dda4a6279dd87c4e013a', N'XEM', 1),
(5, 3, N'giaisat', N'scrypt:32768:8:1$JVJBNakAG5ifxE8Z$5016360a0cdc3d5ea39d7e7ceb3c786f78f1c7dc3c7ae9273aa27edbbd2741bbfd227a8c486405f8649aaa84731e726989df2b28fc9e97e2c4bab2eed5c36948', N'CAPNHAT', 1);
SET IDENTITY_INSERT dbo.TAI_KHOAN OFF;
GO

SET IDENTITY_INSERT dbo.GIAI_DAU ON;
INSERT INTO dbo.GIAI_DAU (MaGiaiDau, TenGiai, NamBatDau, NamKetThuc, NgayKhaiMac, NgayBeMac, TrangThai) VALUES
(1, N'LPBank V-League 1-2024/25', 2024, 2025, '2024-09-14', '2025-06-22', N'ĐÃ KẾT THÚC');
SET IDENTITY_INSERT dbo.GIAI_DAU OFF;
GO

SET IDENTITY_INSERT dbo.SAN_VAN_DONG ON;
INSERT INTO dbo.SAN_VAN_DONG (MaSanVD, TenSan, SucChua, DiaChi) VALUES
(1, N'Mỹ Đình', 40200, N'Hà Nội'),
(2, N'Hàng Đẫy', 22500, N'Hà Nội'),
(3, N'Lạch Tray', 30000, N'Hải Phòng'),
(4, N'Thống Nhất', 16000, N'TP. Hồ Chí Minh'),
(5, N'Pleiku', 12000, N'Gia Lai'),
(6, N'Vinh', 18000, N'Nghệ An'),
(7, N'Thiên Trường', 30000, N'Nam Định'),
(8, N'Hòa Xuân', 20500, N'Đà Nẵng'),
(9, N'Gò Đậu', 13035, N'Bình Dương'),
(10, N'Thanh Hóa', 12000, N'Thanh Hóa'),
(11, N'Hà Tĩnh', 20000, N'Hà Tĩnh'),
(12, N'Tam Kỳ', 15000, N'Quảng Nam'),
(13, N'Quy Nhơn', 15000, N'Bình Định');
SET IDENTITY_INSERT dbo.SAN_VAN_DONG OFF;
GO

SET IDENTITY_INSERT dbo.TRONG_TAI ON;
INSERT INTO dbo.TRONG_TAI (MaTrongTai, HoTen, CapDo) VALUES
(1, N'Nguyễn Trọng Thư', N'FIFA'),
(2, N'Mai Hoàng Hùng', N'FIFA'),
(3, N'Hoàng Ngọc Tuấn', N'Quốc gia'),
(4, N'Trương Hồng Vũ', N'Quốc gia'),
(5, N'Nguyễn Đình Thái', N'Cấp 1'),
(6, N'Lưu Xuân Niêm', N'FIFA');
SET IDENTITY_INSERT dbo.TRONG_TAI OFF;
GO

SET IDENTITY_INSERT dbo.VONG_DAU ON;
INSERT INTO dbo.VONG_DAU (MaVongDau, MaGiaiDau, TenVong, GiaiDoan) VALUES
(1, 1, N'Vòng 1', N'Lượt đi'),
(2, 1, N'Vòng 2', N'Lượt đi'),
(3, 1, N'Vòng 3', N'Lượt đi'),
(4, 1, N'Vòng 4', N'Lượt đi'),
(5, 1, N'Vòng 5', N'Lượt đi'),
(6, 1, N'Vòng 6', N'Lượt đi'),
(7, 1, N'Vòng 7', N'Lượt đi'),
(8, 1, N'Vòng 8', N'Lượt đi'),
(9, 1, N'Vòng 9', N'Lượt đi'),
(10, 1, N'Vòng 10', N'Lượt đi'),
(11, 1, N'Vòng 11', N'Lượt đi'),
(12, 1, N'Vòng 12', N'Lượt đi'),
(13, 1, N'Vòng 13', N'Lượt đi'),
(14, 1, N'Vòng 14', N'Lượt về'),
(15, 1, N'Vòng 15', N'Lượt về'),
(16, 1, N'Vòng 16', N'Lượt về'),
(17, 1, N'Vòng 17', N'Lượt về'),
(18, 1, N'Vòng 18', N'Lượt về'),
(19, 1, N'Vòng 19', N'Lượt về'),
(20, 1, N'Vòng 20', N'Lượt về'),
(21, 1, N'Vòng 21', N'Lượt về'),
(22, 1, N'Vòng 22', N'Lượt về'),
(23, 1, N'Vòng 23', N'Lượt về'),
(24, 1, N'Vòng 24', N'Lượt về'),
(25, 1, N'Vòng 25', N'Lượt về'),
(26, 1, N'Vòng 26', N'Lượt về');
SET IDENTITY_INSERT dbo.VONG_DAU OFF;
GO

SET IDENTITY_INSERT dbo.CLB ON;
INSERT INTO dbo.CLB (MaCLB, TenCLB, Logo, MaSanNha, TenVietTom) VALUES
(1, N'CLB Becamex Bình Dương', N'🔵', 9, N'BBD'),
(2, N'CLB Đông Á Thanh Hóa', N'🟡', 10, N'DTH'),
(3, N'CLB Hải Phòng', N'🟥', 3, N'HPG'),
(4, N'CLB Công An Hà Nội', N'🟢', 2, N'CAHN'),
(5, N'Câu lạc bộ Bóng đá Hà Nội', N'🟣', 2, N'HAN'),
(6, N'CLB Thể Công-Viettel', N'🔴', 1, N'TCV'),
(7, N'CLB Thành phố Hồ Chí Minh', N'⚪', 4, N'HCM'),
(8, N'CLB Hoàng Anh Gia Lai', N'🟨', 5, N'HGL'),
(9, N'CLB Hồng Lĩnh Hà Tĩnh', N'🟧', 11, N'HHT'),
(10, N'CLB Quảng Nam', N'🔷', 12, N'QNA'),
(11, N'CLB Quy Nhơn Bình Định', N'🟠', 13, N'QBD'),
(12, N'CLB SHB Đà Nẵng', N'🔶', 8, N'SDN'),
(13, N'CLB Sông Lam Nghệ An', N'💛', 6, N'SNA'),
(14, N'CLB Thép Xanh Nam Định', N'🟩', 7, N'TND');
SET IDENTITY_INSERT dbo.CLB OFF;
GO

SET IDENTITY_INSERT dbo.CAU_THU ON;
INSERT INTO dbo.CAU_THU (MaCauThu, HoTen, NgaySinh, QuocTich, LoaiCauThu, ViTriSoTruong, MaCLB) VALUES
(1, N'Nguyễn Tiến Linh', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 1),
(2, N'Bùi Vĩ Hào', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 1),
(3, N'Nguyễn Trần Việt Cường', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 1),
(4, N'Ribamar', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 2),
(5, N'Doãn Ngọc Tân', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 2),
(6, N'Lê Văn Thắng', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 2),
(7, N'Lucão do Break', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 3),
(8, N'Triệu Việt Hưng', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 3),
(9, N'Joseph Mpande', NULL, N'Uganda', N'Ngoại binh', N'Tiền vệ', 3),
(10, N'Alan Grafite', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 4),
(11, N'Léo Artur', NULL, N'Brazil', N'Ngoại binh', N'Tiền vệ', 4),
(12, N'Nguyễn Quang Hải', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 4),
(13, N'Phan Văn Đức', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 4),
(14, N'Bùi Hoàng Việt Anh', NULL, N'Việt Nam', N'Nội binh', N'Trung vệ', 4),
(15, N'João Pedro', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 5),
(16, N'Nguyễn Văn Quyết', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 5),
(17, N'Daniel Passira', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 5),
(18, N'Phạm Tuấn Hải', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 5),
(19, N'Đỗ Hùng Dũng', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 5),
(20, N'Đỗ Duy Mạnh', NULL, N'Việt Nam', N'Nội binh', N'Trung vệ', 5),
(21, N'Pedro Henrique', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 6),
(22, N'Amarildo Junior', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 6),
(23, N'Wesley Nata', NULL, N'Brazil', N'Ngoại binh', N'Tiền vệ', 6),
(24, N'Nhâm Mạnh Dũng', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 6),
(25, N'Khuất Văn Khang', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 6),
(26, N'Bùi Tiến Dũng', NULL, N'Việt Nam', N'Nội binh', N'Trung vệ', 6),
(27, N'Erik Sorga', NULL, N'Estonia', N'Ngoại binh', N'Tiền đạo', 7),
(28, N'Endrick', NULL, N'Malaysia', N'Ngoại binh', N'Tiền vệ', 7),
(29, N'Nguyễn Hạ Long', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 7),
(30, N'Trần Minh Vương', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 8),
(31, N'Dụng Quang Nho', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 8),
(32, N'Châu Ngọc Quang', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 8),
(33, N'Trần Bảo Toàn', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 8),
(34, N'Đinh Thanh Bình', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 8),
(35, N'Nguyễn Trọng Hoàng', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 9),
(36, N'Trần Phi Sơn', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 9),
(37, N'Nguyễn Văn Vĩ', NULL, N'Việt Nam', N'Nội binh', N'Hậu vệ', 9),
(38, N'Charles Atshimene', NULL, N'Nigeria', N'Ngoại binh', N'Tiền đạo', 10),
(39, N'Ngân Văn Đại', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 10),
(40, N'Hoàng Vũ Samson', NULL, N'Nigeria', N'Ngoại binh', N'Tiền đạo', 10),
(41, N'Cao Văn Triền', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 11),
(42, N'Lê Minh Tuấn', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 11),
(43, N'Alisson Alves Farias', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 11),
(44, N'Argolo Morbeck', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 11),
(45, N'Werick Caetano', NULL, N'Brazil', N'Ngoại binh', N'Tiền vệ', 12),
(46, N'Thiago Henrique', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 12),
(47, N'Đặng Anh Tuấn', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 12),
(48, N'Phan Văn Long', NULL, N'Việt Nam', N'Nội binh', N'Tiền đạo', 12),
(49, N'Michael Olaha', NULL, N'Nigeria', N'Ngoại binh', N'Tiền đạo', 13),
(50, N'Hồ Văn Cường', NULL, N'Việt Nam', N'Nội binh', N'Hậu vệ', 13),
(51, N'Phan Bá Quyền', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 13),
(52, N'Nguyễn Xuân Son', NULL, N'Việt Nam', N'Nhập tịch', N'Tiền đạo', 14),
(53, N'Hendrio', NULL, N'Brazil', N'Ngoại binh', N'Tiền vệ', 14),
(54, N'Caio Cesar', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 14),
(55, N'Brenner', NULL, N'Brazil', N'Ngoại binh', N'Tiền đạo', 14),
(56, N'Tô Văn Vũ', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 14),
(57, N'Lý Công Hoàng Anh', NULL, N'Việt Nam', N'Nội binh', N'Tiền vệ', 14);
SET IDENTITY_INSERT dbo.CAU_THU OFF;
GO

SET IDENTITY_INSERT dbo.BAN_HUAN_LUYEN ON;
INSERT INTO dbo.BAN_HUAN_LUYEN (MaHLV, HoTen, QuocTich, ChucVu, BangCap, MaCLB) VALUES
(1, N'Nguyễn Anh Đức', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 1),
(2, N'Tomislav Steinbrückner', N'Croatia', N'Huấn luyện viên trưởng', N'AFC Pro', 2),
(3, N'Chu Đình Nghiêm', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 3),
(4, N'Alexandré Pölking', N'Brazil', N'Huấn luyện viên trưởng', N'AFC Pro', 4),
(5, N'Makoto Teguramori', N'Nhật Bản', N'Huấn luyện viên trưởng', N'AFC Pro', 5),
(6, N'Velizar Popov', N'Bulgaria', N'Huấn luyện viên trưởng', N'AFC Pro', 6),
(7, N'Phùng Thanh Phương', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 7),
(8, N'Lê Quang Trãi', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 8),
(9, N'Nguyễn Thành Công', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 9),
(10, N'Văn Sỹ Sơn', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 10),
(11, N'Trần Minh Chiến', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 11),
(12, N'Lê Đức Tuấn', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 12),
(13, N'Phan Như Thuật', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 13),
(14, N'Vũ Hồng Việt', N'Việt Nam', N'Huấn luyện viên trưởng', N'AFC Pro', 14);
SET IDENTITY_INSERT dbo.BAN_HUAN_LUYEN OFF;
GO

SET IDENTITY_INSERT dbo.DANG_KY_CAU_THU ON;
INSERT INTO dbo.DANG_KY_CAU_THU (MaDangKy, MaGiaiDau, MaCLB, MaCauThu, SoAo, ViTriDangKy, TrangThai) VALUES
(1, 1, 1, 1, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(2, 1, 1, 2, 3, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(3, 1, 1, 3, 4, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(4, 1, 2, 4, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(5, 1, 2, 5, 3, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(6, 1, 2, 6, 4, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(7, 1, 3, 7, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(8, 1, 3, 8, 3, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(9, 1, 3, 9, 4, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(10, 1, 4, 10, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(11, 1, 4, 11, 3, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(12, 1, 4, 12, 4, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(13, 1, 4, 13, 5, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(14, 1, 4, 14, 6, N'Trung vệ', N'ĐANG HOẠT ĐỘNG'),
(15, 1, 5, 15, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(16, 1, 5, 16, 3, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(17, 1, 5, 17, 4, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(18, 1, 5, 18, 5, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(19, 1, 5, 19, 6, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(20, 1, 5, 20, 7, N'Trung vệ', N'ĐANG HOẠT ĐỘNG'),
(21, 1, 6, 21, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(22, 1, 6, 22, 3, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(23, 1, 6, 23, 4, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(24, 1, 6, 24, 5, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(25, 1, 6, 25, 6, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(26, 1, 6, 26, 7, N'Trung vệ', N'ĐANG HOẠT ĐỘNG'),
(27, 1, 7, 27, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(28, 1, 7, 28, 3, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(29, 1, 7, 29, 4, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(30, 1, 8, 30, 2, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(31, 1, 8, 31, 3, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(32, 1, 8, 32, 4, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(33, 1, 8, 33, 5, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(34, 1, 8, 34, 6, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(35, 1, 9, 35, 2, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(36, 1, 9, 36, 3, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(37, 1, 9, 37, 4, N'Hậu vệ', N'ĐANG HOẠT ĐỘNG'),
(38, 1, 10, 38, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(39, 1, 10, 39, 3, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(40, 1, 10, 40, 4, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(41, 1, 11, 41, 2, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(42, 1, 11, 42, 3, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(43, 1, 11, 43, 4, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(44, 1, 11, 44, 5, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(45, 1, 12, 45, 2, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(46, 1, 12, 46, 3, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(47, 1, 12, 47, 4, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(48, 1, 12, 48, 5, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(49, 1, 13, 49, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(50, 1, 13, 50, 3, N'Hậu vệ', N'ĐANG HOẠT ĐỘNG'),
(51, 1, 13, 51, 4, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(52, 1, 14, 52, 2, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(53, 1, 14, 53, 3, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(54, 1, 14, 54, 4, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(55, 1, 14, 55, 5, N'Tiền đạo', N'ĐANG HOẠT ĐỘNG'),
(56, 1, 14, 56, 6, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG'),
(57, 1, 14, 57, 7, N'Tiền vệ', N'ĐANG HOẠT ĐỘNG');
SET IDENTITY_INSERT dbo.DANG_KY_CAU_THU OFF;
GO

SET IDENTITY_INSERT dbo.BANG_XEP_HANG ON;
INSERT INTO dbo.BANG_XEP_HANG (MaBXH, MaVongDau, MaCLB, SoTranDaDau, SoTranThang, SoTranHoa, SoTranThua, TongBanThang, TongBanThua, DiemFairPlay, ThuHang, DiemSo, HieuSo) VALUES
(1, 26, 14, 26, 17, 6, 3, 51, 18, 0, 1, 0, 0),
(2, 26, 5, 26, 14, 7, 5, 46, 25, 0, 2, 0, 0),
(3, 26, 4, 26, 12, 9, 5, 45, 23, 0, 3, 0, 0),
(4, 26, 6, 26, 12, 8, 6, 43, 29, 0, 4, 0, 0),
(5, 26, 9, 26, 7, 15, 4, 24, 20, 0, 5, 0, 0),
(6, 26, 3, 26, 9, 8, 9, 29, 27, 0, 6, 0, 0),
(7, 26, 1, 26, 9, 5, 12, 31, 40, 0, 7, 0, 0),
(8, 26, 2, 26, 7, 10, 9, 32, 33, 0, 8, 0, 0),
(9, 26, 8, 26, 7, 8, 11, 34, 41, 0, 9, 0, 0),
(10, 26, 7, 26, 6, 10, 10, 19, 36, 0, 10, 0, 0),
(11, 26, 10, 26, 5, 11, 10, 27, 36, 0, 11, 0, 0),
(12, 26, 13, 26, 5, 11, 10, 22, 36, 0, 12, 0, 0),
(13, 26, 12, 26, 5, 10, 11, 24, 42, 0, 13, 0, 0),
(14, 26, 11, 26, 5, 6, 15, 22, 43, 0, 14, 0, 0);
SET IDENTITY_INSERT dbo.BANG_XEP_HANG OFF;
GO

SET IDENTITY_INSERT dbo.TRAN_DAU ON;
INSERT INTO dbo.TRAN_DAU (MaTranDau, MaVongDau, MaDoiNha, MaDoiKhach, MaSanVD, NgayGioThiDau, TrangThai, BanThangDoiNha, BanThangDoiKhach) VALUES
(1, 1, 1, 14, 9, '2024-09-14 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(2, 1, 2, 13, 10, '2024-09-14 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(3, 1, 3, 12, 3, '2024-09-14 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(4, 1, 4, 11, 2, '2024-09-14 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(5, 1, 5, 10, 2, '2024-09-14 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(6, 1, 6, 9, 1, '2024-09-14 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(7, 1, 7, 8, 4, '2024-09-14 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(8, 2, 1, 13, 9, '2024-09-24 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(9, 2, 14, 12, 7, '2024-09-24 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(10, 2, 2, 11, 10, '2024-09-24 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(11, 2, 3, 10, 3, '2024-09-24 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(12, 2, 4, 9, 2, '2024-09-24 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(13, 2, 5, 8, 2, '2024-09-24 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(14, 2, 6, 7, 1, '2024-09-24 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(15, 3, 1, 12, 9, '2024-10-04 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(16, 3, 13, 11, 6, '2024-10-04 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(17, 3, 14, 10, 7, '2024-10-04 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(18, 3, 2, 9, 10, '2024-10-04 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(19, 3, 3, 8, 3, '2024-10-04 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(20, 3, 4, 7, 2, '2024-10-04 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(21, 3, 5, 6, 2, '2024-10-04 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(22, 4, 1, 11, 9, '2024-10-14 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(23, 4, 12, 10, 8, '2024-10-14 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(24, 4, 13, 9, 6, '2024-10-14 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(25, 4, 14, 8, 7, '2024-10-14 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(26, 4, 2, 7, 10, '2024-10-14 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(27, 4, 3, 6, 3, '2024-10-14 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(28, 4, 4, 5, 2, '2024-10-14 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(29, 5, 1, 10, 9, '2024-10-24 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(30, 5, 11, 9, 13, '2024-10-24 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(31, 5, 12, 8, 8, '2024-10-24 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(32, 5, 13, 7, 6, '2024-10-24 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(33, 5, 14, 6, 7, '2024-10-24 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(34, 5, 2, 5, 10, '2024-10-24 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(35, 5, 3, 4, 3, '2024-10-24 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(36, 6, 1, 9, 9, '2024-11-03 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(37, 6, 10, 8, 12, '2024-11-03 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(38, 6, 11, 7, 13, '2024-11-03 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(39, 6, 12, 6, 8, '2024-11-03 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(40, 6, 13, 5, 6, '2024-11-03 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(41, 6, 14, 4, 7, '2024-11-03 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(42, 6, 2, 3, 10, '2024-11-03 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(43, 7, 1, 8, 9, '2024-11-13 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(44, 7, 9, 7, 11, '2024-11-13 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(45, 7, 10, 6, 12, '2024-11-13 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(46, 7, 11, 5, 13, '2024-11-13 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(47, 7, 12, 4, 8, '2024-11-13 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(48, 7, 13, 3, 6, '2024-11-13 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(49, 7, 14, 2, 7, '2024-11-13 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(50, 8, 1, 7, 9, '2024-11-23 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(51, 8, 8, 6, 5, '2024-11-23 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(52, 8, 9, 5, 11, '2024-11-23 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(53, 8, 10, 4, 12, '2024-11-23 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(54, 8, 11, 3, 13, '2024-11-23 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(55, 8, 12, 2, 8, '2024-11-23 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(56, 8, 13, 14, 6, '2024-11-23 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(57, 9, 1, 6, 9, '2024-12-03 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(58, 9, 7, 5, 4, '2024-12-03 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(59, 9, 8, 4, 5, '2024-12-03 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(60, 9, 9, 3, 11, '2024-12-03 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(61, 9, 10, 2, 12, '2024-12-03 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(62, 9, 11, 14, 13, '2024-12-03 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(63, 9, 12, 13, 8, '2024-12-03 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(64, 10, 1, 5, 9, '2025-01-12 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(65, 10, 6, 4, 1, '2025-01-12 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(66, 10, 7, 3, 4, '2025-01-12 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(67, 10, 8, 2, 5, '2025-01-12 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(68, 10, 9, 14, 11, '2025-01-12 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(69, 10, 10, 13, 12, '2025-01-12 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(70, 10, 11, 12, 13, '2025-01-12 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(71, 11, 1, 4, 9, '2025-01-22 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(72, 11, 5, 3, 2, '2025-01-22 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(73, 11, 6, 2, 1, '2025-01-22 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(74, 11, 7, 14, 4, '2025-01-22 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(75, 11, 8, 13, 5, '2025-01-22 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(76, 11, 9, 12, 11, '2025-01-22 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(77, 11, 10, 11, 12, '2025-01-22 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(78, 12, 1, 3, 9, '2025-02-01 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(79, 12, 4, 2, 2, '2025-02-01 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(80, 12, 5, 14, 2, '2025-02-01 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(81, 12, 6, 13, 1, '2025-02-01 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(82, 12, 7, 12, 4, '2025-02-01 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(83, 12, 8, 11, 5, '2025-02-01 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(84, 12, 9, 10, 11, '2025-02-01 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(85, 13, 1, 2, 9, '2025-02-11 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(86, 13, 3, 14, 3, '2025-02-11 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(87, 13, 4, 13, 2, '2025-02-11 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(88, 13, 5, 12, 2, '2025-02-11 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(89, 13, 6, 11, 1, '2025-02-11 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(90, 13, 7, 10, 4, '2025-02-11 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(91, 13, 8, 9, 5, '2025-02-11 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(92, 14, 14, 1, 7, '2025-02-21 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(93, 14, 13, 2, 6, '2025-02-21 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(94, 14, 12, 3, 8, '2025-02-21 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(95, 14, 11, 4, 13, '2025-02-21 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(96, 14, 10, 5, 12, '2025-02-21 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(97, 14, 9, 6, 11, '2025-02-21 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(98, 14, 8, 7, 5, '2025-02-21 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(99, 15, 13, 1, 6, '2025-03-03 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(100, 15, 12, 14, 8, '2025-03-03 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(101, 15, 11, 2, 13, '2025-03-03 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(102, 15, 10, 3, 12, '2025-03-03 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(103, 15, 9, 4, 11, '2025-03-03 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(104, 15, 8, 5, 5, '2025-03-03 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(105, 15, 7, 6, 4, '2025-03-03 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(106, 16, 12, 1, 8, '2025-03-13 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(107, 16, 11, 13, 13, '2025-03-13 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(108, 16, 10, 14, 12, '2025-03-13 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(109, 16, 9, 2, 11, '2025-03-13 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(110, 16, 8, 3, 5, '2025-03-13 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(111, 16, 7, 4, 4, '2025-03-13 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(112, 16, 6, 5, 1, '2025-03-13 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(113, 17, 11, 1, 13, '2025-03-23 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(114, 17, 10, 12, 12, '2025-03-23 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(115, 17, 9, 13, 11, '2025-03-23 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(116, 17, 8, 14, 5, '2025-03-23 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(117, 17, 7, 2, 4, '2025-03-23 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(118, 17, 6, 3, 1, '2025-03-23 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(119, 17, 5, 4, 2, '2025-03-23 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(120, 18, 10, 1, 12, '2025-04-02 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(121, 18, 9, 11, 11, '2025-04-02 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(122, 18, 8, 12, 5, '2025-04-02 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(123, 18, 7, 13, 4, '2025-04-02 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(124, 18, 6, 14, 1, '2025-04-02 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(125, 18, 5, 2, 2, '2025-04-02 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(126, 18, 4, 3, 2, '2025-04-02 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(127, 19, 9, 1, 11, '2025-04-12 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(128, 19, 8, 10, 5, '2025-04-12 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(129, 19, 7, 11, 4, '2025-04-12 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(130, 19, 6, 12, 1, '2025-04-12 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(131, 19, 5, 13, 2, '2025-04-12 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(132, 19, 4, 14, 2, '2025-04-12 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(133, 19, 3, 2, 3, '2025-04-12 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(134, 20, 8, 1, 5, '2025-04-22 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(135, 20, 7, 9, 4, '2025-04-22 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(136, 20, 6, 10, 1, '2025-04-22 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(137, 20, 5, 11, 2, '2025-04-22 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(138, 20, 4, 12, 2, '2025-04-22 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(139, 20, 3, 13, 3, '2025-04-22 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(140, 20, 2, 14, 10, '2025-04-22 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(141, 21, 7, 1, 4, '2025-05-02 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(142, 21, 6, 8, 1, '2025-05-02 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(143, 21, 5, 9, 2, '2025-05-02 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(144, 21, 4, 10, 2, '2025-05-02 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(145, 21, 3, 11, 3, '2025-05-02 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(146, 21, 2, 12, 10, '2025-05-02 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(147, 21, 14, 13, 7, '2025-05-02 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(148, 22, 6, 1, 1, '2025-05-12 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(149, 22, 5, 7, 2, '2025-05-12 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(150, 22, 4, 8, 2, '2025-05-12 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(151, 22, 3, 9, 3, '2025-05-12 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(152, 22, 2, 10, 10, '2025-05-12 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(153, 22, 14, 11, 7, '2025-05-12 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(154, 22, 13, 12, 6, '2025-05-12 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(155, 23, 5, 1, 2, '2025-05-22 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(156, 23, 4, 6, 2, '2025-05-22 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(157, 23, 3, 7, 3, '2025-05-22 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(158, 23, 2, 8, 10, '2025-05-22 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(159, 23, 14, 9, 7, '2025-05-22 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(160, 23, 13, 10, 6, '2025-05-22 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(161, 23, 12, 11, 8, '2025-05-22 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(162, 24, 4, 1, 2, '2025-06-01 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(163, 24, 3, 5, 3, '2025-06-01 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(164, 24, 2, 6, 10, '2025-06-01 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(165, 24, 14, 7, 7, '2025-06-01 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(166, 24, 13, 8, 6, '2025-06-01 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(167, 24, 12, 9, 8, '2025-06-01 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(168, 24, 11, 10, 13, '2025-06-01 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(169, 25, 3, 1, 3, '2025-06-11 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(170, 25, 2, 4, 10, '2025-06-11 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(171, 25, 14, 5, 7, '2025-06-11 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(172, 25, 13, 6, 6, '2025-06-11 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(173, 25, 12, 7, 8, '2025-06-11 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(174, 25, 11, 8, 13, '2025-06-11 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(175, 25, 10, 9, 12, '2025-06-11 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(176, 26, 2, 1, 10, '2025-06-21 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(177, 26, 14, 3, 7, '2025-06-21 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(178, 26, 13, 4, 6, '2025-06-21 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(179, 26, 12, 5, 8, '2025-06-21 18:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(180, 26, 11, 6, 13, '2025-06-21 19:15:00', N'ĐÃ KẾT THÚC', 0, 0),
(181, 26, 10, 7, 12, '2025-06-21 17:00:00', N'ĐÃ KẾT THÚC', 0, 0),
(182, 26, 9, 8, 11, '2025-06-21 18:00:00', N'ĐÃ KẾT THÚC', 0, 0);
SET IDENTITY_INSERT dbo.TRAN_DAU OFF;
GO

SET IDENTITY_INSERT dbo.SU_KIEN_TRAN_DAU ON;
INSERT INTO dbo.SU_KIEN_TRAN_DAU (MaSuKien, MaTranDau, LoaiSuKien, Phut, MaCauThuChinh, MaCauThuPhu) VALUES
(1, 1, N'BÀN THẮNG', 12, 1, NULL),
(2, 1, N'BÀN THẮNG', 49, 52, NULL),
(3, 1, N'BÀN THẮNG', 86, 52, 53),
(4, 1, N'BÀN THẮNG', 45, 52, NULL),
(5, 1, N'BÀN THẮNG', 82, 53, NULL),
(6, 2, N'BÀN THẮNG', 23, 4, NULL),
(7, 2, N'BÀN THẮNG', 60, 49, NULL),
(8, 3, N'BÀN THẮNG', 34, 7, NULL),
(9, 4, N'BÀN THẮNG', 45, 10, NULL),
(10, 4, N'BÀN THẮNG', 82, 10, NULL),
(11, 4, N'BÀN THẮNG', 41, 10, 11),
(12, 5, N'BÀN THẮNG', 56, 15, NULL),
(13, 5, N'BÀN THẮNG', 15, 15, NULL),
(14, 5, N'BÀN THẮNG', 52, 38, 39),
(15, 6, N'BÀN THẮNG', 67, 21, NULL),
(16, 6, N'BÀN THẮNG', 26, 35, NULL),
(17, 7, N'BÀN THẮNG', 78, 27, NULL),
(18, 8, N'BÀN THẮNG', 89, 1, NULL),
(19, 8, N'BÀN THẮNG', 48, 1, NULL),
(20, 8, N'BÀN THẮNG', 85, 50, 49),
(21, 9, N'BÀN THẮNG', 22, 52, NULL),
(22, 9, N'BÀN THẮNG', 59, 52, NULL),
(23, 9, N'BÀN THẮNG', 18, 52, 53),
(24, 9, N'BÀN THẮNG', 55, 54, NULL),
(25, 9, N'BÀN THẮNG', 14, 55, NULL),
(26, 10, N'BÀN THẮNG', 33, 4, NULL),
(27, 10, N'BÀN THẮNG', 70, 41, NULL),
(28, 11, N'BÀN THẮNG', 44, 38, NULL),
(29, 13, N'BÀN THẮNG', 66, 30, NULL),
(30, 14, N'BÀN THẮNG', 77, 21, NULL),
(31, 14, N'BÀN THẮNG', 36, 21, NULL),
(32, 15, N'BÀN THẮNG', 88, 1, NULL),
(33, 15, N'BÀN THẮNG', 47, 45, NULL),
(34, 16, N'BÀN THẮNG', 21, 51, NULL),
(35, 17, N'BÀN THẮNG', 32, 52, NULL),
(36, 18, N'BÀN THẮNG', 43, 4, NULL),
(37, 18, N'BÀN THẮNG', 80, 36, NULL),
(38, 19, N'BÀN THẮNG', 54, 7, NULL),
(39, 19, N'BÀN THẮNG', 13, 7, NULL),
(40, 21, N'BÀN THẮNG', 76, 16, NULL),
(41, 21, N'BÀN THẮNG', 35, 21, NULL),
(42, 21, N'BÀN THẮNG', 72, 21, 22),
(43, 22, N'BÀN THẮNG', 87, 1, NULL),
(44, 22, N'BÀN THẮNG', 46, 1, NULL),
(45, 22, N'BÀN THẮNG', 83, 42, 41),
(46, 23, N'BÀN THẮNG', 20, 45, NULL),
(47, 24, N'BÀN THẮNG', 31, 49, NULL),
(48, 24, N'BÀN THẮNG', 68, 37, NULL),
(49, 25, N'BÀN THẮNG', 42, 56, NULL),
(50, 25, N'BÀN THẮNG', 79, 57, NULL),
(51, 25, N'BÀN THẮNG', 38, 53, 52),
(52, 25, N'BÀN THẮNG', 75, 54, NULL),
(53, 25, N'BÀN THẮNG', 34, 55, NULL),
(54, 25, N'BÀN THẮNG', 71, 56, 52),
(55, 25, N'BÀN THẮNG', 30, 31, NULL),
(56, 26, N'BÀN THẮNG', 53, 4, NULL),
(57, 26, N'BÀN THẮNG', 12, 28, NULL),
(58, 26, N'BÀN THẮNG', 49, 29, 27),
(59, 27, N'BÀN THẮNG', 64, 7, NULL),
(60, 27, N'BÀN THẮNG', 23, 7, NULL),
(61, 27, N'BÀN THẮNG', 60, 21, 22),
(62, 27, N'BÀN THẮNG', 19, 21, NULL),
(63, 27, N'BÀN THẮNG', 56, 21, NULL),
(64, 28, N'BÀN THẮNG', 75, 17, NULL),
(65, 28, N'BÀN THẮNG', 34, 15, NULL),
(66, 30, N'BÀN THẮNG', 19, 35, NULL),
(67, 31, N'BÀN THẮNG', 30, 45, NULL),
(68, 31, N'BÀN THẮNG', 67, 32, NULL),
(69, 33, N'BÀN THẮNG', 52, 21, NULL),
(70, 34, N'BÀN THẮNG', 63, 4, NULL),
(71, 34, N'BÀN THẮNG', 22, 16, NULL),
(72, 35, N'BÀN THẮNG', 74, 7, NULL),
(73, 35, N'BÀN THẮNG', 33, 10, NULL),
(74, 36, N'BÀN THẮNG', 85, 1, NULL),
(75, 36, N'BÀN THẮNG', 44, 1, NULL),
(76, 36, N'BÀN THẮNG', 81, 36, 35),
(77, 36, N'BÀN THẮNG', 40, 37, NULL),
(78, 37, N'BÀN THẮNG', 18, 33, NULL),
(79, 37, N'BÀN THẮNG', 55, 34, NULL),
(80, 37, N'BÀN THẮNG', 14, 30, 31),
(81, 37, N'BÀN THẮNG', 51, 31, NULL),
(82, 38, N'BÀN THẮNG', 29, 43, NULL),
(83, 38, N'BÀN THẮNG', 66, 27, NULL),
(84, 38, N'BÀN THẮNG', 25, 28, 27),
(85, 39, N'BÀN THẮNG', 40, 46, NULL),
(86, 39, N'BÀN THẮNG', 77, 21, NULL),
(87, 40, N'BÀN THẮNG', 51, 50, NULL),
(88, 40, N'BÀN THẮNG', 88, 17, NULL),
(89, 40, N'BÀN THẮNG', 47, 15, 16),
(90, 41, N'BÀN THẮNG', 62, 11, NULL),
(91, 41, N'BÀN THẮNG', 21, 10, NULL),
(92, 41, N'BÀN THẮNG', 58, 11, 10),
(93, 42, N'BÀN THẮNG', 73, 4, NULL),
(94, 42, N'BÀN THẮNG', 32, 4, NULL),
(95, 42, N'BÀN THẮNG', 69, 4, 5),
(96, 42, N'BÀN THẮNG', 28, 7, NULL),
(97, 43, N'BÀN THẮNG', 84, 1, NULL),
(98, 43, N'BÀN THẮNG', 43, 1, NULL),
(99, 43, N'BÀN THẮNG', 80, 1, 2),
(100, 43, N'BÀN THẮNG', 39, 2, NULL),
(101, 43, N'BÀN THẮNG', 76, 32, NULL),
(102, 44, N'BÀN THẮNG', 17, 35, NULL),
(103, 44, N'BÀN THẮNG', 54, 29, NULL),
(104, 46, N'BÀN THẮNG', 39, 44, NULL),
(105, 46, N'BÀN THẮNG', 76, 41, NULL),
(106, 46, N'BÀN THẮNG', 35, 16, 15),
(107, 46, N'BÀN THẮNG', 72, 17, NULL),
(108, 46, N'BÀN THẮNG', 31, 15, NULL),
(109, 46, N'BÀN THẮNG', 68, 16, 15),
(110, 47, N'BÀN THẮNG', 50, 47, NULL),
(111, 47, N'BÀN THẮNG', 87, 10, NULL),
(112, 47, N'BÀN THẮNG', 46, 11, 10),
(113, 48, N'BÀN THẮNG', 61, 51, NULL),
(114, 49, N'BÀN THẮNG', 72, 57, NULL),
(115, 49, N'BÀN THẮNG', 31, 53, NULL),
(116, 49, N'BÀN THẮNG', 68, 4, 5),
(117, 50, N'BÀN THẮNG', 83, 1, NULL),
(118, 50, N'BÀN THẮNG', 42, 1, NULL),
(119, 50, N'BÀN THẮNG', 79, 1, 2),
(120, 51, N'BÀN THẮNG', 16, 33, NULL),
(121, 51, N'BÀN THẮNG', 53, 34, NULL),
(122, 51, N'BÀN THẮNG', 12, 21, 22),
(123, 52, N'BÀN THẮNG', 27, 36, NULL),
(124, 52, N'BÀN THẮNG', 64, 17, NULL),
(125, 53, N'BÀN THẮNG', 38, 10, NULL),
(126, 53, N'BÀN THẮNG', 75, 11, NULL),
(127, 53, N'BÀN THẮNG', 34, 10, 11),
(128, 54, N'BÀN THẮNG', 49, 42, NULL),
(129, 55, N'BÀN THẮNG', 60, 48, NULL),
(130, 56, N'BÀN THẮNG', 71, 49, NULL),
(131, 56, N'BÀN THẮNG', 30, 50, NULL),
(132, 56, N'BÀN THẮNG', 67, 54, 52),
(133, 56, N'BÀN THẮNG', 26, 55, NULL),
(134, 56, N'BÀN THẮNG', 63, 56, NULL),
(135, 57, N'BÀN THẮNG', 82, 3, NULL),
(136, 57, N'BÀN THẮNG', 41, 21, NULL),
(137, 57, N'BÀN THẮNG', 78, 21, 22),
(138, 58, N'BÀN THẮNG', 15, 15, NULL),
(139, 58, N'BÀN THẮNG', 52, 16, NULL),
(140, 59, N'BÀN THẮNG', 26, 30, NULL),
(141, 60, N'BÀN THẮNG', 37, 37, NULL),
(142, 60, N'BÀN THẮNG', 74, 7, NULL),
(143, 61, N'BÀN THẮNG', 48, 38, NULL),
(144, 63, N'BÀN THẮNG', 70, 46, NULL),
(145, 63, N'BÀN THẮNG', 29, 47, NULL),
(146, 63, N'BÀN THẮNG', 66, 51, 49),
(147, 64, N'BÀN THẮNG', 81, 17, NULL),
(148, 64, N'BÀN THẮNG', 40, 15, NULL),
(149, 64, N'BÀN THẮNG', 77, 16, 15),
(150, 65, N'BÀN THẮNG', 14, 22, NULL),
(151, 65, N'BÀN THẮNG', 51, 23, NULL),
(152, 65, N'BÀN THẮNG', 88, 11, 10),
(153, 66, N'BÀN THẮNG', 25, 7, NULL),
(154, 66, N'BÀN THẮNG', 62, 7, NULL),
(155, 67, N'BÀN THẮNG', 36, 31, NULL),
(156, 67, N'BÀN THẮNG', 73, 4, NULL),
(157, 68, N'BÀN THẮNG', 47, 35, NULL),
(158, 69, N'BÀN THẮNG', 58, 38, NULL),
(159, 69, N'BÀN THẮNG', 17, 49, NULL),
(160, 70, N'BÀN THẮNG', 69, 43, NULL),
(161, 70, N'BÀN THẮNG', 28, 48, NULL),
(162, 70, N'BÀN THẮNG', 65, 46, 45),
(163, 71, N'BÀN THẮNG', 80, 2, NULL),
(164, 71, N'BÀN THẮNG', 39, 10, NULL),
(165, 71, N'BÀN THẮNG', 76, 11, 10),
(166, 71, N'BÀN THẮNG', 35, 10, NULL),
(167, 72, N'BÀN THẮNG', 13, 17, NULL),
(168, 72, N'BÀN THẮNG', 50, 15, NULL),
(169, 72, N'BÀN THẮNG', 87, 7, 8),
(170, 72, N'BÀN THẮNG', 46, 7, NULL),
(171, 73, N'BÀN THẮNG', 24, 24, NULL),
(172, 73, N'BÀN THẮNG', 61, 4, NULL),
(173, 73, N'BÀN THẮNG', 20, 4, 5),
(174, 74, N'BÀN THẮNG', 35, 57, NULL),
(175, 74, N'BÀN THẮNG', 72, 53, NULL),
(176, 74, N'BÀN THẮNG', 31, 54, 52),
(177, 75, N'BÀN THẮNG', 46, 32, NULL),
(178, 75, N'BÀN THẮNG', 83, 33, NULL),
(179, 76, N'BÀN THẮNG', 57, 36, NULL),
(180, 76, N'BÀN THẮNG', 16, 37, NULL),
(181, 76, N'BÀN THẮNG', 53, 47, 45),
(182, 76, N'BÀN THẮNG', 12, 48, NULL),
(183, 77, N'BÀN THẮNG', 68, 38, NULL),
(184, 77, N'BÀN THẮNG', 27, 44, NULL),
(185, 77, N'BÀN THẮNG', 64, 41, 42),
(186, 78, N'BÀN THẮNG', 79, 3, NULL),
(187, 78, N'BÀN THẮNG', 38, 7, NULL),
(188, 79, N'BÀN THẮNG', 12, 5, NULL),
(189, 80, N'BÀN THẮNG', 23, 55, NULL),
(190, 80, N'BÀN THẮNG', 60, 56, NULL),
(191, 80, N'BÀN THẮNG', 19, 57, 52),
(192, 81, N'BÀN THẮNG', 34, 25, NULL),
(193, 82, N'BÀN THẮNG', 45, 27, NULL),
(194, 83, N'BÀN THẮNG', 56, 34, NULL),
(195, 83, N'BÀN THẮNG', 15, 42, NULL),
(196, 85, N'BÀN THẮNG', 78, 2, NULL),
(197, 86, N'BÀN THẮNG', 89, 7, NULL),
(198, 86, N'BÀN THẮNG', 48, 53, NULL),
(199, 86, N'BÀN THẮNG', 85, 54, 52),
(200, 87, N'BÀN THẮNG', 22, 11, NULL),
(201, 87, N'BÀN THẮNG', 59, 50, NULL),
(202, 88, N'BÀN THẮNG', 33, 16, NULL),
(203, 88, N'BÀN THẮNG', 70, 17, NULL),
(204, 88, N'BÀN THẮNG', 29, 15, 16),
(205, 88, N'BÀN THẮNG', 66, 46, NULL),
(206, 88, N'BÀN THẮNG', 25, 47, NULL),
(207, 89, N'BÀN THẮNG', 44, 43, NULL),
(208, 91, N'BÀN THẮNG', 66, 35, NULL),
(209, 92, N'BÀN THẮNG', 77, 55, NULL),
(210, 92, N'BÀN THẮNG', 36, 56, NULL),
(211, 92, N'BÀN THẮNG', 73, 57, 52),
(212, 92, N'BÀN THẮNG', 32, 3, NULL),
(213, 93, N'BÀN THẮNG', 88, 6, NULL),
(214, 95, N'BÀN THẮNG', 32, 44, NULL),
(215, 95, N'BÀN THẮNG', 69, 10, NULL),
(216, 95, N'BÀN THẮNG', 28, 11, 10),
(217, 95, N'BÀN THẮNG', 65, 10, NULL),
(218, 95, N'BÀN THẮNG', 24, 11, NULL),
(219, 95, N'BÀN THẮNG', 61, 10, 11),
(220, 96, N'BÀN THẮNG', 43, 38, NULL),
(221, 96, N'BÀN THẮNG', 80, 18, NULL),
(222, 97, N'BÀN THẮNG', 54, 36, NULL),
(223, 97, N'BÀN THẮNG', 13, 37, NULL),
(224, 97, N'BÀN THẮNG', 50, 26, 21),
(225, 97, N'BÀN THẮNG', 87, 22, NULL),
(226, 98, N'BÀN THẮNG', 65, 30, NULL),
(227, 98, N'BÀN THẮNG', 24, 31, NULL),
(228, 98, N'BÀN THẮNG', 61, 28, 27),
(229, 98, N'BÀN THẮNG', 20, 29, NULL),
(230, 99, N'BÀN THẮNG', 76, 51, NULL),
(231, 101, N'BÀN THẮNG', 20, 41, NULL),
(232, 101, N'BÀN THẮNG', 57, 5, NULL),
(233, 101, N'BÀN THẮNG', 16, 6, 4),
(234, 101, N'BÀN THẮNG', 53, 5, NULL),
(235, 101, N'BÀN THẮNG', 12, 6, NULL),
(236, 102, N'BÀN THẮNG', 31, 38, NULL),
(237, 102, N'BÀN THẮNG', 68, 8, NULL),
(238, 102, N'BÀN THẮNG', 27, 9, 7),
(239, 104, N'BÀN THẮNG', 53, 19, NULL),
(240, 104, N'BÀN THẮNG', 12, 20, NULL),
(241, 104, N'BÀN THẮNG', 49, 18, 15),
(242, 106, N'BÀN THẮNG', 75, 48, NULL),
(243, 106, N'BÀN THẮNG', 34, 2, NULL),
(244, 107, N'BÀN THẮNG', 86, 42, NULL),
(245, 107, N'BÀN THẮNG', 45, 43, NULL),
(246, 107, N'BÀN THẮNG', 82, 49, 50),
(247, 107, N'BÀN THẮNG', 41, 50, NULL),
(248, 108, N'BÀN THẮNG', 19, 53, NULL),
(249, 108, N'BÀN THẮNG', 56, 54, NULL),
(250, 110, N'BÀN THẮNG', 41, 32, NULL),
(251, 111, N'BÀN THẮNG', 52, 27, NULL),
(252, 111, N'BÀN THẮNG', 89, 28, NULL),
(253, 111, N'BÀN THẮNG', 48, 11, 10),
(254, 112, N'BÀN THẮNG', 63, 23, NULL),
(255, 112, N'BÀN THẮNG', 22, 24, NULL),
(256, 112, N'BÀN THẮNG', 59, 19, 15),
(257, 113, N'BÀN THẮNG', 74, 3, NULL),
(258, 114, N'BÀN THẮNG', 85, 38, NULL),
(259, 114, N'BÀN THẮNG', 44, 38, NULL),
(260, 114, N'BÀN THẮNG', 81, 38, 39),
(261, 114, N'BÀN THẮNG', 40, 46, NULL),
(262, 114, N'BÀN THẮNG', 77, 47, NULL),
(263, 115, N'BÀN THẮNG', 18, 51, NULL),
(264, 117, N'BÀN THẮNG', 40, 29, NULL),
(265, 117, N'BÀN THẮNG', 77, 27, NULL),
(266, 117, N'BÀN THẮNG', 36, 5, 4),
(267, 117, N'BÀN THẮNG', 73, 6, NULL),
(268, 118, N'BÀN THẮNG', 51, 25, NULL),
(269, 118, N'BÀN THẮNG', 88, 26, NULL),
(270, 118, N'BÀN THẮNG', 47, 8, 7),
(271, 118, N'BÀN THẮNG', 84, 9, NULL),
(272, 119, N'BÀN THẮNG', 62, 20, NULL),
(273, 119, N'BÀN THẮNG', 21, 10, NULL),
(274, 120, N'BÀN THẮNG', 73, 38, NULL),
(275, 120, N'BÀN THẮNG', 32, 2, NULL),
(276, 120, N'BÀN THẮNG', 69, 3, 1),
(277, 122, N'BÀN THẮNG', 17, 33, NULL),
(278, 122, N'BÀN THẮNG', 54, 34, NULL),
(279, 122, N'BÀN THẮNG', 13, 48, 45),
(280, 122, N'BÀN THẮNG', 50, 46, NULL),
(281, 123, N'BÀN THẮNG', 28, 28, NULL),
(282, 123, N'BÀN THẮNG', 65, 49, NULL),
(283, 124, N'BÀN THẮNG', 39, 55, NULL),
(284, 124, N'BÀN THẮNG', 76, 56, NULL),
(285, 125, N'BÀN THẮNG', 50, 18, NULL),
(286, 125, N'BÀN THẮNG', 87, 19, NULL),
(287, 125, N'BÀN THẮNG', 46, 20, 15),
(288, 125, N'BÀN THẮNG', 83, 5, NULL),
(289, 126, N'BÀN THẮNG', 61, 12, NULL),
(290, 126, N'BÀN THẮNG', 20, 13, NULL),
(291, 127, N'BÀN THẮNG', 72, 35, NULL),
(292, 127, N'BÀN THẮNG', 31, 36, NULL),
(293, 127, N'BÀN THẮNG', 68, 37, 35),
(294, 127, N'BÀN THẮNG', 27, 2, NULL),
(295, 128, N'BÀN THẮNG', 83, 30, NULL),
(296, 128, N'BÀN THẮNG', 42, 31, NULL),
(297, 128, N'BÀN THẮNG', 79, 32, 30),
(298, 128, N'BÀN THẮNG', 38, 39, NULL),
(299, 128, N'BÀN THẮNG', 75, 40, NULL),
(300, 128, N'BÀN THẮNG', 34, 39, 38),
(301, 129, N'BÀN THẮNG', 16, 29, NULL),
(302, 130, N'BÀN THẮNG', 27, 22, NULL),
(303, 130, N'BÀN THẮNG', 64, 23, NULL),
(304, 130, N'BÀN THẮNG', 23, 24, 21),
(305, 130, N'BÀN THẮNG', 60, 25, NULL),
(306, 130, N'BÀN THẮNG', 19, 26, NULL),
(307, 130, N'BÀN THẮNG', 56, 22, 21),
(308, 131, N'BÀN THẮNG', 38, 18, NULL),
(309, 131, N'BÀN THẮNG', 75, 19, NULL),
(310, 131, N'BÀN THẮNG', 34, 20, 15),
(311, 132, N'BÀN THẮNG', 49, 14, NULL),
(312, 132, N'BÀN THẮNG', 86, 57, NULL),
(313, 133, N'BÀN THẮNG', 60, 8, NULL),
(314, 133, N'BÀN THẮNG', 19, 9, NULL),
(315, 133, N'BÀN THẮNG', 56, 6, 4),
(316, 134, N'BÀN THẮNG', 71, 33, NULL),
(317, 134, N'BÀN THẮNG', 30, 34, NULL),
(318, 134, N'BÀN THẮNG', 67, 30, 31),
(319, 134, N'BÀN THẮNG', 26, 31, NULL),
(320, 135, N'BÀN THẮNG', 82, 35, NULL),
(321, 136, N'BÀN THẮNG', 15, 23, NULL),
(322, 136, N'BÀN THẮNG', 52, 24, NULL),
(323, 136, N'BÀN THẮNG', 89, 40, 38),
(324, 136, N'BÀN THẮNG', 48, 39, NULL),
(325, 137, N'BÀN THẮNG', 26, 18, NULL),
(326, 138, N'BÀN THẮNG', 37, 12, NULL),
(327, 138, N'BÀN THẮNG', 74, 13, NULL),
(328, 138, N'BÀN THẮNG', 33, 14, 10),
(329, 140, N'BÀN THẮNG', 59, 5, NULL),
(330, 140, N'BÀN THẮNG', 18, 53, NULL),
(331, 141, N'BÀN THẮNG', 70, 3, NULL),
(332, 141, N'BÀN THẮNG', 29, 2, NULL),
(333, 142, N'BÀN THẮNG', 81, 25, NULL),
(334, 142, N'BÀN THẮNG', 40, 26, NULL),
(335, 142, N'BÀN THẮNG', 77, 32, 30),
(336, 143, N'BÀN THẮNG', 14, 19, NULL),
(337, 143, N'BÀN THẮNG', 51, 36, NULL),
(338, 144, N'BÀN THẮNG', 25, 12, NULL),
(339, 144, N'BÀN THẮNG', 62, 13, NULL),
(340, 144, N'BÀN THẮNG', 21, 14, 10),
(341, 144, N'BÀN THẮNG', 58, 12, NULL),
(342, 144, N'BÀN THẮNG', 17, 40, NULL),
(343, 144, N'BÀN THẮNG', 54, 39, 38),
(344, 144, N'BÀN THẮNG', 13, 40, NULL),
(345, 144, N'BÀN THẮNG', 50, 39, NULL),
(346, 145, N'BÀN THẮNG', 36, 8, NULL),
(347, 145, N'BÀN THẮNG', 73, 9, NULL),
(348, 146, N'BÀN THẮNG', 47, 6, NULL),
(349, 147, N'BÀN THẮNG', 58, 54, NULL),
(350, 147, N'BÀN THẮNG', 17, 55, NULL),
(351, 147, N'BÀN THẮNG', 54, 56, 52),
(352, 147, N'BÀN THẮNG', 13, 57, NULL),
(353, 147, N'BÀN THẮNG', 50, 50, NULL),
(354, 148, N'BÀN THẮNG', 69, 22, NULL),
(355, 149, N'BÀN THẮNG', 80, 20, NULL),
(356, 149, N'BÀN THẮNG', 39, 18, NULL),
(357, 149, N'BÀN THẮNG', 76, 19, 15),
(358, 149, N'BÀN THẮNG', 35, 20, NULL),
(359, 149, N'BÀN THẮNG', 72, 18, NULL),
(360, 149, N'BÀN THẮNG', 31, 27, 28),
(361, 150, N'BÀN THẮNG', 13, 13, NULL),
(362, 150, N'BÀN THẮNG', 50, 14, NULL),
(363, 150, N'BÀN THẮNG', 87, 12, 10),
(364, 150, N'BÀN THẮNG', 46, 33, NULL),
(365, 151, N'BÀN THẮNG', 24, 8, NULL),
(366, 152, N'BÀN THẮNG', 35, 5, NULL),
(367, 152, N'BÀN THẮNG', 72, 40, NULL),
(368, 153, N'BÀN THẮNG', 46, 53, NULL),
(369, 153, N'BÀN THẮNG', 83, 54, NULL),
(370, 153, N'BÀN THẮNG', 42, 55, 52),
(371, 153, N'BÀN THẮNG', 79, 44, NULL),
(372, 155, N'BÀN THẮNG', 68, 19, NULL),
(373, 156, N'BÀN THẮNG', 79, 13, NULL),
(374, 156, N'BÀN THẮNG', 38, 14, NULL),
(375, 156, N'BÀN THẮNG', 75, 23, 21),
(376, 157, N'BÀN THẮNG', 12, 9, NULL),
(377, 157, N'BÀN THẮNG', 49, 8, NULL),
(378, 158, N'BÀN THẮNG', 23, 6, NULL),
(379, 158, N'BÀN THẮNG', 60, 5, NULL),
(380, 158, N'BÀN THẮNG', 19, 34, 30),
(381, 158, N'BÀN THẮNG', 56, 30, NULL),
(382, 159, N'BÀN THẮNG', 34, 56, NULL),
(383, 160, N'BÀN THẮNG', 45, 51, NULL),
(384, 160, N'BÀN THẮNG', 82, 39, NULL),
(385, 161, N'BÀN THẮNG', 56, 47, NULL),
(386, 161, N'BÀN THẮNG', 15, 48, NULL),
(387, 161, N'BÀN THẮNG', 52, 46, 45),
(388, 161, N'BÀN THẮNG', 89, 41, NULL),
(389, 162, N'BÀN THẮNG', 67, 12, NULL),
(390, 164, N'BÀN THẮNG', 89, 6, NULL),
(391, 164, N'BÀN THẮNG', 48, 5, NULL),
(392, 164, N'BÀN THẮNG', 85, 6, 4),
(393, 164, N'BÀN THẮNG', 44, 24, NULL),
(394, 165, N'BÀN THẮNG', 22, 57, NULL),
(395, 165, N'BÀN THẮNG', 59, 28, NULL),
(396, 166, N'BÀN THẮNG', 33, 49, NULL),
(397, 166, N'BÀN THẮNG', 70, 50, NULL),
(398, 166, N'BÀN THẮNG', 29, 51, 49),
(399, 166, N'BÀN THẮNG', 66, 31, NULL),
(400, 166, N'BÀN THẮNG', 25, 32, NULL),
(401, 167, N'BÀN THẮNG', 44, 47, NULL),
(402, 167, N'BÀN THẮNG', 81, 37, NULL),
(403, 167, N'BÀN THẮNG', 40, 35, 36),
(404, 167, N'BÀN THẮNG', 77, 36, NULL),
(405, 168, N'BÀN THẮNG', 55, 42, NULL),
(406, 169, N'BÀN THẮNG', 66, 9, NULL),
(407, 169, N'BÀN THẮNG', 25, 8, NULL),
(408, 169, N'BÀN THẮNG', 62, 9, 7),
(409, 169, N'BÀN THẮNG', 21, 8, NULL),
(410, 169, N'BÀN THẮNG', 58, 3, NULL),
(411, 169, N'BÀN THẮNG', 17, 2, 1),
(412, 170, N'BÀN THẮNG', 77, 5, NULL),
(413, 170, N'BÀN THẮNG', 36, 13, NULL),
(414, 170, N'BÀN THẮNG', 73, 14, 10),
(415, 170, N'BÀN THẮNG', 32, 12, NULL),
(416, 170, N'BÀN THẮNG', 69, 13, NULL),
(417, 171, N'BÀN THẮNG', 88, 53, NULL),
(418, 171, N'BÀN THẮNG', 47, 54, NULL),
(419, 171, N'BÀN THẮNG', 84, 20, 15),
(420, 172, N'BÀN THẮNG', 21, 25, NULL),
(421, 172, N'BÀN THẮNG', 58, 26, NULL),
(422, 172, N'BÀN THẮNG', 17, 22, 21),
(423, 172, N'BÀN THẮNG', 54, 23, NULL),
(424, 172, N'BÀN THẮNG', 13, 24, NULL),
(425, 173, N'BÀN THẮNG', 32, 48, NULL),
(426, 173, N'BÀN THẮNG', 69, 29, NULL),
(427, 174, N'BÀN THẮNG', 43, 43, NULL),
(428, 174, N'BÀN THẮNG', 80, 44, NULL),
(429, 174, N'BÀN THẮNG', 39, 33, 30),
(430, 175, N'BÀN THẮNG', 54, 40, NULL),
(431, 175, N'BÀN THẮNG', 13, 39, NULL),
(432, 176, N'BÀN THẮNG', 65, 6, NULL),
(433, 176, N'BÀN THẮNG', 24, 3, NULL),
(434, 176, N'BÀN THẮNG', 61, 2, 1),
(435, 177, N'BÀN THẮNG', 76, 55, NULL),
(436, 177, N'BÀN THẮNG', 35, 56, NULL),
(437, 178, N'BÀN THẮNG', 87, 49, NULL),
(438, 178, N'BÀN THẮNG', 46, 14, NULL),
(439, 179, N'BÀN THẮNG', 20, 18, NULL),
(440, 179, N'BÀN THẮNG', 57, 19, NULL),
(441, 180, N'BÀN THẮNG', 31, 41, NULL),
(442, 180, N'BÀN THẮNG', 68, 42, NULL),
(443, 180, N'BÀN THẮNG', 27, 25, 21),
(444, 180, N'BÀN THẮNG', 64, 26, NULL),
(445, 181, N'BÀN THẮNG', 42, 40, NULL),
(446, 181, N'BÀN THẮNG', 79, 39, NULL),
(447, 181, N'BÀN THẮNG', 38, 40, 38),
(448, 181, N'BÀN THẮNG', 75, 27, NULL),
(449, 182, N'BÀN THẮNG', 53, 37, NULL);
SET IDENTITY_INSERT dbo.SU_KIEN_TRAN_DAU OFF;
GO

SET IDENTITY_INSERT dbo.PHAN_CONG_TRONG_TAI ON;
INSERT INTO dbo.PHAN_CONG_TRONG_TAI (MaPhanCong, MaTranDau, MaTrongTai, NhiemVu) VALUES
(1, 1, 1, N'TRỌNG TÀI CHÍNH'),
(2, 2, 2, N'TRỌNG TÀI CHÍNH'),
(3, 3, 3, N'TRỌNG TÀI CHÍNH'),
(4, 4, 4, N'TRỌNG TÀI CHÍNH'),
(5, 5, 5, N'TRỌNG TÀI CHÍNH'),
(6, 6, 6, N'TRỌNG TÀI CHÍNH'),
(7, 7, 1, N'TRỌNG TÀI CHÍNH'),
(8, 8, 2, N'TRỌNG TÀI CHÍNH'),
(9, 9, 3, N'TRỌNG TÀI CHÍNH'),
(10, 10, 4, N'TRỌNG TÀI CHÍNH'),
(11, 11, 5, N'TRỌNG TÀI CHÍNH'),
(12, 12, 6, N'TRỌNG TÀI CHÍNH'),
(13, 13, 1, N'TRỌNG TÀI CHÍNH'),
(14, 14, 2, N'TRỌNG TÀI CHÍNH'),
(15, 15, 3, N'TRỌNG TÀI CHÍNH'),
(16, 16, 4, N'TRỌNG TÀI CHÍNH'),
(17, 17, 5, N'TRỌNG TÀI CHÍNH'),
(18, 18, 6, N'TRỌNG TÀI CHÍNH'),
(19, 19, 1, N'TRỌNG TÀI CHÍNH'),
(20, 20, 2, N'TRỌNG TÀI CHÍNH'),
(21, 21, 3, N'TRỌNG TÀI CHÍNH'),
(22, 22, 4, N'TRỌNG TÀI CHÍNH'),
(23, 23, 5, N'TRỌNG TÀI CHÍNH'),
(24, 24, 6, N'TRỌNG TÀI CHÍNH'),
(25, 25, 1, N'TRỌNG TÀI CHÍNH'),
(26, 26, 2, N'TRỌNG TÀI CHÍNH'),
(27, 27, 3, N'TRỌNG TÀI CHÍNH'),
(28, 28, 4, N'TRỌNG TÀI CHÍNH'),
(29, 29, 5, N'TRỌNG TÀI CHÍNH'),
(30, 30, 6, N'TRỌNG TÀI CHÍNH'),
(31, 31, 1, N'TRỌNG TÀI CHÍNH'),
(32, 32, 2, N'TRỌNG TÀI CHÍNH'),
(33, 33, 3, N'TRỌNG TÀI CHÍNH'),
(34, 34, 4, N'TRỌNG TÀI CHÍNH'),
(35, 35, 5, N'TRỌNG TÀI CHÍNH'),
(36, 36, 6, N'TRỌNG TÀI CHÍNH'),
(37, 37, 1, N'TRỌNG TÀI CHÍNH'),
(38, 38, 2, N'TRỌNG TÀI CHÍNH'),
(39, 39, 3, N'TRỌNG TÀI CHÍNH'),
(40, 40, 4, N'TRỌNG TÀI CHÍNH'),
(41, 41, 5, N'TRỌNG TÀI CHÍNH'),
(42, 42, 6, N'TRỌNG TÀI CHÍNH'),
(43, 43, 1, N'TRỌNG TÀI CHÍNH'),
(44, 44, 2, N'TRỌNG TÀI CHÍNH'),
(45, 45, 3, N'TRỌNG TÀI CHÍNH'),
(46, 46, 4, N'TRỌNG TÀI CHÍNH'),
(47, 47, 5, N'TRỌNG TÀI CHÍNH'),
(48, 48, 6, N'TRỌNG TÀI CHÍNH'),
(49, 49, 1, N'TRỌNG TÀI CHÍNH'),
(50, 50, 2, N'TRỌNG TÀI CHÍNH'),
(51, 51, 3, N'TRỌNG TÀI CHÍNH'),
(52, 52, 4, N'TRỌNG TÀI CHÍNH'),
(53, 53, 5, N'TRỌNG TÀI CHÍNH'),
(54, 54, 6, N'TRỌNG TÀI CHÍNH'),
(55, 55, 1, N'TRỌNG TÀI CHÍNH'),
(56, 56, 2, N'TRỌNG TÀI CHÍNH'),
(57, 57, 3, N'TRỌNG TÀI CHÍNH'),
(58, 58, 4, N'TRỌNG TÀI CHÍNH'),
(59, 59, 5, N'TRỌNG TÀI CHÍNH'),
(60, 60, 6, N'TRỌNG TÀI CHÍNH'),
(61, 61, 1, N'TRỌNG TÀI CHÍNH'),
(62, 62, 2, N'TRỌNG TÀI CHÍNH'),
(63, 63, 3, N'TRỌNG TÀI CHÍNH'),
(64, 64, 4, N'TRỌNG TÀI CHÍNH'),
(65, 65, 5, N'TRỌNG TÀI CHÍNH'),
(66, 66, 6, N'TRỌNG TÀI CHÍNH'),
(67, 67, 1, N'TRỌNG TÀI CHÍNH'),
(68, 68, 2, N'TRỌNG TÀI CHÍNH'),
(69, 69, 3, N'TRỌNG TÀI CHÍNH'),
(70, 70, 4, N'TRỌNG TÀI CHÍNH'),
(71, 71, 5, N'TRỌNG TÀI CHÍNH'),
(72, 72, 6, N'TRỌNG TÀI CHÍNH'),
(73, 73, 1, N'TRỌNG TÀI CHÍNH'),
(74, 74, 2, N'TRỌNG TÀI CHÍNH'),
(75, 75, 3, N'TRỌNG TÀI CHÍNH'),
(76, 76, 4, N'TRỌNG TÀI CHÍNH'),
(77, 77, 5, N'TRỌNG TÀI CHÍNH'),
(78, 78, 6, N'TRỌNG TÀI CHÍNH'),
(79, 79, 1, N'TRỌNG TÀI CHÍNH'),
(80, 80, 2, N'TRỌNG TÀI CHÍNH'),
(81, 81, 3, N'TRỌNG TÀI CHÍNH'),
(82, 82, 4, N'TRỌNG TÀI CHÍNH'),
(83, 83, 5, N'TRỌNG TÀI CHÍNH'),
(84, 84, 6, N'TRỌNG TÀI CHÍNH'),
(85, 85, 1, N'TRỌNG TÀI CHÍNH'),
(86, 86, 2, N'TRỌNG TÀI CHÍNH'),
(87, 87, 3, N'TRỌNG TÀI CHÍNH'),
(88, 88, 4, N'TRỌNG TÀI CHÍNH'),
(89, 89, 5, N'TRỌNG TÀI CHÍNH'),
(90, 90, 6, N'TRỌNG TÀI CHÍNH'),
(91, 91, 1, N'TRỌNG TÀI CHÍNH'),
(92, 92, 2, N'TRỌNG TÀI CHÍNH'),
(93, 93, 3, N'TRỌNG TÀI CHÍNH'),
(94, 94, 4, N'TRỌNG TÀI CHÍNH'),
(95, 95, 5, N'TRỌNG TÀI CHÍNH'),
(96, 96, 6, N'TRỌNG TÀI CHÍNH'),
(97, 97, 1, N'TRỌNG TÀI CHÍNH'),
(98, 98, 2, N'TRỌNG TÀI CHÍNH'),
(99, 99, 3, N'TRỌNG TÀI CHÍNH'),
(100, 100, 4, N'TRỌNG TÀI CHÍNH'),
(101, 101, 5, N'TRỌNG TÀI CHÍNH'),
(102, 102, 6, N'TRỌNG TÀI CHÍNH'),
(103, 103, 1, N'TRỌNG TÀI CHÍNH'),
(104, 104, 2, N'TRỌNG TÀI CHÍNH'),
(105, 105, 3, N'TRỌNG TÀI CHÍNH'),
(106, 106, 4, N'TRỌNG TÀI CHÍNH'),
(107, 107, 5, N'TRỌNG TÀI CHÍNH'),
(108, 108, 6, N'TRỌNG TÀI CHÍNH'),
(109, 109, 1, N'TRỌNG TÀI CHÍNH'),
(110, 110, 2, N'TRỌNG TÀI CHÍNH'),
(111, 111, 3, N'TRỌNG TÀI CHÍNH'),
(112, 112, 4, N'TRỌNG TÀI CHÍNH'),
(113, 113, 5, N'TRỌNG TÀI CHÍNH'),
(114, 114, 6, N'TRỌNG TÀI CHÍNH'),
(115, 115, 1, N'TRỌNG TÀI CHÍNH'),
(116, 116, 2, N'TRỌNG TÀI CHÍNH'),
(117, 117, 3, N'TRỌNG TÀI CHÍNH'),
(118, 118, 4, N'TRỌNG TÀI CHÍNH'),
(119, 119, 5, N'TRỌNG TÀI CHÍNH'),
(120, 120, 6, N'TRỌNG TÀI CHÍNH'),
(121, 121, 1, N'TRỌNG TÀI CHÍNH'),
(122, 122, 2, N'TRỌNG TÀI CHÍNH'),
(123, 123, 3, N'TRỌNG TÀI CHÍNH'),
(124, 124, 4, N'TRỌNG TÀI CHÍNH'),
(125, 125, 5, N'TRỌNG TÀI CHÍNH'),
(126, 126, 6, N'TRỌNG TÀI CHÍNH'),
(127, 127, 1, N'TRỌNG TÀI CHÍNH'),
(128, 128, 2, N'TRỌNG TÀI CHÍNH'),
(129, 129, 3, N'TRỌNG TÀI CHÍNH'),
(130, 130, 4, N'TRỌNG TÀI CHÍNH'),
(131, 131, 5, N'TRỌNG TÀI CHÍNH'),
(132, 132, 6, N'TRỌNG TÀI CHÍNH'),
(133, 133, 1, N'TRỌNG TÀI CHÍNH'),
(134, 134, 2, N'TRỌNG TÀI CHÍNH'),
(135, 135, 3, N'TRỌNG TÀI CHÍNH'),
(136, 136, 4, N'TRỌNG TÀI CHÍNH'),
(137, 137, 5, N'TRỌNG TÀI CHÍNH'),
(138, 138, 6, N'TRỌNG TÀI CHÍNH'),
(139, 139, 1, N'TRỌNG TÀI CHÍNH'),
(140, 140, 2, N'TRỌNG TÀI CHÍNH'),
(141, 141, 3, N'TRỌNG TÀI CHÍNH'),
(142, 142, 4, N'TRỌNG TÀI CHÍNH'),
(143, 143, 5, N'TRỌNG TÀI CHÍNH'),
(144, 144, 6, N'TRỌNG TÀI CHÍNH'),
(145, 145, 1, N'TRỌNG TÀI CHÍNH'),
(146, 146, 2, N'TRỌNG TÀI CHÍNH'),
(147, 147, 3, N'TRỌNG TÀI CHÍNH'),
(148, 148, 4, N'TRỌNG TÀI CHÍNH'),
(149, 149, 5, N'TRỌNG TÀI CHÍNH'),
(150, 150, 6, N'TRỌNG TÀI CHÍNH'),
(151, 151, 1, N'TRỌNG TÀI CHÍNH'),
(152, 152, 2, N'TRỌNG TÀI CHÍNH'),
(153, 153, 3, N'TRỌNG TÀI CHÍNH'),
(154, 154, 4, N'TRỌNG TÀI CHÍNH'),
(155, 155, 5, N'TRỌNG TÀI CHÍNH'),
(156, 156, 6, N'TRỌNG TÀI CHÍNH'),
(157, 157, 1, N'TRỌNG TÀI CHÍNH'),
(158, 158, 2, N'TRỌNG TÀI CHÍNH'),
(159, 159, 3, N'TRỌNG TÀI CHÍNH'),
(160, 160, 4, N'TRỌNG TÀI CHÍNH'),
(161, 161, 5, N'TRỌNG TÀI CHÍNH'),
(162, 162, 6, N'TRỌNG TÀI CHÍNH'),
(163, 163, 1, N'TRỌNG TÀI CHÍNH'),
(164, 164, 2, N'TRỌNG TÀI CHÍNH'),
(165, 165, 3, N'TRỌNG TÀI CHÍNH'),
(166, 166, 4, N'TRỌNG TÀI CHÍNH'),
(167, 167, 5, N'TRỌNG TÀI CHÍNH'),
(168, 168, 6, N'TRỌNG TÀI CHÍNH'),
(169, 169, 1, N'TRỌNG TÀI CHÍNH'),
(170, 170, 2, N'TRỌNG TÀI CHÍNH'),
(171, 171, 3, N'TRỌNG TÀI CHÍNH'),
(172, 172, 4, N'TRỌNG TÀI CHÍNH'),
(173, 173, 5, N'TRỌNG TÀI CHÍNH'),
(174, 174, 6, N'TRỌNG TÀI CHÍNH'),
(175, 175, 1, N'TRỌNG TÀI CHÍNH'),
(176, 176, 2, N'TRỌNG TÀI CHÍNH'),
(177, 177, 3, N'TRỌNG TÀI CHÍNH'),
(178, 178, 4, N'TRỌNG TÀI CHÍNH'),
(179, 179, 5, N'TRỌNG TÀI CHÍNH'),
(180, 180, 6, N'TRỌNG TÀI CHÍNH'),
(181, 181, 1, N'TRỌNG TÀI CHÍNH'),
(182, 182, 2, N'TRỌNG TÀI CHÍNH');
SET IDENTITY_INSERT dbo.PHAN_CONG_TRONG_TAI OFF;
GO

-- =====================================================================
-- PHAN 5: KIEM TRA
-- =====================================================================
SELECT 'NHAN_SU' AS Bang, COUNT(*) AS SoDong FROM dbo.NHAN_SU;
SELECT 'TAI_KHOAN' AS Bang, COUNT(*) AS SoDong FROM dbo.TAI_KHOAN;
SELECT 'GIAI_DAU' AS Bang, COUNT(*) AS SoDong FROM dbo.GIAI_DAU;
SELECT 'SAN_VAN_DONG' AS Bang, COUNT(*) AS SoDong FROM dbo.SAN_VAN_DONG;
SELECT 'TRONG_TAI' AS Bang, COUNT(*) AS SoDong FROM dbo.TRONG_TAI;
SELECT 'VONG_DAU' AS Bang, COUNT(*) AS SoDong FROM dbo.VONG_DAU;
SELECT 'CLB' AS Bang, COUNT(*) AS SoDong FROM dbo.CLB;
SELECT 'CAU_THU' AS Bang, COUNT(*) AS SoDong FROM dbo.CAU_THU;
SELECT 'BAN_HUAN_LUYEN' AS Bang, COUNT(*) AS SoDong FROM dbo.BAN_HUAN_LUYEN;
SELECT 'DANG_KY_CAU_THU' AS Bang, COUNT(*) AS SoDong FROM dbo.DANG_KY_CAU_THU;
SELECT 'BANG_XEP_HANG' AS Bang, COUNT(*) AS SoDong FROM dbo.BANG_XEP_HANG;
SELECT 'TRAN_DAU' AS Bang, COUNT(*) AS SoDong FROM dbo.TRAN_DAU;
SELECT 'DOI_HINH_TRAN_DAU' AS Bang, COUNT(*) AS SoDong FROM dbo.DOI_HINH_TRAN_DAU;
SELECT 'SU_KIEN_TRAN_DAU' AS Bang, COUNT(*) AS SoDong FROM dbo.SU_KIEN_TRAN_DAU;
SELECT 'PHAN_CONG_TRONG_TAI' AS Bang, COUNT(*) AS SoDong FROM dbo.PHAN_CONG_TRONG_TAI;
GO
