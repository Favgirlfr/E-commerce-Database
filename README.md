E-Commerce Store Database Schema

📌 Objective

This project designs and implements a full-featured relational database for an E-commerce Store using MySQL.

The schema supports customers, products, orders, payments, shipments, reviews, and wishlists, ensuring data consistency through proper normalization and constraints.

🗂️ Overview

The database models an e-commerce platform with the following major entities:

Customers – Stores customer details.

Addresses – Supports multiple addresses per customer (billing & shipping).

Suppliers – Provides products to the store.

Categories – Groups products for easier browsing.

Products – Stores catalog items with pricing and inventory details.

Orders & OrderItems – Captures purchases and items per order.

Payments – Tracks transactions for each order.

Shippers & Shipments – Manages delivery logistics.

Reviews – Allows customers to rate and review products.

Wishlists & WishlistItems – Customers can save products for later.

🔑 Relationships

One-to-Many:

Customers → Orders

Orders → OrderItems

Suppliers → Products

Many-to-Many:

Products ↔ Categories (via ProductCategories)

Customers ↔ Products (via Wishlists and Reviews)

One-to-One:

Orders ↔ Payments

⚙️ Features

PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK, and DEFAULT constraints.

Composite keys for many-to-many join tables.

Stored generated column for LineTotal in OrderItems.

ENUM fields for controlled values (e.g., OrderStatus, PaymentStatus).

Indexes for fast lookups on products, orders, and inventory.

📂 File Contents

ecommerce.sql

CREATE DATABASE statement

CREATE TABLE statements for all entities

Constraints and relationships

🚀 How to Use

Open MySQL client or a tool like MySQL Workbench.

Run the file:

mysql -u username -p < ecommerce.sql

The database ecommerce_db will be created with all tables and relationships.

✅ Next Steps

Populate tables with sample data (INSERT statements).

Write queries for:

Retrieving customer orders.

Checking stock availability.

Tracking shipments.

Analyzing sales by category.
