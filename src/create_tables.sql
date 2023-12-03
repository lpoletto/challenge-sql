--Autor: Lautaro Poletto

CREATE DATABASE Ecommerce;
GO

USE [Ecommerce]
GO

IF OBJECT_ID('[dbo].[CustomerType]', 'U') IS NULL
CREATE TABLE dbo.CustomerType(
    CustomerTypeID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    TypeName VARCHAR(50) NOT NULL
);


IF OBJECT_ID('[dbo].[Customer]', 'U') IS NULL
CREATE TABLE dbo.Customer(
    CustomerID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(50) NOT NULL UNIQUE,
    [Address] VARCHAR(100) NOT NULL,
    BirthDate DATE NOT NULL,
    Sex CHAR(1) NOT NULL,
    CustomerTypeID INT NOT NULL,

    CONSTRAINT FK_Customer_Type FOREIGN KEY (CustomerTypeID)
    REFERENCES CustomerType(CustomerTypeID)
);
-- Agregar INDEX a la tabla Customer
CREATE NONCLUSTERED INDEX idx_customer_type
ON Customer(CustomerTypeID);



IF OBJECT_ID('[dbo].[Category]', 'U') IS NULL
CREATE TABLE dbo.Category(
    CategoryID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL,
    CategoryDescription VARCHAR(150) NULL,
    [PATH] VARCHAR(500) NOT NULL
);


IF OBJECT_ID('[dbo].[ItemStatus]', 'U') IS NULL
CREATE TABLE dbo.ItemStatus(
    ItemStatusID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    StatusName VARCHAR(50) NOT NULL
);


IF OBJECT_ID('[dbo].[Item]', 'U') IS NULL
CREATE TABLE dbo.Item(
    ItemID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ItemName VARCHAR(100) NOT NULL,
    ItemDescription VARCHAR(150) NULL,
    [Price] NUMERIC(18,2) NOT NULL,
    DateFrom DATE NOT NULL,
    DateUntil DATE NULL,
    CategoryID INT NOT NULL,
    ItemStatusID INT NOT NULL,
    SellerID INT NOT NULL, -- Para saber quien es el vendedor del producto
    
    CONSTRAINT FK_ItemCategory FOREIGN KEY (CategoryID)
    REFERENCES Category(CategoryID),

    CONSTRAINT FK_ItemStatus FOREIGN KEY (ItemStatusID)
    REFERENCES ItemStatus(ItemStatusID),
    
    CONSTRAINT FK_ItemCustomer FOREIGN KEY (SellerID)
    REFERENCES Customer(CustomerID)
);
-- Se agregan los index porque el volumen es muy grande debido a que se encuentran todos los productos
CREATE NONCLUSTERED INDEX idx_item_name
ON Item(ItemName);
CREATE NONCLUSTERED INDEX idx_item_status
ON Item(ItemStatusID);
CREATE NONCLUSTERED INDEX idx_item_category
ON Item(CategoryID);


IF OBJECT_ID('[dbo].[Order]', 'U') IS NULL
CREATE TABLE dbo.[Order]
(
    OrderID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Quantity INT NOT NULL,
    OrderDate DATE NOT NULL,
    ItemID INT NOT NULL,
    SellerID INT NOT NULL,
    BuyerID INT NOT NULL,

    CONSTRAINT FK_OrderSeller FOREIGN KEY (SellerID)
    REFERENCES Customer(CustomerID),

    CONSTRAINT FK_OrderBuyer FOREIGN KEY (BuyerID)
    REFERENCES Customer(CustomerID),
        
    CONSTRAINT FK_OrderItem FOREIGN KEY (ItemID)
    REFERENCES Item(ItemID)
);

