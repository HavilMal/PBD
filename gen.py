
import re
from dataclasses import dataclass, field
from typing import List, Optional


@dataclass
class QueryBlock:
    desc: List[str] = field(default_factory=list)
    sql: List[str] = field(default_factory=list)
    runQuery = False

    def finalize(self):
        self.desc = "\n".join(self.desc).strip()
        self.sql = "\n".join(self.sql).strip()


@dataclass
class ReportEntry:
    head: Optional[str] = None
    queries: List[QueryBlock] = field(default_factory=list)


class SqlReportParser:
    HEAD_RE = re.compile(r"^\s*--\s*head\s*:\s*(.*)$", re.IGNORECASE)
    DESC_RE = re.compile(r"^\s*--\s*desc\s*:\s*(.*)$", re.IGNORECASE)
    GENERIC_COMMENT_RE = re.compile(r"^\s*--\s*(.*)$")
    RUN_RE = re.compile(r"^\s*--\s*run\s*$", re.IGNORECASE)

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
            comment = self.GENERIC_COMMENT_RE.match(line)

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
            if comment and collecting_desc and not run:
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

            # ---- SQL LINES ----
            if current_query:
                if not line.strip().startswith("--"):
                    current_query.sql.append(line)
                
                if line.endswith(";"):
                    if current_query:
                        current_query.finalize()
                        if current_query.sql != "": 
                            current_report.queries.append(current_query)
                    current_query = QueryBlock()
                    
                continue

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

if __name__ == "__main__":
    file = "L2/R1Oracle.sql"
    with open(file, "r") as f:
        parser = SqlReportParser()
        result = parser.parse(f)
        
    for r in result:
        print("HEAD:", r.head)
        print("DESC:", r.queries)
        print("------")