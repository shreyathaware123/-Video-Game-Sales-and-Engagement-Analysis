Create Database video_game_analysis;
USE video_game_analysis;

SHOW VARIABLES LIKE 'secure_file_priv';

# Creating Table games

CREATE TABLE games (
    game_id INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Release_Date DATE,
    Team VARCHAR(255),
    Rating FLOAT,
    Times_Listed INT,
    Number_of_Reviews INT,
    Genres VARCHAR(255),
    Summary TEXT,
    Reviews TEXT,
    Plays INT,
    Playing INT,
    Backlogs INT,
    Wishlist INT
);

ALTER TABLE games
MODIFY Release_Date DATE NULL;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/games_cleaned_file.csv'
INTO TABLE games
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
 Title,
 @Release_Date,
 Team,
 Rating,
 Times_Listed,
 Number_of_Reviews,
 Genres,
 Summary,
 Reviews,
 Plays,
 Playing,
 Backlogs,
 Wishlist
)
SET Release_Date = NULLIF(@Release_Date,'');

# Verifying 
SELECT game_id, Title, Release_Date, Rating FROM games LIMIT 5;

# Creating vgsales table

CREATE TABLE vgsales (
    vg_id INT AUTO_INCREMENT PRIMARY KEY,
    `Rank` INT,
    Name VARCHAR(255) NOT NULL,
    Platform VARCHAR(50),
    Year INT,
    Genre VARCHAR(100),
    Publisher VARCHAR(255),
    NA_Sales FLOAT,
    EU_Sales FLOAT,
    JP_Sales FLOAT,
    Other_Sales FLOAT,
    Global_Sales FLOAT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/vgsales_cleaned.csv'
INTO TABLE vgsales
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
 @Rank,
 Name,
 Platform,
 @Year,
 Genre,
 Publisher,
 NA_Sales,
 EU_Sales,
 JP_Sales,
 Other_Sales,
 Global_Sales
)
SET `Rank` = NULLIF(@Rank,''),
    Year = CASE 
              WHEN @Year REGEXP '^[0-9]+$' THEN @Year 
              ELSE NULL 
           END;
           
# Verifying 

SELECT vg_id,
 `Rank`,
 Name, 
 Platform, 
 Year, 
 Global_Sales 
FROM vgsales 
LIMIT 5;
 
# Create Table merge_table 
 CREATE TABLE merge_table AS
SELECT 
    g.game_id,
    g.Title,
    g.Release_Date,
    g.Team,
    g.Rating,
    g.Times_Listed,
    g.Number_of_Reviews,
    g.Genres,
    g.Summary,
    g.Reviews,
    g.Plays,
    g.Playing,
    g.Backlogs,
    g.Wishlist,
    v.Platform,
    v.Year,
    v.Genre AS VG_Genre,
    v.Publisher,
    v.NA_Sales,
    v.EU_Sales,
    v.JP_Sales,
    v.Other_Sales,
    v.Global_Sales
FROM games g
LEFT JOIN vgsales v
ON g.Title = v.Name;

# Retrive data from merge_table 
SELECT * FROM merge_table LIMIT 10;

# All tables
Show tables ;

-- ROWS & COLUMNS 
# 1 Number of rows for each table
SELECT 'games' AS Table_Name, COUNT(*) AS Num_Rows FROM games;
SELECT 'vgsales' AS Table_Name, COUNT(*) AS Num_Rows FROM vgsales;
SELECT 'merge_table' AS Table_Name, COUNT(*) AS Num_Rows FROM merge_table;

# 2 Number of columns for each table
SELECT 'games' AS Table_Name, COUNT(*) AS Num_Columns 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'games';

SELECT 'vgsales' AS Table_Name, COUNT(*) AS Num_Columns 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vgsales';

SELECT 'merge_table' AS Table_Name, COUNT(*) AS Num_Columns 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'merge_table';
 
-- Data Types

# 1️ Get column names and data types for 'games'
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'games';

# ️ For 'vgsales'
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'vgsales';

# ️ For 'merge_table'
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE, COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'merge_table';
 
 
-- GAMES INSIGHTS

# Most Played games
SELECT Title, Plays, Playing, Backlogs, Wishlist
FROM games
ORDER BY Plays DESC
LIMIT 10;

# Average Rating by Genre
SELECT Genres, AVG(Rating) AS Avg_Rating, COUNT(*) AS Num_Games
FROM games
GROUP BY Genres
ORDER BY Avg_Rating DESC
LIMIT 10;

# Backlog vs Wishlist Ratio

