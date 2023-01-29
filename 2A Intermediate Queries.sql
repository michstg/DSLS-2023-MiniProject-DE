--- [1] Query untuk mendapatkan jumlah customer tiap bulan yang melakukan order pada tahun 1997
select b.MonthOrder, COUNT(CustomerID) as 'TotalCustomer'
from
	(select * from Northwind.dbo.[Order Details])a
	right join
	(select OrderID, CustomerID, MONTH(OrderDate) as 'MonthOrder' from Northwind.dbo.Orders
		where YEAR(OrderDate) = '1997')b
	on a.OrderID = b.OrderID
group by MonthOrder
order by MonthOrder

--- [2] Query untuk mendapatkan nama employee yang termasuk Sales Representative
select FirstName, LastName, Title from Northwind.dbo.Employees
	where Title = 'Sales Representative'

--- [3] Query untuk mendapatkan top 5 nama produk yang quantitynya paling banyak diorder pada bulan Januari 1997
select top(5) ProductName, SUM(Quantity) as TotalQuantity
from
	(select a.*, b.ProductName from
		(select OrderID, ProductID, Quantity from Northwind.dbo.[Order Details])a
		left join
		(select ProductID, ProductName from Northwind.dbo.Products)b
		on a.ProductID = b.ProductID)c
	where OrderID in (select OrderID from Northwind.dbo.Orders 
						where OrderDate between '1997-01-01' and '1997-01-31')
group by ProductName
order by TotalQuantity desc

--- [4] Query untuk mendapatkan nama company yang melakukan order Chai pada bulan Juni 1997
select CompanyName from Northwind.dbo.[Order Details]
join Northwind.dbo.Orders on [Order Details].OrderID = Orders.OrderID
join Northwind.dbo.Products on [Order Details].ProductID = Products.ProductID
join Northwind.dbo.Customers on Orders.CustomerID = Customers.CustomerID
where ProductName = 'Chai' and OrderDate between '1997-06-01' and '1997-06-30'
group by CompanyName

--- [5] Query untuk mendapatkan jumlah OrderID yang pernah melakukan pembelian (unit_price dikali quantity) <=100, 100<x<=250, 250<x<=500, dan >500
select Buying, COUNT(Buying) as 'Total Order ID Buying' from
	(select OrderID, case 
					when UnitPrice*Quantity <= 100 then '<= 100'
					when UnitPrice*Quantity > 100 and UnitPrice*Quantity <= 250 then '100 < x <= 250'
					when UnitPrice*Quantity > 250 and UnitPrice*Quantity <= 500 then '250 < x <= 500'
					else '> 500' end as 'Buying'
	from Northwind.dbo.[Order Details])A
group by buying 
order by [Total Order ID Buying] desc

--- [6] Query untuk mendapatkan Company name pada tabel customer yang melakukan pembelian di atas 500 pada tahun 1997
select CompanyName from Northwind.dbo.Customers
where exists (
				select C.*, D.CompanyName from
					(select A.OrderID, OrderDate, CustomerID, Buying from
						(select *, UnitPrice*Quantity as 'Buying' from Northwind.dbo.[Order Details])A
						left join
						(select * from Northwind.dbo.Orders)B
						on A.OrderID = B.OrderID)C
					left join
					(select * from Northwind.dbo.Customers)D
					on C.CustomerID = D.CustomerID
				where Year(OrderDate) = 1997 AND Buying > 500
			)

--- [7] Query untuk mendapatkan nama produk yang merupakan Top 5 sales tertinggi tiap bulan di tahun 1997
select * from
	(select ROW_NUMBER() over(partition by Month
		   order by sales desc) as [Rank Sales Product], *
	from
		(select MONTH(OrderDate) as Month, ProductName, SUM(Quantity) as Sales
			from Northwind.dbo.Orders
			join Northwind.dbo.[Order Details] on Orders.OrderID = [Order Details].OrderID
			join Northwind.dbo.Products on [Order Details].ProductID = Products.ProductID
			where YEAR(OrderDate) = 1997
			group by MONTH(OrderDate), ProductName)A)B
where [Rank Sales Product] <= 5

--- [8] Query Membuat view order details yang berisi OrderID, ProductID, ProductName, UnitPrice, Quantity, Discount, Harga setelah diskon
select Orders.OrderID,
		[Order Details].ProductID,
		Products.ProductName,
		Products.UnitPrice,
		[Order Details].Quantity,
		[Order Details].Discount,
		([Order Details].Quantity * Products.UnitPrice * (1 - [Order Details].Discount)) as 'Price After Discount'
from Northwind.dbo.Orders
inner join Northwind.dbo.[Order Details] on Orders.OrderID = [Order Details].OrderID
inner join Northwind.dbo.Products on [Order Details].ProductID = Products.ProductID;

--- [9] Query Membuat procedure invoice untuk memanggil CustomerID, CustomerName/company name, OrderID, OrderDate, RequiredDate, ShippedDate jika terdapat inputan CustomerID tertentu
USE Northwind;
GO
DECLARE @customer_id VARCHAR(10);
SET @customer_id = 'ALFKI';

SELECT Orders.CustomerID, CompanyName, Orders.OrderID, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate
FROM Customers
JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Customers.CustomerID = @customer_id;