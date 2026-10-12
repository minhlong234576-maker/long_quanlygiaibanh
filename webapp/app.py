"""Webapp Quản lý Giải vô địch Bóng đá Quốc gia (V-League) - Flask + SQLite.

Chạy:   python3 webapp/app.py     ->  http://localhost:5000
Login demo (mật khẩu 123456): admin / kyluat / giaisat / xem
Phân quyền: ADMIN (quản trị + CRUD danh mục), CAPNHAT (cập nhật trận đấu, sự kiện, BXH), XEM (tra cứu).
"""
import math
import os
import sqlite3
from functools import wraps

from flask import (Flask, abort, flash, g, jsonify, redirect, render_template,
                   request, session, url_for)
from werkzeug.security import check_password_hash, generate_password_hash

BASE = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(BASE, "app.db")

app = Flask(__name__)
app.secret_key = os.environ.get("SECRET_KEY", "vleague-demo-secret")

# ---------------------------------------------------------------- DB helpers
def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(DB_PATH)
        g.db.row_factory = sqlite3.Row
        g.db.execute("PRAGMA foreign_keys = ON")
    return g.db


@app.teardown_appcontext
def close_db(_=None):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def _row(r):
    return dict(r) if r is not None else None


def q(sql, args=()):
    return [_row(r) for r in get_db().execute(sql, args).fetchall()]


def q1(sql, args=()):
    return _row(get_db().execute(sql, args).fetchone())


def run(sql, args=()):
    db = get_db()
    cur = db.execute(sql, args)
    db.commit()
    return cur.lastrowid


# ---------------------------------------------------------------- Auth
LEVEL = {"XEM": 0, "CAPNHAT": 1, "ADMIN": 2}


def login_required(min_level="XEM"):
    def deco(f):
        @wraps(f)
        def wrapper(*a, **kw):
            if not session.get("user"):
                flash("Vui lòng đăng nhập để tiếp tục.", "warning")
                return redirect(url_for("login", next=request.path))
            if LEVEL[session.get("quyen", "XEM")] < LEVEL[min_level]:
                abort(403)
            return f(*a, **kw)
        return wrapper
    return deco


@app.context_processor
def inject_user():
    return dict(user=session.get("user"), quyen=session.get("quyen"),
                level=LEVEL.get(session.get("quyen", "XEM"), 0),
                can_edit=LEVEL.get(session.get("quyen", "XEM"), 0) >= LEVEL["CAPNHAT"],
                is_admin=LEVEL.get(session.get("quyen", "XEM"), 0) >= LEVEL["ADMIN"])


@app.route("/login", methods=["GET", "POST"])
def login():
    error = None
    if request.method == "POST":
        tk = q1("SELECT * FROM TAI_KHOAN WHERE TenDangNhap = ?", (request.form["username"].strip(),))
        if tk and tk["TrangThaiHoatDong"] == 1 and check_password_hash(tk["MatKhau"], request.form["password"]):
            ns = q1("SELECT HoTen FROM NHAN_SU WHERE MaNhanSu = ?", (tk["MaNhanSu"],))
            session["user"] = {"id": tk["MaTaiKhoan"], "ten": tk["TenDangNhap"],
                               "ho_ten": ns["HoTen"] if ns else tk["TenDangNhap"]}
            session["quyen"] = tk["QuyenHan"]
            return redirect(request.args.get("next") or url_for("index"))
        error = "Sai tên đăng nhập / mật khẩu, hoặc tài khoản đã bị khóa."
    return render_template("login.html", error=error)


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for("login"))


@app.route("/taikhoan", methods=["GET", "POST"])
@login_required("ADMIN")
def taikhoan():
    ds = q("""SELECT t.*, n.HoTen FROM TAI_KHOAN t JOIN NHAN_SU n ON n.MaNhanSu = t.MaNhanSu
              ORDER BY t.MaTaiKhoan""")
    if request.method == "POST":
        action = request.form.get("action")
        if action == "them":
            try:
                run("""INSERT INTO TAI_KHOAN (MaNhanSu,TenDangNhap,MatKhau,QuyenHan,TrangThaiHoatDong)
                       VALUES (?,?,?,?,?)""",
                    (int(request.form["manhansu"]), request.form["tendangnhap"].strip(),
                     generate_password_hash(request.form["matkhau"]), request.form["quyenhan"],
                     int(request.form["trangthai"])))
                flash("Đã tạo tài khoản mới.", "success")
            except sqlite3.IntegrityError:
                flash("Trùng tên đăng nhập hoặc mã nhân sự (mỗi nhân sự chỉ 1 tài khoản).", "danger")
        elif action == "xoaymk":
            run("UPDATE TAI_KHOAN SET MatKhau = ? WHERE MaTaiKhoan = ?",
                (generate_password_hash(request.form["matkhau"] or "123456"), int(request.form["id"])))
            flash("Đã đổi mật khẩu tài khoản.", "success")
        elif action == "toggle":
            run("UPDATE TAI_KHOAN SET TrangThaiHoatDong = 1 - TrangThaiHoatDong WHERE MaTaiKhoan = ?",
                (int(request.form["id"]),))
            flash("Đã cập nhật trạng thái hoạt động.", "success")
        return redirect(url_for("taikhoan"))
    nhan_sus = q("SELECT MaNhanSu, HoTen FROM NHAN_SU ORDER BY MaNhanSu")
    return render_template("taikhoan.html", ds=ds, nhan_sus=nhan_sus)