SELECT Title, Backlogs, Wishlist, (Wishlist / NULLIF(Backlogs,0)) AS Wishlist_to_Backlog_Ratio
FROM games
WHERE Backlogs > 0
ORDER BY Wishlist_to_Backlog_Ratio DESC
LIMIT 10;

-- VGSALES INSIGHTS

# Top 10 Best-Selling Games Globally 
SELECT Name, Platform, Global_Sales
FROM vgsales
ORDER BY Global_Sales DESC
LIMIT 10;

# Total Sales per Platform
SELECT Platform, SUM(Global_Sales) AS Total_Global_Sales, COUNT(*) AS Num_Games
FROM vgsales
GROUP BY Platform
ORDER BY Total_Global_Sales DESC;

# Average Global Sales by Genre

SELECT Genre, AVG(Global_Sales) AS Avg_Global_Sales, COUNT(*) AS Num_Games
FROM vgsales
GROUP BY Genre
ORDER BY Avg_Global_Sales DESC
LIMIT 10;

-- MERGE_TABLE INSIGHTS

# 1. Total Global Sales by Platform
SELECT Platform, SUM(Global_Sales) AS Total_Global_Sales
FROM merge_table
GROUP BY Platform
ORDER BY Total_Global_Sales DESC;

# 2. Regional Sales Contribution (NA, EU, JP, Other)
SELECT 
    SUM(NA_Sales) AS NA_Total,
    SUM(EU_Sales) AS EU_Total,
    SUM(JP_Sales) AS JP_Total,
    SUM(Other_Sales) AS Other_Total
FROM merge_table;

# 3. Total Global Sales by Genre
SELECT VG_Genre AS Genre, SUM(Global_Sales) AS Total_Global_Sales
FROM merge_table
GROUP BY VG_Genre
ORDER BY Total_Global_Sales DESC;

# 4. Top 10 Games by Number of Plays
SELECT Title, Plays, Playing
FROM merge_table
ORDER BY Plays DESC
LIMIT 10;

# 5. Average Rating per Genre
SELECT Genres, AVG(Rating) AS Avg_Rating, COUNT(*) AS Num_Games
FROM merge_table
GROUP BY Genres
ORDER BY Avg_Rating DESC;

# 6. Top Teams by Average Rating
SELECT Team, AVG(Rating) AS Avg_Rating, COUNT(*) AS Num_Games
FROM merge_table
GROUP BY Team
ORDER BY Avg_Rating DESC
LIMIT 10;

# 7. Wishlist vs Backlogs Ratio
SELECT Title, Wishlist, Backlogs, (Wishlist / NULLIF(Backlogs,0)) AS Wishlist_to_Backlog_Ratio
FROM merge_table
WHERE Backlogs > 0
ORDER BY Wishlist_to_Backlog_Ratio DESC
LIMIT 10;

# 8. Most Reviewed Games
SELECT Title, Number_of_Reviews, Rating
FROM merge_table
ORDER BY Number_of_Reviews DESC
LIMIT 10;

# 9. Average Plays by Platform
SELECT Platform, AVG(Plays) AS Avg_Plays, AVG(Playing) AS Avg_Playing
FROM merge_table
GROUP BY Platform
ORDER BY Avg_Plays DESC;

# 10. Average Global Sales by Genre
SELECT VG_Genre AS Genre, AVG(Global_Sales) AS Avg_Global_Sales
FROM merge_table
GROUP BY VG_Genre
ORDER BY Avg_Global_Sales DESC
LIMIT 10;

# 11. Top 10 Games by Rating and Sales (High Rating, High Sales)
SELECT Title, Rating, Global_Sales
FROM merge_table
WHERE Rating >= 4
ORDER BY Global_Sales DESC
LIMIT 10;

# 12. Count of Games per Publisher
SELECT Publisher, COUNT(*) AS Num_Games, SUM(Global_Sales) AS Total_Sales
FROM merge_table
GROUP BY Publisher
ORDER BY Total_Sales DESC
LIMIT 10;

# 13. Games Released After 2018 with High Sales
SELECT Title, Release_Date, Global_Sales, Rating
FROM merge_table
WHERE Release_Date >= '2018-01-01' AND Global_Sales > 1
ORDER BY Global_Sales DESC;

# 14. Engagement vs Rating Correlation
SELECT Title, Plays, Rating
FROM merge_table
WHERE Plays > 0
ORDER BY Rating DESC
LIMIT 10;

# 15. Top 10 Games with High Wishlist but Low Plays
SELECT Title, Wishlist, Plays, Backlogs
FROM merge_table
WHERE Plays < 1000
ORDER BY Wishlist DESC
LIMIT 10;



Show columns from merge_table;


 


 