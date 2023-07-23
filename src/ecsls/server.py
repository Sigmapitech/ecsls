from .version import __version__
from .vera import ReportType, Report, get_vera_output

from pygls.server import LanguageServer
from lsprotocol.types import (
    TEXT_DOCUMENT_DID_CHANGE,
    TEXT_DOCUMENT_DID_OPEN,
    Diagnostic,
    DidOpenTextDocumentParams,
    Position,
    Range,
)


server = LanguageServer('ecsls', __version__)

class LineRange(Range):
    def __init__(self, line: int):
        super().__init__(
            start=Position(line - 1, 1),
            end=Position(line - 1, 80)
        )

def get_diagnolstics(filename: str):
    reports = get_vera_output(filename)
    return [
        Diagnostic(
            range=LineRange(report.line),
            message=report.rule,
            source="Json Server",
        )
        for report in reports
    ]


@server.feature(TEXT_DOCUMENT_DID_OPEN)
async def did_open(ls: LanguageServer, params: DidOpenTextDocumentParams):
    """Text document did open notification."""
    text_doc = ls.workspace.get_document(params.text_document.uri)
    name = text_doc.uri.partition('://')[2]
    ls.publish_diagnostics(text_doc.uri, get_diagnolstics(name))


@server.feature(TEXT_DOCUMENT_DID_CHANGE)
async def did_changement(ls: LanguageServer, params: DidOpenTextDocumentParams):
    text_doc = ls.workspace.get_document(params.text_document.uri)
    name = text_doc.uri.partition('://')[2]
    ls.publish_diagnostics(text_doc.uri, get_diagnolstics(name))

