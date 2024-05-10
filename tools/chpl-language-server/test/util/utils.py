import json
import os
import tempfile
import typing

from lsprotocol.types import (
    DefinitionParams,
    DeclarationParams,
    TypeDefinitionParams,
)
from lsprotocol.types import ReferenceParams, ReferenceContext
from lsprotocol.types import InlayHintParams, InlayHintKind
from lsprotocol.types import LocationLink, Location, Position, Range
from lsprotocol.types import TextDocumentIdentifier
from lsprotocol.types import (
    DidChangeWorkspaceFoldersParams,
    WorkspaceFoldersChangeEvent,
    WorkspaceFolder,
)
from pytest_lsp import LanguageClient

from .config import CHPL_HOME


def strip_leading_whitespace(text: str) -> str:
    lines = text.split("\n")

    # Ignore leading empty lines
    while lines and not lines[0].strip():
        lines.pop(0)

    min_indent = min(
        len(line) - len(line.lstrip()) for line in lines if line.strip()
    )
    return "\n".join(line[min_indent:] for line in lines)


class SourceFilesContext:
    def __init__(self, client: LanguageClient, files: typing.Dict[str, str]):
        self.tempdir = tempfile.TemporaryDirectory(delete=False)
        self.client = client

        commands = {}
        allfiles = []
        for name, contents in files.items():
            # make the directory structure, last component is the name
            dir_path = self.tempdir.name
            components = os.path.normpath(name).split(os.sep)
            name = components[-1]
            for component in components[:-1]:
                dir_path = os.path.join(dir_path, component)
                os.makedirs(dir_path, exist_ok=True)

            filepath = os.path.join(dir_path, name + ".chpl")
            with open(filepath, "w") as f:
                f.write(strip_leading_whitespace(contents))

            allfiles.append(filepath)
            commands[filepath] = [{"module_dirs": [], "files": allfiles}]

        commandspath = os.path.join(self.tempdir.name, ".cls-commands.json")
        with open(commandspath, "w") as f:
            json.dump(commands, f)

    def __enter__(self):
        self.tempdir.__enter__()

        # Let the client know we added a new workspace folder.
        uri = "file://" + self.tempdir.name
        added = [WorkspaceFolder(uri=uri, name="Temp Workspace")]
        event = WorkspaceFoldersChangeEvent(added=added, removed=[])
        params = DidChangeWorkspaceFoldersParams(event=event)
        self.client.workspace_did_change_workspace_folders(params)

        return lambda name: TextDocumentIdentifier(
            uri=f"file://{os.path.join(self.tempdir.name, name + '.chpl')}"
        )

    def __exit__(self, *exc):
        return self.tempdir.__exit__(*exc)


class SourceFileContext:
    def __init__(
        self,
        main_file: str,
        client: LanguageClient,
        files: typing.Dict[str, str],
    ):
        self.main_file = main_file
        self.source_files_context = SourceFilesContext(client, files)

    def __enter__(self):
        return self.source_files_context.__enter__()(self.main_file)

    def __exit__(self, *exc):
        return self.source_files_context.__exit__(*exc)


def source_files(client: LanguageClient, **files: str):
    """
    Context manager that creates a temporary directory and populates
    it with the given files. The names of the keyword arguments are
    used as the names of the files. Yields a function that can be used to
    get the URI of a file by name.

    Also creates a .cls-commands.json file that can be used by the
    language server to connect the files together in the workspace.
    """
    return SourceFilesContext(client, files)


def source_file(client: LanguageClient, contents: str):
    """
    Context manager that creates a temporary directory and populates
    it with the given file. Yields the path to the file.
    """
    return SourceFileContext("main", client, {"main": contents})


def source_files_dict(client: LanguageClient, files: typing.Dict[str, str]):
    """
    Context manager that creates a temporary directory and populates it with
    the given files. The files dictionary uses the keys as file paths and the
    values as the content of the files. Yields a function that can be used to
    get the URI of a file by name.

    Also creates a .cls-commands.json file that can be used by the
    language server to connect the files together in the workspace.
    """
    return SourceFilesContext(client, files)


