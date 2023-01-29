use Northwind;

select * from [Order Details] a
join Orders b on a.OrderID = b.OrderID
join Products c on a.ProductID = c.ProductID
join Customers d on b.CustomerID = d.CustomerID
join Categories e on c.CategoryID = e.CategoryID


--- [1] Product Analysis
select
	MONTH(a.OrderDate) as 'Month',
	e.CategoryName as 'Product Category',
	SUM(c.UnitPrice * c.Quantity) as 'Total Sales',
	SUM(c.Quantity) AS 'Total Qty'
	--- INTO Northwind.dbo.ProductAnalysis1
from Orders a
join [Order Details] c on a.OrderID = c.OrderID
join Products b on c.ProductID = b.ProductID
join Categories e on b.CategoryID = e.CategoryID
where OrderDate between '1997-01-01' and '1997-12-31' 
group by e.CategoryName, MONTH(a.OrderDate)
order by e.CategoryName, MONTH(a.OrderDate)


----------------------------------------------------------------------------------//
select top(5)
	e.CategoryName as 'Product Category',
	SUM(c.UnitPrice * c.Quantity) as 'Total Sales'
from Orders a
join [Order Details] c on a.OrderID = c.OrderID
join Products b on c.ProductID = b.ProductID
join Categories e on b.CategoryID = e.CategoryID
where OrderDate between '1997-01-01' and '1997-12-31' 
group by e.CategoryName
order by SUM(c.UnitPrice * c.Quantity) desc

select top(5)
	e.CategoryName as 'Product Category',
	SUM(c.Quantity) AS 'Total Qty'
from Orders a
join [Order Details] c on a.OrderID = c.OrderID
join Products b on c.ProductID = b.ProductID
join Categories e on b.CategoryID = e.CategoryID
where OrderDate between '1997-01-01' and '1997-12-31' 
group by e.CategoryName
order by SUM(c.Quantity) desc
----------------------------------------------------------------------------------//

--- [2] Product Analysis [Total Sales]
select *
--- INTO Northwind.dbo.ProductAnalysis21
from
	(select ROW_NUMBER() over(partition by [Category Name]
		   order by [Total Sales] desc) as [Rank Total Sales], *
	from
		(select
			e.CategoryName as 'Category Name',
			d.Country as 'Cust Country',
			SUM(c.UnitPrice * c.Quantity) as 'Total Sales'
		from Orders a
		join [Order Details] c on a.OrderID = c.OrderID
		join Products b on c.ProductID = b.ProductID
		join Customers d on a.CustomerID = d.CustomerID
		join Categories e on b.CategoryID = e.CategoryID
		where OrderDate between '1997-01-01' and '1997-12-31'
			  and
			  CategoryName in ('Dairy Products','Beverages','Meat/Poultry','Confections','Seafood')
		group by e.CategoryName, d.Country)Z)ZZ
	where [Rank Total Sales] <= 3 
	order by [Category Name], [Total Sales] desc

--- [2] Product Analysis [Total Qty]
select *
--- INTO Northwind.dbo.ProductAnalysis22
from
	(select ROW_NUMBER() over(partition by [Category Name]
		   order by [Total Qty] desc) as [Rank Total Qty], *
	from
		(select
			e.CategoryName as 'Category Name',
			b.ProductName as 'Product Name',
			SUM(c.Quantity) as 'Total Qty'
		from Orders a
		join [Order Details] c on a.OrderID = c.OrderID
		join Products b on c.ProductID = b.ProductID
		join Categories e on b.CategoryID = e.CategoryID
		where OrderDate between '1997-01-01' and '1997-12-31'
			  and
			  CategoryName in ('Dairy Products','Beverages','Meat/Poultry','Confections','Seafood')
		group by e.CategoryName, b.ProductName)Z)ZZ
	where [Rank Total Qty] <= 3
	order by [Category Name], [Total Qty] desc