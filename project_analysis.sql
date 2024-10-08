--------1.Top 10 batsmen in IPL with 3 or more consectuvie 30+ scores--------
with batsman_runs as (
select sum(batsman_runs) as runs,batter,match_id from murali_ipl.deliveries_raw 
group by 2,3),
rno as(
select *,row_number() over (partition by batter order by match_id)  as rn from batsman_runs 
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


----------3. More no bowls bowled in IPL-------

select bowler, sum(total_runs) as runs_conceeded_in_pp ,round(count(ball)/6)  as overs_in_pp , round(sum(total_runs)/round(count(ball)/6) ,2) as economy
from murali_ipl.deliveries_raw 
where over_no in (0,1,2,3,4,5) 
group by bowler having count(ball) > 600
order by round(sum(total_runs)/round(count(ball)/6) ,2) LIMIT 10 ;

---------4. No of wins by each team in the IPL----

select winner,count(*) as no_of_wins from murali_ipl.matches_raw 
group by winner order by count(*) desc ;


------5. Batsman with most not outs in successful chases in IPL----- 

with cte as (
  select match_id , max(over_no) as over_no from murali_ipl.deliveries_raw
  where inning=2
  group by match_id
),
cte2 as (
select b.* ,row_number() over(partition by b.match_id order by b.ball desc)  as rn from cte a inner join murali_ipl.deliveries_raw b
on a.match_id = b.match_id and a.over_no = b.over_no
where b.inning = 2 and b.is_wicket = 0-- and b.match_id =1254094
)
select batter , sum(no_of_not_outs_in_chasing) as no_of_not_outs_in_chasing from (
select batter ,count(*) as no_of_not_outs_in_chasing from cte2 a inner join murali_ipl.matches_raw 
b on a.match_id = b.id 
and a.batting_team = b.winner  where a.rn = 1
group by batter
union all 
select non_striker as batter ,count(*) as no_of_not_outs_in_chasing from cte2 a inner join murali_ipl.matches_raw 
b on a.match_id = b.id 
and a.batting_team = b.winner  where a.rn = 1
group by batter)a group by batter order by no_of_not_outs_in_chasing desc;


------6. Top 5 teams who has defended less than or equal to 150---

select winner,count(winner)  as count_of_defended_150 from murali_ipl.matches_raw where safe_cast(target_runs as int64)<=150
and result = 'runs'
group by 1 order by 2 desc limit 5

-----7. Top 5 batsmen with best averages in knockout stages of IPL(Play off's ,finals) with alteast 5 innings played in knock out stages

with cte as (
  select player_dismissed as batter , count(1) as no_of_outs from 
murali_ipl.deliveries_raw a
inner join murali_ipl.matches_raw b 
on a.match_id = b.id where player_dismissed <> 'NA' and b.match_type <> 'League'
group by player_dismissed
) ,
cte2 as (
select a.batter,round(sum(batsman_runs)/max(no_of_outs),2) as average_in_knockouts  from cte a inner join 
murali_ipl.deliveries_raw b on a.batter = b.batter
inner join murali_ipl.matches_raw c on b.match_id = c.id
where c.match_type<> 'League' and a.no_of_outs > 5
group by batter)
select a.batter , average_in_knockouts from cte2 a inner join (
  select batter,count(*) as no_of_knock_out_inngs from(
  select batter , match_id, sum(batsman_runs)  from murali_ipl.deliveries_raw a 
  inner join murali_ipl.matches_raw b on a.match_id= b.id and b.match_type <> 'League'
  group by batter,match_id) group by batter
) b on a.batter = b.batter where b.no_of_knock_out_inngs >5
order by average_in_knockouts desc limit 5





