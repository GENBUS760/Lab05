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
select OwnerUserId, avg(nvl(regexp_count(tags, '<'), 0)) as AvgTagCount
from Posts
where PostTypeId = 1
group by OwnerUserId
having count(*) > 50;

-- LECTURE 5

-- Advanced Grouping: Multiple Columns

-- Q. How many posts were created in each month and year?
select year(CreationDate), month(CreationDate), count(*)
from Posts
group by year(CreationDate), month(CreationDate);

-- Advanced Grouping: rollup

-- Q. How many posts were created in each month and year?
--    Also report the year totals and grand total.
select year(CreationDate) y, month(CreationDate) m, count(*) c
from Posts
group by rollup (y, m);

-- Q. How many posts were created in each month and year?
--    Also report the year totals and grand total.
--    Order the results by year and month in increasing order.
select year(CreationDate) y, month(CreationDate) m, count(*) c
from Posts
group by rollup (y, m)
order by (y, m);

-- Q. Replace the NULL cells in the previous result with "TOTAL"

-- Subqueries

-- Which user had the most reputation?
select Id, Reputation
from Users
where Reputation = (select max(Reputation) from Users);

-- Q. Top 3 users with the highest reputation
select Id, Reputation
from Users
where Reputation in (
    select Reputation from Users
    order by Reputation desc limit 3
);

-- Q. Top 3 users with the most no. of posts
select OwnerUserId, count(*) from Posts
group by OwnerUserId
having OwnerUserId in (
    select OwnerUserId
    from Posts
    group by OwnerUserId
    order by count(*) desc
    limit 3
);

-- Q. Users who created at least one community wiki
select * from PostTypes;

select OwnerUserId
from Posts p
where exists (
    select OwnerUserId
    from Posts q
    where PostTypeId = 3
        and p.OwnerUserId = q.OwnerUserId
);

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
select a.OwnerUserId as AnswererId,
       count(*) c
from Posts q
inner join Posts a
    on q.AcceptedAnswerId = a.Id
where q.AcceptedAnswerId != 0
    and a.PostTypeId = 2
group by AnswererId
order by c desc;

-- Q. Among users who had at least one accepted answer, what is the
--    average number of accepted answers?
--
-- Hint: Convert the query above into a subquery
select avg(c) from (
    select count(*) c,
           a.OwnerUserId as AnswererId
    from Posts q
    inner join Posts a
        on q.AcceptedAnswerId = a.Id
    where q.AcceptedAnswerId != 0
        and a.PostTypeId = 2
    group by AnswererId
    order by c desc
);

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
select a.OwnerUserId as AnswererId,
       count(*) c,
       (select count(*) from Posts where OwnerUserId= a.OwnerUserId and PostTypeId = 2) as TotalAnswers
from Posts q
inner join Posts a
    on q.AcceptedAnswerId = a.Id
where q.AcceptedAnswerId != 0
    and a.PostTypeId = 2
group by AnswererId
order by c desc;

-- Set Operations

-- Q. Report the number of questions tagged with <mysql> and the
--    number of questions tagged with <postgresql> separately
select 'MySQL', count(*) from Posts where tags like '%<mysql>%' and PostTypeId = 1
union all
select 'PostgreSQL', count(*) from Posts where tags like '%<postgresql>%' and PostTypeId = 1;

-- Q. How many questions were tagged with <sql> but not with <mysql>?
select count(*) from (
    select Id from Posts where tags like '%<sql>%' and PostTypeId = 1
    minus
    select Id from Posts where tags like '%<mysql>%' and PostTypeId = 1
);

-- Q. How many questions were tagged with <sql> and <mysql>?
select count(*) from (
    select Id from Posts where tags like '%<sql>%' and PostTypeId = 1
    intersect
    select Id from Posts where tags like '%<mysql>%' and PostTypeId = 1
);

-- Conditional Logic

-- Q. Return the IDs of questions with a new column
--    called EditStatus, set to Edited if the question
--    was edited (LastEditDate is not null) or Never
--    Edited otherwise 

select Id, (case when LastEditDate is null then 'Never Edited'
                 when LastEditDate is not null then 'Edited'
            end) as EditStatus
from Posts
where PostTypeId = 1;

-- Q. Report the number of questions with an accepted answer and the number
-- of questions with no accepted answer using a single query
select sum(case when AcceptedAnswerId > 0
            then 1
            else 0
           end) as NumQuestionsWithAccepted,
       sum(case when AcceptedAnswerId = 0
            then 1
            else 0
           end) as NumQuestionsWithoutAccepted
from Posts
where PostTypeId = 1;

select count(*) from Posts where PostTypeId = 1 and AcceptedAnswerId > 0
union all
select count(*) from Posts where PostTypeId = 1 and AcceptedAnswerId = 0;

-- Q. Report the number of users with (i) no questions, (ii) between
--    1 and 100 questions, and (iii) more than 100 questions using
--    a single query without unions

select t.NumPosts, count(*) from 
(
    select OwnerUserId,
        (case when count(*) = 0 then 'None'
              when count(*) between 1 and 100 then '<100'
              when count(*) > 100 then '>100'
         end) as NumPosts
    from Posts
    where PostTypeId = 1
    group by OwnerUserId
) t
group by t.NumPosts;

-- Q. Can you redo the previous query using union?

-- Ranking
select Id, Reputation,
    row_number() over (order by Reputation)
from Users;

select Id, Reputation,
    rank() over (order by Reputation)
from Users
where Reputation > 3000;
