"""Khởi tạo CSDL + dữ liệu mẫu cho webapp Quản lý Giải VĐQG Bóng đá (V-League).

Chạy:  python3 webapp/seed.py          (tạo mới, ghi đè file app.db)
Tài khoản demo (mật khẩu chung: 123456):
  admin    - ADMIN   : toàn quyền
  kyluat   - CAPNHAT : cập nhật sự kiện/thẻ phạt, BXH...
  giaisat  - CAPNHAT : cập nhật tỷ số (giám sát trận đấu)
  xem      - XEM     : chỉ tra cứu
"""
import os
import sqlite3

from werkzeug.security import generate_password_hash

BASE = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE, "app.db")


def get_conn():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


def seed():
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)
    conn = get_conn()
    cur = conn.cursor()
    with open(os.path.join(BASE, "schema.sql"), encoding="utf-8") as f:
        cur.executescript(f.read())

    # ---------- NHAN_SU / TAI_KHOAN ----------
    nhan_su = [
        ("Nguyễn Văn A", "Nam", "1980-05-12", "0905111222", "admin@vleague.vn", "Trưởng ban tổ chức", 1),
        ("Trần Thị B", "Nữ", "1988-09-21", "0905333444", "kyluat@vleague.vn", "Trưởng ban kỷ luật", 1),
        ("Lê Văn C", "Nam", "1990-01-30", "0905555666", "giaisat@vleague.vn", "Giám sát trận đấu", 1),
        ("Phạm Minh D", "Nam", "1995-07-07", "0905777888", "view@vleague.vn", "Nhân viên văn phòng", 1),
    ]
    cur.executemany(
        "INSERT INTO NHAN_SU (HoTen,GioiTinh,NgaySinh,SoDienThoai,Email,ChucVu,TrangThaiLamViec) VALUES (?,?,?,?,?,?,?)",
        nhan_su)
    pw = generate_password_hash("123456")
    cur.executemany(
        "INSERT INTO TAI_KHOAN (MaNhanSu,TenDangNhap,MatKhau,QuyenHan,TrangThaiHoatDong) VALUES (?,?,?,?,1)",
        [(1, "admin", pw, "ADMIN"), (2, "kyluat", pw, "CAPNHAT"),
         (3, "giaisat", pw, "CAPNHAT"), (4, "xem", pw, "XEM")])

    # ---------- GIAI_DAU ----------
    cur.executemany(
        "INSERT INTO GIAI_DAU (TenGiai,NamBatDau,NamKetThuc,NgayKhaiMac,NgayBeMac,TrangThai) VALUES (?,?,?,?,?,?)",
        [("LPBank V-League 1-2025", 2025, 2025, "2025-08-15", "2025-12-28", "ĐANG DIỄN RA"),
         ("Night Wolf V-League 1-2023/24", 2023, 2024, "2023-10-21", "2024-06-30", "ĐÃ KẾT THÚC")])

    # ---------- SAN_VAN_DONG ----------
    sans = [
        ("Mỹ Đình", 40192, "Hà Nội"), ("Thống Nhất", 15000, "TP. Hồ Chí Minh"),
        ("Lạch Tray", 19000, "Hải Phòng"), ("Hàng Đẫy", 19000, "Hà Nội"),
        ("Vinh", 18000, "Nghệ An"), ("Pleiku", 12800, "Gia Lai"),
        ("Thiên Trường", 19000, "Nam Định"), ("Hòa Xuân", 20000, "Đà Nẵng"),
    ]
    cur.executemany("INSERT INTO SAN_VAN_DONG (TenSan,SucChua,DiaChi) VALUES (?,?,?)", sans)

    # ---------- TRONG_TAI ----------
    trongs = [("Nguyễn Trọng Thư", "FIFA"), ("Mai Hoàng Hùng", "FIFA"), ("Hoàng Ngọc Tuấn", "Quốc gia"),
              ("Trương Hồng Vũ", "Quốc gia"), ("Nguyễn Đình Thái", "Cấp 1"), ("Luu Xuân Niêm", "FIFA")]
    cur.executemany("INSERT INTO TRONG_TAI (HoTen,CapDo) VALUES (?,?)", trongs)

    # ---------- CLB (MaSanNha) ----------
    clbs = [
        ("Câu lạc bộ Bóng đá Hà Nội", "HANOI FC", "🔵⚪", 4),
        ("CLB Thành phố Hồ Chí Minh", "HCMC", "🔴⚪", 2),
        ("CLB Hải Phòng", "HPFC", "🟥🟦", 3),
        ("CLB Sông Lam Nghệ An", "SLNA", "💛❤️", 5),
        ("CLB Hoàng Anh Gia Lai", "HAGL", "🟡", 6),
        ("CLB Nam Định", "NDC", "🟧⚪", 7),
        ("CLB SHB Đà Nẵng", "DNFC", "🟠", 8),
        ("CLB Thể Công Viettel", "TVA", "🔴🔴", 1),
    ]
    cur.executemany("INSERT INTO CLB (TenCLB,TenVietTom,Logo,MaSanNha) VALUES (?,?,?,?)", clbs)

    # ---------- CAU_THU ----------
    ct = [
        ("Nguyễn Văn Quyết", "1991-04-23", "Việt Nam", "Nội binh", "Tiền vệ cánh", 1),
        ("Phạm Tuấn Hải", "1998-05-19", "Việt Nam", "Nội binh", "Tiền đạo", 1),
        ("Đỗ Duy Mạnh", "1996-09-29", "Việt Nam", "Nội binh", "Trung vệ", 1),
        ("Nguyễn Quang Hải", "1997-06-12", "Việt Nam", "Nội binh", "Tiền vệ", 8),
        ("Bùi Tiến Dũng", "1995-02-12", "Việt Nam", "Nội binh", "Trung vệ", 8),
        ("Paulo Oliveira", "1994-03-08", "Brazil", "Ngoại binh", "Tiền đạo", 2),
        ("Nguyễn Công Phượng", "1995-01-21", "Việt Nam", "Nội binh", "Tiền đạo", 5),
        ("Trần Minh Vương", "1995-03-05", "Việt Nam", "Nội binh", "Tiền vệ", 5),
        ("Nguyễn Hoàng Đức", "1998-10-11", "Việt Nam", "Nội binh", "Tiền vệ", 6),
        ("Rafson Barbosa", "1996-05-13", "Brazil", "Ngoại binh", "Tiền đạo", 6),
        ("Luis Antonio", "1993-07-20", "Brazil", "Nhập tịch", "Trung vệ", 3),
        ("Nguyễn Văn Toàn", "1996-04-12", "Việt Nam", "Nội binh", "Tiền đạo cánh", None),  # tự do
        ("Hồ Tân Tỷ", "1997-02-14", "Việt Nam", "Nội binh", "Thủ môn", 7),
        ("Phạm Văn Lợi", "1995-05-26", "Việt Nam", "Nội binh", "Hậu vệ", 3),
    ]
    cur.executemany(
        "INSERT INTO CAU_THU (HoTen,NgaySinh,QuocTich,LoaiCauThu,ViTriSoTruong,MaCLB) VALUES (?,?,?,?,?,?)", ct)

    # ---------- BAN_HUAN_LUYEN ----------
    hlvs = [
        ("Masashi Tsuboi", "Nhật Bản", "Huấn luyện viên trưởng", "Pro License AFC", 1),
        ("Alexandre Polking", "Brazil", "Huấn luyện viên trưởng", "UEFA Pro", 2),
        ("Chu Đình Nghiêm", "Việt Nam", "Huấn luyện viên trưởng", "AFC A", 3),
        ("Phan Như Trúc", "Việt Nam", "Huấn luyện viên phó", "AFC B", 4),
        ("Dương Minh Ninh", "Việt Nam", "Trợ lý HLV", "AFC A", 5),
        ("Vũ Hồng Việt", "Việt Nam", "Huấn luyện viên trưởng", "AFC A", 6),
    ]
    cur.executemany("INSERT INTO BAN_HUAN_LUYEN (HoTen,QuocTich,ChucVu,BangCap,MaCLB) VALUES (?,?,?,?,?)", hlvs)

    # ---------- VONG_DAU ----------
    cur.executemany(
        "INSERT INTO VONG_DAU (MaGiaiDau,TenVong,GiaiDoan) VALUES (?,?,?)",
        [(1, "Vòng 1", "Lượt đi"), (1, "Vòng 2", "Lượt đi"), (1, "Vòng 3", "Lượt đi"),
         (1, "Vòng 4", "Lượt đi"), (1, "Vòng 13", "Lượt về"),
         (2, "Vòng 26", "Lượt về")])

    # ---------- TRAN_DAU ----------
    td = [
        (1, 1, 2, 4, "2025-08-16 19:15", "ĐÃ KẾT THÚC"),
        (1, 3, 5, 6, "2025-08-16 18:00", "ĐÃ KẾT THÚC"),
        (2, 2, 3, 7, "2025-08-23 19:15", "ĐÃ KẾT THÚC"),
        (2, 6, 1, 5, "2025-08-23 18:00", "ĐÃ KẾT THÚC"),
        (3, 1, 6, 8, "2025-09-13 19:15", "ĐÃ KẾT THÚC"),
        (3, 3, 2, 4, "2025-09-14 18:00", "ĐANG ĐÁ"),
        (4, 5, 1, 7, "2025-09-20 19:15", "CHƯA ĐÁ"),
        (4, 2, 6, 3, "2025-09-21 18:00", "HOÃN"),
    ]
    cur.executemany(
        "INSERT INTO TRAN_DAU (MaVongDau,MaDoiNha,MaDoiKhach,MaSanVD,NgayGioThiDau,TrangThai) VALUES (?,?,?,?,?,?)", td)

    # ---------- DOI_HINH_TRAN_DAU ----------
    dh = [
        (1, 1, "Đá chính", 1), (1, 2, "Đá chính", 0), (1, 3, "Đá chính", 0),
        (1, 6, "Đá chính", 1), (1, 8, "Dự bị", 0),
        (2, 4, "Đá chính", 1), (2, 10, "Đá chính", 0), (2, 7, "Dự bị", 0),
        (3, 2, "Đá chính", 0), (3, 11, "Đá chính", 1),
        (4, 9, "Đá chính", 1), (4, 1, "Đá chính", 0),
        (5, 9, "Đá chính", 1), (5, 10, "Đá chính", 0),
        (6, 1, "Đá chính", 1), (6, 2, "Đá chính", 0), (6, 6, "Đá chính", 0),
    ]
    cur.executemany(
        "INSERT INTO DOI_HINH_TRAN_DAU (MaTranDau,MaCauThu,LoaiRaSan,DaiDoTruong) VALUES (?,?,?,?)", dh)

    # ---------- SU_KIEN_TRAN_DAU ----------
    sk = [
        # Trận 1: HN 2-1 HCM
        (1, "BÀN THẮNG", 12, 1, 2), (1, "BÀN THẮNG", 55, 6, None), (1, "BÀN THẮNG", 78, 2, 1),
        (1, "THẺ VÀNG", 34, 3, None), (1, "THẺ VÀNG", 66, 6, None), (1, "THAY NGƯỜI", 82, 8, 6),
        # Trận 2: HP 0-0 HAGL
        (2, "THẺ VÀNG", 45, 11, None), (2, "THẺ ĐỎ", 90, 10, None),
        # Trận 3: HCM 3-2 DN
        (3, "BÀN THẮNG", 9, 6, 1), (3, "BÀN THẮNG", 23, 6, None), (3, "BÀN THẮNG", 61, 2, 1),
        (3, "THẺ VÀNG", 70, 13, None), (3, "THẺ VÀNG", 88, 1, None),
        # Trận 4: NĐ 1-1 SLNA
        (4, "BÀN THẮNG", 30, 9, 10), (4, "BÀN THẮNG", 75, 7, None), (4, "THẺ VÀNG", 52, 9, None),
        # Trận 5: HN 2-0 TVC
        (5, "BÀN THẮNG", 18, 1, 2), (5, "BÀN THẮNG", 64, 2, None), (5, "THẺ VÀNG", 40, 4, None),
        # Trận 6 (đang đá): HA.GL 1-0 HN
        (6, "BÀN THẮNG", 25, 7, 8), (6, "THẺ VÀNG", 44, 3, None),
    ]
    cur.executemany(
        "INSERT INTO SU_KIEN_TRAN_DAU (MaTranDau,LoaiSuKien,Phut,MaCauThuChinh,MaCauThuPhu) VALUES (?,?,?,?,?)", sk)

    # ---------- PHAN_CONG_TRONG_TAI ----------
    pc = [
        (1, 1, "TRỌNG TÀI CHÍNH"), (1, 3, "BIÊN"), (1, 5, "VAR"),
        (2, 2, "TRỌNG TÀI CHÍNH"), (2, 4, "BIÊN"),
        (3, 6, "TRỌNG TÀI CHÍNH"), (3, 3, "BIÊN"), (3, 5, "VAR"),
        (4, 1, "TRỌNG TÀI CHÍNH"), (4, 4, "BIÊN"),
        (5, 2, "TRỌNG TÀI CHÍNH"), (5, 6, "VAR"),
        (6, 1, "TRỌNG TÀI CHÍNH"),
    ]
    cur.executemany("INSERT INTO PHAN_CONG_TRONG_TAI (MaTranDau,MaTrongTai,NhiemVu) VALUES (?,?,?)", pc)

    # ---------- DANG_KY_CAU_THU (mùa 2025 = MaGiaiDau 1) ----------
    # Cầu thủ tự do (MaCLB NULL) không được đăng ký thi đấu.
    ct_clb = [(i + 1, c[5]) for i, c in enumerate(ct) if c[5]]  # (thứ tự chèn = MaCauThu, MaCLB)
    for n, (ct_id, clb_id) in enumerate(ct_clb):
        cur.execute("INSERT INTO DANG_KY_CAU_THU (MaGiaiDau,MaCLB,MaCauThu,SoAo,ViTriDangKy) VALUES (1,?,?,?,?)",
                    (clb_id, ct_id, 10 + n * 3, ct[ct_id - 1][4]))

    conn.commit()
    counts = {t: cur.execute(f"SELECT COUNT(*) c FROM {t}").fetchone()["c"] for t in
              ["NHAN_SU", "TAI_KHOAN", "GIAI_DAU", "SAN_VAN_DONG", "TRONG_TAI", "VONG_DAU", "CLB",
               "CAU_THU", "BAN_HUAN_LUYEN", "DANG_KY_CAU_THU", "TRAN_DAU", "DOI_HINH_TRAN_DAU",
               "SU_KIEN_TRAN_DAU", "PHAN_CONG_TRONG_TAI"]}
    conn.close()
    print("Seed OK:", counts)


if __name__ == "__main__":
    seed()
