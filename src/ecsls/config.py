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

        user_home = os.environ.get("$HOME", "~")
        user_conf = os.environ.get("$XDG_CONFIG_HOME", f"{user_home}/.config")
        self.path = os.path.expanduser(f"{user_conf}/ecsls")

    def set_opts(self, opts: LSPAny, ls: LanguageServer):
        if opts is None:
            return

        self.path = opts.get("path", self.path)
        ls.show_message(f"=> PATH = [{self.path}]")
        if not os.path.exists(self.path):
            raise ValueError

    def _read_conf(self, confpath):
        default_conf = {
            "ignore": [],
            "severity_levels": True,
            "merge": "multiline",
            "text": {
                "level": False,
                "code": True,
                "description": True
            }
        }

        if not os.path.exists(confpath):
            self.__conf = default_conf
            return

        with open(confpath, "rb") as f:
            self.__conf = tomli.load(f).get("reports", default_conf)

    def read(self, ls: LanguageServer, filepath):
        path = Path(filepath.split(':')[-1])

        while path != '/':
            abs_path = (path / 'ecsls.toml').absolute()
            if abs_path.exists():
                ls.show_message(f"load conf @ {abs_path}")
                return self._read_conf(path / "ecsls.toml")

            path = path.parent

    def get(self, key, typ, default):
        v = self.__conf.get(key)

        if v is None:
            return default

        if not isinstance(v, typ):
            return default

        return v