def pos(coord: typing.Tuple[int, int]):
    """
    Shorthand for writing position literals.
    """

    line, column = coord
    return Position(line=line, character=column)


def standard_module(name: str):
    """
    Retrieves the path of a standard module with the given name.
    """

    fullname = name + ".chpl"
    return TextDocumentIdentifier(
        f"file://{os.path.join(CHPL_HOME(), 'modules', 'standard', fullname)}"
    )


def internal_module(name: str):
    """
    Retrieves the path of an internal module with the given name.
    """

    fullname = name + ".chpl"
    return TextDocumentIdentifier(
        f"file://{os.path.join(CHPL_HOME(), 'modules', 'internal', fullname)}"
    )


DestinationTestType = typing.Union[
    None,
    Position,
    TextDocumentIdentifier,
    typing.Tuple[TextDocumentIdentifier, Position],
]
"""
The type of 'expected destinations' to be used with the various checking
functions below.
"""


def check_dst(
    doc: TextDocumentIdentifier,
    dst_actual: typing.Union[Location, LocationLink],
    dst_expected: DestinationTestType,
    expect_str: typing.Optional[str] = None,
) -> bool:
    """
    Matches a location against what it is expected to be.

    * If the expected destination is a position, matches the position
      and expects the same file as the source document.
    * If the expected destination is a document, only ensures that the
      actual location is in that document, and ignores the line etc.
    * If the expected destination is a document-position tuple, ensures
      that both the file and line number are as specified by the tuple.

    If expect_str is provided, also ensures that the first line of the location
    contains the given string. This is useful to help validate against module
    code, whose line numbers might change as the module is updated.
    """

    if isinstance(dst_actual, LocationLink):
        got_dst_pos = dst_actual.target_range.start
        got_dst_uri = dst_actual.target_uri
    else:
        got_dst_pos = dst_actual.range.start
        got_dst_uri = dst_actual.uri

    if isinstance(dst_expected, tuple):
        if got_dst_uri != dst_expected[0].uri or got_dst_pos != dst_expected[1]:
            return False
    elif isinstance(dst_expected, TextDocumentIdentifier):
        if got_dst_uri != dst_expected.uri:
            return False
    else:
        if got_dst_pos != dst_expected or got_dst_uri != doc.uri:
            return False

    if expect_str is not None:
        assert got_dst_uri.startswith("file://")
        file_content = open(got_dst_uri[len("file://") :]).read()
        return expect_str in file_content.split("\n")[got_dst_pos.line]

    return True


async def check_goto_decl_def(
    client: LanguageClient,
    doc: TextDocumentIdentifier,
    src: Position,
    dst: DestinationTestType,
    expect_str: typing.Optional[str] = None,
):
    """
    Ensures that go-to-definition and go-to-declaration on a symbol
    work, taking a source cursor position to an expected destination position.
    In Chapel, declaration and definition are the same, so the same check
    is used for both.
    """

    def validate(
        results: typing.Optional[
            typing.Union[
                Location, typing.List[Location], typing.List[LocationLink]
            ]
        ]
    ):
        if dst is None:
            assert results is None or (
                isinstance(results, list) and len(results) == 0
            )
            return

        assert results is not None
        result = None
        if isinstance(results, list):
            assert len(results) == 1
            result = results[0]
        else:
            result = results

        assert check_dst(doc, result, dst, expect_str)

    results = await client.text_document_definition_async(
        params=DefinitionParams(text_document=doc, position=src)
    )
    validate(results)

    results = await client.text_document_declaration_async(
        params=DeclarationParams(text_document=doc, position=src)
    )
    validate(results)


