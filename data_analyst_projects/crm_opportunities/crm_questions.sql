use crm;

-- 1) Which agents have the best and worst performance in terms of the percentage of won deals achieved?
	
    -- 1.1) First, we will create a CTE to store the number of deals by type grouped by agent:
    
		with agent_won as (
			select
				agent,
				count(deal_stage) as num_deals,
				count(case when deal_stage = 'Won' then deal_stage else null end) as 'won_deals'
			from sales
			group by 1
		)

    -- 1.2) Finally, we write a query to just return the agent names and their percentage won using SUBQUERIES:
    
		select
			(select agent from agent_won order by won_deals / num_deals desc limit 1) as 'best % won agent',
			(select concat(round(max(won_deals / num_deals * 100)), ' %') from agent_won) as 'best % won',
            (select num_deals from agent_won order by won_deals / num_deals desc limit 1) as 'deals best % won agent',
			(select agent from agent_won order by won_deals / num_deals limit 1) as 'worst % won agent',
			(select concat(round(min(won_deals / num_deals * 100)), ' %') from agent_won) as 'worst % won',
            (select num_deals from agent_won order by won_deals / num_deals limit 1) as 'deals worst % won agent'
		;
    
-- 2) If these agents are from different offices, do those offices follow the same pattern regarding the percentage of won deals?
		
	-- 2.1) We will use again the CTE created previously to be able to find their office in the next step:
    
		with agent_won as (
			select
				agent,
				count(deal_stage) as num_deals,
				count(case when deal_stage = 'Won' then deal_stage else null end) as 'won_deals'
			from sales
			group by 1
		)
    
    -- 2.2) To find their offices, we will join the CTE table with 'sales_teams' using subqueries:
    
		select
			(select agent from agent_won order by won_deals / num_deals desc limit 1) as 'best % won agent',
			(
				select s.regional_office
				from agent_won a
				join sales_teams s on a.agent = s.sales_agent
				order by won_deals / num_deals desc 
				limit 1
			) as 'office best % won agent',											
			(select agent from agent_won order by won_deals / num_deals limit 1) as 'worst % won agent',
			(
				select s.regional_office
				from agent_won a
				join sales_teams s on a.agent = s.sales_agent
				order by won_deals / num_deals 
				limit 1
			) as 'office worst % won agent'													
		;
		
	-- 2.3) Based on the CTE used previously, we have amended it to return the office information to make comparisons:

		select
			st.regional_office,
			concat(round(count(s.deal_stage) / (select count(deal_stage) from sales) * 100), ' %') as '%_from_total_deals',
			concat(round(count(case when s.deal_stage = 'Won' then s.deal_stage else null end) / count(s.deal_stage) * 100), ' %') as '%_won_deals',
			concat(round(count(case when s.deal_stage = 'Lost' then s.deal_stage else null end) / count(s.deal_stage) * 100), ' %') as '%_lost_deals',
			concat(round(count(case when s.deal_stage = 'Engaging' then s.deal_stage else null end) / count(s.deal_stage) * 100), ' %') as '%_engage_deals',
			concat(round(count(case when s.deal_stage = 'Prospecting' then s.deal_stage else null end) / count(s.deal_stage) * 100), ' %') as '%_prospect_deals',
			concat('$', sum(close_value)) as 'revenue_closed'
		from sales s
		join sales_teams st on s.agent = st.sales_agent
		group by 1
		order by 3 desc;
            
-- 3) Are there significant differences between the products managed by both agents?

     with agent_deals as (
		select
			agent,
			count(deal_stage) as num_deals,
			count(case when deal_stage = 'Won' then deal_stage else null end) as 'won_deals'
		from sales
		group by 1
		order by 2 desc
	)

    select
		product,
        count(case when agent = (select agent from agent_deals order by won_deals / num_deals desc limit 1) then deal_stage else null end) as 'num deals - Best % won agent',
        count(case when agent = (select agent from agent_deals order by won_deals / num_deals limit 1) then deal_stage else null end) as 'num deals - Worst % won agent',
        concat(round(count(case when agent = (select agent from agent_deals order by won_deals / num_deals desc limit 1) then deal_stage else null end) / (select num_deals from agent_deals order by won_deals / num_deals desc limit 1) * 100), ' %') as '% deals from total agent - Best % won agent',
        concat(round(count(case when agent = (select agent from agent_deals order by won_deals / num_deals limit 1) then deal_stage else null end) / (select num_deals from agent_deals order by won_deals / num_deals limit 1) * 100), ' %') as '% deals from total agent - Worst % won agent'
    from sales
    group by 1
    order by 2 desc;

