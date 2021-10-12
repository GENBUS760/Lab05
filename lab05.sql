-- set context
use stackoverflow2010;

-- RECAP OF LECTURE/LAB 4

-- query structure 1
-- order matters! case does not matter
select distinct * -- should duplicate rows be removed? which columns?
from Posts -- which table(?)
where PostTypeId = 1 or PostTypeId = 2 -- filters: =, >, >=, <, <=, !=, <>
                                       -- more: like, ilike, in, between, is null
                                       -- logical operations: and, or, not
order by CreationDate -- ordering columns
limit 1; -- limit number of rows

-- query structure 2
select OwnerUserId, sum(AnswerCount) as NumAnswers,
    sum(AnswerCount)/10 as NumAnswersDividedBy10
from Posts
where PostTypeId = 1
group by OwnerUserId
having NumAnswers > 10
order by NumAnswers desc
limit 1;

-- Challenge Lab 4 Solution
--
-- Q1. How many questions in the
-- dataset have accepted answers?



-- Q2. How many questions with the
-- <sql> tag (among other tags) are posted in each year?



-- Q3. On what day of the week are
-- most questions posted?



-- Some more exercises:
--
-- Q. What is the average number of tags used by each
--    user in the questions they ask? Only consider users
--    having at least 50 questions.


-- LECTURE 5

-- Advanced Grouping: Multiple Columns

-- Q. How many posts were created in each month and year?


-- Advanced Grouping: rollup

-- Q. How many posts were created in each month and year?
--    Also report the year totals and grand total.


-- Q. How many posts were created in each month and year?
--    Also report the year totals and grand total.
--    Order the results by year and month in increasing order.


-- Q. Replace the NULL cells in the previous result with "TOTAL"

-- Subqueries

-- Which user had the most reputation?


-- Q. Top 3 users with the highest reputation


-- Q. Top 3 users with the most no. of posts


-- Q. Users who created at least one community wiki
select * from PostTypes;


-- Q. How many posts were created in each month and year?
--    Also report the year totals and grand total.
--    Order the results by year and month in increasing order.
--    Replace the NULL months (not years) in the result with "TOTAL".
--
-- Try: Fix the query below.

select t.y as Year, t.m as Month, t.c
from (
    select year(CreationDate) y, month(CreationDate) m, count(*) c
    from Posts
    group by rollup (y, m)
    order by (y, m)
) t;

-- Joins

-- Q. Which user had the largest number of answers accepted?
--
-- Hints: i.   The Posts table contains both questions and answers.
--
--        ii.  Inspect the AcceptedAnswerID column.
--
--        iii. Is there a way to get the accepted answer and its OwnerUserId
--             for each question from the Posts table? Maybe a self join?
--
--        iv.  Once you have done the above, group by the OwnerUserId of the
--             accepted answer and count to get the number of accepted answers
--             by each user


-- Q. Among users who had at least one accepted answer, what is the
--    average number of accepted answers?
--
-- Hint: Convert the query above into a subquery


-- Q. Can the query above be changed to compute the average
--    number of accepted answers for all users? How?

-- Challenge Lab 5: Write a query to compute the average
-- number of accepted answers over all users in the data.
-- 
-- Note: This is a difficult query!

-- Q. For each user with at least one accepted answer,
-- report the number of answers they had accepted and
-- their total number of answers
--
-- Hint: Use a correlated subquery in the SELECT statement
--       along with a query you wrote earlier in this lab


-- Set Operations

-- Q. Report the number of questions tagged with <mysql> and the
--    number of questions tagged with <postgresql> separately


-- Q. How many questions were tagged with <sql> but not with <mysql>?


-- Q. How many questions were tagged with <sql> and <mysql>?


-- Conditional Logic

-- Q. Return the IDs of questions with a new column
--    called EditStatus, set to Edited if the question
--    was edited (LastEditDate is not null) or Never
--    Edited otherwise 



-- Q. Report the number of questions with an accepted answer and the number
-- of questions with no accepted answer using a single query


-- Q. Report the number of users with (i) no questions, (ii) between
--    1 and 100 questions, and (iii) more than 100 questions using
--    a single query without unions


-- Q. Can you redo the previous query using union?
