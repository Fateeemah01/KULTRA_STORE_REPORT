--Cleaning the data
--convert the order date type and ship date type from datetime to date
alter table Orders
alter column [Order Date] DATE

alter table Orders
alter column [Ship Date] DATE

SELECT * FROM Orders

--Case 1: Which product category had the highest sales?
select [Product Category], SUM(Sales) as TotalSales from Orders
group by [Product Category]
order by TotalSales desc

--Case 2: What are the Top 3 and Bottom 3 Regions with regards to sales?
select Region, round(sum(sales),2) as TotalSalesbyregion from Orders
group by Region
order by TotalSalesbyregion desc

--Case 3: What was the total sales of appliances in Ontario?
select round(sum(sales),2) as TotalSalesofAppliances from Orders
where Province= 'Ontario' AND [Product Sub-Category]='Appliances'

--Case 4: Advise the management of KMS on what to do to increase the revenue from the bottom 10 customers
SELECT TOP 10
    [Customer Name], [Customer Segment] ,count([Order Quantity]) as [Total Order Quantity], 
    COALESCE(SUM(CASE WHEN [Product Category] = 'Furniture' THEN Sales ELSE 0 END), 0) AS "Furniture",
    COALESCE(SUM(CASE WHEN [Product Category] = 'Office Supplies' THEN Sales ELSE 0 END), 0) AS "Office Supplies",
    COALESCE(SUM(CASE WHEN [Product Category] = 'Technology' THEN Sales ELSE 0 END), 0) AS "Technology",
    COALESCE(SUM(Sales), 0) AS "Category Total"
FROM Orders
GROUP BY [Customer Name], [Customer Segment]
ORDER BY [Category Total] ASC;
select * from orders
--Case 5: KMS incurred the most shipping cost using which shipping method?
select [Ship Mode], round(sum([Shipping Cost]),2) as TotalShippingCost from Orders
Group by [Ship Mode]
order by TotalShippingCost desc

--Case 6: Who are the most valuable customers and what do they purchase?
SELECT TOP 10
    [Customer Name],
    COALESCE([Furniture], 0) AS "Furniture",
    COALESCE([Office Supplies], 0) AS "Office Supplies",
    COALESCE([Technology], 0) AS "Technology",
    [Furniture] + [Office Supplies] + [Technology] AS "Category Total"
FROM (
    SELECT
        CASE WHEN GROUPING([customer Name]) = 1 THEN 'Grand Total' ELSE [customer Name] END as [Customer Name],
        [Product Category],
        Sales
    FROM Orders
    GROUP BY ROLLUP ([Customer Name], [Product Category]), Sales
) AS SourceData
PIVOT (
    SUM(Sales)
    FOR [Product Category] IN ([Furniture], [Office Supplies], [Technology])
) AS PivotTable
ORDER BY [Category Total] DESC;

/*Case 7: If the delivery truck is the most economical but the slowest shipping method and Express Air is the 
fastest but the most expensive one, do you think the company appropriately spent shipping costs
based on the Order Priority? Explain your answer*/

SELECT
    [Ship Mode],
    ROUND(SUM(CASE WHEN [Order Priority] = 'Low' THEN [Shipping Cost] ELSE 0 END), 2) AS [Low],
    ROUND(SUM(CASE WHEN [Order Priority] = 'High' THEN [Shipping Cost] ELSE 0 END), 2) AS [High],
    ROUND(SUM(CASE WHEN [Order Priority] = 'Medium' THEN [Shipping Cost] ELSE 0 END), 2) AS [Medium],
    ROUND(SUM(CASE WHEN [Order Priority] = 'Critical' THEN [Shipping Cost] ELSE 0 END), 2) AS [Critical],
    ROUND(SUM([Shipping Cost]), 2) AS TotalShippingCost
FROM Orders
GROUP BY [Ship Mode]
ORDER BY TotalShippingCost DESC;

--Case 8: Which small business customer had the highest sales?
select Top 1 [Customer Name],[Customer Segment], sum(Sales) as TotalSales from Orders
where [Customer Segment]= 'Small Business'
group by [Customer Name], [Customer Segment]
order by TotalSales desc

/*Case 9: Which Corporate Customer placed the most number of orders in 2009 – 2012? 
How many orders were placed by the Corporate customer?*/
SELECT [Customer Name],
       SUM(CASE WHEN OrderYear = '2009' THEN TotalOrders ELSE 0 END) AS '2009',
       SUM(CASE WHEN OrderYear = '2010' THEN TotalOrders ELSE 0 END) AS '2010',
       SUM(CASE WHEN OrderYear = '2011' THEN TotalOrders ELSE 0 END) AS '2011',
       SUM(CASE WHEN OrderYear = '2012' THEN TotalOrders ELSE 0 END) AS '2012',
       SUM(TotalOrders) AS 'Grand Total'
FROM (
    SELECT [Customer Name], 
           DATEPART(YYYY, [Order Date]) AS OrderYear, 
           COUNT([Order Quantity]) AS TotalOrders
    FROM Orders
    WHERE [Customer Segment] = 'Corporate' 
          AND DATEPART(YYYY, [Order Date]) IN ('2009', '2010', '2011', '2012')
    GROUP BY [Customer Name], DATEPART(YYYY, [Order Date])
) AS Subquery
GROUP BY [Customer Name]
ORDER BY [Grand Total] desc;

--Case 10: Which consumer customer was the most profitable one?
select Top 1 [Customer Name],[Customer Segment], sum(Sales) as TotalSales from Orders
where [Customer Segment]= 'Consumer'
group by [Customer Name], [Customer Segment]
order by TotalSales desc

--Case 11: Which customer returned items and what segment do they belong?
select * from CustomerName
select * from Orders
select * from Returns

SELECT DISTINCT C.[Order ID], C.[Customer Name], R.Status, O.[Customer Segment]
  FROM CustomerName AS C
    INNER JOIN Returns AS R ON C.[Order ID] = R.[Order ID]
	INNER JOIN Orders AS O ON R.[Order ID] = O.[Order ID]
  ORDER BY [Order ID] ASC