-- 4) Which products have the best performance by sector?

	-- 4.1) First, we will create a CTE to count the number of deals per product and sector:
    
		with count_prod_sec as (
			select
				a.sector,
				s.product,
				count(s.deal_stage) as num_deals,
				count(case when deal_stage = 'Won' then deal_stage else null end) as 'won_deals',
				count(case when deal_stage = 'Lost' then deal_stage else null end) as 'lost_deals',
				count(case when deal_stage = 'Engaging' then deal_stage else null end) as 'engaging_deals',
				count(case when deal_stage = 'Prospecting' then deal_stage else null end) as 'prospecting_deals'
			from sales s
			join accounts a on s.account_name = a.account_id
			group by 1, 2
			order by 1, 3 desc
		),
    
    -- 4.2) Secondly, we will create a new CTE to filter maximum number of deals per sector to calculate the % from the total:
    
		max_sec as (
			select
				sector,
				max(num_deals) as max_deals
			from count_prod_sec
			group by 1
		)
    
    -- 4.3) Finally, we will create a query to calculate the % per type of deal from their total and grouped by sector with their best product:
    
		select
			c.sector,
			c.product,
			c.num_deals,
			concat(round(c.won_deals / c.num_deals * 100, 1), ' %') as '% won',
			concat(round(c.lost_deals / c.num_deals * 100, 1), ' %') as '% lost',
			concat(round(c.engaging_deals / c.num_deals * 100, 1), ' %') as '% engag',
			concat(round(c.prospecting_deals / c.num_deals * 100, 1), ' %') as '% prosp'
		from max_sec m
		join count_prod_sec c on m.sector = c.sector and m.max_deals = c.num_deals
		order by 4 desc, 3 desc;

-- 5) What are the top 5 agents who have won the most opportunities above the overall average won per agent in the shortest average time? Therefore, we can focus on the agents with bigger proportions of won deals
	
    -- 5.1) We created a CTE to calculate the number of days between the engage and close dates only for won deals:
    
		with datediff_per_deal as (
			select
				st.sales_agent,
				s.deal_stage,
				datediff(s.close_date, s.engage_date) as num_days
			from sales_teams st
			join sales s on st.sales_agent = s.agent
			where s.deal_stage = 'Won'
		),
    
    -- 5.2) Next, another CTE to calculate the average of the count of won deals grouped by agent:
    
		agent_count_deals as (
			select
				count(deal_stage) as num_deals
			from datediff_per_deal
			group by sales_agent
		)
	
    -- 5.3) Finally, we create a query to return the top 5 agents with the number of deals above the average number of deals per agent, the % from the total 
    --      won deals and the average days of a won deal:
    
		select
			sales_agent,
			count(deal_stage) as num_deals,
			concat(round(count(deal_stage) / (select count(deal_stage) from sales where deal_stage = 'Won') * 100, 1), ' %') as '%_total_won',
			concat(round(avg(num_days)), ' days') as avg_days
		from datediff_per_deal
		group by 1
		having num_deals > (select avg(num_deals) from agent_count_deals)
		order by 4
		limit 5;
        
