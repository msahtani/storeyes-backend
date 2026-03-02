# -*- coding: utf-8 -*-
"""Generate SQL for Phases 2-4 + soda unit update. Output: scripts/PHASES_2_3_4_COMPLETE.sql"""
import json

STORE_ID = 2
ARTICLES_JSON = r"scripts/articles_parsed.json"
MAPPING_JSON = r"scripts/ingredient_to_stock_product_mapping.json"
OUTPUT_SQL = r"scripts/PHASES_2_3_4_COMPLETE.sql"

# Recipe ingredient -> stock_product name (from mapping)
INGREDIENT_TO_PRODUCT = {
    "Orange cl": "orange / box",
    "Citron cl": "Citron",
    "Fraise (g)": "fraise",
    "Avocat (g)": "avocat",
    "Mangue (g)": "mangue",
    "Ananas (g)": "ananas",
    "Gingembre": "gingembre",
    "Fruits secs": "raisin",
    "Lait": "lait",
    "Lait (cl)": "lait",
    "grain café (g)": "Café",
    "thé / verveine": "thé bellar",
    "Chocolat carraro (g)": "Chocolat carraro",
    "Sirop (ml)": "Sirop Vanille",
    "capsule": "nespresso / piece",
    "Œufs": "oeufs / plateau",
    "Farine": "farine nouara",
    "Sucre vanille": "ideal sucre vanille",
    "Beurre": "beure \"ladda\"",
    "Nutella": "Nutella 3kg",
    "Pistache": "sauce pistache",
    "Lotus": "Biscuit lotus",
    "Croissant": "croissant",
    "Glace": "glace vanille",
    "Sandwich": "Pain sandwich",
    "thon": "thon",
    "dinde fumé (u)": "dinde fumé",
    "oeuf (u)": "oeufs / plateau",
    "tomate (g)": "tomate",
    "Sirop": "Sirop Vanille",
    "Purée fruits": "Purée de fraise",
    "matcha (g)": "matcha",
    "Café": "Café",
    "Soda": "schweppes tonic 33cl",
    "Pain": "pain",
    "Crêpe": "fondant",
    "Œufs": "oeufs / plateau",
    "Khlie (g)": "khlie",
    "f/ss": "farine nouara",
    "thon": "thon",
    "Prix vente": None,
    "prix": None,
}

# Products to skip (no mapping or header artifacts)
SKIP_INGREDIENTS = {"Prix vente", "prix", "Prix chocolat", "prix vanille", "Prix chocolat", "Prix pistache"}


def subcat(code):
    return f"(SELECT sc.id FROM variable_charge_sub_categories sc JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id WHERE mc.store_id = {STORE_ID} AND mc.code = 'stock' AND sc.code = '{code}')"