# ---------------------------------------------------------------- Trang chủ / Dashboard
def compute_score(tran_id):
    """Tự động tổng hợp tỷ số từ bàn thắng trong SU_KIEN_TRAN_DAU."""
    row = q1("""
      SELECT
        SUM(CASE WHEN s.LoaiSuKien='BÀN THẮNG' AND c.MaCLB=t.MaDoiNha   THEN 1 ELSE 0 END) bt_nha,
        SUM(CASE WHEN s.LoaiSuKien='BÀN THẮNG' AND c.MaCLB=t.MaDoiKhach THEN 1 ELSE 0 END) bt_khach
      FROM TRAN_DAU t
      JOIN SU_KIEN_TRAN_DAU s ON s.MaTranDau = t.MaTranDau
      JOIN CAU_THU c ON c.MaCauThu = s.MaCauThuChinh
      WHERE t.MaTranDau = ?""", (tran_id,))
    return (row["bt_nha"] or 0, row["bt_khach"] or 0)


@app.route("/")
@login_required()
def index():
    giai = q1("SELECT * FROM GIAI_DAU WHERE TrangThai='ĐANG DIỄN RA' ORDER BY NamBatDau DESC LIMIT 1") \
         or q1("SELECT * FROM GIAI_DAU ORDER BY MaGiaiDau DESC LIMIT 1")
    stats = {
        "so_clb": q1("SELECT COUNT(*) c FROM CLB")["c"],
        "so_cauthu": q1("SELECT COUNT(*) c FROM CAU_THU")["c"],
        "so_tran": q1("SELECT COUNT(*) c FROM TRAN_DAU WHERE MaVongDau IN (SELECT MaVongDau FROM VONG_DAU WHERE MaGiaiDau=?)",
                      (giai["MaGiaiDau"],))["c"],
        "so_ban": q1("""SELECT COUNT(*) c FROM SU_KIEN_TRAN_DAU s JOIN TRAN_DAU t ON t.MaTranDau=s.MaTranDau
                        JOIN VONG_DAU v ON v.MaVongDau=t.MaVongDau
                        WHERE s.LoaiSuKien='BÀN THẮNG' AND v.MaGiaiDau=?""", (giai["MaGiaiDau"],))["c"],
        "so_the": q1("""SELECT COUNT(*) c FROM SU_KIEN_TRAN_DAU s JOIN TRAN_DAU t ON t.MaTranDau=s.MaTranDau
                        JOIN VONG_DAU v ON v.MaVongDau=t.MaVongDau
                        WHERE s.LoaiSuKien IN ('THẺ VÀNG','THẺ ĐỎ') AND v.MaGiaiDau=?""", (giai["MaGiaiDau"],))["c"],
    }
    tran_live = q("""SELECT t.*, vn.TenVong, sn.TenSan AS SanNha,
                            d1.TenVietTom doi_nha, d2.TenVietTom doi_khach
                     FROM TRAN_DAU t
                     JOIN VONG_DAU vn ON vn.MaVongDau=t.MaVongDau
                     JOIN CLB d1 ON d1.MaCLB=t.MaDoiNha JOIN CLB d2 ON d2.MaCLB=t.MaDoiKhach
                     JOIN SAN_VAN_DONG sn ON sn.MaSanVD=t.MaSanVD
                     WHERE vn.MaGiaiDau=? AND t.TrangThai IN ('ĐANG ĐÁ','CHƯA ĐÁ','HOÃN')
                     ORDER BY t.NgayGioThiDau""", (giai["MaGiaiDau"],))
    top_scorers = scorer_query(giai["MaGiaiDau"], limit="LIMIT 5")
    return render_template("index.html", giai=giai, stats=stats, tran_live=tran_live, top_scorers=top_scorers)


SCORER_SQL = """
  WITH agg AS (
    SELECT c.MaCauThu, c.HoTen, cl.TenVietTom CLB, cl.Logo,
           SUM(CASE WHEN s.LoaiSuKien='BÀN THẮNG' THEN 1 ELSE 0 END) BanThang,
           SUM(CASE WHEN s.LoaiSuKien='THẺ VÀNG' THEN 1 ELSE 0 END) TheVang,
           SUM(CASE WHEN s.LoaiSuKien='THẺ ĐỎ'   THEN 1 ELSE 0 END) TheDo
    FROM SU_KIEN_TRAN_DAU s
    JOIN TRAN_DAU t ON t.MaTranDau = s.MaTranDau
    JOIN VONG_DAU v ON v.MaVongDau = t.MaVongDau
    JOIN CAU_THU c ON c.MaCauThu = s.MaCauThuChinh
    LEFT JOIN CLB cl ON cl.MaCLB = c.MaCLB
    WHERE v.MaGiaiDau = ?
    GROUP BY c.MaCauThu
  )
  SELECT * FROM agg ORDER BY BanThang DESC, TheVang ASC
"""


