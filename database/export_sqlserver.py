# -*- coding: utf-8 -*-
"""Xuat database live -> QUAN_LY_BONG_DA_SQLServer.sql (schema + trigger + data).
Chay: python database/export_sqlserver.py  (ghi de file .sql, UTF-8 BOM)"""
import codecs
import io
import os
import pyodbc
from datetime import date, datetime

BASE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(BASE, "QUAN_LY_BONG_DA_SQLServer.sql")

ORDER = ["NHAN_SU", "TAI_KHOAN", "GIAI_DAU", "SAN_VAN_DONG", "TRONG_TAI",
         "VONG_DAU", "CLB", "CAU_THU", "BAN_HUAN_LUYEN", "DANG_KY_CAU_THU",
         "BANG_XEP_HANG", "TRAN_DAU", "DOI_HINH_TRAN_DAU", "SU_KIEN_TRAN_DAU",
         "PHAN_CONG_TRONG_TAI"]

_CP1252_UNDEF = {0x81, 0x8D, 0x8F, 0x90, 0x9D}

def mojibake_decode(s):
    out = bytearray()
    for ch in s:
        o = ord(ch)
        if o < 0x80:
            out.append(o)
        elif 0x80 <= o <= 0x9F:
            out.append(o)
        else:
            try:
                out.extend(ch.encode("cp1252"))
            except UnicodeEncodeError:
                return None
    try:
        return bytes(out).decode("utf-8")
    except UnicodeDecodeError:
        return None

def mojibake_encode(f):
    out = []
    for b in f.encode("utf-8"):
        if b < 0x80:
            out.append(chr(b))
        elif b in _CP1252_UNDEF:
            out.append(chr(b))
        else:
            try:
                out.append(bytes([b]).decode("cp1252"))
            except UnicodeDecodeError:
                return None
    return "".join(out)

def fix(s):
    if s is None or s == "":
        return None
    f = mojibake_decode(s)
    if f is None or f == s:
        return None
    if mojibake_encode(f) != s:
        return None
    return f

def sql_type(tname, maxlen, prec, scale):
    if tname in ("int", "date", "datetime", "bit", "bigint", "smallint",
                 "tinyint", "float", "money", "smallmoney", "text", "ntext"):
        return tname.upper()
    if tname in ("nvarchar", "varchar", "char", "nchar", "binary", "varbinary"):
        if maxlen == -1:
            return "%s(MAX)" % tname.upper()
        ln = maxlen // 2 if tname.startswith("n") else maxlen
        return "%s(%d)" % (tname.upper(), ln)
    if tname in ("decimal", "numeric"):
        return "%s(%d,%d)" % (tname.upper(), prec, scale)
    raise ValueError("unknown type %s" % tname)

c = pyodbc.connect(
    "DRIVER={ODBC Driver 18 for SQL Server};SERVER=localhost;"
    "DATABASE=QUAN_LY_BONG_DA;Trusted_Connection=yes;"
    "TrustServerCertificate=yes;", timeout=30)
cur = c.cursor()
w = io.open(OUT, "w", encoding="utf-8-sig")  # BOM de SSMS tu nhan UTF-8

w.write("-- =====================================================================\n")
w.write("-- QUAN_LY_BONG_DA - Script SQL Server (TAI TAO TU LIVE DB)\n")
w.write("-- Quan ly Giai vo dich Bong da Quoc gia (V-League) - 15 bang\n")
w.write("-- Noi dung tieng Viet trong file nay la UNICODE chuan.\n")
w.write("-- Chay: sqlcmd -S localhost -E -f 65001 -i QUAN_LY_BONG_DA_SQLServer.sql\n")
w.write("--   (-f 65001 BAT BUOC de giu tieng Viet; neu chay sai encoding se\n")
w.write("--    sinh mojibake nhu truoc day. SSMS: mo file (co BOM) roi Execute.)\n")
w.write("-- =====================================================================\n\n")
w.write("IF DB_ID('QUAN_LY_BONG_DA') IS NULL\n    CREATE DATABASE QUAN_LY_BONG_DA;\nGO\n")
w.write("USE QUAN_LY_BONG_DA;\nGO\n\n")

