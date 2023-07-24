import tempfile
from pygls.workspace import Document

from .version import __version__
from .vera import get_vera_output, ReportType

from pygls.server import LanguageServer
from lsprotocol.types import (
    TEXT_DOCUMENT_DID_CHANGE,
    TEXT_DOCUMENT_DID_OPEN,
    Diagnostic,
    DiagnosticSeverity,
    DidOpenTextDocumentParams,
    Position,
    Range,
)

server = LanguageServer("ecsls", __version__)


class LineRange(Range):
    def __init__(self, line: int):
        super().__init__(start=Position(line - 1, 1), end=Position(line - 1, 80))


SEVERITIES = {
    ReportType.MAJOR: DiagnosticSeverity.Warning,
    ReportType.MINOR: DiagnosticSeverity.Information,
    ReportType.INFO: DiagnosticSeverity.Hint
}


def get_diagnostics(text_doc: Document):
    content = text_doc.source
 
    with tempfile.NamedTemporaryFile(suffix=".c") as tf:
        tf.write(content.encode())
        tf.flush()

        reports = get_vera_output(tf.name)

    return [
        Diagnostic(
            range=LineRange(report.line),
            message=report.message,
            source="Json Server",
            severity=SEVERITIES[report.type],
        )
        for report in reports
    ]


@server.feature(TEXT_DOCUMENT_DID_OPEN)
async def did_open(ls: LanguageServer, params: DidOpenTextDocumentParams):
    """Text document did open notification."""
    text_doc = ls.workspace.get_document(params.text_document.uri)
    ls.publish_diagnostics(text_doc.uri, get_diagnostics(text_doc))


@server.feature(TEXT_DOCUMENT_DID_CHANGE)
async def did_changement(ls: LanguageServer, params: DidOpenTextDocumentParams):
    text_doc = ls.workspace.get_document(params.text_document.uri)
    ls.publish_diagnostics(text_doc.uri, get_diagnostics(text_doc))
