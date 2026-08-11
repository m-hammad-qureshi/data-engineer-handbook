# Set variables for previous year and current year so can make change just for one time.
SET custom.p_year = '1972';
SET custom.c_year = '1973';

Insert INTO actors
WITH prev_year AS(
			Select * from actors
			where year = current_setting('custom.p_year')::int
),
	cur_year AS(
			SELECT actorid, actor, year, ARRAY_AGG(Row(filmid, votes, rating, film)::film_state) as aggr_film
			from actor_films
			where year = current_setting('custom.c_year')::int
			GROUP by actorid, actor, year
	),
	rating_avg as(
			Select actorid, avg(actor_films.rating) as avg_point
			from actor_films
			where year <= current_setting('custom.c_year')::int  -- Average of actor rating till the most recent year
			group by actorid
	)
	Select 
		COALESCE(c.actorid, p.actorid) as actorid,
		COALESCE(c.actor, p.actor) as actor,
		current_setting('custom.c_year')::int as year,  -- To keep the missing actor data.
		Case 
			when p.film_state IS null then c.aggr_film
			when c.year is not null then p.film_state || c.aggr_film
			ELSE p.film_state
		END as film_state,
		Case 
			when c.year is not null then 0
			Else p.years_since_last_movie + 1
		End as years_since_last_movie
	from cur_year as c full outer join prev_year as p on c.actorid = p.actorid
	join rating_avg as ra on coalesce(c.actorid, p.actorid) = ra.actorid;
	on conflict(actorid, year) do nothing;
