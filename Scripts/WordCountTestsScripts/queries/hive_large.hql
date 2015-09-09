drop table if exists wc_large;
CREATE TABLE wc_large AS SELECT word, count(1) AS count FROM (SELECT explode(split(line, '\s')) AS word FROM docs_large) w GROUP BY word ORDER BY word;
