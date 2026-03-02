"""Read Excel Fiche de stock and generate SQL INSERT for stock_products (store_id=2)."""
import pandas as pd

FILE_PATH = r"C:\Users\Mohamed Ben Arrouch\Downloads\Fiche de stock .xlsx"
OUTPUT_SQL = r"C:\Users\Mohamed Ben Arrouch\OneDrive\Desktop\PFS\storeyes-backend\scripts\stock_products_insert_store2.sql"
SHEET = "le comptoir Palmier"

# Excel category -> variable_charge_sub_categories.code
CAT_MAP = {
    "Bar": "bar",
    "Congelateur": "freezer",
    "Soda": "soda",
    "caisse": "cash_register",
    "cuisine": "kitchen",
    "hygienne": "hygiene",
}


def infer_unit(desig: str) -> str:
    d = desig.lower()
    if "/kg" in d or "/ kg" in d or " kg" in d:
        return "kg"
    if "/g" in d or "250g" in d or "500g" in d or "g/" in d:
        return "g"
    if "/l" in d or "/ l" in d or " litre" in d or " liter" in d or "litre" in d:
        return "L"
    if "33cl" in d or "cl" in d or "/cl" in d or " 33cl" in d:
        return "cl"
    if "/piece" in d or "/ piece" in d or "piece" in d or "pièce" in d or "piéce" in d:
        return "piece"
    if "/box" in d or "/ box" in d or "/boite" in d or "box" in d:
        return "box"
    if "plateau" in d:
        return "plateau"
    if "rll" in d or "roll" in d:
        return "roll"
    if "paquet" in d or "pack" in d:
        return "pack"
    return "unit"


def main():
    df = pd.read_excel(FILE_PATH, sheet_name=SHEET, header=None, engine="openpyxl")

    current_cat = None
    rows = []
    for i in range(2, len(df)):
        row = df.iloc[i]
        cat = row[0]
        if pd.notna(cat) and str(cat).strip():
            current_cat = str(cat).strip()
        prix = row[1]
        seuil = row[2]
        desig = row[3]
        if pd.isna(desig) or str(desig).strip() == "" or str(desig).strip() == "Designation":
            continue
        if current_cat not in CAT_MAP:
            continue
        desig = str(desig).strip().replace("'", "''")
        unit = infer_unit(desig)
        p = prix
        if pd.isna(p) or (isinstance(p, str) and not p.replace(".", "").replace("-", "").replace(" ", "").isdigit()):
            p = 0
        else:
            p = float(p)
        s = seuil
        if pd.isna(s) or (isinstance(s, str) and not str(s).replace(".", "").replace("-", "").replace(" ", "").isdigit()):
            s = 0
        else:
            s = float(s)
        rows.append({
            "category_code": CAT_MAP[current_cat],
            "designation": desig,
            "unit": unit,
            "prix": p,
            "seuil": s,
        })

    lines = [
        "-- INSERT stock_products for store_id = 2 (from Fiche de stock - le comptoir Palmier)",
        "-- Uses sub_category lookup by code for store 2 Stock main category",
        "-- Run in pgAdmin on your PostgreSQL DB",
        "",
    ]
    for r in rows:
        subq = f"(SELECT sc.id FROM variable_charge_sub_categories sc JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id WHERE mc.store_id = 2 AND mc.code = 'stock' AND sc.code = '{r['category_code']}')"
        sql = f"INSERT INTO stock_products (store_id, sub_category_id, name, unit, unit_price, minimal_threshold, created_at, updated_at) VALUES (2, {subq}, '{r['designation']}', '{r['unit']}', {r['prix']}, {r['seuil']}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);"
        lines.append(sql)
    lines.append("")
    lines.append(f"-- Total rows: {len(rows)}")

    content = "\n".join(lines)
    with open(OUTPUT_SQL, "w", encoding="utf-8") as f:
        f.write(content)
    print(content)


if __name__ == "__main__":
    main()
