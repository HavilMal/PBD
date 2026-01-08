

SELECT MAX(level) "lvl" FROM kocury CONNECT BY PRIOR LENGTH(pseudo) < LENGTH(pseudo);