-- 6) What are the top 3 sectors with the fewest opportunities won?
	
    -- 6.1) CTE to find the top 3 with fewer opportunities with also their count of the other type deals:
    
		with top_3_fewest_won_deals as (
			select
				a.sector,
				count(s.deal_stage) as num_deals,
				count(case when s.deal_stage = 'Won' then s.deal_stage else null end) as 'won_deals',
				count(case when s.deal_stage = 'Lost' then s.deal_stage else null end) as 'lost_deals',
				count(case when s.deal_stage = 'Engaging' then s.deal_stage else null end) as 'engaging_deals',
				count(case when s.deal_stage = 'Prospecting' then s.deal_stage else null end) as 'prospecting_deals'
			from accounts a
			join sales s on a.account_id = s.account_name
			group by 1
			order by 3
			limit 3
		),
        
	-- 6.2) CTE to find the top 3 with more opportunities with also their count of the other type deals:
    
		top_3_most_won_deals as (
			select
				a.sector,
				count(s.deal_stage) as num_deals,
				count(case when s.deal_stage = 'Won' then s.deal_stage else null end) as 'won_deals',
				count(case when s.deal_stage = 'Lost' then s.deal_stage else null end) as 'lost_deals',
				count(case when s.deal_stage = 'Engaging' then s.deal_stage else null end) as 'engaging_deals',
				count(case when s.deal_stage = 'Prospecting' then s.deal_stage else null end) as 'prospecting_deals'
			from accounts a
			join sales s on a.account_id = s.account_name
			group by 1
			order by 3 desc
			limit 3
		),
        
    -- 6.3) CTEs to calculate the average per type deal:
    
		sector_count_deals as (
			select
				a.sector,
                count(s.deal_stage) as num_deals,
				count(case when s.deal_stage = 'Won' then s.deal_stage else null end) as 'won_deals',
				count(case when s.deal_stage = 'Lost' then s.deal_stage else null end) as 'lost_deals',
				count(case when s.deal_stage = 'Engaging' then s.deal_stage else null end) as 'engaging_deals',
				count(case when s.deal_stage = 'Prospecting' then s.deal_stage else null end) as 'prospecting_deals'
			from accounts a
			join sales s on a.account_id = s.account_name
            group by 1
		),
        
        sector_avg_deals as (
			select
				avg(num_deals) as 'avg_deals',
				avg(won_deals) as 'avg_won',
                avg(lost_deals) as 'avg_lost',
                avg(engaging_deals) as 'avg_eng',
                avg(prospecting_deals) as 'avg_prosp'
			from sector_count_deals
        )
        
	-- 6.4) Finally, we identify how far the two groups are from the average per type of deal adding a rank per group:
    
		select
			'Top 3 more won deals' as 'top type',
            dense_rank() over(order by won_deals desc) 'won_rank',
            sector,
            concat(round((num_deals - (select avg_deals from sector_avg_deals)) / (select avg_deals from sector_avg_deals) * 100), ' %') as '% from deals_avg',
            concat(round((won_deals - (select avg_won from sector_avg_deals)) / (select avg_won from sector_avg_deals) * 100), ' %') as '% from won_avg',
            concat(round((lost_deals - (select avg_lost from sector_avg_deals)) / (select avg_lost from sector_avg_deals) * 100), ' %') as '% from lost_avg',
            concat(round((engaging_deals - (select avg_eng from sector_avg_deals)) / (select avg_eng from sector_avg_deals) * 100), ' %') as '% from eng_avg',
            concat(round((prospecting_deals - (select avg_prosp from sector_avg_deals)) / (select avg_prosp from sector_avg_deals) * 100), ' %') as '% from prosp_avg'
		from top_3_most_won_deals

        union all
        
        select
			'Top 3 fewer won deals' as 'top type',
            dense_rank() over(order by won_deals) 'won_rank',
            sector,
            concat(round((num_deals - (select avg_deals from sector_avg_deals)) / (select avg_deals from sector_avg_deals) * 100), ' %') as '% from deals_avg',
            concat(round((won_deals - (select avg_won from sector_avg_deals)) / (select avg_won from sector_avg_deals) * 100), ' %') as '% from won_avg',
            concat(round((lost_deals - (select avg_lost from sector_avg_deals)) / (select avg_lost from sector_avg_deals) * 100), ' %') as '% from lost_avg',
            concat(round((engaging_deals - (select avg_eng from sector_avg_deals)) / (select avg_eng from sector_avg_deals) * 100), ' %') as '% from eng_avg',
            concat(round((prospecting_deals - (select avg_prosp from sector_avg_deals)) / (select avg_prosp from sector_avg_deals) * 100), ' %') as '% from prosp_avg'
		from top_3_fewest_won_deals;