from __future__ import annotations

import os
from pathlib import Path

import tomli
from lsprotocol.types import LSPAny
from pygls.server import LanguageServer

class Config:
    _instance = None

    @classmethod
    def instance(cls) -> Config:
        if cls._instance is None:
            cls._instance = cls()

        return cls._instance

    def __init__(self):
        self.__conf = {}
        self.path = "./banana-coding-style-checker"

    def set_opts(self, opts: LSPAny, ls: LanguageServer):
        if opts is None:
            return

        self.path = opts.get("path", self.path)
        ls.show_message(f"=> PATH = [{self.path}]")
        if not os.path.exists(self.path):
            raise ValueError

    def _read_conf(self, confpath):
        with open(confpath, "rb") as f:
            self.__conf = tomli.load(f)

    def read(self, filepath):
        path = Path(filepath)

        while path != '/':
            if (path / "ecsls.toml").exists():
                return self._read_conf(path / "ecsls.toml")

            path = path.parent

    def get(self, key, default):
        return self.__conf.get(key, default)
