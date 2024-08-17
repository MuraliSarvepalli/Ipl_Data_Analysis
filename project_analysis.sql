--------1.Top 10 batsmen in IPL with 3 or more consectuvie 30+ scores--------
with batsman_runs as (
select sum(batsman_runs) as runs,batter,match_id from murali_ipl.deliveries_raw 
group by 2,3),
rno as(
select *,row_number() over (partition by batter order by match_id)  as rn from batsman_runs --where batter = 'V Kohli'
),
consec as (
select a.runs,a.batter,a.match_id, a.runs as current_match_score, b.runs as previous_match1_score, c.runs as previous_match2_score from rno a 
left join rno b on a.rn = b.rn+1 and a.batter = b.batter  
left join rno c on b.rn = c.rn+1 and b.batter = c.batter)
select batter ,count(*) as no_of_consec_30plus from consec where current_match_score >=30 and previous_match1_score >= 30 and previous_match2_score >=30 
group by batter order by no_of_consec_30plus desc
;


------------2.Top 10 economical bowlers in powerplay in entire IPL (alteast 100 overs bowled) -------------

select bowler, sum(total_runs) as runs_conceeded_in_pp ,round(count(ball)/6)  as overs_in_pp , round(sum(total_runs)/round(count(ball)/6) ,2) as economy
from murali_ipl.deliveries_raw 
where over_no in (0,1,2,3,4,5) 
group by bowler having count(ball) > 600
order by round(sum(total_runs)/round(count(ball)/6) ,2) LIMIT 10;


----------3. Most no bowls bowled in IPL-------

select bowler, sum(total_runs) as runs_conceeded_in_pp ,round(count(ball)/6)  as overs_in_pp , round(sum(total_runs)/round(count(ball)/6) ,2) as economy
from murali_ipl.deliveries_raw 
where over_no in (0,1,2,3,4,5) 
group by bowler having count(ball) > 600
order by round(sum(total_runs)/round(count(ball)/6) ,2) LIMIT 10 ;