# ---------- PHAN 1: CREATE TABLE ----------
w.write("-- =====================================================================\n")
w.write("-- PHAN 1: TAO BANG\n")
w.write("-- =====================================================================\n\n")
for t in ORDER:
    cur.execute("""SELECT c.name, ty.name, c.max_length, c.precision, c.scale,
                          c.is_nullable, c.is_identity
                   FROM sys.columns c JOIN sys.types ty ON ty.user_type_id = c.user_type_id
                   WHERE c.object_id = OBJECT_ID(?) ORDER BY c.column_id""", (t,))
    cols = cur.fetchall()
    cur.execute("""SELECT d.name, d.definition, col.name FROM sys.default_constraints d
                   JOIN sys.columns col ON col.object_id = d.parent_object_id
                   AND col.column_id = d.parent_column_id
                   WHERE d.parent_object_id = OBJECT_ID(?)""", (t,))
    defs = {r[2]: (r[0], r[1]) for r in cur.fetchall()}
    w.write("-- ================= %s =================\n" % t)
    w.write("IF OBJECT_ID('dbo.%s', 'U') IS NULL\nBEGIN\n" % t)
    w.write("    CREATE TABLE dbo.%s (\n" % t)
    lines = []
    for name, tname, maxlen, prec, scale, nul, ident in cols:
        line = "        %s %s" % (name, sql_type(tname, maxlen, prec, scale))
        if ident:
            line += " IDENTITY(1,1)"
        line += " NULL" if nul else " NOT NULL"
        if name in defs:
            line += " CONSTRAINT %s DEFAULT %s" % defs[name]
        lines.append(line)
    w.write(",\n".join(lines) + "\n    );\nEND;\nGO\n\n")

# ---------- PHAN 2: PK / UQ / FK / CHECK ----------
w.write("-- =====================================================================\n")
w.write("-- PHAN 2: KHOA CHINH / UNIQUE / KHOA NGOAI / CHECK\n")
w.write("-- =====================================================================\n\n")
for t in ORDER:
    # PK
    cur.execute("""SELECT k.name FROM sys.key_constraints k
                   WHERE k.parent_object_id = OBJECT_ID(?) AND k.type = 'PK'""", (t,))
    r = cur.fetchone()
    if r:
        pk = r[0]
        cur.execute("""SELECT c.name FROM sys.index_columns ic
                       JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                       JOIN sys.indexes i ON i.object_id = ic.object_id AND i.index_id = ic.index_id
                       WHERE i.object_id = OBJECT_ID(?) AND i.name = ? AND ic.is_included_column = 0
                       ORDER BY ic.key_ordinal""", (t, pk))
        cols = [x[0] for x in cur.fetchall()]
        w.write("ALTER TABLE dbo.%s ADD CONSTRAINT %s PRIMARY KEY (%s);\nGO\n"
                % (t, pk, ", ".join(cols)))
    # UQ
    cur.execute("""SELECT k.name FROM sys.key_constraints k
                   WHERE k.parent_object_id = OBJECT_ID(?) AND k.type = 'UQ'""", (t,))
    for (uq,) in cur.fetchall():
        cur.execute("""SELECT c.name FROM sys.index_columns ic
                       JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
                       JOIN sys.indexes i ON i.object_id = ic.object_id AND i.index_id = ic.index_id
                       WHERE i.object_id = OBJECT_ID(?) AND i.name = ? AND ic.is_included_column = 0
                       ORDER BY ic.key_ordinal""", (t, uq))
        cols = [x[0] for x in cur.fetchall()]
        w.write("ALTER TABLE dbo.%s ADD CONSTRAINT %s UNIQUE (%s);\nGO\n"
                % (t, uq, ", ".join(cols)))
# FK
cur.execute("""SELECT f.name, OBJECT_NAME(f.parent_object_id),
                      OBJECT_NAME(f.referenced_object_id),
                      f.delete_referential_action_desc, f.update_referential_action_desc
               FROM sys.foreign_keys f ORDER BY f.name""")
