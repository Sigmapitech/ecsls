from __future__ import annotations

from dataclasses import dataclass
from enum import StrEnum

import re
import subprocess
from typing import Final, List, Optional


REPORT_FORMAT: Final[re.Pattern] = re.compile(
    r"^[^:]+:(?P<line>\d+):\s?(?P<type>MAJOR|MINOR|INFO):(?P<rule>C-\w\d)$"
)


class ReportType(StrEnum):
    MAJOR = "MAJOR"
    MINOR = "MINOR"
    INFO = "INFO"


@dataclass
class Report:
    line: int
    type: ReportType
    rule: str

    @classmethod
    def from_string(cls, line: str) -> Optional[Report]:
        match = re.match(REPORT_FORMAT, line)

        if match is None:
            return None

        line, typ, rule = match.groups()

        return cls(line=int(line), type=ReportType(typ), rule=rule)

    @property
    def message(self) -> str:
        msg = populate_descriptions()
        desc = str(msg.get(self.rule))

        return f"{self.rule}: {desc}"


def populate_descriptions():
    descriptions = {}

    with open("banana-coding-style-checker/vera/code_to_comment") as f:
        content = f.read()

    for line in content.split("\n"):
        rule, _, desc = line.partition(":")
        descriptions[rule] = desc

    return descriptions


def parse_vera_output(raw_report: str) -> List[Report]:
    reports = raw_report.split("\n")

    out = []
    for reported_line in reports:
        report = Report.from_string(reported_line)

        if report is None:
            continue

        out.append(report)

    return out


def get_vera_output(filename: str):
    out = subprocess.run(
        (
            "vera++",
            "--profile",
            "epitech",
            "--root",
            "banana-coding-style-checker/vera",
            filename,
        ),
        capture_output=True,
    ).stdout

    return parse_vera_output(out.decode())


if __name__ == "__main__":
    print(get_vera_output("caca.c"))
