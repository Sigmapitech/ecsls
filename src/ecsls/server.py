import tempfile
from typing import Dict, List

from .config import Config
from .version import __version__
from .vera import get_vera_output, Report, ReportType

from pygls.server import LanguageServer
from pygls.workspace import Document

from lsprotocol.types import (
    TEXT_DOCUMENT_DID_CHANGE,
    TEXT_DOCUMENT_DID_OPEN,
    INITIALIZE,
    Diagnostic,
    DiagnosticSeverity,
    DidOpenTextDocumentParams,
    InitializeParams,
    Position,
    Range,
)

server = LanguageServer("ecsls", __version__)


class LineRange(Range):
    def __init__(self, line: int, last_line: int = 0):
        super().__init__(
            start=Position(line - 1, 1),
            end=Position(last_line or (line - 1), 80)
        )


SEVERITIES = {
    ReportType.MAJOR: DiagnosticSeverity.Warning,
    ReportType.MINOR: DiagnosticSeverity.Information,
    ReportType.INFO: DiagnosticSeverity.Hint
}

def _merge_cf4s(reports: List[Report]) -> List[Report]:
    out_reports = []
    cf4s: Dict[int, Report] = {}

    for report in sorted(reports, key=lambda r: r.line):
        if report.rule != 'C-F4':
            out_reports.append(report)
            continue

        for k in cf4s.values():
            if k.is_mergeable(report.line):
               k.merge(report)
               break
        else:
            cf4s[report.line] = report

    out_reports.extend(cf4s.values())
    return out_reports


def get_diagnostics(text_doc: Document):
    content = text_doc.source
    filename = ".mk" if text_doc.filename == "Makefile" else text_doc.filename 
    
    conf = Config.instance()
    conf.read(text_doc.uri)

    with tempfile.NamedTemporaryFile(suffix=filename) as tf:
        tf.write(content.encode())
        tf.flush()

        reports = get_vera_output(tf.name)

    return [
        Diagnostic(
            range=LineRange(report.line, report.last_line),
            message=report.message,
            source="Json Server",
            severity=SEVERITIES[report.type],
        )
        for report in _merge_cf4s(reports)
        if report.rule not in conf.get("ignore", [])
    ]

@server.feature(INITIALIZE)
async def initialize(ls: LanguageServer, params: InitializeParams):
    Config.instance().set_opts(params.initialization_options, ls)


@server.feature(TEXT_DOCUMENT_DID_OPEN)
async def did_open(ls: LanguageServer, params: DidOpenTextDocumentParams):
    """Text document did open notification."""
    text_doc = ls.workspace.get_document(params.text_document.uri)
    ls.publish_diagnostics(text_doc.uri, get_diagnostics(text_doc))


@server.feature(TEXT_DOCUMENT_DID_CHANGE)
async def did_changement(ls: LanguageServer, params: DidOpenTextDocumentParams):
    text_doc = ls.workspace.get_document(params.text_document.uri)
    ls.publish_diagnostics(text_doc.uri, get_diagnostics(text_doc))
