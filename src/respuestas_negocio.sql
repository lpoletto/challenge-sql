--Autor: Lautaro Poletto

--1.	Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas
--		realizadas en enero 2020 sea superior a 1500.
SELECT c.CustomerID, 
	c.FirstName,
	c.LastName, 
	c.Email
	--SUM(o.Quantity * i.Price) > 1500 as Sales
FROM [dbo].[Customer] c
INNER JOIN [dbo].[Order] o 
	ON	c.CustomerID = o.SellerID
INNER JOIN Item i
	ON o.ItemID = i.ItemID
WHERE 
	( MONTH(c.BirthDate) = MONTH(GETDATE()) AND DAY(c.BirthDate) = DAY(GETDATE()) )
	AND c.CustomerTypeID IN (1,3) -- Vendedor/Ambos
	AND o.OrderDate BETWEEN '2020-01-01' AND '2020-01-31'
	AND i.ItemStatusID = 1 -- Estado activo/disponible
GROUP BY c.CustomerID, c.FirstName, c.LastName, c.Email
HAVING SUM(o.Quantity * i.Price) > 1500;

-- 2.	Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la
--		categoría Celulares. Se requiere el mes y año de análisis, nombre y apellido del
--		vendedor, cantidad de ventas realizadas, cantidad de productos vendidos y el monto
--		total transaccionado.

-- Creo un CTE para que el codigo quede mejor organizado
WITH sales_top_amount_cte ([Año de análisis], Mes, Nombre, Apellido, [Cantiad de ventas realizadas], [Cantiad de productos vendidas], [Monto Total], Ranking) AS (
	SELECT 
		YEAR(o.OrderDate) as 'Año de análisis'
		,MONTH(o.OrderDate) as 'Mes'
		,c.FirstName
		,c.LastName
		,COUNT(o.OrderID) as 'Cantiad de ventas realizadas'
		,SUM(o.Quantity) as 'Cantiad de productos vendidas'
		,SUM(o.Quantity * i.Price) as 'Monto Total'
		,DENSE_RANK() OVER (PARTITION BY YEAR(o.OrderDate), MONTH(o.OrderDate) ORDER BY SUM(o.Quantity * i.Price) DESC) as 'Ranking'
	FROM [Order] o
	INNER JOIN Customer c
		ON o.SellerID = c.CustomerID
	INNER JOIN Item i
		ON o.ItemID = i.ItemID
	WHERE i.CategoryID = 1 -- Celulares
	AND i.ItemStatusID = 1 -- Estado disponible
	AND c.CustomerTypeID IN (1,3) -- Vendedor/Ambos
	AND o.OrderDate BETWEEN '2020-01-01' AND '2020-12-31'
	GROUP BY YEAR(o.OrderDate), MONTH(o.OrderDate), c.FirstName, c.LastName
)

SELECT [Año de análisis], Mes, Nombre, Apellido, [Cantiad de ventas realizadas], [Cantiad de productos vendidas], [Monto Total]
FROM sales_top_amount_cte
WHERE Ranking <= 5
ORDER BY [Año de análisis], Mes, [Monto Total] DESC


-- 3.	Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día.
-- 		Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item,
-- 		vamos a tener únicamente el último estado informado por la PK definida. (Se puede
-- 		resolver a través de StoredProcedure)

CREATE PROCEDURE populate_table_item_price_status
AS
BEGIN
	IF OBJECT_ID('dbo.ItemPriceStatus', 'U') IS NULL
	BEGIN
		CREATE TABLE ItemPriceStatus(
			ItemPriceStatusID int IDENTITY(1,1) PRIMARY KEY,
			ItemID int NOT NULL,
			Price numeric(18,2) NOT NULL,
			ItemStatus varchar(50) NOT NULL,
			LastStatusDate date NOT NULL,
			ExecutionTimestamp datetime NOT NULL,
			CONSTRAINT fk_item FOREIGN KEY (ItemID) 
			REFERENCES Item(ItemID)
		);
	END

	-- Borrar los datos del día anterior
	TRUNCATE TABLE ItemPriceStatus;

	-- Insertar los datos de los items a fin del dia
	INSERT INTO ItemPriceStatus(ItemID, Price, ItemStatus, LastStatusDate, ExecutionTimestamp)
	SELECT	ItemID
			,Price
			,ItemStatusID
			,IIF(ISNULL(DateUntil,'1900-01-01') > DateFrom, DateUntil, DateFrom) as LastStatusDate
			,GETDATE() as Timestamp_
	FROM Item

END;
GO
EXEC populate_table_item_price_status;
SELECT * FROM ItemPriceStatus;