def scorer_query(ma_giai, where="", limit=""):
    """where/limit chỉ ghép phần sau ORDER BY -> dùng tham số hóa cho MaGiaiDau."""
    sql = SCORER_SQL.replace("ORDER BY BanThang DESC, TheVang ASC",
                             f"{where} ORDER BY BanThang DESC, TheVang ASC {limit}")
    return q(sql, (ma_giai,))


# ---------------------------------------------------------------- Bảng xếp hạng
def rebuild_bxh(ma_giai):
    """Tổng hợp kết quả các trận ĐÃ KẾT THÚC theo vòng đấu gần nhất -> BANG_XEP_HANG."""
    vong = q1("""SELECT v.MaVongDau FROM VONG_DAU v
                 WHERE v.MaGiaiDau=? AND EXISTS (SELECT 1 FROM TRAN_DAU t
                         WHERE t.MaVongDau=v.MaVongDau AND t.TrangThai='ĐÃ KẾT THÚC')
                 ORDER BY v.MaVongDau DESC LIMIT 1""", (ma_giai,))
    if not vong:
        return 0
    mv = vong["MaVongDau"]
    rows = q("""
      WITH bt AS (
        SELECT s.MaTranDau, c.MaCLB team, COUNT(*) goals
        FROM SU_KIEN_TRAN_DAU s JOIN CAU_THU c ON c.MaCauThu=s.MaCauThuChinh
        WHERE s.LoaiSuKien='BÀN THẮNG' GROUP BY s.MaTranDau, c.MaCLB
      ),
      the AS (
        SELECT s.MaTranDau, c.MaCLB team,
               SUM(CASE WHEN s.LoaiSuKien='THẺ VÀNG' THEN 1 ELSE 0 END)*1
             + SUM(CASE WHEN s.LoaiSuKien='THẺ ĐỎ' THEN 3 ELSE 0 END)*0 fp
        FROM SU_KIEN_TRAN_DAU s JOIN CAU_THU c ON c.MaCauThu=s.MaCauThuChinh
        WHERE s.LoaiSuKien IN ('THẺ VÀNG','THẺ ĐỎ') GROUP BY s.MaTranDau, c.MaCLB
      )
      SELECT x.MaCLB,
             COUNT(*) SoTranDaDau,
             SUM(x.win) SoTranThang, SUM(x.draw) SoTranHoa, SUM(x.loss) SoTranThua,
             SUM(x.gf) TongBanThang, SUM(x.ga) TongBanThua,
             COALESCE(SUM(x.fp),0) DiemFairPlay
      FROM (
        SELECT t.MaTranDau, cl.MaCLB,
          CASE WHEN cl.MaCLB=t.MaDoiNha AND (n.goals>k.goals) THEN 1
               WHEN cl.MaCLB=t.MaDoiKhach AND (k.goals>n.goals) THEN 1 ELSE 0 END win,
          CASE WHEN n.goals=k.goals THEN 1 ELSE 0 END draw,
          CASE WHEN cl.MaCLB=t.MaDoiNha AND (n.goals<k.goals) THEN 1
               WHEN cl.MaCLB=t.MaDoiKhach AND (k.goals<n.goals) THEN 1 ELSE 0 END loss,
          CASE WHEN cl.MaCLB=t.MaDoiNha THEN COALESCE(n.goals,0) ELSE COALESCE(k.goals,0) END gf,
          CASE WHEN cl.MaCLB=t.MaDoiNha THEN COALESCE(k.goals,0) ELSE COALESCE(n.goals,0) END ga,
          COALESCE(th.fp,0) fp
        FROM TRAN_DAU t
        JOIN VONG_DAU v ON v.MaVongDau=t.MaVongDau AND v.MaGiaiDau=?
        JOIN CLB cl
        LEFT JOIN bt n ON n.MaTranDau=t.MaTranDau AND n.team=t.MaDoiNha
        LEFT JOIN bt k ON k.MaTranDau=t.MaTranDau AND k.team=t.MaDoiKhach
        LEFT JOIN the th ON th.MaTranDau=t.MaTranDau AND th.team=cl.MaCLB
        WHERE t.TrangThai='ĐÃ KẾT THÚC' AND t.MaVongDau<=?
          AND (cl.MaCLB=t.MaDoiNha OR cl.MaCLB=t.MaDoiKhach)
      ) x GROUP BY x.MaCLB""", (ma_giai, mv))
    db = get_db()
    db.execute("DELETE FROM BANG_XEP_HANG WHERE MaVongDau=?", (mv,))
    ranked = sorted(rows, key=lambda r: (-(r["SoTranThang"] * 3 + r["SoTranHoa"]),
                                         -(r["TongBanThang"] - r["TongBanThua"]),
                                         -r["TongBanThang"], r["DiemFairPlay"]))
    for i, r in enumerate(ranked, 1):
        db.execute("""INSERT INTO BANG_XEP_HANG
                      (MaVongDau,MaCLB,SoTranDaDau,SoTranThang,SoTranHoa,SoTranThua,
                       TongBanThang,TongBanThua,DiemFairPlay,ThuHang)
                      VALUES (?,?,?,?,?,?,?,?,?,?)""",
                   (mv, r["MaCLB"], r["SoTranDaDau"], r["SoTranThang"], r["SoTranHoa"],
                    r["SoTranThua"], r["TongBanThang"], r["TongBanThua"], r["DiemFairPlay"], i))
    db.commit()
    return len(ranked)


