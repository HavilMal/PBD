chcp 65001 >nul

python write.py Raport.md "# Raport lista 1" -o
python write.py Raport.md "## Tworzenie bazy w Oracle"
python sql_to_markdown.py KocuryOracle.sql Raport.md -a  
python write.py Raport.md "## Tworzenie bazy w SQL Server"
python sql_to_markdown.py KocuryServer.sql Raport.md -a
python write.py Raport.md "## Ładowanie danych w Oracle"
python sql_to_markdown.py KocuryDataOracle.sql Raport.md -a
python write.py Raport.md "## Ładowanie danych w SQL Server
python sql_to_markdown.py KocuryDataServer.sql Raport.md -a
python write.py Raport.md "## Część 1 w Oracle"
python sql_to_markdown.py KocuryZadanie1.sql Raport.md -a
python write.py Raport.md "## Część 1 w SQL Server"
python sql_to_markdown.py KocuryZadanie1Server.sql Raport.md -a
python write.py Raport.md "## Część 2 w Oracle"
python sql_to_markdown.py KocuryZadanie2.sql Raport.md -a
python write.py Raport.md "## Część 3 w Oracle"
python sql_to_markdown.py KocuryZadanie3.sql Raport.md -a