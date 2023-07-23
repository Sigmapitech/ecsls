from .version import __version__

from pygls.server import LanguageServer
from lsprotocol.types import (
    TEXT_DOCUMENT_COMPLETION,
    CompletionItem,
    CompletionList,
    CompletionOptions,
    CompletionParams,
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

