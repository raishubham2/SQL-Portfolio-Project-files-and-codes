select * from Data1
select * from data2

--number of rows indataset
select COUNT(*) from Data1
select COUNT(*) from Data2

--dataset for jharkhand and bihar
select distinct(state) as unique_state from Data1
select * from Data1 where state in ('Bihar','Jharkhand')

--population of india

select SUM(population) as population from data2

--avgerage growth of india

select AVG(growth)*100 as avg_growth from Data1

--avg growth for state
select state ,AVG(growth)*100 avg_growth_state from Data1 group by [State ];

--avg sex ratio

select state ,round(AVG(Sex_Ratio),0) avg_sex_ratio_state from Data1 group by
[State ] order by avg_sex_ratio_state desc

--avg literacy 

select state ,round(AVG(Literacy),0) avg_literacy_state from Data1 group by
[State ] having round(AVG(Literacy),0) > 90 order by avg_literacy_state desc 

--top 3 state showing highest growth ratio

select state ,AVG(growth)*100 avg_growth_state from Data1
group by [State ] order by avg_growth_state desc;

--bottom 3 state showing lowest growth ratio

select top 3 state ,round(AVG(Sex_Ratio),0) avg_sex_ratio_state from Data1 group by
[State ] order by avg_sex_ratio_state

--top and bottom  3 state in literacy state  

create table #topstate
(state nvarchar(255),topstate float)

insert into #topstate
select state ,round(AVG(Literacy),0) avg_literacy_state from Data1 group by
[State ] having round(AVG(Literacy),0) > 90 order by avg_literacy_state desc 

create table #bottomstate 
(state nvarchar(255) ,bottomstate float)

insert into #bottomstate
select state ,round(AVG(Literacy),0) avg_literacy_state from Data1 group by
[State ] order by avg_literacy_state 

-- union operator

select * from (
select top 3 * from #topstate order by topstate desc) a

union
select * from (select top 3 *from #bottomstate order by bottomstate) b

--state starting with letter a 

select distinct [State ] from Data1 where LOWER([State ]) like  'a%'

--join table

--total number of males in females in each state 

 select d.state,sum(d.males) total_males ,sum(d.females) total_females from 
 (select district ,state ,round(population/(sex_ratio+1),0) males ,
 round((population*sex_ratio)/(sex_ratio +1),0) as females
 from (select d1.District,d1.State,d1.Sex_Ratio/1000 as sex_ratio,d2.Population  from Data1 d1 inner join 
 Data2 d2 on d1.District = d2.District) c) d group by d.state

 ---total literacy state

 select e.state ,SUM(literate_people) as total_literate_pop ,SUM(illiterate_people) total_illiterate_pop from
 (select district ,state ,round((literacy_ratio *population),0) literate_people ,
 round((1-literacy_ratio)* population,0) illiterate_people  from  
 (select d1.District,d1.State,d1.Literacy/100 literacy_ratio ,d2.Population  
 from Data1 d1 inner join Data2 d2 on d1.District = d2.District) as d) e
 group by e.state 

 --population in previous census

 select SUM(total_prev_pop) total_previous_census_pop ,SUM(total_current_pop) current_census_pop  from
 (select state ,SUM(previous_census_population) total_prev_pop ,SUM(current_cesus_population) total_current_pop from
 (select state ,District ,round(population/(1+growth),0) previous_census_population ,population current_cesus_population from
 (select d1.District,d1.State,d1.Growth growth ,d2.Population  
 from Data1 d1 inner join Data2 d2 on d1.District = d2.District)d) e
 group by state ) f

 --populaton vs area

 select (total_area/total_previous_census_pop)as previous_census_population_vs_area ,(total_area/current_census_pop) as
 current_census_population_vs_area  from

 (select q.*,r.total_area from 
 (select '1' as keyy ,n.* from(

  select SUM(total_prev_pop) total_previous_census_pop ,SUM(total_current_pop) as current_census_pop  from
 (select state ,SUM(previous_census_population) total_prev_pop ,SUM(current_cesus_population) total_current_pop from
 (select state ,District ,round(population/(1+growth),0) previous_census_population ,population current_cesus_population from
 (select d1.District,d1.State,d1.Growth growth ,d2.Population  
 from Data1 d1 inner join Data2 d2 on d1.District = d2.District)d) e
 group by state ) f)n) q inner join 

 (select '1' as keyy,z.* from(
 select  sum(Area_km2) total_area from Data2) z) r on q.keyy = r.keyy) t



--top 3 district from each state with highest literacy rate

select a.* from 
 (select state,district , RANK() over(partition by state order by literacy desc) rnk from Data1) a
  where rnk in (1,2,3) 

  --top 3 district in each state in terms of good sex_ratio

  select a.* from (
  select state ,district,RANK() over(partition by state order by sex_ratio desc ) rnk from Data1 ) a 
   where rnk In (1,2,3,4,5)