@app.route("/bang-xep-hang")
@login_required()
def bxh():
    ma_giai = int(request.args.get("giai", 1))
    if request.method == "POST" and can_edit():
        n = rebuild_bxh(ma_giai)
        flash(f"Đã kết xuất lại bảng xếp hạng ({n} CLB).", "success")
        return redirect(url_for("bxh", giai=ma_giai))
    vong = q1("""SELECT v.* FROM BANG_XEP_HANG b JOIN VONG_DAU v ON v.MaVongDau=b.MaVongDau
                 WHERE v.MaGiaiDau=? ORDER BY b.MaVongDau DESC LIMIT 1""", (ma_giai,))
    ds = []
    if vong:
        ds = q("""SELECT b.*, c.TenCLB, c.TenVietTom, c.Logo, s.TenSan
                  FROM BANG_XEP_HANG b JOIN CLB c ON c.MaCLB=b.MaCLB
                  JOIN SAN_VAN_DONG s ON s.MaSanVD=c.MaSanNha
                  WHERE b.MaVongDau=? ORDER BY b.ThuHang""", (vong["MaVongDau"],))
    gias = q("SELECT * FROM GIAI_DAU ORDER BY NamBatDau DESC")
    return render_template("bxh.html", vong=vong, ds=ds, gias=gias, ma_giai=ma_giai)


def can_edit():
    return LEVEL.get(session.get("quyen", "XEM"), 0) >= LEVEL["CAPNHAT"]


# ---------------------------------------------------------------- Lịch thi đấu / Trận đấu
@app.route("/lich-thi-dau")
@login_required()
def lich():
    ma_giai = int(request.args.get("giai", 1))
    vong = request.args.get("vong", "")
    where, args = ["vn.MaGiaiDau = ?"], [ma_giai]
    if vong:
        where.append("t.MaVongDau = ?")
        args.append(int(vong))
    ds = q(f"""SELECT t.*, vn.TenVong, vn.GiaiDoan, sn.TenSan,
                      d1.TenCLB doi_nha, d1.TenVietTom tt_nha, d1.Logo logo_nha,
                      d2.TenCLB doi_khach, d2.TenVietTom tt_khach, d2.Logo logo_khach
               FROM TRAN_DAU t
               JOIN VONG_DAU vn ON vn.MaVongDau=t.MaVongDau
               JOIN CLB d1 ON d1.MaCLB=t.MaDoiNha JOIN CLB d2 ON d2.MaCLB=t.MaDoiKhach
               JOIN SAN_VAN_DONG sn ON sn.MaSanVD=t.MaSanVD
               WHERE {' AND '.join(where)}
               ORDER BY t.NgayGioThiDau, t.MaTranDau""", args)
    for r in ds:
        r["bt_nha"], r["bt_khach"] = compute_score(r["MaTranDau"])
    gias = q("SELECT * FROM GIAI_DAU ORDER BY NamBatDau DESC")
    vongs = q("SELECT * FROM VONG_DAU WHERE MaGiaiDau=? ORDER BY MaVongDau", (ma_giai,))
    clbs = q("SELECT MaCLB, TenVietTom, TenCLB FROM CLB ORDER BY TenVietTom")
    sans = q("SELECT MaSanVD, TenSan FROM SAN_VAN_DONG ORDER BY TenSan")
    return render_template("lich.html", ds=ds, gias=gias, vongs=vongs, clbs=clbs, sans=sans,
                           ma_giai=ma_giai, vong_sel=vong)


@app.route("/lich-thi-dau/them", methods=["POST"])
@login_required("CAPNHAT")
def lich_them():
    try:
        run("""INSERT INTO TRAN_DAU (MaVongDau,MaDoiNha,MaDoiKhach,MaSanVD,NgayGioThiDau,TrangThai)
               VALUES (?,?,?,?,?,?)""",
            (int(request.form["MaVongDau"]), int(request.form["MaDoiNha"]),
             int(request.form["MaDoiKhach"]), int(request.form["MaSanVD"]),
             request.form["NgayGioThiDau"], request.form["TrangThai"]))
        flash("Đã thêm trận đấu vào lịch thi đấu.", "success")
    except (sqlite3.IntegrityError, ValueError) as e:
        flash(f"Không hợp lệ: {e}", "danger")
    return redirect(url_for("lich", giai=request.form.get("giai", 1)))


