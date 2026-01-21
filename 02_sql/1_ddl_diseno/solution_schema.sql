USE LegacyRetail_Reto;
GO
USE LegacyRetail_Reto;
GO

IF OBJECT_ID('dbo.Ventas', 'U') IS NOT NULL DROP TABLE dbo.Ventas;
IF OBJECT_ID('dbo.Productos', 'U') IS NOT NULL DROP TABLE dbo.Productos;
IF OBJECT_ID('dbo.Sucursales', 'U') IS NOT NULL DROP TABLE dbo.Sucursales;
IF OBJECT_ID('dbo.Clientes', 'U') IS NOT NULL DROP TABLE dbo.Clientes;
GO

CREATE TABLE dbo.Clientes (
    ClienteID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Clientes PRIMARY KEY,
    Nombre    VARCHAR(200) NOT NULL,
    Email     VARCHAR(200) NULL
);

CREATE TABLE dbo.Productos (
    ProductoID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Productos PRIMARY KEY,
    Nombre     VARCHAR(200) NOT NULL,
    Categoria  VARCHAR(100) NULL
);

CREATE TABLE dbo.Sucursales (
    SucursalID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sucursales PRIMARY KEY,
    Nombre     VARCHAR(150) NOT NULL,
    Ciudad     VARCHAR(120) NULL
);

CREATE TABLE dbo.Ventas (
    VentaID        BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Ventas PRIMARY KEY,
    TransaccionID  INT NULL,
    FechaVenta     DATE NOT NULL,
    ClienteID      INT NOT NULL,
    ProductoID     INT NOT NULL,
    SucursalID     INT NOT NULL,
    Cantidad       INT NOT NULL,
    PrecioUnitario DECIMAL(12,2) NOT NULL,
    TotalLinea     AS (Cantidad * PrecioUnitario) PERSISTED,

    CONSTRAINT FK_Ventas_Clientes   FOREIGN KEY (ClienteID)  REFERENCES dbo.Clientes(ClienteID),
    CONSTRAINT FK_Ventas_Productos  FOREIGN KEY (ProductoID) REFERENCES dbo.Productos(ProductoID),
    CONSTRAINT FK_Ventas_Sucursales FOREIGN KEY (SucursalID) REFERENCES dbo.Sucursales(SucursalID)
);

CREATE INDEX IX_Ventas_Cliente  ON dbo.Ventas (ClienteID);
CREATE INDEX IX_Ventas_Producto ON dbo.Ventas (ProductoID);
CREATE INDEX IX_Ventas_Sucursal ON dbo.Ventas (SucursalID);
GO

-- Clientes (normalizamos: nombre en UPPER, email en lower)
INSERT INTO dbo.Clientes (Nombre, Email)
SELECT DISTINCT
    UPPER(LTRIM(RTRIM(Cliente_Nombre))) AS Nombre,
    NULLIF(LOWER(LTRIM(RTRIM(Cliente_Email))), '') AS Email
FROM dbo.raw_sales_dump
WHERE Cliente_Nombre IS NOT NULL AND LTRIM(RTRIM(Cliente_Nombre)) <> '';

-- Productos
INSERT INTO dbo.Productos (Nombre, Categoria)
SELECT DISTINCT
    UPPER(LTRIM(RTRIM(Producto))) AS Nombre,
    NULLIF(UPPER(LTRIM(RTRIM(Categoria))), '') AS Categoria
FROM dbo.raw_sales_dump
WHERE Producto IS NOT NULL AND LTRIM(RTRIM(Producto)) <> '';

-- Sucursales
INSERT INTO dbo.Sucursales (Nombre, Ciudad)
SELECT DISTINCT
    UPPER(LTRIM(RTRIM(Sucursal))) AS Nombre,
    NULLIF(UPPER(LTRIM(RTRIM(Ciudad_Sucursal))), '') AS Ciudad
FROM dbo.raw_sales_dump
WHERE Sucursal IS NOT NULL AND LTRIM(RTRIM(Sucursal)) <> '';

-- Ventas
INSERT INTO dbo.Ventas (TransaccionID, FechaVenta, ClienteID, ProductoID, SucursalID, Cantidad, PrecioUnitario)
SELECT
    TRY_CONVERT(INT, r.Transaccion_ID),
    TRY_CONVERT(DATE, r.Fecha_Venta),
    c.ClienteID,
    p.ProductoID,
    s.SucursalID,
    TRY_CONVERT(INT, r.Cantidad),
    TRY_CONVERT(DECIMAL(12,2), r.Precio_Unitario)
FROM dbo.raw_sales_dump r
JOIN dbo.Clientes c
  ON c.Nombre = UPPER(LTRIM(RTRIM(r.Cliente_Nombre)))
 AND ISNULL(c.Email,'') = ISNULL(NULLIF(LOWER(LTRIM(RTRIM(r.Cliente_Email))),''),'')
JOIN dbo.Productos p
  ON p.Nombre = UPPER(LTRIM(RTRIM(r.Producto)))
 AND ISNULL(p.Categoria,'') = ISNULL(NULLIF(UPPER(LTRIM(RTRIM(r.Categoria))),''),'')
JOIN dbo.Sucursales s
  ON s.Nombre = UPPER(LTRIM(RTRIM(r.Sucursal)))
 AND ISNULL(s.Ciudad,'') = ISNULL(NULLIF(UPPER(LTRIM(RTRIM(r.Ciudad_Sucursal))),''),'')
WHERE TRY_CONVERT(DATE, r.Fecha_Venta) IS NOT NULL
  AND TRY_CONVERT(INT, r.Cantidad) IS NOT NULL
  AND TRY_CONVERT(DECIMAL(12,2), r.Precio_Unitario) IS NOT NULL;
GO

-- Validación
SELECT COUNT(*) AS RawRows FROM dbo.raw_sales_dump;
SELECT COUNT(*) AS Clientes FROM dbo.Clientes;
SELECT COUNT(*) AS Productos FROM dbo.Productos;
SELECT COUNT(*) AS Sucursales FROM dbo.Sucursales;
SELECT COUNT(*) AS Ventas FROM dbo.Ventas;
GO



