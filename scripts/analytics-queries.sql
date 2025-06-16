-- Updating Data
-- Updating the caption for post_id 3
UPDATE Posts
SET caption = 'Best pizza ever'
WHERE post_id = 3;

-- WHERE Condition
-- Selecting all the posts where user_id is 1
SELECT *
FROM Posts
WHERE user_id = 1;

-- ORDER BY
-- Selecting all the posts and ordering them by created_at in descending order
SELECT *
FROM Posts
ORDER BY created_at DESC;

-- GROUP BY and HAVING
-- Counting the number of likes for each post and showing only the posts with more than 2 likes
SELECT p.post_id, COUNT(l.like_id) AS num_likes
FROM Posts p
LEFT JOIN Likes l ON p.post_id = l.post_id
GROUP BY p.post_id
HAVING COUNT(*) >= 2;

-- Aggregation Function
-- Finding the total number of likes for all posts
SELECT SUM(num_likes) FROM (
	SELECT p.post_id, COUNT(l.like_id) AS num_likes
	FROM Posts p
	LEFT JOIN Likes l ON p.post_id = l.post_id
	GROUP BY p.post_id
) AS total_likes;

-- Subquery
-- Finding all the users who have commented on post_id 1
SELECT name
FROM Users
WHERE user_id IN (
	SELECT user_id FROM Comments
	WHERE post_id = 1
);

-- Window Function
-- Ranking the posts based on the number of likes
SELECT post_id, num_likes, RANK() OVER (ORDER BY num_likes DESC) AS rank
FROM(
	SELECT p.post_id, COUNT(l.like_id) AS num_likes
	FROM Posts p
	LEFT JOIN Likes l ON p.post_id = l.post_id
	GROUP BY p.post_id
);

SELECT post_id, num_likes, DENSE_RANK() OVER (ORDER BY num_likes DESC) AS rank
FROM(
	SELECT p.post_id, COUNT(l.like_id) AS num_likes
	FROM Posts p
	LEFT JOIN Likes l ON p.post_id = l.post_id
	GROUP BY p.post_id
);

-- CTE
-- Finding all the posts and their comments using a Common Table Expression (CTE)
WITH post_comments AS (
	SELECT p.post_id, p.caption, c.comment_text
	FROM Posts p
	LEFT JOIN Comments c ON p.post_id = c.post_id
)
SELECT *
FROM post_comments;

-- Case Statement
-- Categorizing the posts based on the number of likes
-- Num_likes = 0 --> No likes
-- Num_likes < 5 --> Few likes
-- Num_likes < 10 --> Some likes
SELECT
	post_id,
	num_likes,
	CASE
		WHEN num_likes = 0 THEN 'No likes'
		WHEN num_likes < 5 THEN 'Few likes'
		WHEN num_likes < 10 THEN 'Some likes'
		ELSE 'Lot of likes'
	END AS like_category
FROM (
	SELECT p.post_id, COUNT(l.like_id) AS num_likes
	FROM Posts p
	LEFT JOIN Likes l ON p.post_id = l.post_id
	GROUP BY p.post_id
);

-- Date Casting and Working with Dates
-- Finding all the posts created in the last month
SELECT *
FROM Posts
WHERE created_at >= CAST(DATE_TRUNC('month', CURRENT_TIMESTAMP - INTERVAL '1 month') AS DATE);

