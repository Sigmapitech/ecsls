from typing import NamedTuple


class VersionInfo(NamedTuple):
    major: int
    minor: int
    micro: int

    def __repr__(self) -> str:
        return f"v{self.major}.{self.minor}.{self.micro}"


version_info = VersionInfo(0, 0, 1)
__version__ = repr(version_info)
