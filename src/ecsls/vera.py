from __future__ import annotations

import re
import subprocess

from dataclasses import dataclass
from enum import Enum

import re
import subprocess
from typing import Final, List, Optional

from .config import Config


class ReportType(str, Enum):
    FATAL = "FATAL"
    MAJOR = "MAJOR"
    MINOR = "MINOR"
    INFO = "INFO"


_levels = '|'.join(m for m in ReportType.__members__)

REPORT_FORMAT: Final[re.Pattern] = re.compile(
    rf"^[^:]+:(?P<line>\d+):\s?(?P<type>{_levels}):(?P<rule>C-\w\d+)$"
)


@dataclass
class Report:
    line: int
    type: ReportType
    rule: str

    last_line: int = 0
    count: int = 1

    def __post_init__(self):
        self.last_line = self.line

    def is_mergeable(self, line):
        return line in range(self.line - 1, self.last_line + 2)

    def merge(self, report: Report):
        self.line = min(self.line, report.line)
        self.last_line = max(self.last_line, report.line)
        self.count += report.count

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

        conf = Config.instance()
        text = conf.get("text", dict, {})

        desc_members = []

        if text.get("level", False):
            desc_members.append(str(self.type))
        if text.get("code", True):
            desc_members.append(self.rule)
        if text.get("description", True):
            desc_members.append(str(msg.get(self.rule)))

        desc = ':'.join(desc_members)
        if conf.get("merge", str, "multiline") != "multiplier":
            return desc

        times = f" x{self.count}" * (self.count > 1)
        return desc + times

def populate_descriptions():
    descriptions = {}

    conf = Config.instance()
    with open(f"{conf.path}/vera/code_to_comment") as f:
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


def get_vera_output(filename: str) -> List[Report]:
    conf = Config.instance()
    if not filename:
        return []

    out = subprocess.run(
        (
            "vera++",
            "--profile",
            "epitech",
            "--root",
            f"{conf.path}/vera",
            filename,
        ),
        capture_output=True,
    ).stdout

    return parse_vera_output(out.decode())


if __name__ == "__main__":
    print(get_vera_output("caca.c"))
