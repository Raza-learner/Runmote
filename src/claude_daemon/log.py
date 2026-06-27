import sys
import traceback
from datetime import datetime, timezone
from typing import Optional


DEBUG: bool = False


class LogLevel:
    DEBUG = 10
    INFO = 20
    WARN = 30
    ERROR = 40

    _NAMES = {10: "DEBUG", 20: "INFO", 30: "WARN", 40: "ERROR"}

    @classmethod
    def name(cls, level: int) -> str:
        return cls._NAMES.get(level, "UNKNOWN")


_min_level = LogLevel.INFO


def configure(debug: bool = False, level: str = "INFO"):
    global _min_level, DEBUG
    DEBUG = debug
    if debug:
        _min_level = LogLevel.DEBUG
    else:
        _min_level = getattr(LogLevel, level.upper(), LogLevel.INFO)


def _ts() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")


def _write(level: int, message: str, **extra):
    if level < _min_level:
        return
    ts = _ts()
    level_name = LogLevel.name(level)
    parts = [ts, "ClaudeAgent", level_name, message]
    for k, v in extra.items():
        if v is not None:
            parts.append(f"{k}={v}")
    print(" ".join(parts), file=sys.stderr, flush=True)


def debug(message: str, **extra):
    _write(LogLevel.DEBUG, message, **extra)


def info(message: str, **extra):
    _write(LogLevel.INFO, message, **extra)


def warn(message: str, **extra):
    _write(LogLevel.WARN, message, **extra)


def error(message: str, **extra):
    _write(LogLevel.ERROR, message, **extra)


def exception(message: str, exc: Optional[BaseException] = None, **extra):
    tb = ""
    if exc is not None:
        tb = "".join(traceback.format_exception(type(exc), exc, exc.__traceback__))
    _write(LogLevel.ERROR, f"{message}\n{tb}" if tb else message, **extra)
