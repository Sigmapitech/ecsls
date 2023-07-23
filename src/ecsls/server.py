from .version import __version__

from pygls.server import LanguageServer
from lsprotocol.types import (
    TEXT_DOCUMENT_COMPLETION,
    TEXT_DOCUMENT_DID_OPEN,
    CompletionItem,
    CompletionList,
    CompletionOptions,
    CompletionParams,
    Diagnostic,
    DidOpenTextDocumentParams,
    Position,
    Range,
)

server = LanguageServer('ecsls', __version__)

@server.feature(
    TEXT_DOCUMENT_COMPLETION,
    CompletionOptions(trigger_characters=["!"])
)
def completions(_params: CompletionParams):
    return CompletionList(
        is_incomplete=False,
        items=[
            CompletionItem(label="its"),
            CompletionItem(label="working"),
        ]
    )

@server.feature(TEXT_DOCUMENT_DID_OPEN)
async def did_open(ls, params: DidOpenTextDocumentParams):
    """Text document did open notification."""
    ls.show_message("Text Document Did Open")

    # Get document from workspace
    text_doc = ls.workspace.get_document(params.text_document.uri)
    line = 1
    col = 1

    diagnostic = Diagnostic(
        range=Range(
            start=Position(line - 1, col - 1),
            end=Position(line - 1, col)
        ),
        message="Custom validation message",
        source="Json Server"
    )

    # Send diagnostics
    ls.publish_diagnostics(text_doc.uri, [diagnostic])