async def check_goto_type_def(
    client: LanguageClient,
    doc: TextDocumentIdentifier,
    src: Position,
    dst: DestinationTestType,
    expect_str: typing.Optional[str] = None,
):
    """
    Ensures that go-to-type-definition works, taking a source cursor position for a variable to an expected destination position.
    """

    def validate(
        results: typing.Optional[
            typing.Union[
                Location, typing.List[Location], typing.List[LocationLink]
            ]
        ]
    ):
        if dst is None:
            assert results is None or (
                isinstance(results, list) and len(results) == 0
            )
            return

        assert results is not None
        result = None
        if isinstance(results, list):
            assert len(results) == 1
            result = results[0]
        else:
            result = results

        assert check_dst(doc, result, dst, expect_str)

    results = await client.text_document_type_definition_async(
        params=TypeDefinitionParams(text_document=doc, position=src)
    )
    validate(results)


async def check_goto_decl_def_module(
    client: LanguageClient,
    doc: TextDocumentIdentifier,
    src: Position,
    mod: TextDocumentIdentifier,
):
    pieces = os.path.split(mod.uri)
    mod_name = pieces[-1][: -len(".chpl")]
    await check_goto_decl_def(client, doc, src, mod, f"module {mod_name} ")


async def check_references(
    client: LanguageClient,
    doc: TextDocumentIdentifier,
    src: Position,
    dsts: typing.List[DestinationTestType],
) -> typing.List[Location]:
    """
    Given a document, a 'hover' position and a list of expected results,
    validates that the language server finds the given references.
    """

    references = await client.text_document_references_async(
        params=ReferenceParams(
            text_document=doc,
            position=src,
            context=ReferenceContext(include_declaration=True),
        )
    )
    assert references is not None

    # Two-way check: make sure that all references are expected, and
    # all expected references are found.

    for ref in references:
        assert any(check_dst(doc, ref, dst) for dst in dsts)

    for dst in dsts:
        assert any(check_dst(doc, ref, dst) for ref in references)

    return references


async def check_references_and_cross_check(
    client: LanguageClient,
    doc: TextDocumentIdentifier,
    src: Position,
    dsts: typing.List[DestinationTestType],
):
    """
    Does two things:
        1. Performs the usual references list, ensuring that the references
           found by the language server match the expected ones.
        2. For each reference point found, repeats that check. Thus,
           if hovering over A finds B and C, then hovering over B should
           find A and C.
    This way, we can test a lot more cases automatically.
    """

    references = await check_references(client, doc, src, dsts)
    locations = [
        (TextDocumentIdentifier(uri=ref.uri), ref.range.start)
        for ref in references
    ]
    for ref in references:
        new_doc = TextDocumentIdentifier(uri=ref.uri)
        await check_references(client, new_doc, ref.range.start, locations)

async def check_inlay_hints(client: LanguageClient, doc: TextDocumentIdentifier, rng: Range, expected_inlays: typing.List[typing.Tuple[Position, str, typing.Optional[InlayHintKind]]]):
    """
    Check that the inlay hints in the document match the expected inlays. The
    expected inlays list should be sorted in the order that the inlays appear
    in the document.

    Each tuple in the expected inlays list should be a tuple of the position of
    the inlay hint, the text of the inlay hint, and kind of inlay. If the kind
    is None, it is ignored.
    """
    results = await client.text_document_inlay_hint_async(
        params=InlayHintParams(text_document=doc, range=rng)
    )

    if len(expected_inlays) == 0:
        assert results is None or len(results) == 0
        return

    assert results is not None
    assert len(expected_inlays) == len(results)

    sorted_results = sorted(results, key=lambda x: x.position)
    print(sorted_results)

    for expected, actual in zip(expected_inlays, sorted_results):
        assert expected[0] == actual.position

        actual_label = actual.label
        if isinstance(actual_label, list):
            actual_label = "".join([l.value for l in actual_label])

        assert expected[1] == actual_label
        assert expected[2] == actual.kind