-- Datos de prueba
USE [Ecommerce]
GO
SET IDENTITY_INSERT [dbo].[CustomerType] ON 
GO
INSERT [dbo].[CustomerType] ([CustomerTypeID], [TypeName]) VALUES (1, N'Vendedor')
GO
INSERT [dbo].[CustomerType] ([CustomerTypeID], [TypeName]) VALUES (2, N'Comprador')
GO
INSERT [dbo].[CustomerType] ([CustomerTypeID], [TypeName]) VALUES (3, N'Ambos')
GO
SET IDENTITY_INSERT [dbo].[CustomerType] OFF
GO
SET IDENTITY_INSERT [dbo].[Customer] ON 
GO
INSERT [dbo].[Customer] ([CustomerID], [FirstName], [LastName], [Email], [Address], [BirthDate], [Sex], [CustomerTypeID]) VALUES (1, N'Homer', N'Simpson', N'homer@example.com', N'742 Evergreen Terrace', CAST(N'1956-05-12' AS Date), N'M', 1)
GO
INSERT [dbo].[Customer] ([CustomerID], [FirstName], [LastName], [Email], [Address], [BirthDate], [Sex], [CustomerTypeID]) VALUES (2, N'Marge', N'Simpson', N'marge@example.com', N'742 Evergreen Terrace', CAST(N'1954-04-01' AS Date), N'F', 2)
GO
INSERT [dbo].[Customer] ([CustomerID], [FirstName], [LastName], [Email], [Address], [BirthDate], [Sex], [CustomerTypeID]) VALUES (3, N'Bart', N'Simpson', N'bart@example.com', N'742 Evergreen Terrace', CAST(N'1980-02-23' AS Date), N'M', 3)
GO
INSERT [dbo].[Customer] ([CustomerID], [FirstName], [LastName], [Email], [Address], [BirthDate], [Sex], [CustomerTypeID]) VALUES (4, N'Lisa', N'Simpson', N'lisa@example.com', N'742 Evergreen Terrace', CONVERT(DATE, CONCAT(1981,'-',MONTH(getdate()),'-',DAY(getdate()))), N'F', 1)
GO
INSERT [dbo].[Customer] ([CustomerID], [FirstName], [LastName], [Email], [Address], [BirthDate], [Sex], [CustomerTypeID]) VALUES (5, N'Milhouse', N'Van Houten', N'milhouse@example.com', N'745 Evergreen Terrace', CAST(N'1980-03-26' AS Date), N'M', 2)
GO
INSERT [dbo].[Customer] ([CustomerID], [FirstName], [LastName], [Email], [Address], [BirthDate], [Sex], [CustomerTypeID]) VALUES (6, N'Seymour', N'Skinner', N'skinner@example.com', N'123 Street Fake', CAST(N'1953-07-05' AS Date), N'M', 2)
GO
SET IDENTITY_INSERT [dbo].[Customer] OFF
GO
SET IDENTITY_INSERT [dbo].[Category] ON 
GO
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [CategoryDescription], [PATH]) VALUES (1, N'Celulares', N'Dispositivos de comunicación móvil', N'/categorias/celulares')
GO
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [CategoryDescription], [PATH]) VALUES (2, N'Electrodomésticos', N'Aparatos eléctricos para el hogar', N'/categorias/electrodomesticos')
GO
INSERT [dbo].[Category] ([CategoryID], [CategoryName], [CategoryDescription], [PATH]) VALUES (3, N'Ropa', N'Prendas de vestir y accesorios', N'/categorias/ropa')
GO
SET IDENTITY_INSERT [dbo].[Category] OFF
GO
SET IDENTITY_INSERT [dbo].[ItemStatus] ON 
GO
INSERT [dbo].[ItemStatus] ([ItemStatusID], [StatusName]) VALUES (1, N'Activo')
GO
INSERT [dbo].[ItemStatus] ([ItemStatusID], [StatusName]) VALUES (2, N'En pausa')
GO
INSERT [dbo].[ItemStatus] ([ItemStatusID], [StatusName]) VALUES (3, N'Eliminado')
GO
SET IDENTITY_INSERT [dbo].[ItemStatus] OFF
GO
SET IDENTITY_INSERT [dbo].[Item] ON 
GO
INSERT [dbo].[Item] ([ItemID], [ItemName], [ItemDescription], [Price], [DateFrom], [DateUntil], [CategoryID], [ItemStatusID], [SellerID]) VALUES (1, N'iPhone X', N'Último modelo de iPhone', CAST(999.99 AS Numeric(18, 2)), CAST(N'2023-01-01' AS Date), NULL, 1, 1, 1)
GO
INSERT [dbo].[Item] ([ItemID], [ItemName], [ItemDescription], [Price], [DateFrom], [DateUntil], [CategoryID], [ItemStatusID], [SellerID]) VALUES (2, N'Samsung Galaxy S21', N'Potente smartphone Android', CAST(799.99 AS Numeric(18, 2)), CAST(N'2023-01-01' AS Date), NULL, 1, 1, 1)
GO
INSERT [dbo].[Item] ([ItemID], [ItemName], [ItemDescription], [Price], [DateFrom], [DateUntil], [CategoryID], [ItemStatusID], [SellerID]) VALUES (3, N'Smart TV 55"', N'Televisor inteligente de alta definición', CAST(1299.99 AS Numeric(18, 2)), CAST(N'2023-01-01' AS Date), NULL, 2, 1, 1)
GO
INSERT [dbo].[Item] ([ItemID], [ItemName], [ItemDescription], [Price], [DateFrom], [DateUntil], [CategoryID], [ItemStatusID], [SellerID]) VALUES (4, N'Camiseta Bart Simpson', N'Camiseta con diseño de Bart Simpson', CAST(19.99 AS Numeric(18, 2)), CAST(N'2023-01-01' AS Date), NULL, 3, 1, 3)
GO
INSERT [dbo].[Item] ([ItemID], [ItemName], [ItemDescription], [Price], [DateFrom], [DateUntil], [CategoryID], [ItemStatusID], [SellerID]) VALUES (5, N'iPhone X Pro', N'Último modelo de iPhone X Pro', CAST(999.99 AS Numeric(18, 2)), CAST(N'2023-01-01' AS Date), NULL, 1, 1, 4)
GO
INSERT [dbo].[Item] ([ItemID], [ItemName], [ItemDescription], [Price], [DateFrom], [DateUntil], [CategoryID], [ItemStatusID], [SellerID]) VALUES (11, N'iPhone X Pro', N'Último modelo de iPhone X Pro', CAST(1100.99 AS Numeric(18, 2)), CAST(N'2023-01-10' AS Date), NULL, 1, 1, 3)
GO
SET IDENTITY_INSERT [dbo].[Item] OFF
GO
SET IDENTITY_INSERT [dbo].[Order] ON 
GO
INSERT [dbo].[Order] ([OrderID], [Quantity], [OrderDate], [ItemID], [SellerID], [BuyerID]) VALUES (1, 2, CAST(N'2020-02-01' AS Date), 1, 1, 2)
GO
INSERT [dbo].[Order] ([OrderID], [Quantity], [OrderDate], [ItemID], [SellerID], [BuyerID]) VALUES (2, 1, CAST(N'2020-03-02' AS Date), 2, 1, 3)
GO
INSERT [dbo].[Order] ([OrderID], [Quantity], [OrderDate], [ItemID], [SellerID], [BuyerID]) VALUES (3, 3, CAST(N'2020-02-10' AS Date), 11, 3, 2)
GO
INSERT [dbo].[Order] ([OrderID], [Quantity], [OrderDate], [ItemID], [SellerID], [BuyerID]) VALUES (4, 10, CAST(N'2020-01-12' AS Date), 5, 4, 5)
GO
INSERT [dbo].[Order] ([OrderID], [Quantity], [OrderDate], [ItemID], [SellerID], [BuyerID]) VALUES (6, 1, CAST(N'2020-01-10' AS Date), 11, 3, 5)
GO
INSERT [dbo].[Order] ([OrderID], [Quantity], [OrderDate], [ItemID], [SellerID], [BuyerID]) VALUES (8, 1, CAST(N'2020-02-11' AS Date), 11, 3, 6)
GO
SET IDENTITY_INSERT [dbo].[Order] OFF