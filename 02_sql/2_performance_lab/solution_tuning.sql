USE LegacyRetail_Reto;
GO

SET NOCOUNT ON;
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

/* ===========================
   CROSS JOIN (MALA)
   =========================== */
PRINT '--- CROSS JOIN (MALA) ---';

SELECT
    s.SucursalID,
    p.ProductoID,
    SUM(ISNULL(v.TotalLinea, 0)) AS VentasTotales
FROM dbo.Sucursales s
CROSS JOIN dbo.Productos p
LEFT JOIN dbo.Ventas v
  ON v.SucursalID = s.SucursalID
 AND v.ProductoID = p.ProductoID
GROUP BY s.SucursalID, p.ProductoID;
GO

/* ===========================
   INNER JOIN (BUENA)
   =========================== */
PRINT '--- INNER JOIN (BUENA) ---';

SELECT
    v.SucursalID,
    v.ProductoID,
    SUM(v.TotalLinea) AS VentasTotales
FROM dbo.Ventas v
INNER JOIN dbo.Sucursales s ON s.SucursalID = v.SucursalID
INNER JOIN dbo.Productos  p ON p.ProductoID = v.ProductoID
GROUP BY v.SucursalID, v.ProductoID;
GO

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


