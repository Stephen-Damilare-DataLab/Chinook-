USE chinook;

-- UNDERSTANDING THE DATASET AFTER IMPORTING
select * from album;
select * from artist; -- 275 distinct artist
select * from customer; -- THERE ARE 59 CUSTOMER IDS
SELECT * FROM track; -- total number of  Production IS 3503, 25 genre
select* FROM genre;
select * from mediatype; -- 5 distinct media type eg MPEG, protected AAC ,protected MPEG etc
select * from invoiceline;
select * from invoice;
select * from employee;

With genre_usa as
	(select g.GenreId from genre g
	inner join track t
	on g.GenreId= t.GenreId
	inner join invoiceline inv
	on t.TrackId= inv.TrackId
	join invoice invo on inv.InvoiceId= invo.InvoiceId
	where BillingCountry= 'USA')
    select genreId,TrackId,invoiceId,invoiceId,BillingCity,BillingCountry
    from genre_usa;
    
   WITH genre_usa as
(select t.TrackId,invo.invoiceId,inv.InvoiceLineId, g.Name AS genre,invo.BillingCity
	from genre g
	inner join track t
	on g.GenreId= t.GenreId
	inner join invoiceline inv
	on t.TrackId= inv.TrackId
	join invoice invo on inv.InvoiceId= invo.InvoiceId
	where BillingCountry= 'USA')
    select * from genre_usa;
    
    
    select g.Name,t.TrackId,invo.invoiceId,inv.InvoiceLineId,invo.BillingCity,invo.BillingCountry
	from genre g
	inner join track t
	on g.GenreId= t.GenreId
	inner join invoiceline inv
	on t.TrackId= inv.TrackId
	join invoice invo on inv.InvoiceId= invo.InvoiceId
	where BillingCountry= 'USA';
    
    -- RETURNING THE GENRE OF MUSIC SOLD IN USA(IN NUMBER AND PERCENTAGE)
       WITH genre_usa as
(select t.TrackId,invo.invoiceId,inv.InvoiceLineId, g.Name AS genre,invo.BillingCity
	from genre g
	inner join track t
	on g.GenreId= t.GenreId
	inner join invoiceline inv
	on t.TrackId= inv.TrackId
	join invoice invo on inv.InvoiceId= invo.InvoiceId
	where BillingCountry= 'USA')
    
    select genre,
    count(*) as count,
    (cast(count(*) as float )/(select count(*) from genre_usa)) as percentage
      from genre_usa
    group by genre
    order by count desc
  ;
  
  -- understanding the genre of music people in united kingdom listened to
         WITH genre_uk as
(select t.TrackId,invo.invoiceId,inv.InvoiceLineId, g.Name AS genre,invo.BillingCity
	from genre g
	inner join track t
	on g.GenreId= t.GenreId
	inner join invoiceline inv
	on t.TrackId= inv.TrackId
	join invoice invo on inv.InvoiceId= invo.InvoiceId
	where BillingCountry= 'United Kingdom')
    
    select genre,
    count(*) as count,
    (cast(count(*) as float )/(select count(*) from genre_uk)) as percentage
      from genre_uk
    group by genre
    order by count desc
    ;
    -- Rock, Lati and Metal are the most listend to. World is the least listened music

    
    -- Analyzing the performance of the employee using the metric of sales individual made
    select * from employee; -- there are 8 employees; 3 sales support agent
   SELECT 
    e.employeeid,
    e.firstName,
    e.LastName,
    e.HireDate,
    SUM(inv.total) as my_sales,
    sum(inv.total)/ count(c.customerid) as avg_sales_per_customer
FROM
    employee e
        JOIN
    Customer c ON e.employeeid = c.supportRepId
        JOIN
    invoice inv ON inv.customerid = c.customerid
    group by 1; -- 5.70 and 5.53
    
    
    with customer_count as 
    ( select country, count(customerid) as total_num_of_customers
		from customer c
        group by country),
	labelled_invoices as 
    ( select case when cc.total_num_of_customers = 1 then 'Other' 
				else c.country end as country,
                i.customerid,
                i.invoiceid,
                il.Unitprice
			from invoiceline as il
            join invoice i on il.invoiceid = i.invoiceid
            join customer c on c.customerid = i.customerid
            join customer_count cc on cc.country = c.country
        )