@app.route("/tran/<int:mid>")
@login_required()
def tran(mid):
    t = q1("""SELECT t.*, vn.TenVong, vn.GiaiDoan, vn.MaGiaiDau, sn.TenSan, sn.DiaChi,
                     d1.TenCLB doi_nha, d1.TenVietTom tt_nha, d1.Logo logo_nha,
                     d2.TenCLB doi_khach, d2.TenVietTom tt_khach, d2.Logo logo_khach
              FROM TRAN_DAU t JOIN VONG_DAU vn ON vn.MaVongDau=t.MaVongDau
              JOIN CLB d1 ON d1.MaCLB=t.MaDoiNha JOIN CLB d2 ON d2.MaCLB=t.MaDoiKhach
              JOIN SAN_VAN_DONG sn ON sn.MaSanVD=t.MaSanVD WHERE t.MaTranDau=?""", (mid,))
    if not t:
        abort(404)
    t["bt_nha"], t["bt_khach"] = compute_score(mid)
    su_kiens = q("""SELECT s.*, c.HoTen ten_chinh, p.HoTen ten_phu, cl.TenVietTom club
                    FROM SU_KIEN_TRAN_DAU s
                    JOIN CAU_THU c ON c.MaCauThu=s.MaCauThuChinh
                    LEFT JOIN CAU_THU p ON p.MaCauThu=s.MaCauThuPhu
                    LEFT JOIN CLB cl ON cl.MaCLB=c.MaCLB
                    WHERE s.MaTranDau=? ORDER BY s.Phut""", (mid,))
    doi_hinhs = q("""SELECT d.*, c.HoTen, c.ViTriSoTruong, cl.TenVietTom club
                    FROM DOI_HINH_TRAN_DAU d JOIN CAU_THU c ON c.MaCauThu=d.MaCauThu
                    LEFT JOIN CLB cl ON cl.MaCLB=c.MaCLB
                    WHERE d.MaTranDau=? ORDER BY cl.TenVietTom, d.LoaiRaSan, c.HoTen""", (mid,))
    trong_tais = q("""SELECT p.*, w.HoTen, w.CapDo FROM PHAN_CONG_TRONG_TAI p
                      JOIN TRONG_TAI w ON w.MaTrongTai=p.MaTrongTai WHERE p.MaTranDau=?
                      ORDER BY p.NhiemVu""", (mid,))
    # cầu thủ của 2 đội cho form thêm sự kiện/đội hình (kèm CLB để hiển thị)
    all_cs = q("""SELECT c.*, cl.TenVietTom club FROM CAU_THU c
                  LEFT JOIN CLB cl ON cl.MaCLB=c.MaCLB ORDER BY c.HoTen""")
    all_trong_tai = q("SELECT MaTrongTai, HoTen, CapDo FROM TRONG_TAI ORDER BY HoTen")
    return render_template("tran.html", t=t, su_kiens=su_kiens, doi_hinhs=doi_hinhs,
                           trong_tais=trong_tais, cs=all_cs, trong_tai_ds=all_trong_tai)


@app.route("/tran/<int:mid>/trangthai", methods=["POST"])
@login_required("CAPNHAT")
def tran_trangthai(mid):
    tt = request.form["TrangThai"]
    if tt not in ("CHƯA ĐÁ", "ĐANG ĐÁ", "ĐÃ KẾT THÚC", "HOÃN"):
        abort(400)
    run("UPDATE TRAN_DAU SET TrangThai=? WHERE MaTranDau=?", (tt, mid))
    if tt == "ĐÃ KẾT THÚC":
        giai = q1("SELECT v.MaGiaiDau FROM TRAN_DAU t JOIN VONG_DAU v ON v.MaVongDau=t.MaVongDau WHERE t.MaTranDau=?", (mid,))["MaGiaiDau"]
        rebuild_bxh(giai)
        flash("Chốt trận đấu - tỷ số tự động tổng hợp, bảng xếp hạng đã được kết xuất lại.", "success")
    else:
        flash("Đã cập nhật trạng thái trận đấu.", "success")
    return redirect(url_for("tran", mid=mid))


@app.route("/tran/<int:mid>/sukien", methods=["POST"])
@login_required("CAPNHAT")
def tran_sukien(mid):
    try:
        phu = request.form.get("MaCauThuPhu") or None
        run("""INSERT INTO SU_KIEN_TRAN_DAU (MaTranDau,LoaiSuKien,Phut,MaCauThuChinh,MaCauThuPhu)
               VALUES (?,?,?,?,?)""",
            (mid, request.form["LoaiSuKien"], int(request.form["Phut"]),
             int(request.form["MaCauThuChinh"]), int(phu) if phu else None))
        flash("Đã ghi nhận sự kiện. Tỷ số được tự động tổng hợp lại.", "success")
    except (sqlite3.IntegrityError, ValueError) as e:
        flash(f"Lỗi: {e}", "danger")
    return redirect(url_for("tran", mid=mid))


