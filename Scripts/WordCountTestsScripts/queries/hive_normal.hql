drop table if exists wc_normal;
CREATE TABLE wc_normal AS SELECT word, count(1) AS count FROM (SELECT explode(split(line, '\s')) AS word FROM docs_normal) w GROUP BY word ORDER BY word;
