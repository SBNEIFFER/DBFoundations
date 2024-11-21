--*************************************************************************--
-- Title: Assignment06
-- Author: Spencer_Neiffer
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,Spencer_Neiffer,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_Spencer_Neiffer')
	 Begin 
	  Alter Database [Assignment06DB_Spencer_Neiffer] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_Spencer_Neiffer;
	 End
	Create Database Assignment06DB_Spencer_Neiffer;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_Spencer_Neiffer;

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
,[UnitPrice] [mOney] NOT NULL
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
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
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
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

/*
-Create the SELECT statement that will encompass all columns from the table.
SELECT
	CategoryID,
	CategoryName
FROM
	dbo.Categories
;

-Wrap the SELECT statement with CREATE VIEW syntax.
GO
CREATE
VIEW 
	vCategories
AS
SELECT
	CategoryID,
	CategoryName
FROM
	dbo.Categories
;

-Add a SCHEMABINDING clause to protect view from being orphaned.
GO
CREATE
VIEW 
	vCategories
WITH SCHEMABINDING
AS
SELECT
	CategoryID,
	CategoryName
FROM
	dbo.Categories
;
*/

GO

CREATE VIEW 
	vCategories
WITH SCHEMABINDING
AS
SELECT
	CategoryID,
	CategoryName
FROM
	dbo.Categories
;
GO

/*
-Create the SELECT statement that will encompass all columns from the table.
SELECT
	ProductID,
	ProductName,
	CategoryID,
	UnitPrice
FROM
	dbo.Products
;

-Wrap the SELECT statement with CREATE VIEW syntax.
CREATE VIEW
	vProducts
AS
SELECT
	ProductID,
	ProductName,
	CategoryID,
	UnitPrice
FROM
	dbo.Products
;

-Add a SCHEMABINDING clause to protect view from being orphaned.
CREATE VIEW
	vProducts
WITH SCHEMABINDING
AS
SELECT
	ProductID,
	ProductName,
	CategoryID,
	UnitPrice
FROM
	dbo.Products
;
*/

CREATE VIEW
	vProducts
WITH SCHEMABINDING
AS
SELECT
	ProductID,
	ProductName,
	CategoryID,
	UnitPrice
FROM
	dbo.Products
;
GO

/*
-Create the SELECT statement that will encompass all columns from the table.
SELECT
	EmployeeID,
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
FROM
	dbo.Employees
;

-Wrap the SELECT statement with CREATE VIEW syntax.
CREATE VIEW
	vEmployees
AS
SELECT
	EmployeeID,
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
FROM
	dbo.Employees
;

-Add a SCHEMABINDING clause to protect view from being orphaned.
CREATE VIEW
	vEmployees
WITH SCHEMABINDING
AS
SELECT
	EmployeeID,
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
FROM
	dbo.Employees
;
*/

CREATE VIEW
	vEmployees
WITH SCHEMABINDING
AS
SELECT
	EmployeeID,
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
FROM
	dbo.Employees
;
GO

/*
-Create the SELECT statement that will encompass all columns from the table.
SELECT
	InventoryID,
	InventoryDate,
	EmployeeID,
	ProductID,
	Count
FROM
	dbo.Inventories
;

-Wrap the SELECT statement with CREATE VIEW syntax.
CREATE VIEW
	vInventories
AS
SELECT
	InventoryID,
	InventoryDate,
	EmployeeID,
	ProductID,
	Count
FROM
	dbo.Inventories
;

-Add a SCHEMABINDING clause to protect view from being orphaned.
CREATE VIEW
	vInventories
WITH SCHEMABINDING
AS
SELECT
	InventoryID,
	InventoryDate,
	EmployeeID,
	ProductID,
	Count
FROM
	dbo.Inventories
;
*/

CREATE VIEW
	vInventories
WITH SCHEMABINDING
AS
SELECT
	InventoryID,
	InventoryDate,
	EmployeeID,
	ProductID,
	Count