@app.route("/sukien/<int:sid>/delete", methods=["POST"])
@login_required("CAPNHAT")
def sukien_delete(sid):
    run("DELETE FROM SU_KIEN_TRAN_DAU WHERE MaSuKien=?", (sid,))
    flash("Đã xóa sự kiện.", "success")
    return redirect(request.referrer or url_for("index"))


@app.route("/tran/<int:mid>/doihinh", methods=["POST"])
@login_required("CAPNHAT")
def tran_doihinh(mid):
    try:
        run("""INSERT INTO DOI_HINH_TRAN_DAU (MaTranDau,MaCauThu,LoaiRaSan,DaiDoTruong)
               VALUES (?,?,?,?)""",
            (mid, int(request.form["MaCauThu"]), request.form["LoaiRaSan"],
             int(request.form.get("DaiDoTruong") or 0)))
        flash("Đã bổ sung đội hình ra sân.", "success")
    except sqlite3.IntegrityError:
        flash("Cầu thủ đã có trong đội hình trận này.", "danger")
    return redirect(url_for("tran", mid=mid))


@app.route("/phancong", methods=["POST"])
@login_required("CAPNHAT")
def phan_cong():
    try:
        run("INSERT INTO PHAN_CONG_TRONG_TAI (MaTranDau,MaTrongTai,NhiemVu) VALUES (?,?,?)",
            (int(request.form["MaTranDau"]), int(request.form["MaTrongTai"]), request.form["NhiemVu"]))
        flash("Đã phân công trọng tài.", "success")
    except sqlite3.IntegrityError:
        flash("Trọng tài này đã được phân công cho trận đó.", "danger")
    return redirect(request.referrer or url_for("index"))


# ---------------------------------------------------------------- Thống kê
@app.route("/thong-ke")
@login_required()
def thong_ke():
    ma_giai = int(request.args.get("giai", 1))
    gias = q("SELECT * FROM GIAI_DAU ORDER BY NamBatDau DESC")
    vua_pha_luoi = scorer_query(ma_giai, where="WHERE BanThang > 0", limit="")
    doi_nhieu_ban = q("""SELECT cl.TenCLB, cl.TenVietTom, cl.Logo, COUNT(*) BanThang
                         FROM SU_KIEN_TRAN_DAU s
                         JOIN TRAN_DAU t ON t.MaTranDau=s.MaTranDau
                         JOIN VONG_DAU v ON v.MaVongDau=t.MaVongDau
                         JOIN CAU_THU c ON c.MaCauThu=s.MaCauThuChinh
                         JOIN CLB cl ON cl.MaCLB=c.MaCLB
                         WHERE s.LoaiSuKien='BÀN THẮNG' AND v.MaGiaiDau=?
                         GROUP BY cl.MaCLB ORDER BY BanThang DESC""", (ma_giai,))
    the_phat = q("""SELECT cl.TenCLB, cl.TenVietTom,
                           SUM(s.LoaiSuKien='THẺ VÀNG') TheVang, SUM(s.LoaiSuKien='THẺ ĐỎ') TheDo
                    FROM SU_KIEN_TRAN_DAU s JOIN TRAN_DAU t ON t.MaTranDau=s.MaTranDau
                    JOIN VONG_DAU v ON v.MaVongDau=t.MaVongDau
                    JOIN CAU_THU c ON c.MaCauThu=s.MaCauThuChinh JOIN CLB cl ON cl.MaCLB=c.MaCLB
                    WHERE s.LoaiSuKien IN ('THẺ VÀNG','THẺ ĐỎ') AND v.MaGiaiDau=?
                    GROUP BY cl.MaCLB ORDER BY TheDo DESC, TheVang DESC""", (ma_giai,))
    return render_template("thongke.html", gias=gias, ma_giai=ma_giai,
                           vua=vua_pha_luoi, nhieu_ban=doi_nhieu_ban, the=the_phat)


# ---------------------------------------------------------------- Tìm kiếm
@app.route("/tim-kiem")
@login_required()
def tim_kiem():
    kw = (request.args.get("q") or "").strip()
    res = {"clb": [], "ct": [], "san": [], "hlv": [], "gd": [], "vong": [], "tran": []}
    if kw:
        like = f"%{kw}%"
        res["clb"] = q("SELECT * FROM CLB WHERE TenCLB LIKE ? OR TenVietTom LIKE ?", (like, like))
        res["ct"] = q("""SELECT c.*, cl.TenVietTom club FROM CAU_THU c
                        LEFT JOIN CLB cl ON cl.MaCLB=c.MaCLB WHERE c.HoTen LIKE ?""", (like,))
        res["san"] = q("SELECT * FROM SAN_VAN_DONG WHERE TenSan LIKE ? OR DiaChi LIKE ?", (like, like))
        res["hlv"] = q("""SELECT h.*, cl.TenVietTom club FROM BAN_HUAN_LUYEN h
                         JOIN CLB cl ON cl.MaCLB=h.MaCLB WHERE h.HoTen LIKE ?""", (like,))
        res["gd"] = q("SELECT * FROM GIAI_DAU WHERE TenGiai LIKE ?", (like,))
        res["vong"] = q("""SELECT v.*, g.TenGiai FROM VONG_DAU v JOIN GIAI_DAU g ON g.MaGiaiDau=v.MaGiaiDau
                          WHERE v.TenVong LIKE ?""", (like,))
        res["tran"] = q("""SELECT t.*, d1.TenVietTom nha, d2.TenVietTom khach FROM TRAN_DAU t
                           JOIN CLB d1 ON d1.MaCLB=t.MaDoiNha JOIN CLB d2 ON d2.MaCLB=t.MaDoiKhach
                           WHERE d1.TenCLB LIKE ? OR d2.TenCLB LIKE ?""", (like, like))
    return render_template("timkiem.html", kw=kw, res=res)


