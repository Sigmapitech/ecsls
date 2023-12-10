import logging
import sys
from . import __version__, server


logger = logging.getLogger(__package__)

def main():
    logger.info("hello from ECSLS", __version__)
    server.start_io()


if __name__ == "__main__":
    sys.exit(main())
