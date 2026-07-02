/* =====================================================================
   E-COMMERCE DATASET — BUSINESS-FOCUSED SQL QUERIES (PostgreSQL)
   =====================================================================
   Har query ek real BUSINESS QUESTION ka jawab deti hai — interview
   mein yeh bataना hota hai: "Is query se business ko kya insight mila?"
   ===================================================================== */


/* =====================================================================
   Q1. Hamara sabse profitable product category kaunsa hai?
   ---------------------------------------------------------------------
   Business Use: Inventory aur marketing budget kis category par
   focus karna chahiye, yeh decide karne ke liye.
   ===================================================================== */

SELECT
    Product_Category,
    ROUND(SUM(Profit_Amount), 2)        AS total_profit,
    ROUND(AVG(Profit_Margin_Percent), 2) AS avg_profit_margin_pct
FROM ecommerce_orders
GROUP BY Product_Category
ORDER BY total_profit DESC;


/* =====================================================================
   Q2. Returns se hamara kitna revenue/profit loss ho raha hai?
   ---------------------------------------------------------------------
   Business Use: Returns ka actual financial impact dikhane ke liye —
   management ko return-reduction strategy banane mein madad.
   ===================================================================== */

SELECT
    SUM(CASE WHEN Returned = 1 THEN Order_Amount ELSE 0 END) AS revenue_lost_to_returns,
    SUM(CASE WHEN Returned = 1 THEN Profit_Amount ELSE 0 END) AS profit_lost_to_returns,
    ROUND(
        SUM(CASE WHEN Returned = 1 THEN Order_Amount ELSE 0 END) * 100.0
        / SUM(Order_Amount), 2
    ) AS pct_revenue_lost
FROM ecommerce_orders;


/* =====================================================================
   Q3. Membership wale customers (Premium/Gold) kya zyada spend
       karte hain non-members ke comparison mein?
   ---------------------------------------------------------------------
   Business Use: Membership program ka ROI justify karne ke liye.
   ===================================================================== */

SELECT
    Membership_Status,
    COUNT(DISTINCT Customer_ID)  AS total_customers,
    ROUND(AVG(Order_Amount), 2)  AS avg_order_value,
    ROUND(SUM(Order_Amount), 2)  AS total_revenue
FROM ecommerce_orders
GROUP BY Membership_Status
ORDER BY avg_order_value DESC;


/* =====================================================================
   Q4. Marketing budget kis Traffic_Source par sabse effective hai?
   ---------------------------------------------------------------------
   Business Use: Ad spend allocation (Social Media vs Search vs
   Email vs Direct) decide karne ke liye.
   ===================================================================== */

SELECT
    Traffic_Source,
    COUNT(Order_ID)              AS total_orders,
    ROUND(SUM(Order_Amount), 2)  AS total_revenue,
    ROUND(AVG(Order_Amount), 2)  AS avg_order_value
FROM ecommerce_orders
GROUP BY Traffic_Source
ORDER BY total_revenue DESC;


/* =====================================================================
   Q5. Late delivery se customer satisfaction (review rating) par
       kya asar padta hai?
   ---------------------------------------------------------------------
   Business Use: Shipping/logistics improvement ki zaroorat hai ya
   nahi, yeh justify karne ke liye.
   ===================================================================== */

SELECT
    CASE
        WHEN Delivery_Days <= 3 THEN 'Fast (0-3 days)'
        WHEN Delivery_Days <= 7 THEN 'Medium (4-7 days)'
        ELSE 'Slow (8+ days)'
    END AS delivery_speed_bucket,
    COUNT(Order_ID)               AS total_orders,
    ROUND(AVG(Review_Rating), 2)  AS avg_review_rating,
    ROUND(AVG(CASE WHEN Returned = 1 THEN 1.0 ELSE 0 END) * 100, 2) AS return_rate_pct
FROM ecommerce_orders
GROUP BY delivery_speed_bucket
ORDER BY avg_review_rating DESC;


/* =====================================================================
   Q6. Coupon dene se actually order amount/sales badhti hai ya
       sirf profit margin kam hota hai?
   ---------------------------------------------------------------------
   Business Use: Coupon/promotion strategy effective hai ya nahi.
   ===================================================================== */

SELECT
    Coupon_Used,
    COUNT(Order_ID)                       AS total_orders,
    ROUND(AVG(Order_Amount), 2)           AS avg_order_value,
    ROUND(AVG(Profit_Margin_Percent), 2)  AS avg_profit_margin_pct,
    ROUND(SUM(Profit_Amount), 2)          AS total_profit
FROM ecommerce_orders
GROUP BY Coupon_Used;


/* =====================================================================
   Q7. Sabse zyada business kis Warehouse_Region se aata hai, aur
       wahan ki delivery performance kaisi hai?
   ---------------------------------------------------------------------
   Business Use: Warehouse expansion/investment decisions ke liye.
   ===================================================================== */

SELECT
    Warehouse_Region,
    COUNT(Order_ID)                AS total_orders,
    ROUND(SUM(Order_Amount), 2)    AS total_revenue,
    ROUND(AVG(Delivery_Days), 1)   AS avg_delivery_days
FROM ecommerce_orders
GROUP BY Warehouse_Region
ORDER BY total_revenue DESC;


/* =====================================================================
   Q8. Mobile vs Desktop vs Tablet — kis device se customers zyada
       kharidte hain aur kitna spend karte hain?
   ---------------------------------------------------------------------
   Business Use: Website/App development priority decide karne ke
   liye (mobile-first ya desktop-first strategy).
   ===================================================================== */

SELECT
    Device_Type,
    COUNT(Order_ID)              AS total_orders,
    ROUND(SUM(Order_Amount), 2)  AS total_revenue,
    ROUND(AVG(Order_Amount), 2)  AS avg_order_value
FROM ecommerce_orders
GROUP BY Device_Type
ORDER BY total_revenue DESC;


/* =====================================================================
   Q9. Festive/Holiday Season mein sales aur returns dono kaise
       badalte hain normal season ke comparison mein?
   ---------------------------------------------------------------------
   Business Use: Holiday season planning — stock, staff, returns
   handling capacity ke liye.
   ===================================================================== */

SELECT
    Holiday_Season,
    COUNT(Order_ID)                                              AS total_orders,
    ROUND(SUM(Order_Amount), 2)                                  AS total_revenue,
    ROUND(AVG(Order_Amount), 2)                                  AS avg_order_value,
    ROUND(AVG(CASE WHEN Returned = 1 THEN 1.0 ELSE 0 END) * 100, 2) AS return_rate_pct
FROM ecommerce_orders
GROUP BY Holiday_Season;


/* =====================================================================
   Q10. Kaunsa Age Group sabse zyada High_Value_Order place karta
        hai? (Target marketing ke liye)
   ---------------------------------------------------------------------
   Business Use: Marketing campaigns ko sahi age-group par target
   karne ke liye.
   ===================================================================== */

WITH age_grouped AS (
    SELECT
        Customer_Age,
        CASE NTILE(4) OVER (ORDER BY Customer_Age)
            WHEN 1 THEN 'Young Adult'
            WHEN 2 THEN 'Adult'
            WHEN 3 THEN 'Middle-Aged'
            WHEN 4 THEN 'Senior'
        END AS age_group
    FROM ecommerce_orders
)
SELECT
    age_group,
    MIN(Customer_Age) AS min_age,
    MAX(Customer_Age) AS max_age,
    COUNT(*) AS total_customers
FROM age_grouped
GROUP BY age_group
ORDER BY min_age;


