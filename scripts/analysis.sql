-- Which users have liked post_id 2?
SELECT u.user_id, u.name FROM Users u
LEFT JOIN Likes l ON u.user_id = l.user_id
WHERE post_id = 2;

-- Which posts have no comments?
SELECT p.post_id, p.caption FROM Posts p
LEFT JOIN Comments c ON p.post_id = c.post_id
WHERE c.comment_id IS NULL

-- Which posts were created by users who have no followers?
SELECT Posts.caption
FROM Posts
JOIN Users ON Posts.user_id = Users.user_id
LEFT JOIN Followers ON Users.user_id = Followers.user_id
WHERE Followers.follower_id IS NULL;

-- or using subquery
SELECT post_id, caption FROM Posts
WHERE user_id IN (
	SELECT user_id
	FROM Followers
	GROUP BY user_id
	HAVING COUNT(follower_user_id) = 0 
);

-- How many likes does each post have?
SELECT p.post_id, p.caption, COUNT(l.like_id) AS num_likes
FROM Posts p
LEFT JOIN Likes l ON p.post_id = l.post_id
GROUP BY p.post_id;

-- What is the average number of likes?
SELECT AVG(num_likes) AS avg_likes
FROM (
    SELECT COUNT(Likes.like_id) AS num_likes
    FROM Posts
    LEFT JOIN Likes ON Posts.post_id = Likes.post_id
    GROUP BY Posts.post_id
);

--Which user has the most followers?
SELECT u.name, COUNT(f.follower_id) AS num_followers
FROM Users u
LEFT JOIN Followers f ON u.user_id = f.user_id
GROUP BY u.user_id
ORDER BY num_followers DESC
LIMIT 1;

-- Rank the users by the number of posts they have created.
SELECT name, num_posts, RANK() OVER(ORDER BY num_posts DESC) AS rank
FROM(
	SELECT u.name, COUNT(p.post_id) AS num_posts
	FROM Users u
	LEFT JOIN Posts p ON u.user_id = p.user_id
	GROUP BY u.user_id
);

-- Rank the posts based on the number of likes.
SELECT caption, num_likes, RANK() OVER(ORDER BY num_likes DESC) AS rank
FROM(
	SELECT p.caption, COUNT(l.like_id) AS num_likes
	FROM Posts p
	LEFT JOIN Likes l ON p.post_id = l.post_id
	GROUP BY p.post_id
)

-- Find the cumulative number of likes for each post.
SELECT post_id, num_likes, SUM(num_likes) OVER (ORDER BY created_at) AS cumulative_likes
FROM(
	SELECT p.post_id, COUNT(l.like_id) AS num_likes, p.created_at
	FROM Posts p
	LEFT JOIN Likes l ON p.post_id = l.post_id
	GROUP BY p.post_id
);

-- Find all the comments and their users using a Common Table Expression (CTE)
WITH comment_users AS (
	SELECT c.comment_text, u.name
	FROM Comments c
	JOIN Users u ON c.user_id = u.user_id
)
SELECT * FROM comment_users

-- Find all the followers and their follower users using a CTE.
WITH follower_users AS (
    SELECT Users.name AS follower, follower_users.name AS user_followed
    FROM Users
    JOIN Followers ON Users.user_id = Followers.follower_user_id
    JOIN Users AS follower_users ON Followers.user_id = follower_users.user_id
)
SELECT *
FROM follower_users;

-- Find all the posts and their comments using a CTE.
WITH post_comments AS (
    SELECT p.caption, c.comment_text
    FROM Posts p
    LEFT JOIN Comments c ON p.post_id = c.post_id
)
SELECT *
FROM post_comments;

-- Categorize the users based on the number of comments they have made.
SELECT
    Users.name,
    CASE
        WHEN num_comments = 0 THEN 'No comments'
        WHEN num_comments < 5 THEN 'Few comments'
        WHEN num_comments < 10 THEN 'Some comments'
        ELSE 'Lot of comments'
    END AS comment_category
FROM Users
LEFT JOIN (
    SELECT user_id, COUNT(comment_id) AS num_comments
    FROM Comments
    GROUP BY user_id
) AS comments_by_user ON Users.user_id = comments_by_user.user_id;

-- Categorize the posts based on their age.
SELECT
    post_id,
    CASE
        WHEN age_in_days < 7 THEN 'New post'
        WHEN age_in_days < 30 THEN 'Recent post'
        ELSE 'Old post'
    END AS age_category
FROM (
    SELECT post_id, CURRENT_DATE - created_at::DATE AS age_in_days
    FROM Posts
) AS post_ages;