# ---------------------------------------------------------------- CRUD danh mục
CRUD_TABLES = {
    "giai-dau":   ("GIAI_DAU",   "MaGiaiDau",  ["TenGiai", "NamBatDau", "NamKetThuc", "NgayKhaiMac", "NgayBeMac", "TrangThai"], "Các giải đấu"),
    "san":        ("SAN_VAN_DONG", "MaSanVD",  ["TenSan", "SucChua", "DiaChi"], "Sân vận động"),
    "trong-tai":  ("TRONG_TAI",  "MaTrongTai", ["HoTen", "CapDo"], "Trọng tài"),
    "clb":        ("CLB",        "MaCLB",      ["TenCLB", "TenVietTom", "Logo", "MaSanNha"], "Câu lạc bộ"),
    "cau-thu":    ("CAU_THU",    "MaCauThu",   ["HoTen", "NgaySinh", "QuocTich", "LoaiCauThu", "ViTriSoTruong", "MaCLB"], "Cầu thủ"),
    "hlv":        ("BAN_HUAN_LUYEN", "MaHLV",  ["HoTen", "QuocTich", "ChucVu", "BangCap", "MaCLB"], "Ban huấn luyện"),
    "vong-dau":   ("VONG_DAU",   "MaVongDau",  ["MaGiaiDau", "TenVong", "GiaiDoan"], "Vòng đấu"),
    "dang-ky":    ("DANG_KY_CAU_THU", "MaDangKy", ["MaGiaiDau", "MaCLB", "MaCauThu", "SoAo", "ViTriDangKy", "TrangThai"], "Danh sách đăng ký cầu thủ"),
    "nhan-su":    ("NHAN_SU",    "MaNhanSu",   ["HoTen", "GioiTinh", "NgaySinh", "SoDienThoai", "Email", "ChucVu", "TrangThaiLamViec"], "Cán bộ ban tổ chức"),
}

LABELS = {
    "TenGiai": "Tên giải", "NamBatDau": "Năm bắt đầu", "NamKetThuc": "Năm kết thúc",
    "NgayKhaiMac": "Ngày khai mạc", "NgayBeMac": "Ngày bế mạc", "TrangThai": "Trạng thái",
    "TenSan": "Tên sân", "SucChua": "Sức chứa", "DiaChi": "Địa chỉ", "HoTen": "Họ tên",
    "CapDo": "Cấp độ", "TenCLB": "Tên CLB", "TenVietTom": "Tên viết tắt", "Logo": "Logo",
    "MaSanNha": "Sân nhà", "NgaySinh": "Ngày sinh", "QuocTich": "Quốc tịch",
    "LoaiCauThu": "Loại cầu thủ", "ViTriSoTruong": "Vị trí sở trường", "MaCLB": "CLB chủ quản",
    "ChucVu": "Chức vụ", "BangCap": "Bằng cấp", "MaGiaiDau": "Giải đấu", "TenVong": "Tên vòng",
    "GiaiDoan": "Giai đoạn", "MaCauThu": "Cầu thủ", "SoAo": "Số áo", "ViTriDangKy": "Vị trí đăng ký",
    "GioiTinh": "Giới tính", "SoDienThoai": "Điện thoại", "Email": "Email",
    "TrangThaiLamViec": "Trạng thái làm việc",
}

OPTIONS = {
    "GIAI_DAU": {"TrangThai": ["CHƯA BẮT ĐẦU", "ĐANG DIỄN RA", "ĐÃ KẾT THÚC"]},
    "TRONG_TAI": {"CapDo": ["FIFA", "Quốc gia", "Cấp 1", "Cấp 2"]},
    "CAU_THU": {"LoaiCauThu": ["Nội binh", "Ngoại binh", "Nhập tịch"]},
    "VONG_DAU": {"GiaiDoan": ["Lượt đi", "Lượt về", "Tranh vô địch", "Trụ hạng"]},
    "DANG_KY_CAU_THU": {"TrangThai": ["ĐANG HOẠT ĐỘNG", "NGỪNG ĐĂNG KÝ"]},
    "NHAN_SU": {"GioiTinh": ["Nam", "Nữ", "Khác"], "TrangThaiLamViec": ["1", "0"]},
}