for fname, pt, rt, dact, uact in cur.fetchall():
    cur.execute("""SELECT pc.name, rc.name FROM sys.foreign_key_columns fkc
                   JOIN sys.columns pc ON pc.object_id = fkc.parent_object_id
                   AND pc.column_id = fkc.parent_column_id
                   JOIN sys.columns rc ON rc.object_id = fkc.referenced_object_id
                   AND rc.column_id = fkc.referenced_column_id
                   WHERE fkc.constraint_object_id = OBJECT_ID(?)
                   ORDER BY fkc.constraint_column_id""", (fname,))
    pairs = cur.fetchall()
    w.write("ALTER TABLE dbo.%s ADD CONSTRAINT %s FOREIGN KEY (%s) REFERENCES dbo.%s(%s)"
            % (pt, fname, ", ".join(p[0] for p in pairs), rt, ", ".join(p[1] for p in pairs)))
    if dact != "NO_ACTION":
        w.write(" ON DELETE %s" % dact.replace("_", " "))
    if uact != "NO_ACTION":
        w.write(" ON UPDATE %s" % uact.replace("_", " "))
    w.write(";\nGO\n")
# CHECK
cur.execute("SELECT OBJECT_NAME(parent_object_id), name, definition "
            "FROM sys.check_constraints ORDER BY name")
for pt, name, definition in cur.fetchall():
    w.write("ALTER TABLE dbo.%s ADD CONSTRAINT %s CHECK %s;\nGO\n" % (pt, name, definition))
w.write("\n")

# ---------- PHAN 3: TRIGGER ----------
w.write("-- =====================================================================\n")
w.write("-- PHAN 3: TRIGGER\n")
w.write("-- =====================================================================\n\n")
cur.execute("""SELECT t.name, m.definition FROM sys.triggers t
               JOIN sys.sql_modules m ON m.object_id = t.object_id
               WHERE t.is_ms_shipped = 0 ORDER BY t.name""")
for name, definition in cur.fetchall():
    f = fix(definition)
    if f is not None:
        w.write("-- (da sua mojibake trong thong bao loi)\n")
        definition = f
    w.write(definition.strip() + "\nGO\n\n")

# ---------- PHAN 4: DATA ----------
w.write("-- =====================================================================\n")
w.write("-- PHAN 4: DU LIEU THAT V-LEAGUE 2024/25\n")
w.write("-- =====================================================================\n\n")
for t in ORDER:
    cur.execute("SELECT COUNT(*) FROM %s" % t)
    n = cur.fetchone()[0]
    if n == 0:
        continue
    cur.execute("SELECT * FROM %s ORDER BY 1" % t)
    colnames = [d[0] for d in cur.description]
    rows = cur.fetchall()
    cur.execute("""SELECT c.name, ty.name FROM sys.columns c
                    JOIN sys.types ty ON ty.user_type_id = c.user_type_id
                    WHERE c.object_id = OBJECT_ID(?)""", (t,))
    coltypes = dict(cur.fetchall())
    cur.execute("SELECT COUNT(*) FROM sys.columns WHERE object_id = OBJECT_ID('%s') AND is_identity = 1" % t)
    has_ident = cur.fetchone()[0] > 0
    if has_ident:
        w.write("SET IDENTITY_INSERT dbo.%s ON;\n" % t)
    w.write("INSERT INTO dbo.%s (%s) VALUES\n" % (t, ", ".join(colnames)))
    vals = []
    for r in rows:
        parts = []
        for cn, v in zip(colnames, r):
            if v is None:
                parts.append("NULL")
            elif isinstance(v, bool):
                parts.append("1" if v else "0")
            elif isinstance(v, int):
                parts.append(str(v))
            elif isinstance(v, float):
                parts.append(repr(v))
            elif isinstance(v, datetime):
                parts.append("'%s'" % v.strftime("%Y-%m-%d %H:%M:%S"))
            elif isinstance(v, date):
                parts.append("'%s'" % v.isoformat())
            else:
                s = str(v).replace("'", "''")
                if coltypes.get(cn, "").startswith("n"):
                    parts.append("N'%s'" % s)
                else:
                    parts.append("'%s'" % s)
        vals.append("(%s)" % ", ".join(parts))
    w.write(",\n".join(vals) + ";\n")
    if has_ident:
        w.write("SET IDENTITY_INSERT dbo.%s OFF;\n" % t)
    w.write("GO\n\n")

w.write("-- =====================================================================\n")
w.write("-- PHAN 5: KIEM TRA\n")
w.write("-- =====================================================================\n")
for t in ORDER:
    w.write("SELECT '%s' AS Bang, COUNT(*) AS SoDong FROM dbo.%s;\n" % (t, t))
w.write("GO\n")
w.close()
print("wrote %s" % OUT)