FROM
	dbo.Inventories
;
GO

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

/*
-Block PUBLIC group from selecting the actual table using DENY clause.
DENY SELECT ON Categories TO PUBLIC

-Allow PUBLIC group to select view representing the Categories table.
DENY SELECT ON Categories TO PUBLIC
GRANT SELECT ON vCategories TO PUBLIC
*/

USE
	Assignment06DB_Spencer_Neiffer
DENY SELECT ON Categories TO PUBLIC
GRANT SELECT ON vCategories TO PUBLIC
GO

/*
-Block PUBLIC group from selecting the actual table using DENY clause.
DENY SELECT ON Employees TO PUBLIC

-Allow PUBLIC group to select view representing the Employees table.
DENY SELECT ON Employees TO PUBLIC
GRANT SELECT ON vEmployees TO PUBLIC
*/

USE
	Assignment06DB_Spencer_Neiffer
DENY SELECT ON Employees TO PUBLIC
GRANT SELECT ON vEmployees TO PUBLIC
GO

/*
-Block PUBLIC group from selecting the actual table using DENY clause.
DENY SELECT ON Inventories TO PUBLIC

-Allow PUBLIC group to select view representing the Inventories table.
DENY SELECT ON Inventories TO PUBLIC
GRANT SELECT ON vInventories TO PUBLIC
*/

USE
	Assignment06DB_Spencer_Neiffer
DENY SELECT ON Inventories TO PUBLIC
GRANT SELECT ON vInventories TO PUBLIC
GO

/*
-Block PUBLIC group from selecting the actual table using DENY clause.
DENY SELECT ON Products TO PUBLIC

-Allow PUBLIC group to select view representing the Products table.
DENY SELECT ON Products TO PUBLIC
GRANT SELECT ON vProducts TO PUBLIC
*/

USE
	Assignment06DB_Spencer_Neiffer
DENY SELECT ON Products TO PUBLIC
GRANT SELECT ON vProducts TO PUBLIC
GO

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/*
-Create SELECT statement including CategoryName, ProductName, and UnitPrice and join the Categories and Products views with aliases.
SELECT
	c.CategoryName,
	p.ProductName,
	p.UnitPrice
FROM
	dbo.vCategories AS c
JOIN
	dbo.vProducts AS p
ON
	c.CategoryID = p.CategoryID
;

-Add VIEW syntax to SELECT statement.
CREATE VIEW
	vProductsByCategories
AS
SELECT
	c.CategoryName,
	p.ProductName,
	p.UnitPrice
FROM
	dbo.vCategories AS c
JOIN
	dbo.vProducts AS p
ON
	c.CategoryID = p.CategoryID
;

-Order the VIEW by CategoryName and ProductName
ORDER BY
	CategoryName,
	ProductName
;
*/

CREATE VIEW
	vProductsByCategories
AS
SELECT TOP 1000000000
	c.CategoryName,
	p.ProductName,
	p.UnitPrice
FROM
	dbo.vCategories AS c
INNER JOIN
	dbo.vProducts AS p
ON
	c.CategoryID = p.CategoryID
ORDER BY
	CategoryName,
	ProductName
;
GO

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

/*
-Create SELECT statement to include the ProductName, Count, and InventoryDate and JOIN the Products and Inventories views with aliases.
SELECT
	p.ProductName,
	i.InventoryDate,
	i.Count
FROM
	vProducts AS p
JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
;

-Add VIEW syntax to SELECT statement and assign view name as vProductCountOnDate
CREATE VIEW
	vInventoriesByProductsByDates
AS
SELECT
	p.ProductName,
	i.InventoryDate,
	i.Count
FROM
	vProducts AS p
JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
;

-Order the view by ProductName, InventoryDate, and Count.
ORDER BY
	ProductName,
	InventoryDate,
	Count
;
*/

CREATE VIEW
	vInventoriesByProductsByDates
