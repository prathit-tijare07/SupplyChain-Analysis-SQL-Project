Create Database Supplychain_analysis;
use supplychain_analysis;
	CREATE TABLE orderlist 
                         ( Order_Date Date,
	                       Order_ID decimal,
	                       Product_ID int,
	                       Customer	varchar(50),
	                       Unit_quantity int,
	                       Weight decimal,
	                       Ship_ahead_day_count int,
	                       Ship_Late_Day_count int,
	                       Origin_Port varchar(50),	
						   Destination_Port	varchar(50),
						   Carrier varchar(50),
	                       Plant_Code varchar(50),
						   TPT int,
						   Service_Level varchar(50)		
);
select * from orderlist;

Create table Plantports( Plant_Code	VARCHAR(50),
                          Ports VARCHAR(50));
select * from plantports;

Create table ProductsperPlant( Plant_Code Varchar(50),
                             	Product_id int);
select * from productsperplant;

Create table WhCapacities( Plant_id Varchar(50),
						   daily_capacity INT);
select * from whcapacities;

Create Table Whcosts( WH Varchar(50),
					  Cost_unit decimal);
select * from whcosts;

Create table Vmicustomers( Plant_Code Varchar(50),
                           Customers Varchar(50));
select * from Vmicustomers;

CREATE TABLE FreightRates (
                           Carrier VARCHAR(50),
                           orig_port_cd VARCHAR(50),
                          dest_port_cd VARCHAR(50),
                          minm_wgh_qty DECIMAL,
                          max_wgh_qty DECIMAL,
                          svc_cd VARCHAR(50),
                          minimum_cost DECIMAL,
                          rate DECIMAL,
                          mode_dsc VARCHAR(50),
                          tpt_day_cnt INT,
                         Carrier_type VARCHAR(50));
select * from freightrates;


-- /* In this SQL file, we will be analysing the data with some business questions.*/

 -- [Q1] Count of Top 100 Products which has maximum order.
       select product_id,count(order_id) as total_orders
       from orderlist
       group by product_id
       order by total_orders desc
       limit 100;
       
 -- [Q2] Sum of quantity ordered by each customer.
       select customer,sum(unit_quantity) as total_quantity
       from orderlist
       group by customer
       order by total_quantity desc;
       
-- [Q3] Origin & destination port of each customer.
       select distinct(customer),origin_port,destination_port,plant_code
       from orderlist 
       order by customer;
       
-- [Q4] List of Customers with respective product ids where the early delivery is more than 3.
         select customer,product_id,
                round(avg(ship_ahead_day_count),0) as avg_delivery
                from orderlist
                group by product_id,customer
                having round(avg(ship_ahead_day_count),0)>3
                order by customer desc,avg_delivery desc; 

-- Q5) List the product with total orders & quantity and average weight.
	select   product_id ,
	         count(product_id) as total_orders,
	         sum(unit_quantity) as total_units, 
	         round(avg(weight),0) as avg_weight
             from orderlist
			 group by product_id
			 order by avg_weight desc;

-- Q6) List of ports and plants used for customers.
        select distinct(a.customer),b.plant_code,b.ports 
        from orderlist as a
        JOIN plantports as b
        ON a.plant_code = b.plant_code
        order by a.customer DESC;
        
-- Q7) Total cost incurred at each plant by every customer.
        select distinct(customer),
		sum(a.unit_quantity) total_qty,
        b.plant_code,b.ports,
        c.cost_unit,
        sum((a.unit_quantity*c.cost_unit))as total_cost
        from orderlist as a
        JOIN plantports as b
        ON a.plant_code = b.plant_code
        JOIN whcosts as c
        ON a.plant_code = c.WH
        Group by a.customer,
        b.plant_code,b.ports,c.cost_unit
        order by customer DESC;
        
-- Q8) Total cost incurred for each product.
		select distinct(a.product_id),
		sum(a.unit_quantity) as total_quantity,
		sum((a.unit_quantity*b.cost_unit)) as total_cost
         from orderlist as a
         JOIN whcosts as b
         ON a.plant_code = b.WH
         group by (a.product_id)
		 order by 	total_cost desc; 

-- Q9) Show the total cost column in th orderlist table.	
         select a.*, ( a.unit_quantity*b.cost_unit) as total_cost
         from orderlist as a
         JOIN whcosts as b
         ON a.plant_code = b.WH;

-- Q10) Query a output representing min & max quantity of origin port and destination port.
       select orig_port_cd,
              dest_port_cd,
              sum(minm_wgh_qty) min_qty,
              sum(max_wgh_qty) max_qty
              from freightrates
              group by orig_port_cd,dest_port_cd
              order by orig_port_cd,dest_port_cd; 
              
-- Q11) Query a output representing min & max quantity of mode type. 
       select mode_dsc,
               sum(minm_wgh_qty) min_qty,
               sum(max_wgh_qty) max_qty,
               sum(minimum_cost) min_cost
               from freightrates
               group by mode_dsc
               order by min_cost;

-- Q12) Find out average transport day count by carrier.
       select carrier,round(avg(tpt_day_cnt),2) 
       from freightrates
       group by carrier
       order by carrier;
       
-- Q13) Query total rate by origin port
      select orig_port_cd,sum(rate)total_rate from freightrates
	  group by orig_port_cd
      order by orig_port_cd; 




