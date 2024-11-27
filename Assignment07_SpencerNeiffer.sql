--*************************************************************************--
-- Title: Assignment07
-- Author: Spencer_Neiffer
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,Spencer_Neiffer,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_Spencer_Neiffer')
	 Begin 
	  Alter Database [Assignment07DB_Spencer_Neiffer] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_Spencer_Neiffer;
	 End
	Create Database Assignment07DB_Spencer_Neiffer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_Spencer_Neiffer;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --

/*
-	Create a SELECT statement to grab the ProductName column and a new column called UnitPrice.
-	Use a FORMAT function to put the dollars in currency form using USD.
-	Add the Products view to the FROM clause and order results by the ProductName column.
*/

SELECT
	ProductName,
	FORMAT(UnitPrice, 'C', 'en-us') AS 'UnitPrice'
FROM
	vProducts
ORDER BY
	ProductName
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --

/*
-	Create a SELECT statement including CategoryName and ProductName columns, and a new column called UnitPrice.
-	Use a FORMAT function to put the dollars in currency form using USD.
-	Add the Categories view and INNER JOIN it to the Products view on the CategoryID column, give the views aliases.
-	Order results by the CategoryName and ProductName columns.
*/

SELECT
	c.CategoryName,
	p.ProductName,
	Format(UnitPrice, 'C', 'en-us') AS 'UnitPrice'
From
	vCategories AS c
INNER JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
ORDER BY
	CategoryName,
	ProductName
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

/*
-	Create a SELECT statement and add the ProductName column, and two new columns called InventoryDate and InventoryCount.
-	Use the DateName function to display the InventoryDate as spelled month and 4 digit year.
-	Use the SUM function to add the values in the Count column and display them in the InventoryCount column.
-	Add the Products view and INNER JOIN it to the Inventories view on the ProductID column, give the views aliases.
-	Group results by all three columns and order by the ProductName column.
*/

SELECT
	p.ProductName,
	[InventoryDate] = DateName(mm, InventoryDate) + ', ' + DateName(yy, InventoryDate),
	[InventoryCount] = SUM(Count)
FROM
	vProducts AS p
INNER JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
GROUP BY
	ProductName,
	InventoryDate,
	InventoryDate
ORDER BY
	ProductName
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

/*
-	Create a SELECT statement including the ProductName column, and two new columns called InventoryDate and InventoryCount.
-	Add a TOP clause using 1000000000 so the results can be ordered.
-	Use the DateName function to display the InventoryDate as spelled month and 4 digit year.
-	Add the Products and Inventories views and INNER JOIN them on the ProductID column, giving them aliases.
-	Put the Count column from vInventories into the InventoryCount column.
-	Group results by all three columns
-	Order results by the ProductName, InventoryDate using the Month function, and InventoryCount columns, using order numbers from the TOP clause.
-	Wrap the whole statement in a CREATE VIEW clause WITH SCHEMABINDING.
*/

CREATE VIEW 
	vProductInventories
WITH SCHEMABINDING AS
	SELECT TOP 1000000000
	p.ProductName,
	[InventoryDate] = DateName(mm, i.InventoryDate) + ', ' + DateName(yy, i.InventoryDate),
	[InventoryCount] = (i.[Count])
FROM
	dbo.vProducts AS p
INNER JOIN
	dbo.vInventories AS i
ON
	p.ProductID = i.ProductID
GROUP BY
	InventoryDate,
	ProductName,
	i.[Count]
ORDER BY
	1,
	Month(InventoryDate),
	3
go

-- Check that it works: Select * From vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

/*
-	Create a SELECT statement showing the Categoryname column, and two new columns called InventoryDate, and InventoryCountByCategory.
-	Use the DateName function to display the InventoryDate as spelled month and 4 digit year.
-	Use a SUM function to add values in the Count column from vInventories and put then into the InventoryCountByCategory column.
-	Add the Categories and Products views and INNER JOIN them on the CategoryID column, giving them aliases.
-	Then INNER JOIN the Products and Inventories views on the ProductID column, giving vInventories an alias.
-	Group results by the InventoryDate and CategoryName columns.
-	Wrap entire statement in a CREATE VIEW clause WITH SCHEMABINDING. 
*/

