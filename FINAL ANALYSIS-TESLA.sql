create database tesla;
use tesla;
CREATE TABLE tesla (
    id INT AUTO_INCREMENT PRIMARY KEY,
    date DATE,
    open DECIMAL(10,2),
    high DECIMAL(10,2),
    low DECIMAL(10,2),
    close DECIMAL(10,2),
    adj_close DECIMAL(10,2),
    volume BIGINT
);
SELECT * FROM tesla;
SELECT 
    date,
    close,
    (close - LAG(close) OVER (ORDER BY date)) / LAG(close) OVER (ORDER BY date) AS daily_return
FROM tesla;

SELECT 
    date,
    close,
    AVG(close) OVER (ORDER BY date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) AS ma_30
FROM tesla;
SELECT 
    YEAR(date) AS year,
    AVG(close) AS avg_close
FROM tesla
GROUP BY YEAR(date);
SELECT 
    MAX(high) AS highest_price,
    MIN(low) AS lowest_price
FROM tesla;
SELECT date, volume
FROM tesla
ORDER BY volume DESC
LIMIT 1;
SELECT 
    DATE_FORMAT(date, '%Y-%m') AS month,
    AVG(volume) AS avg_volume
FROM tesla
GROUP BY month
ORDER BY month;
SELECT 
    date,
    (high - low) AS volatility
FROM tesla
ORDER BY volatility DESC;
SELECT 
    date,
    open - LAG(close) OVER (ORDER BY date) AS price_gap
FROM tesla;
SELECT 
    date,
    EXP(SUM(log_ret) OVER (ORDER BY date)) - 1 AS cumulative_return
FROM (
    SELECT 
        date,
        LN(close / LAG(close) OVER (ORDER BY date)) AS log_ret
    FROM tesla
) AS t;
SELECT 
    date,
    (close - LAG(close) OVER (ORDER BY date)) / LAG(close) OVER (ORDER BY date) AS daily_return
FROM tesla
ORDER BY daily_return ASC
LIMIT 10;
SELECT 
    date,
    close,
    volume
FROM tesla
ORDER BY volume DESC;
SELECT 
    date,
    open,
    close,
    CASE 
        WHEN close > open THEN 'Bullish'
        WHEN close < open THEN 'Bearish'
        ELSE 'Neutral'
    END AS market_sentiment
FROM tesla;
SELECT 
    YEAR(date) AS year,
    MONTH(date) AS month,
    (AVG(close) - MIN(close)) / MIN(close) AS monthly_return
FROM tesla
GROUP BY year, month;
SELECT 
    date,
    close,
    MAX(close) OVER (ORDER BY date ROWS BETWEEN 90 PRECEDING AND 1 PRECEDING) AS prev_90day_high
FROM tesla;
SELECT
    date,
    STDDEV_SAMP(close) OVER (ORDER BY date ROWS BETWEEN 252 PRECEDING AND CURRENT ROW) AS one_year_volatility
FROM tesla;










