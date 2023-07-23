import sys
from . import __version__


def main() -> int:
    print("Hello from ECSLS", __version__)


if __name__ == "__main__":
    sys.exit(main())

