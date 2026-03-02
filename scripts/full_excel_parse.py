# -*- coding: utf-8 -*-
"""Full parse of Fich pour storeyes.xlsx - extract all articles and recipe ingredients."""
import pandas as pd
import json

FILE = r"C:\Users\Mohamed Ben Arrouch\Downloads\Fich pour storeyes.xlsx"
OUT_JSON = r"C:\Users\Mohamed Ben Arrouch\OneDrive\Desktop\PFS\storeyes-backend\scripts\articles_parsed.json"
OUT_TXT = r"C:\Users\Mohamed Ben Arrouch\OneDrive\Desktop\PFS\storeyes-backend\scripts\articles_parsed.txt"


def parse_sheet(df, sheet_name):
    """Parse one sheet into articles with recipe ingredients."""
    articles = []
    header_row = df.iloc[0]
    cols = list(df.columns)
    # Identify ingredient columns: pairs of (quantity, price)
    ingredient_cols = []
    i = 2  # skip Article, Prix vente
    while i < len(cols) - 1:
        ing_header = str(header_row.iloc[i]).strip() if pd.notna(header_row.iloc[i]) else ""
        if ing_header and "total" not in ing_header.lower() and "co" not in ing_header.lower():
            ingredient_cols.append({"col": i, "header": ing_header})
        i += 2
    # Parse articles
    for r in range(1, len(df)):
        article_name = df.iloc[r, 0]
        if pd.isna(article_name) or not str(article_name).strip():
            continue
        prix_vente = df.iloc[r, 1]
        recipe = []
        for ing in ingredient_cols:
            qty = df.iloc[r, ing["col"]]
            if pd.notna(qty) and str(qty).strip():
                try:
                    qty_val = float(qty)
                except (ValueError, TypeError):
                    continue
                if qty_val > 0:
                    recipe.append({"ingredient": ing["header"], "quantity": qty_val})
        articles.append({
            "article": str(article_name).strip(),
            "prix_vente": prix_vente if pd.notna(prix_vente) else None,
            "recipe": recipe,
        })
    return articles


def main():
    xl = pd.ExcelFile(FILE, engine="openpyxl")
    result = {}
    all_ingredients = set()
    for sheet in xl.sheet_names:
        df = pd.read_excel(FILE, sheet_name=sheet, header=None, engine="openpyxl")
        articles = parse_sheet(df, sheet)
        result[sheet] = articles
        for a in articles:
            for r in a["recipe"]:
                all_ingredients.add(r["ingredient"])

    with open(OUT_JSON, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2, ensure_ascii=False)

    lines = ["INGREDIENTS (unique from all sheets):"]
    for ing in sorted(all_ingredients):
        lines.append(f"  - {ing}")

    lines.append("\n\nARTICLE COUNT PER SHEET:")
    for sheet, arts in result.items():
        lines.append(f"  {sheet}: {len(arts)} articles")

    lines.append("\n\nSAMPLE RECIPES (first 3 per sheet):")
    for sheet, arts in result.items():
        lines.append(f"\n--- {sheet} ---")
        for a in arts[:3]:
            lines.append(f"  {a['article']}: {a['recipe']}")

    with open(OUT_TXT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"JSON: {OUT_JSON}")
    print(f"TXT: {OUT_TXT}")
    print("Ingredients:", len(all_ingredients))
    return result


if __name__ == "__main__":
    main()
