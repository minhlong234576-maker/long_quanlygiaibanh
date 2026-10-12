#!/usr/bin/env python3
"""
build_database.py - Tao CSDL QUAN_LY_BONG_DA (SQLite) tu ERD da duyet
(13 bang, 20 FK - chi cac cot PK/FK)

Cac DBMS khong co san trong moi truong nay (SQL Server/sqlcmd), nen dung
SQLite de tao va kiem chung thu nghiem. Chay:
    python3 database/build_database.py
"""

import os
import sqlite3

DB_DIR = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(DB_DIR, "QUAN_LY_BONG_DA.db")

# ---------------------------------------------------------------------------
# 13 BANG theo thu tu phu thuoc (cha truoc, con sau) - chi cot PK/FK
# ---------------------------------------------------------------------------
TABLES = [
    # (TenBang, [Cot], [FK: (ten_fk, cot, bang_tham_chieu, cot_tham_chieu)])
    ("GIAI_DAU",
     ["MaGiaiDau INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL"],
     []),

    ("SAN_VAN_DONG",
     ["MaSanVD INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL"],
     []),

    ("TRONG_TAI",
     ["MaTrongTai INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL"],
     []),

    ("VONG_DAU",
     ["MaVongDau INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaGiaiDau INTEGER NOT NULL"],
     [("FK_VD_GiaiDau", "MaGiaiDau", "GIAI_DAU", "MaGiaiDau")]),

    ("CLB",
     ["MaCLB INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaSanNha INTEGER NOT NULL"],
     [("FK_CLB_SanNha", "MaSanNha", "SAN_VAN_DONG", "MaSanVD")]),

    # MaCLB NULL - cau thu chua co CLB, theo dien giai ERD
    ("CAU_THU",
     ["MaCauThu INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaCLB INTEGER NULL"],
     [("FK_CauThu_CLB", "MaCLB", "CLB", "MaCLB")]),

    ("BAN_HUAN_LUYEN",
     ["MaHLV INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaCLB INTEGER NOT NULL"],
     [("FK_HLV_CLB", "MaCLB", "CLB", "MaCLB")]),

    ("DANG_KY_CAU_THU",
     ["MaDangKy INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaGiaiDau INTEGER NOT NULL",
      "MaCLB INTEGER NOT NULL",
      "MaCauThu INTEGER NOT NULL"],
     [("FK_DK_GiaiDau", "MaGiaiDau", "GIAI_DAU", "MaGiaiDau"),
      ("FK_DK_CLB", "MaCLB", "CLB", "MaCLB"),
      ("FK_DK_CauThu", "MaCauThu", "CAU_THU", "MaCauThu")]),

    ("BANG_XEP_HANG",
     ["MaBXH INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaVongDau INTEGER NOT NULL",
      "MaCLB INTEGER NOT NULL"],
     [("FK_BXH_VongDau", "MaVongDau", "VONG_DAU", "MaVongDau"),
      ("FK_BXH_CLB", "MaCLB", "CLB", "MaCLB")]),

    ("TRAN_DAU",
     ["MaTranDau INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaVongDau INTEGER NOT NULL",
      "MaDoiNha INTEGER NOT NULL",
      "MaDoiKhach INTEGER NOT NULL",
      "MaSanVD INTEGER NOT NULL"],
     [("FK_TD_VongDau", "MaVongDau", "VONG_DAU", "MaVongDau"),
      ("FK_TD_DoiNha", "MaDoiNha", "CLB", "MaCLB"),
      ("FK_TD_DoiKhach", "MaDoiKhach", "CLB", "MaCLB"),
      ("FK_TD_San", "MaSanVD", "SAN_VAN_DONG", "MaSanVD")]),

    ("DOI_HINH_TRAN_DAU",
     ["MaDoiHinh INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaTranDau INTEGER NOT NULL",
      "MaCauThu INTEGER NOT NULL"],
     [("FK_DH_TranDau", "MaTranDau", "TRAN_DAU", "MaTranDau"),
      ("FK_DH_CauThu", "MaCauThu", "CAU_THU", "MaCauThu")]),

    # MaCauThuPhu NULL - su kien khong phai luc nao cung co nguoi thay/tao
    ("SU_KIEN_TRAN_DAU",
     ["MaSuKien INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaTranDau INTEGER NOT NULL",
      "MaCauThuChinh INTEGER NOT NULL",
      "MaCauThuPhu INTEGER NULL"],
     [("FK_SK_TranDau", "MaTranDau", "TRAN_DAU", "MaTranDau"),
      ("FK_SK_Chinh", "MaCauThuChinh", "CAU_THU", "MaCauThu"),
      ("FK_SK_Phu", "MaCauThuPhu", "CAU_THU", "MaCauThu")]),

    ("PHAN_CONG_TRONG_TAI",
     ["MaPhanCong INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL",
      "MaTranDau INTEGER NOT NULL",
      "MaTrongTai INTEGER NOT NULL"],
     [("FK_PC_TranDau", "MaTranDau", "TRAN_DAU", "MaTranDau"),
      ("FK_PC_TrongTai", "MaTrongTai", "TRONG_TAI", "MaTrongTai")]),
]


def create_database(db_path: str) -> None:
    if os.path.exists(db_path):
        os.remove(db_path)

    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    # Bat buoc FK duoc thuc thi tren moi lenh INSERT/UPDATE/DELETE
    cur.execute("PRAGMA foreign_keys = ON;")

    for name, cols, fks in TABLES:
        ddl_cols = list(cols)
        for fk_name, col, ref_table, ref_col in fks:
            ddl_cols.append(
                f"CONSTRAINT {fk_name} FOREIGN KEY ({col}) "
                f"REFERENCES {ref_table}({ref_col})"
            )
        sql = f"CREATE TABLE {name} (\n    " + ",\n    ".join(ddl_cols) + "\n);"
        print(sql)
        cur.execute(sql)

    conn.commit()
    conn.close()
    print(f"\n>>> Da tao CSDL thanh cong: {db_path}")


def verify(db_path: str) -> bool:
    """Kiem tra: du 13 bang, du 20 FK, va FK duoc thuc thi."""
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    ok = True

    cur.execute(
        "SELECT name FROM sqlite_master WHERE type='table' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name;"
    )
    table_names = [r[0] for r in cur.fetchall()]
    print(f"So bang: {len(table_names)} (ky vong 13): {', '.join(table_names)}")
    ok &= len(table_names) == 13

    n_fk = 0
    for name in table_names:
        cnt = len(cur.execute(f"PRAGMA foreign_key_list({name});").fetchall())
        n_fk += cnt
        if cnt:
            print(f"  {name}: {cnt} FK")
    print(f"Tong so FK: {n_fk} (ky vong 20)")
    ok &= n_fk == 20

    # Thu nghiem rang buộc FK: vi pham phai bi tu choi
    cur.execute("PRAGMA foreign_keys = ON;")
    try:
        cur.execute("INSERT INTO VONG_DAU (MaGiaiDau) VALUES (999);")
        print("!! LOI: FK khong bi buoc buoc")
        ok = False
    except sqlite3.IntegrityError as e:
        print(f"OK: FK buoc buoc ({e})")

    conn.close()
    return ok


if __name__ == "__main__":
    create_database(DB_PATH)
    print("\n=== KIEM TRA ===")
    raise SystemExit(0 if verify(DB_PATH) else 1)
