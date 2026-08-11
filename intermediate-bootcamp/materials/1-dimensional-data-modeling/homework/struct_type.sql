CREATE TYPE film_state AS(
			filmid text,
			votes integer,
			rating real,
			film text
);

CREATE TYPE quality_class AS ENUM('star', 'good','average', 'bad');
CREATE TYPE is_active AS ENUM('yes','no');

Create Table actors(
			actorid text,
			actor text,
			year integer,
			film_state film_state[],
			years_since_last_movie INTEGER,
			quality_class quality_class,
			is_active is_active,
			primary key (actorid, year)
);