select country, count(distinct customerid) as total_customers, sum(unitprice) as total_sales
	from labelled_invoices
    group by 1
order by case when country = 'Other' then 1 else 0 end,total_sales desc;



-- which artist is used in the most playlist

-- identifying artist with the highest album
select a.artistid, count(al.albumid) AS num_of_album
FROM artist a
join album al on a.artistid = al.artistid
join track t on t.albumid = al.albumid
group by 1
order by 2 desc; -- artistid 90 produced the highest number of album of 213 followed by id=150 with 135 and 275 id as the least album

-- which is it  purchased most often-- 
select invoiceid, count(*) as top20_customer_with_highest_num_of_frequent_purchase
from invoiceline 
group by 1
order by 2 desc
Limit 20;-- 5,12,19,26,33

select trackid, count(trackid) as number_of_times_track_purchased
from invoiceline
group by 1
order by 2 desc;

 -- the highly paid track is identified
select i.trackid as trackid, count(i.trackid) number_of_times_bought,sum(i.unitprice) as total_sales 
from invoiceline i 
inner join invoice inv 
on i.invoiceid = inv.invoiceid
group by 1
order by 2 desc,3 desc;

-- identifying prenium customers 
-- CUSTOMER PURCHASING POWER
select  i.invoiceid, customerid,  sum(inv.total) as total_sales
from invoiceline i 
inner join invoice inv 
on i.invoiceid = inv.invoiceid
group by 1
order by 3 desc;
-- customerid 6,26,45,46,7 are our top 3 prenium customers


-- IDENTIFYING TRACK PUCHASE
select i.trackid trackid, i.invoiceid, sum(i.unitprice) as total_sales, customerid-- the highly paid is identified
from invoiceline i 
inner join invoice inv 
on i.invoiceid = inv.invoiceid
group by 1,2
order by 3 desc;

select inv.customerid, count(inv.customerid) frequency_of_customers, avg(i.unitprice) avg_amount_spent-- all 7times except id = 59 
from invoice inv
join invoiceline i on inv.invoiceid = i.invoiceid
group by 1
order by 3 desc;

-- how many tracks produced were sold vs the once not sold
SELECT * FROM TRACK;
WITH genre_not_purchased as(
select t.trackid,t.Name,t.genreid
 from track t 
 where t.trackid not in (select i.trackid from invoiceline i)
),
 
  name_of_genre as (select g.genreid, g.name from genre g where g.genreid NOT IN (
        SELECT DISTINCT t2.genreid
        FROM track t2
        JOIN invoiceline i2 ON t2.trackid = i2.trackid)
        )
 
SELECT 
    genreid, Name, COUNT(trackid) numberof_unpurchased_track
FROM
    (SELECT 
        gnp.trackid, gnp.genreid, g.name
    FROM
        genre_not_purchased gnp
    JOIN name_of_genre g ON gnp.genreid = g.genreid) sub
GROUP BY 1
ORDER BY 3 ASC
 ;		-- Opera is the only genre that is not purchased by customer at all.
 
 
-- identifying trackid not bought
SELECT
    g.genreid,
    g.name AS genre_name,
    t.trackid trackid_not_bought
FROM 
    genre g
JOIN 
    track t ON t.genreid = g.genreid
LEFT JOIN 
    invoiceline i ON t.trackid = i.trackid
WHERE 
    i.trackid IS NULL
ORDER BY 
    1 DESC;
-- one opera genre, 38 classical,27 alternative, 9 comedy,37 drama, 6 scifi and fantasy, 50 TV shows, 8 science fictio, 20 hip hop and rap, 16 world
-- 19 electronica/Dance, 24 R&B/Soul etc
