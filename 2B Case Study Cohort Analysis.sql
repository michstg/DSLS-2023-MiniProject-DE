USE Northwind;

--- Customer id, find first time order (month)
WITH FIRSTBUY AS(
				SELECT o.CustomerID,
					   DATEPART(MONTH, MIN(o.OrderDate)) first_time_buy
				FROM Orders o
				WHERE YEAR(o.OrderDate) = 1997
				GROUP BY o.CustomerID),

--- Customer id, find all time order (month)
NEXTPURCHASE AS(
				SELECT o.CustomerID,
					   DATEPART(MONTH, o.OrderDate) - first_time_buy AS buy_interval 
				FROM Orders o
				JOIN FIRSTBUY f ON o.CustomerID = f.CustomerID
				WHERE YEAR(o.OrderDate) = 1997),

--- Calculate the number of total distinct customer
INITIALUSER AS(
				SELECT first_time_buy,
					   COUNT(DISTINCT CustomerID) AS users
				FROM FIRSTBUY
				GROUP BY first_time_buy),

--- Calculate the retention for each first time buy & buy interval
RETENTION AS(
	SELECT
		fb.first_time_buy,
		buy_interval,
		COUNT(DISTINCT np.CustomerID) AS users_transacting
	FROM FIRSTBUY fb
	JOIN NEXTPURCHASE np ON fb.CustomerID = np.CustomerID
	WHERE buy_interval IS NOT NULL
	GROUP BY fb.first_time_buy, buy_interval)

--- Convert the retention
SELECT
	r.first_time_buy,
	iu.users,
	r.buy_interval,
	r.users_transacting,
	100.0*r.users_transacting/iu.users AS '%UserTransaction'
FROM RETENTION r
LEFT JOIN INITIALUSER iu ON r.first_time_buy = iu.first_time_buy
ORDER BY r.first_time_buy, r.buy_interval;