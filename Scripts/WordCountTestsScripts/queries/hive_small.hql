drop table if exists wc_small;
CREATE TABLE wc_small AS SELECT word, count(1) AS count FROM (SELECT explode(split(line, '\s')) AS word FROM docs_small) w GROUP BY word ORDER BY word;
