# -*- coding: utf-8 -*-
"""Analyze Fich pour storeyes.xlsx - articles and recipes, map to stock_products."""
import pandas as pd
import json
import re

FILE = r"C:\Users\Mohamed Ben Arrouch\Downloads\Fich pour storeyes.xlsx"
OUT = r"C:\Users\Mohamed Ben Arrouch\OneDrive\Desktop\PFS\storeyes-backend\scripts\articles_analysis.txt"

# Stock products from our insert (name -> unit mapping)
STOCK_PRODUCTS = {
    "orange / box": "box",
    "lait": "unit",  # WRONG - recipe uses Lait (cl)
    "Citron": None,
    "Fraise": "g",
    "Avocat": "g",
    "Mangue": "g",
    "Ananas": "g",
    "Gingembre": None,
    "Fruits secs": None,
    "Café": "unit",  # WRONG - recipe uses grain café (g)
    "thé bellar": "unit",
    "Chocolat carraro": "unit",  # Recipe uses (g)
    "Sirop Vanille": "unit",
    "Sirop Chocolat": None,
    "Sirop pistache": "unit",
    "sauce pistache": "unit",  # ml in recipe
    "nespresso / piece": "piece",
    "Crème chatillé": "unit",
    "schweppes tonic 33cl": "cl",
    "pepsi 33cl": "cl",
    # ... more from stock insert
}


def safe_str(x):
    if pd.isna(x):
        return ""
    s = str(x).strip()
    return s.encode("ascii", "replace").decode() if s else ""


def extract_recipe_columns(df, row0):
    """Row 0 has headers: Article, Prix vente, then ingredient pairs (name, prix)."""
    cols = list(df.columns)
    recipe = []
    i = 2  # skip Article, Prix vente
    while i < len(cols) - 1:
        ing_name = df.iloc[0, i]
        ing_prix = df.iloc[0, i + 1] if i + 1 < len(cols) else None
        if pd.notna(ing_name) and str(ing_name).strip() and "total" not in str(ing_name).lower():
            recipe.append({"col_qty": i, "col_prix": i + 1, "header": str(ing_name).strip()})
        i += 2
    return recipe


def parse_unit_from_header(h):
    """Extract unit from header like 'Orange cl', 'Fraise (g)', 'Sirop (ml)'."""
    h = str(h).strip()
    m = re.search(r"\((\w+)\)", h)
    if m:
        return m.group(1).lower()
    if "cl" in h.lower():
        return "cl"
    if "ml" in h.lower():
        return "ml"
    if "g" in h.lower() or "kg" in h.lower():
        return "g" if "kg" not in h.lower() else "kg"
    if "capsule" in h.lower() or "piece" in h.lower():
        return "piece"
    return "unit"


def main():
    lines = []
    xl = pd.ExcelFile(FILE, engine="openpyxl")

    lines.append("=" * 80)
    lines.append("ARTICLES & RECIPES ANALYSIS - Fich pour storeyes.xlsx")
    lines.append("=" * 80)
    lines.append("")

    all_ingredients = set()
    articles_by_sheet = {}
    ingredient_units_from_recipes = {}

    for sheet in xl.sheet_names:
        df = pd.read_excel(FILE, sheet_name=sheet, header=None, engine="openpyxl")
        lines.append("")
        lines.append("-" * 60)
        lines.append(f"SHEET: {sheet} | Shape: {df.shape}")
        lines.append("-" * 60)

        # Headers in row 0
        headers_row = df.iloc[0]
        headers = [str(h).strip() for h in headers_row if pd.notna(h) and str(h).strip()]
        lines.append(f"Headers (row 0): {headers[:12]}...")
        lines.append("")

        # Parse recipe structure: pairs of (ingredient, prix)
        recipe_cols = []
        i = 2
        while i < len(df.columns) - 1:
            h = df.iloc[0, i]
            if pd.notna(h):
                unit = parse_unit_from_header(str(h))
                recipe_cols.append({"idx": i, "header": str(h).strip(), "inferred_unit": unit})
                all_ingredients.add(str(h).strip().split(" ")[0] if " " in str(h) else str(h).strip())
                # Normalize key for unit lookup
                key = str(h).strip()
                ingredient_units_from_recipes[key] = unit
            i += 2

        lines.append("Recipe ingredients (from headers):")
        for rc in recipe_cols[:20]:
            lines.append(f"  - {rc['header']} -> unit: {rc['inferred_unit']}")
        if len(recipe_cols) > 20:
            lines.append(f"  ... and {len(recipe_cols) - 20} more")
        lines.append("")

        # Articles (data rows 1+)
        articles = []
        for r in range(1, min(len(df), 50)):
            article_name = df.iloc[r, 0]
            if pd.isna(article_name) or not str(article_name).strip():
                continue
            articles.append(str(article_name).strip())

        articles_by_sheet[sheet] = articles
        lines.append(f"Articles ({len(articles)}): {articles[:8]}...")
        lines.append("")

    lines.append("")
    lines.append("=" * 80)
    lines.append("INGREDIENT -> UNIT mapping (from recipe headers)")
    lines.append("=" * 80)
    for k, v in sorted(ingredient_units_from_recipes.items(), key=lambda x: x[0]):
        lines.append(f"  {k} -> {v}")

    # Full sheet scan for all unique ingredient headers
    lines.append("")
    lines.append("=" * 80)
    lines.append("FULL INGREDIENT LIST (all sheets)")
    lines.append("=" * 80)
    all_ings = set()
    for sheet in xl.sheet_names:
        df = pd.read_excel(FILE, sheet_name=sheet, header=None, engine="openpyxl")
        for c in range(2, len(df.columns) - 1, 2):
            h = df.iloc[0, c]
            if pd.notna(h):
                all_ings.add(str(h).strip())
    for ing in sorted(all_ings):
        unit = parse_unit_from_header(ing)
        lines.append(f"  {ing} | unit: {unit}")

    # Stock product unit fixes
    lines.append("")
    lines.append("=" * 80)
    lines.append("STOCK_PRODUCTS UNIT FIXES NEEDED")
    lines.append("Recipe uses (cl, g, ml, piece) - stock_products must align for auto stock calc")
    lines.append("=" * 80)
    fixes = [
        ("lait", "cl", "Recipe: Lait (cl)"),
        ("Café / grain café", "g", "Recipe: grain café (g)"),
        ("Chocolat carraro", "g", "Recipe: Chocolat carraro (g)"),
        ("Sirop Vanille, Chocolat, Pistache", "ml", "Recipe: Sirop (ml)"),
        ("sauce pistache", "ml", "Recipe: Pistache (ml)"),
        ("Sodas (Hawai ananas, Sprit menth, Poms, oulmes)", "cl", "Bottles 33cl - use cl"),
        ("eau sidi ali 0,5l", "L", "0.5L bottle -> L or cl(50)"),
        ("Purée de fraise, etc.", "unit", "OK - sold per pot"),
        ("glace vanille, etc.", "unit", "OK - per tub"),
        ("Fruits (fraise, mangue, ananas) freezer", "g", "Recipe uses (g) - currently unit"),
    ]
    for name, correct_unit, reason in fixes:
        lines.append(f"  {name}: -> {correct_unit} | {reason}")

    with open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"Analysis written to {OUT}")
    return OUT


if __name__ == "__main__":
    main()