FK_REF = {
    "MaSanNha": ("SAN_VAN_DONG", "MaSanVD", "TenSan"), "MaSanVD": ("SAN_VAN_DONG", "MaSanVD", "TenSan"),
    "MaCLB": ("CLB", "MaCLB", "TenCLB"), "MaCauThu": ("CAU_THU", "MaCauThu", "HoTen"),
    "MaGiaiDau": ("GIAI_DAU", "MaGiaiDau", "TenGiai"), "MaVongDau": ("VONG_DAU", "MaVongDau", "TenVong"),
    "MaTrongTai": ("TRONG_TAI", "MaTrongTai", "HoTen"), "MaTranDau": ("TRAN_DAU", "MaTranDau", "NULL"),
}


def fk_display(table, col, val):
    if val is None:
        return "<span class='text-muted'>Tự do / Không</span>"
    if table == "DANG_KY_CAU_THU" and col == "MaCauThu":
        r = q1("SELECT HoTen FROM CAU_THU WHERE MaCauThu=?", (val,))
        return r["HoTen"] if r else val
    ref = FK_REF.get(col)
    if not ref:
        return val
    t, pk, namecol = ref
    if namecol == "NULL":
        r = q1(f"SELECT CAST({pk} AS TEXT) v FROM {t} WHERE {pk}=?", (val,))
    else:
        r = q1(f"SELECT {namecol} v FROM {t} WHERE {pk}=?", (val,))
    return r["v"] if r else val


@app.route("/ql/<slug>")
@login_required()
def ql_list(slug):
    if slug not in CRUD_TABLES:
        abort(404)
    table, pk, cols, title = CRUD_TABLES[slug]
    rows = q(f"SELECT * FROM {table} ORDER BY {pk}")
    edit_id = request.args.get("edit", type=int)
    editing = q1(f"SELECT * FROM {table} WHERE {pk}=?", (edit_id,)) if edit_id else None
    # danh sách lựa chọn cho các cột FK
    fkopts = {}
    for c in cols:
        ref = FK_REF.get(c)
        if ref:
            t, rpk, namecol = ref
            if namecol == "NULL":
                opts = [(r[rpk], f"Trận #{r[rpk]}") for r in q(f"SELECT {rpk} FROM {t}")]
            else:
                opts = [(r[rpk], f"{r[namecol]}") for r in q(f"SELECT {rpk}, {namecol} FROM {t} ORDER BY {namecol}")]
            fkopts[c] = opts
    return render_template("crud.html", slug=slug, table=table, pk=pk, cols=cols,
                           title=title, rows=rows, editing=editing, labels=LABELS,
                           options=OPTIONS.get(table, {}), fkdisp=fk_display, fkopts=fkopts)


@app.route("/ql/<slug>", methods=["POST"])
@login_required("ADMIN")
def ql_save(slug):
    if slug not in CRUD_TABLES:
        abort(404)
    table, pk, cols, _ = CRUD_TABLES[slug]
    f = request.form
    vals = []
    for c in cols:
        v = f.get(c, "").strip()
        if v == "":
            vals.append(None)
        elif c in ("NamBatDau", "NamKetThuc", "SucChua", "SoAo", "MaSanNha", "MaCLB",
                   "MaCauThu", "MaGiaiDau", "MaVongDau", "TrangThaiLamViec"):
            vals.append(int(v))
        else:
            vals.append(v)
    try:
        if f.get("id"):
            run(f"UPDATE {table} SET {','.join(c+'=?' for c in cols)} WHERE {pk}=?",
                vals + [int(f["id"])])
            flash("Đã cập nhật bản ghi.", "success")
        else:
            run(f"INSERT INTO {table} ({','.join(cols)}) VALUES ({','.join('?'*len(cols))})", vals)
            flash("Đã thêm bản ghi mới.", "success")
    except sqlite3.IntegrityError as e:
        flash(f"Lỗi ràng buộc dữ liệu (FK/UNIQUE): {e}", "danger")
    return redirect(url_for("ql_list", slug=slug) + (f"?edit={f.get('id')}" if f.get("id") else ""))


@app.route("/ql/<slug>/delete/<int:rid>", methods=["POST"])
@login_required("ADMIN")
def ql_delete(slug, rid):
    if slug not in CRUD_TABLES:
        abort(404)
    table, pk, _, _ = CRUD_TABLES[slug]
    try:
        run(f"DELETE FROM {table} WHERE {pk}=?", (rid,))
        flash("Đã xóa bản ghi.", "success")
    except sqlite3.IntegrityError:
        flash("Không thể xóa: bản ghi đang được tham chiếu bởi dữ liệu khác.", "danger")
    return redirect(url_for("ql_list", slug=slug))


@app.errorhandler(403)
def err403(e):
    return render_template("error.html", code=403, msg="Bạn không đủ quyền thực hiện chức năng này."), 403


@app.errorhandler(404)
def err404(e):
    return render_template("error.html", code=404, msg="Không tìm thấy dữ liệu."), 404


if __name__ == "__main__":
    if not os.path.exists(DB_PATH):
        from seed import seed
        seed()
    app.run(debug=True, host="0.0.0.0", port=5000)
