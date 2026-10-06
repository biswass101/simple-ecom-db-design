# E-commerce Database Design

This MySQL schema models an e-commerce catalog and order system. It is designed to support products with multiple purchasable variants and orders containing multiple products.

## Files

- `ecommerze.sql`: Creates the database, tables, relationships, indexes, and sample data.

## Database Setup

The SQL script creates and selects the following database:

```sql
luxurylo_naeembiswassniloy_ecommerce_db
```

It uses `utf8mb4` with the `utf8mb4_unicode_ci` collation.

Run the script with a MySQL client:

```bash
mysql -u <username> -p < ecommerze.sql
```

## Schema Overview

```text
products 1 ────< product_variants
orders   1 ────< order_items >──── 1 product_variants
```

An order can therefore contain many variants, and the same variant can be included in many different orders over time.

## Tables

### `products`

Stores information common to all variants of a product:

- `id`: Primary key.
- `name`: Product name.
- `description`: General product description.
- `created_at`, `updated_at`: Audit timestamps.

A product is the parent record for one or more entries in `product_variants`.

### `product_variants`

Stores each independently purchasable version of a product:

- `product_id`: Foreign key to `products`.
- `sku`: Unique stock-keeping unit for inventory and ordering.
- `size`, `color`, `model`: Variant-specific attributes.
- `weight`: Variant weight.
- `price`: Current price for the variant.
- `image_url`: Image associated with the variant.
- `stock_quantity`: Available inventory.

A single product can have different prices, images, SKUs, and stock levels for each variant. Deleting a product cascades to its variants.

### `orders`

Stores order-level information:

- `id`: Primary key.
- `status`: Order lifecycle state: `pending`, `confirmed`, `processing`, `shipped`, `delivered`, or `cancelled`.
- `total_amount`: Stored order total.
- `created_at`, `updated_at`: Audit timestamps.

The current design intentionally keeps customer and shipping information outside this task's scope.

### `order_items`

Associates orders with the exact variants purchased:

- `order_id`: Foreign key to `orders`.
- `product_variant_id`: Foreign key to `product_variants`.
- `quantity`: Number of units purchased.
- `unit_price`: Price captured when the item was ordered.

`unit_price` is stored separately from the current variant price so historical orders remain accurate when catalog prices change. An order can contain multiple rows, allowing it to include multiple products or variants.

## Normalization

- Product-level data is stored once in `products`.
- Variant-level data is stored in `product_variants`, avoiding repeated product descriptions and names.
- The many-to-many order relationship is normalized through `order_items` instead of storing product IDs in a comma-separated field.
- Order-specific values such as quantity and purchase price belong to `order_items`.
- Foreign keys protect referential integrity and define delete behavior.

## Relationship and Delete Behavior

- `products` to `product_variants`: one-to-many.
- `orders` to `order_items`: one-to-many.
- `product_variants` to `order_items`: one-to-many.
- Deleting an order deletes its order items with `ON DELETE CASCADE`.
- A variant referenced by an order item cannot be deleted because the relationship uses `ON DELETE RESTRICT`.
- Updates to referenced IDs cascade with `ON UPDATE CASCADE`.

Restricting deletion of ordered variants preserves historical order references. In production, discontinued variants should generally be marked inactive rather than physically deleted.

## Indexing

The schema includes indexes for common access paths:

- Product name searches.
- Variants by product, size, and color.
- Order items by order and variant.
- Orders by status and creation time.
- Unique SKU lookup.

These indexes support catalog browsing, order retrieval, inventory lookup, and operational order management.

## Sample Data

The script inserts:

- Three products.
- Seven product variants with different sizes, colors, models, prices, images, and stock quantities.
- Two orders with different statuses.
- Order items demonstrating that one order can contain multiple variants.

For example, order `1` contains two Nike T-shirt variants, while order `2` contains a Samsung Galaxy S25 variant.

## Example Queries

Get a product with all of its variants:

```sql
SELECT
    p.id,
    p.name,
    pv.sku,
    pv.size,
    pv.color,
    pv.model,
    pv.price,
    pv.image_url,
    pv.stock_quantity
FROM products AS p
JOIN product_variants AS pv ON pv.product_id = p.id
WHERE p.id = 1;
```

Get all items in an order:

```sql
SELECT
    oi.order_id,
    p.name,
    pv.sku,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS line_total
FROM order_items AS oi
JOIN product_variants AS pv ON pv.id = oi.product_variant_id
JOIN products AS p ON p.id = pv.product_id
WHERE oi.order_id = 1;
```

## Scalability Considerations

For a production system, the schema can be extended with:

- A customer or user table linked to `orders`.
- Shipping, billing, payment, and fulfillment tables.
- Separate product attribute tables if variant attributes become highly dynamic.
- A `status_history` table for auditing order state changes.
- Inventory transaction and warehouse tables instead of relying only on `stock_quantity`.
- Soft-delete or active-status fields for products and variants.
- Additional composite indexes based on measured query patterns.
- Transactional order creation that validates stock, records order items, calculates totals, and updates inventory atomically.
- Decimal monetary values with an explicit currency column for multi-currency support.

## Design Summary

This design satisfies the task requirements by separating shared product data from variant-specific data and by resolving the relationship between orders and purchasable variants through `order_items`. It avoids data duplication, preserves historical purchase prices, enforces referential integrity, and provides a foundation for adding customers, inventory, payments, and fulfillment as the application grows.
