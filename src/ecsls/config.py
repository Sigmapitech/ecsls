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
        self._has_invalid_ruleset = False

        user_home = os.environ.get("$HOME", "~")
        user_conf = os.environ.get("$XDG_CONFIG_HOME", f"{user_home}/.config")
        self.path = os.path.expanduser(f"{user_conf}/ecsls")

    def set_opts(self, opts: LSPAny, ls: LanguageServer):
        if opts is None:
            return

        self.path = opts.get("path", self.path)
        if not os.path.exists(self.path):
            self._has_invalid_ruleset = True
            ls.show_message(
                f"cannot find coding style ruleset in {self.path}."
                " ESCSLS will not run"
            )

    def _read_conf(self, confpath) -> bool:
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
            return False

        with open(confpath, "rb") as f:
            self.__conf = tomli.load(f).get("reports", default_conf)
        return True

    def read(self, ls: LanguageServer, filepath) -> bool:
        if self._has_invalid_ruleset:
            return False

        path = Path(filepath.split(':')[-1])
        count_slash = str(path.absolute).count('/')

        for _ in range(count_slash):
            abs_path = (path / 'ecsls.toml').absolute()

            if abs_path.exists():
                ls.show_message(f"load conf @ {abs_path}")
                return self._read_conf(path / "ecsls.toml")

            path = path.parent
        return False

    def get(self, key, typ, default):
        v = self.__conf.get(key)

        if v is None:
            return default

        if not isinstance(v, typ):
            return default

        return v