CREATE VIEW
	vCategoryInventories
WITH SCHEMABINDING AS
	SELECT
		c.CategoryName,
		[InventoryDate] = DateName(mm, i.InventoryDate) + ', ' + DateName(yy, i.InventoryDate),
		SUM(i.[Count]) AS 'InventoryCountByCategory'
	FROM
		dbo.vCategories AS c
	INNER JOIN
		dbo.vProducts AS p
	ON
		c.CategoryID = p.CategoryID
	INNER JOIN
		dbo.vInventories AS i
	ON
		p.ProductID = i.ProductID
	GROUP BY
		InventoryDate,
		CategoryName
		go
-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --

/*
-	Create SELECT statement including the ProductNamen, InventoryDate, and InventoryCount columns, and a new column called PreviousMonthCount.
-	Add a TOP clause using 1000000000 to later order the results.
-	In the PreviousMonthCount column, use the IIF, ISNULL, and LAG functions to replace NULL values in January with 0 and display values from one month prior.
-	Add vProductInventories after the FROM clause.
-	Order results by the ProductName, InventoryDate as Month, and the InventoryCount columns, using their order numbers.
-	Wrapp entire statement in a CREATE VIEW clause WITH SCHEMABINDING. 
*/

CREATE VIEW vProductInventoriesWithPreviousMonthCounts
	WITH SCHEMABINDING AS
SELECT TOP 1000000000
	o.ProductName,
	o.InventoryDate,
	InventoryCount,
	[PreviousMonthCount] = IIF(InventoryDate LIKE ('January%'), 0, IsNULL(LAG(InventoryCount)  OVER(ORDER BY YEAR(InventoryDate)), 0))
FROM
	dbo.vProductInventories AS o
ORDER BY
	1,
	Month(o.InventoryDate),
	3
go
	
	
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

/*
-	Create a SELECT statement including the ProductName, InventoryDate, InventoryCount, PreviousMonthCount, and a new column called CountVsPreviousCountKPI.
-	Add a TOP clause so the results can be ordered later.
-	Add a CASE to CountVsPreviousCountKPI to display 1 when InventoryCount is greater than PreviousMonthCount, 0 when they're equal, and -1 when it's less.
-	Add the vProductInventoriesWithPreviousMonthCounts view to the FROM clause.
-	Order the resulst by the ProductName and InventoryDate columns, using the Month function.
-	Wrap entire statement in a CREATE VIEW clause WITH SCHEMABINDING.
*/

CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
	WITH SCHEMABINDING 
	AS
SELECT TOP 1000000000
	ProductName,
	InventoryDate,
	InventoryCount,
	PreviousMonthCount,
	[CountVsPreviousCountKPI] = CASE
								WHEN InventoryCount > PreviousMonthCount THEN 1
								WHEN InventoryCount = PreviousMonthCount THEN 0
								WHEN InventoryCount < PreviousMonthCount THEN -1
								END
FROM
	dbo.vProductInventoriesWithPreviousMonthCounts
ORDER BY
	1,
	Month(InventoryDate)
;

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

/*
-	Create SELECT statement including columns ProductName, InventoryDate, InventoryCount, PreviousMonthCount, and CountVsPreviousCountKPI.
-	Add the vProductInventoriesWithPreviousMonthCountsWithKPIs to the FROM clause.
-	Wrap the statement in a CREATE FUNCTION clause and name it dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs.
-	Declare its value as an integer and call it 'KPIVALUE'.
-	Add a WHERE clause so the function will return the KPIValue from the CountVsPreviousCountKPI column.
*/

CREATE FUNCTION 
	dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPIValue int)
RETURNS TABLE AS
	RETURN SELECT
		ProductName,
		InventoryDate,
		InventoryCount,
		PreviousMonthCount,
		CountVsPreviousCountKPI
	FROM
		vProductInventoriesWithPreviousMonthCountsWithKPIs
	WHERE
		CountVsPreviousCountKPI = @KPIValue
go
;
		
/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/