AS
SELECT TOP 1000000000
	p.ProductName,
	i.InventoryDate,
	i.Count
FROM
	vProducts AS p
INNER JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
ORDER BY
	ProductName,
	InventoryDate,
	Count
;
GO

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

/*
-Create SELECT statement to inlude the InventoryDate column and the EmployeeName column as a concatenation of the first and last name columns. Join Inventory and Employee views and give them aliases.
SELECT DISTINCT
	i.InventoryDate,
	[Employee Name] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM
	vInventories AS i
JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID

-Add CREATE VIEW syntax to SELECT statement giving it the name vEmployeeInventoryDate.
CREATE VIEW
	
AS
	vInventoriesByEmployeesByDates
SELECT DISTINCT
	i.InventoryDate,
	[Employee Name] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM
	vInventories AS i
JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
;

-Display the view and order results by InventoryDate.
ORDER BY
	InventoryDate
;
*/

CREATE VIEW
	vInventoriesByEmployeesByDates
AS
SELECT DISTINCT TOP 1000000000
	i.InventoryDate,
	[Employee Name] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM
	vInventories AS i
INNER JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
ORDER BY
	InventoryDate
;
GO

-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

/*
-Create the SELECT statement including the CategoryName, ProductName, InventoryDate, and Count columns, joining the Categories, Products, and Inventories views and giving them aliases.
SELECT
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count
FROM
	vCategories AS c
JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID

-Add CREATE VIEW syntax to SELECT statement, giving it a name of vProductAndCategoryCountOnDate.
CREATE VIEW
	vInventoriesByProductsByCategories
AS
SELECT
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count
FROM
	vCategories AS c
JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
;

-Order the view by the CategoryName, ProductName, InventoryDate, and Count columns.
ORDER BY
	CategoryName,
	ProductName,
	InventoryDate,
	Count
;
*/

CREATE VIEW
	vInventoriesByProductsByCategories
AS
SELECT TOP 1000000000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count
FROM
	vCategories AS c
INNER JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
INNER JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
ORDER BY
	CategoryName,
	ProductName,
	InventoryDate,
	Count
;
GO

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/*
-Create SELECT statement including the CategoryName, ProductName, InventoryDate, Count, columns.  Concatenate first and last name to EmployeeName. Join all four basic views and give them aliases.
SELECT
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.COUNT,
	[EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM
	vCategories AS c
JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID

-Add CREATE VIEW syntax and give it the name of vCategoryAndProductCountByEmployeeOnDate.
CREATE VIEW
	vInventoriesByProductsByEmployees
AS
SELECT
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.COUNT,
	[EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM
	vCategories AS c
JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
;

--Order the view by InvendotyDate, CategoryName, ProductName, and EmployeeName columns.
ORDER BY
	InventoryDate,
	CategoryName,
	ProductName,
	EmployeeName
;
GO
*/

CREATE VIEW
	vInventoriesByProductsByEmployees