def main():
    lines = []
    lines.append("-- =============================================================================")
    lines.append("-- PHASES 2, 3, 4 + SODA UNIT UPDATE - Run in pgAdmin")
    lines.append("-- store_id = 2 | Execute in order")
    lines.append("-- =============================================================================")
    lines.append("")

    # ---- SODA: Update all soda products to unit ----
    lines.append("-- -----------------------------------------------------------------------------")
    lines.append("-- SODA: Update all soda sub_category products to unit (sold by bottle)")
    lines.append("-- -----------------------------------------------------------------------------")
    lines.append("UPDATE stock_products sp SET unit = 'unit'")
    lines.append("FROM variable_charge_sub_categories sc")
    lines.append("JOIN variable_charge_main_categories mc ON sc.main_category_id = mc.id")
    lines.append(f"WHERE sp.sub_category_id = sc.id AND mc.store_id = {STORE_ID} AND mc.code = 'stock' AND sc.code = 'soda';")
    lines.append("")

    # ---- PHASE 2: Add missing stock products ----
    lines.append("-- -----------------------------------------------------------------------------")
    lines.append("-- PHASE 2: Add missing stock products (Citron, Gingembre, Avocat, thon, tomate, matcha)")
    lines.append("-- -----------------------------------------------------------------------------")
    missing = [
        ("Citron", "bar", "cl", 0, 2),
        ("gingembre", "bar", "g", 0, 1),
        ("avocat", "kitchen", "g", 0, 2),
        ("thon", "kitchen", "g", 0, 2),
        ("tomate", "kitchen", "g", 0, 2),
        ("matcha", "bar", "g", 0, 1),
    ]
    for name, subcat_code, unit, price, threshold in missing:
        lines.append(f"INSERT INTO stock_products (store_id, sub_category_id, name, unit, unit_price, minimal_threshold, created_at, updated_at)")
        lines.append(f"SELECT {STORE_ID}, {subcat(subcat_code)}, '{name}', '{unit}', {price}, {threshold}, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP")
        lines.append(f"WHERE NOT EXISTS (SELECT 1 FROM stock_products WHERE store_id = {STORE_ID} AND LOWER(name) = '{name}');")
        lines.append("")

    # ---- PHASE 3: Create tables ----
    lines.append("-- -----------------------------------------------------------------------------")
    lines.append("-- PHASE 3: Create articles and recipe_ingredients tables")
    lines.append("-- -----------------------------------------------------------------------------")
    lines.append("CREATE TABLE IF NOT EXISTS articles (")
    lines.append("    id BIGSERIAL PRIMARY KEY,")
    lines.append("    store_id BIGINT NOT NULL REFERENCES stores(id) ON DELETE CASCADE,")
    lines.append("    name VARCHAR(255) NOT NULL,")
    lines.append("    sale_price DECIMAL(12, 2) NOT NULL,")
    lines.append("    category VARCHAR(100) NULL,")
    lines.append("    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,")
    lines.append("    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP")
    lines.append(");")
    lines.append("CREATE INDEX IF NOT EXISTS idx_articles_store_id ON articles(store_id);")
    lines.append("CREATE INDEX IF NOT EXISTS idx_articles_store_name ON articles(store_id, name);")
    lines.append("")
    lines.append("CREATE TABLE IF NOT EXISTS recipe_ingredients (")
    lines.append("    id BIGSERIAL PRIMARY KEY,")
    lines.append("    article_id BIGINT NOT NULL REFERENCES articles(id) ON DELETE CASCADE,")
    lines.append("    product_id BIGINT NOT NULL REFERENCES stock_products(id) ON DELETE RESTRICT,")
    lines.append("    quantity DECIMAL(12, 4) NOT NULL,")
    lines.append("    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,")
    lines.append("    UNIQUE(article_id, product_id)")
    lines.append(");")
    lines.append("CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_article ON recipe_ingredients(article_id);")
    lines.append("CREATE INDEX IF NOT EXISTS idx_recipe_ingredients_product ON recipe_ingredients(product_id);")
    lines.append("")

    # ---- PHASE 4: Insert articles ----
    lines.append("-- -----------------------------------------------------------------------------")
    lines.append("-- PHASE 4: Insert articles")
    lines.append("-- -----------------------------------------------------------------------------")
    with open(ARTICLES_JSON, "r", encoding="utf-8") as f:
        data = json.load(f)

    for category, articles in data.items():
        for a in articles:
            name = a["article"].replace("'", "''")
            prix = a.get("prix_vente")
            if prix is None or prix == "-" or prix == "":
                prix = 0
            try:
                prix = float(prix)
            except (ValueError, TypeError):
                prix = 0
            lines.append(f"INSERT INTO articles (store_id, name, sale_price, category) SELECT {STORE_ID}, '{name}', {prix}, '{category}' WHERE NOT EXISTS (SELECT 1 FROM articles WHERE store_id = {STORE_ID} AND name = '{name}' AND category = '{category}');")

    lines.append("")

    # ---- PHASE 4: Insert recipe_ingredients ----
    lines.append("-- -----------------------------------------------------------------------------")
    lines.append("-- PHASE 4: Insert recipe_ingredients (article -> stock_product, quantity)")
    lines.append("-- -----------------------------------------------------------------------------")
    for category, articles in data.items():
        for a in articles:
            art_name = a["article"].replace("'", "''")
            for r in a.get("recipe", []):
                ing = r["ingredient"]
                qty = r["quantity"]
                if ing in SKIP_INGREDIENTS:
                    continue
                prod = INGREDIENT_TO_PRODUCT.get(ing)
                if prod is None:
                    prod = ing
                if prod:
                    prod_esc = prod.replace("'", "''")
                    lines.append(f"INSERT INTO recipe_ingredients (article_id, product_id, quantity)")
                    lines.append(f"SELECT a.id, p.id, {qty} FROM (SELECT id FROM articles WHERE store_id = {STORE_ID} AND name = '{art_name}' AND category = '{category}' LIMIT 1) a,")
                    lines.append(f"     (SELECT id FROM stock_products WHERE store_id = {STORE_ID} AND name = '{prod_esc}' LIMIT 1) p")
                    lines.append(f"WHERE a.id IS NOT NULL AND p.id IS NOT NULL")
                    lines.append(f"ON CONFLICT (article_id, product_id) DO UPDATE SET quantity = EXCLUDED.quantity;")

    lines.append("")
    lines.append("-- Done.")

    out = "\n".join(lines)
    with open(OUTPUT_SQL, "w", encoding="utf-8") as f:
        f.write(out)
    print(f"Generated {OUTPUT_SQL}")


if __name__ == "__main__":
    main()
