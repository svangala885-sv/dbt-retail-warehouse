"""Generate synthetic seed CSVs for the warehouse. All values are random and fictional."""

import csv
import random
from datetime import datetime, timedelta
from pathlib import Path

rng = random.Random(11)
OUT = Path(__file__).resolve().parents[1] / "seeds"
STATES = ["CA", "TX", "NY", "WA", "IL", "CO", "GA", "NC"]
CATEGORIES = {"Audio": (20, 300), "Home": (10, 150), "Outdoor": (15, 400), "Office": (5, 120)}
T0 = datetime(2025, 1, 1)


def write(name, rows):
    with open(OUT / name, "w", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)
    print(f"{name}: {len(rows)} rows")


def main():
    OUT.mkdir(exist_ok=True)
    changes = []
    for i in range(1, 121):
        state = rng.choice(STATES)
        ts = T0 + timedelta(days=rng.randint(0, 60))
        changes.append({"customer_id": i, "first_name": f"First{i}", "last_name": f"Last{i}",
                        "email": f"customer{i}@example.com", "state": state, "updated_at": ts.isoformat()})
        if i % 6 == 0:  # some customers move state later in the year
            moved = rng.choice([s for s in STATES if s != state])
            changes.append({**changes[-1], "state": moved,
                            "updated_at": (ts + timedelta(days=rng.randint(90, 240))).isoformat()})
    write("raw_customer_changes.csv", changes)

    products = []
    for pid in range(1, 41):
        cat = rng.choice(list(CATEGORIES))
        lo, hi = CATEGORIES[cat]
        products.append({"product_id": pid, "product_name": f"{cat} Item {pid}", "category": cat,
                         "list_price": f"{rng.uniform(lo, hi):.2f}"})
    write("raw_products.csv", products)

    orders, items = [], []
    for oid in range(1, 1501):
        cust = rng.randint(1, 120)
        ts = T0 + timedelta(days=rng.randint(61, 364), minutes=rng.randint(0, 1439))
        status = rng.choices(["completed", "shipped", "cancelled", "returned"], [70, 15, 10, 5])[0]
        orders.append({"order_id": oid, "customer_id": cust, "ordered_at": ts.isoformat(), "status": status})
        for line in range(1, rng.randint(1, 4) + 1):
            p = rng.choice(products)
            items.append({"order_id": oid, "line_number": line, "product_id": p["product_id"],
                          "quantity": rng.randint(1, 3),
                          "unit_price": f"{float(p['list_price']) * rng.choice([1, 1, 1, 0.9, 0.8]):.2f}"})
    write("raw_orders.csv", orders)
    write("raw_order_items.csv", items)


if __name__ == "__main__":
    main()
