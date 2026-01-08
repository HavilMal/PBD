
import re
from dataclasses import dataclass, field
from typing import List, Optional
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus


header = "### "
description = ""
sql_start = "```sql\n"
sql_end = "\n```"


@dataclass
class QueryBlock:
    desc: List[str] = field(default_factory=list)
    sql: List[str] = field(default_factory=list)
    runQuery = False
    silent = False

    def finalize(self):
        self.desc = "\n".join(self.desc).strip()
        self.sql = "\n".join(self.sql).strip()
        
    def run(self, connection):
        return connection.execute(text(self.sql))

@dataclass
class ReportEntry:
    head: Optional[str] = None
    queries: List[QueryBlock] = field(default_factory=list)


class SqlReportParser:
    HEAD_RE = re.compile(r"^\s*--\s*head\s*:\s*(.*)$", re.IGNORECASE)
    DESC_RE = re.compile(r"^\s*--\s*desc\s*:\s*(.*)$", re.IGNORECASE)
    GENERIC_COMMENT_RE = re.compile(r"^\s*--\s*(.*)$")
    RUN_RE = re.compile(r"^\s*--\s*run\s*$", re.IGNORECASE)
    RUNSILENT_RE = re.compile(r"^\s*--\s*silent\s*$", re.IGNORECASE)
    END_RE = re.compile(r"^\s*--\s*end\s*$", re.IGNORECASE)

    def parse(self, lines: List[str]) -> List[ReportEntry]:
        reports = []
        current_report = None
        current_query = None
        collecting_desc = False
        collecting_sql = False

        for raw in lines:
            line = raw.rstrip("\n")

            head = self.HEAD_RE.match(line)
            desc = self.DESC_RE.match(line)
            run = self.RUN_RE.match(line)
            runsilent = self.RUNSILENT_RE.match(line)
            comment = self.GENERIC_COMMENT_RE.match(line)
            end = self.END_RE.match(line)

            # ---- HEAD START ----
            if head:
                if current_report:
                    reports.append(current_report)

                current_report = ReportEntry(head=head.group(1).strip())
                current_query = None
                collecting_desc = False
                if current_query is None:
                    current_query = QueryBlock()
                continue

            # ---- DESC START ----
            if desc and current_report:
                
                collecting_desc = True
                current_query.desc.append(desc.group(1).strip())
                continue

            # ---- MULTILINE DESCRIPTION ----
            if comment and collecting_desc and not (run or runsilent):
                text = comment.group(1).strip()
                # skip empty "--"
                if text:
                    current_query.desc.append(text)
                continue

            # ---- RUN (SQL STARTS NOW) ----
            if run and current_report:
                # ensure a query exists
                current_query.runQuery = True
                collecting_desc = False
                continue
            
            if runsilent and current_report:
                current_query.runQuery = True
                current_query.silent = True
                collecting_desc = False
                continue


            # ---- SQL LINES ----
            if current_query:
                if not line.strip().startswith("--"):
                    current_query.sql.append(line)

                
            if end:
                if current_query:
                    current_query.finalize()
                    if current_query.sql != "":
                        current_report.queries.append(current_query)
                current_query = QueryBlock()
                    

            # If any other line, descriptions end
            collecting_desc = False

        # ---- FINALIZE LAST REPORT + QUERY ----
        if current_report:
            if current_query:
                current_query.finalize()
                # only push if nonempty
                if current_query.sql or current_query.desc:
                    current_report.queries.append(current_query)
            reports.append(current_report)

        return reports
    
def to_table(result, header):
    rows = result.fetchall()
    cols = ["#"] + list(result.keys())
    if (rows is None):
        print("ERROR", header, ": empty result")
    else:
        print("PASS ", header, ": fetched", len(rows), "lines")


    header = f"| {' | '.join(cols)} |"
    sep = f"| {' | '.join(['---']*len(cols))} |"

    lines = [header, sep]
    for i, row in enumerate(rows, 1):
        line = f"| {i} | " + " | ".join(str(x) if x is not None else "null" for x in row) + " |"
        lines.append(line)

    return "\n".join(lines) + "\n"

    
def chooseEngine(path: str):
    if path.count("Oracle") > 0:
        return create_engine("oracle+oracledb://koty:password@localhost:1521/?service_name=FREEPDB1")    

    if path.count("MSSQL") > 0 or path.count("TSQL") > 0:
        password = quote_plus("P@ssw0rd")
        return create_engine(f"mssql+pyodbc://sa:{password}@localhost,1433/Koty?driver=ODBC+Driver+17+for+SQL+Server")
    
    raise Exception("Unrecognized database file")

def writeRaport(f, parsed, connection):
    for r in parsed:
        f.write(header + r.head + "\n")
        for q in r.queries:
            f.write(description + q.desc.capitalize() + "\n")
            f.write(sql_start + q.sql + sql_end + "\n")
            if q.runQuery:
                try:
                    result = q.run(connection)
                except Exception:
                    print("FAILED: ", q.sql)
                    continue

                if not q.silent:
                    f.write(to_table(result, r.head) + "\n")
                    
def writePart(sql_path, md_path):
    engine = chooseEngine(sql_path)
    with engine.connect() as connection:
        if "Oracle" in sql_path:
            connection.execute(text("ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD'"))
        
        with open(sql_path, "r", encoding="utf-8") as f:
            parser = SqlReportParser()
            result = parser.parse(f)
            
        with open(md_path, "a+", encoding="utf-8") as f:
            writeRaport(f, result, connection)

if __name__ == "__main__":
    files = [
#         "L2/R1Oracle.sql",
#         "L2/R1MSSQL.sql",
#         "L2/Zadania1Oracle.sql",
#         "L2/Zadania1MSSQL.sql",
#         "L2/Zadania2Oracle.sql",
#         "L2/Zadania2MSSQL.sql",
          "L3/BlokOracle.sql"
    ]
    
    md_path = "Raport 3.md"
    
    open(md_path, "w+")
    
    for file in files:
        writePart(file, md_path=md_path)

            