AS
SELECT TOP 1000000000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.COUNT,
	[EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM
	vCategories AS c
INNER JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
INNER JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
INNER JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
ORDER BY
	InventoryDate,
	CategoryName,
	ProductName,
	EmployeeName
;
GO

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

/*
-Create SELECT statement to include CategoryName, ProductName, InventoryDate, Count, and EmployeeName. Join all four views and give them aliases. Add WHERE clause to filter via Chai and Chang
SELECT
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count,
	[EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM
	vCategories AS c
INNER JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
WHERE
	p.ProductName IN ('Chai', 'Chang')
;

-Add CREATE VIEW syntax and give it the name vChaiAndChangEmployeeInventoryCountOnDate
CREATE VIEW
	vInventoriesForChaiAndChangByEmployees
AS
SELECT
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count,
	[EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM
	vCategories AS c
INNER JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
WHERE
	p.ProductName IN ('Chai', 'Chang')
;
*/

CREATE VIEW
	vInventoriesForChaiAndChangByEmployees
AS
SELECT TOP 1000000000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count,
	[EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
FROM
	vCategories AS c
INNER JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
INNER JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
INNER JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
WHERE
	p.ProductID IN(
		SELECT
			p.ProductID
		FROM
			vProducts
		WHERE
			p.ProductName IN ('Chai' , 'Chang')
)
ORDER BY
	3,1,2,4
;
GO
	
-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

/*
-Create SELECT statement to include the Manager and Employee columns which are concatenations of the EmployeeFirstName and EmployeeLastName columns. Join Employee view to itself and give it an alias.
SELECT
	[Manager] = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
	[Employee] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
	FROM
	vEmployees AS e
	INNER JOIN
	vEmployees AS m
ON
	m.ManagerID = e.EmployeeID
;

-Add CREATE VIEW syntax and give it the name vManagerToEmployer.
CREATE VIEW
	vEmployeesByManager
AS
SELECT
	[Manager] = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
	[Employee] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
	FROM
	vEmployees AS e
	INNER JOIN
	vEmployees AS m
ON
	m.ManagerID = e.EmployeeID
;

-Order the view by Manager Name, then Employer Name.
ORDER BY
	Manager,
	Employee
;
*/

CREATE VIEW
	vEmployeesByManager
AS
SELECT TOP 1000000000
	[Manager] = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
	[Employee] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
	FROM
	vEmployees AS e
	INNER JOIN
	vEmployees AS m
ON
	m.ManagerID = e.EmployeeID
ORDER BY
	Manager,
	Employee
;
GO

-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

/*
-Create SELECT statement including all distinct columns from all views with Emplyee and Manager as concatenations of EmployeeFirstName and EmployeeLastName. Join all views, then join Employee view to itself.  Give the views aliases.
SELECT
	c.CategoryID,
	c.CategoryName,
	p.ProductID,
	p.ProductName,
	p.UnitPrice,
	i.InventoryID,
	i.InventoryDate,
	i.Count,
	e.EmployeeID,
	[Employee] = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
	[Manager] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
FROM
	vCategories AS c
INNER JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
INNER JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
INNER JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
INNER JOIN
	vEmployees AS m
ON
	e.ManagerID = m.EmployeeID
;

-Add CREATE VIEW syntax and give it the name vAllViewsWithManagerName.
CREATE VIEW
	vInventoriesByProductsByCategoriesByEmployees
AS
SELECT
	c.CategoryID,
	c.CategoryName,
	p.ProductID,
	p.ProductName,
	p.UnitPrice,
	i.InventoryID,
	i.InventoryDate,
	i.Count,
	e.EmployeeID,
	[Employee] = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
	[Manager] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
FROM
	vCategories AS c
INNER JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
INNER JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
INNER JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
INNER JOIN
	vEmployees AS m
ON
	e.ManagerID = m.EmployeeID
;

-Display view and order the results by CategoryName, ProductName, InventoryID, and EmployeeName.
SELECT
	*
FROM
	vAllViewsWithManagerName
ORDER BY
	CategoryName,
	ProductName,
	InventoryID,
	Employee
;
*/

CREATE VIEW
	vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 1000000000
	c.CategoryID,
	c.CategoryName,
	p.ProductID,
	p.ProductName,
	p.UnitPrice,
	i.InventoryID,
	i.InventoryDate,
	i.Count,
	e.EmployeeID,
	[Employee] = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
	[Manager] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
FROM
	vCategories AS c
INNER JOIN
	vProducts AS p
ON
	c.CategoryID = p.CategoryID
INNER JOIN
	vInventories AS i
ON
	p.ProductID = i.ProductID
INNER JOIN
	vEmployees AS e
ON
	i.EmployeeID = e.EmployeeID
INNER JOIN
	vEmployees AS m
ON
	e.ManagerID = m.EmployeeID
ORDER BY
	CategoryName,
	ProductName,
	InventoryID,
	Employee
;
GO

-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/