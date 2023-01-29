use Northwind;

--- [1.1] Customer Analysis
select ContactTitle, CategoryName, Round(AVG(UnitPrice),2) as 'Avg UnitPrice Order'
--- INTO Northwind.dbo.CustomerAnalysis1
from
	(select c.ContactTitle,
		    b.UnitPrice,
		    e.CategoryName
	from Orders a
	join [Order Details] b on a.OrderID = b.OrderID
	join Customers c on a.CustomerID = c.CustomerID
	join Products d on b.ProductID = d.ProductID
	join Categories e on d.CategoryID = e.CategoryID)Z
group by ContactTitle, CategoryName
order by CategoryName, AVG(UnitPrice) desc


---[1.2] Customer Analysis
select ContactTitle, [Label Discount], COUNT([Label Discount]) as 'Count LabelDiscount'
--- INTO Northwind.dbo.CustomerAnalysis2
from
	(select c.ContactTitle,
			CASE WHEN [Discount] = 0 THEN 'No Discount'
			WHEN (Discount > 0) and (Discount <= 0.10) THEN 'Discount <= 10%'
			WHEN (Discount > 0.10) and (Discount <= 0.20) THEN 'Discount <= 20%'
			WHEN (Discount > 0.20) and (Discount <= 0.30) THEN 'Discount <= 30%'
			ELSE 'Discount > 30%' end as 'Label Discount'
	from Orders a
	join [Order Details] b on a.OrderID = b.OrderID
	join Customers c on a.CustomerID = c.CustomerID)Z
group by ContactTitle, [Label Discount]
order by COUNT([Label Discount]) desc


--- [2] Customer Analysis
select * 
--- INTO Northwind.dbo.CustomerAnalysis3
from
	(select ROW_NUMBER() over(partition by ContactTitle
		   order by ContactTitle, [Sum Qty Category] desc) as [Rank Sum Qty], *
	from
		(select ContactTitle, CategoryName, SUM(Quantity) as 'Sum Qty Category'
		from
			(select c.ContactTitle,
					b.Quantity,
					e.CategoryName
			from Orders a
			join [Order Details] b on a.OrderID = b.OrderID
			join Customers c on a.CustomerID = c.CustomerID
			join Products d on b.ProductID = d.ProductID
			join Categories e on d.CategoryID = e.CategoryID)Z
		group by ContactTitle, CategoryName)Z)ZZ
	where [Rank Sum Qty] <= 5