-- Create Database
CREATE DATABASE ecommerce_db
    DEFAULT CHARACTER SET utf8mb4
    COLLATE utf8mb4_general_ci;
USE ecommerce_db;

-- Customers table (1 - M with Orders, 1 - M with Addresses)
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(30),
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Customer Addresses (One customer can have many addresses)
CREATE TABLE Addresses (
    AddressID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    AddressLine1 VARCHAR(255) NOT NULL,
    AddressLine2 VARCHAR(255),
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Country VARCHAR(100) NOT NULL,
    IsDefault BOOLEAN NOT NULL DEFAULT FALSE,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Suppliers (one supplier supplies many products)
CREATE TABLE Suppliers (
    SupplierID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierName VARCHAR(200) NOT NULL,
    ContactEmail VARCHAR(255),
    ContactPhone VARCHAR(30),
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Categories (for products)
CREATE TABLE Categories (
    CategoryID INT AUTO_INCREMENT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE,
    Description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Products table
CREATE TABLE Products (
    ProductID INT AUTO_INCREMENT PRIMARY KEY,
    SupplierID INT,
    SKU VARCHAR(100) NOT NULL UNIQUE,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    Price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    Cost DECIMAL(10,2),
    Active BOOLEAN NOT NULL DEFAULT TRUE,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Many-to-Many: Products <-> Categories
CREATE TABLE ProductCategories (
    ProductID INT NOT NULL,
    CategoryID INT NOT NULL,
    PRIMARY KEY (ProductID, CategoryID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Inventory (One-to-One-ish per product variant; simplified)
CREATE TABLE Inventory (
    InventoryID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL UNIQUE,
    StockQty INT NOT NULL DEFAULT 0,
    ReorderLevel INT NOT NULL DEFAULT 0,
    LastRestock TIMESTAMP NULL,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Orders table (one customer can have many orders)
CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    ShippingAddressID INT,
    BillingAddressID INT,
    OrderStatus ENUM('Pending','Processing','Shipped','Delivered','Cancelled','Returned') NOT NULL DEFAULT 'Pending',
    OrderTotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UpdatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ShippingAddressID) REFERENCES Addresses(AddressID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (BillingAddressID) REFERENCES Addresses(AddressID) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- OrderItems (composite PK OrderID + ProductID) : Order -< OrderItems (1 - M)
CREATE TABLE OrderItems (
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL,
    LineTotal DECIMAL(12,2) AS (UnitPrice * Quantity) STORED,
    PRIMARY KEY (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Payments (one-to-one with orders: enforce unique OrderID)
CREATE TABLE Payments (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL UNIQUE,
    PaymentMethod ENUM('Card','PayPal','BankTransfer','Cash') NOT NULL,
    PaymentStatus ENUM('Pending','Completed','Failed','Refunded') NOT NULL DEFAULT 'Pending',
    Amount DECIMAL(12,2) NOT NULL,
    TransactionRef VARCHAR(255),
    PaidAt TIMESTAMP NULL,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Shippers (one shipper can handle many orders)
CREATE TABLE Shippers (
    ShipperID INT AUTO_INCREMENT PRIMARY KEY,
    ShipperName VARCHAR(200) NOT NULL,
    Phone VARCHAR(30)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Shipments (orders may have shipments assigned)
CREATE TABLE Shipments (
    ShipmentID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ShipperID INT,
    TrackingNumber VARCHAR(255),
    ShippedAt TIMESTAMP NULL,
    DeliveredAt TIMESTAMP NULL,
    Status ENUM('Prepared','InTransit','Delivered','Returned') NOT NULL DEFAULT 'Prepared',
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ShipperID) REFERENCES Shippers(ShipperID) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Product Reviews (Customers review products) : many-to-many through reviews
CREATE TABLE Reviews (
    ReviewID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID INT NOT NULL,
    CustomerID INT,
    Rating TINYINT NOT NULL CHECK (Rating >= 1 AND Rating <= 5),
    Title VARCHAR(255),
    Body TEXT,
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Wishlists (many-to-many: Customers <-> Products)
CREATE TABLE Wishlists (
    WishlistID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    Name VARCHAR(100) NOT NULL DEFAULT 'My Wishlist',
    CreatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE WishlistItems (
    WishlistID INT NOT NULL,
    ProductID INT NOT NULL,
    AddedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (WishlistID, ProductID),
    FOREIGN KEY (WishlistID) REFERENCES Wishlists(WishlistID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Indexes to speed up common lookups
CREATE INDEX idx_products_name ON Products (Name(100));
CREATE INDEX idx_orders_customer ON Orders (CustomerID);
CREATE INDEX idx_orderitems_product ON OrderItems (ProductID);
CREATE INDEX idx_inventory_product ON Inventory (ProductID);

