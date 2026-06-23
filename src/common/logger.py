"""Shared logger for relay and daemon components.

Usage:
    from common.logger import ACPLogger

    log = ACPLogger("Relay")
    log.info("Device connected", device="abc123")
    log.exception("Handler failed", exc=e, session_id=sid, payload=body)
"""

import os
import sys
import traceback
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional


_LOG_DIR = Path(os.environ.get("ACP_LOG_DIR", "logs"))
_LOG_LEVEL = os.environ.get("ACP_LOG_LEVEL", "DEBUG").upper()


class LogLevel:
    DEBUG = 10
    INFO = 20
    WARN = 30
    ERROR = 40

    _NAMES = {10: "DEBUG", 20: "INFO", 30: "WARN", 40: "ERROR"}

    @classmethod
    def name(cls, level: int) -> str:
        return cls._NAMES.get(level, "UNKNOWN")


class ACPLogger:
    """Structured logger for ACP components.

    Log format: ``YYYY-MM-DD HH:MM:SS COMPONENT LEVEL message key=val ...``

    Components should use the names ``Relay``, ``Daemon``, ``Agent``.
    """

    def __init__(self, component: str, log_dir: Optional[Path] = None):
        self._component = component
        self._log_dir = log_dir or _LOG_DIR
        self._log_dir.mkdir(parents=True, exist_ok=True)
        self._min_level = getattr(LogLevel, _LOG_LEVEL, LogLevel.DEBUG)
        self._file_path = self._log_dir / f"{component.lower()}.log"
        self._error_path = self._log_dir / "errors.log"
        self._device_id: str = os.environ.get("ACP_DEVICE_ID", "")

    @property
    def device_id(self) -> str:
        return self._device_id

    @device_id.setter
    def device_id(self, value: str):
        self._device_id = value

    def _timestamp(self) -> str:
        return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")

    def _write(self, level: int, message: str, **extra):
        ts = self._timestamp()
        level_name = LogLevel.name(level)
        parts = [ts, self._component, level_name, message]
        for k, v in extra.items():
            if v is not None:
                key = k.replace("_", "-")
                parts.append(f"{key}={v}")
        if self._device_id:
            parts.append(f"device={self._device_id}")
        line = " ".join(parts)
        # Always print to stderr for dev visibility
        print(line, file=sys.stderr, flush=True)
        # Write to component log file
        try:
            with open(self._file_path, "a") as f:
                f.write(line + "\n")
        except OSError:
            pass

    def _should_log(self, level: int) -> bool:
        return level >= self._min_level

    def debug(self, message: str, **extra):
        if self._should_log(LogLevel.DEBUG):
            self._write(LogLevel.DEBUG, message, **extra)

    def info(self, message: str, **extra):
        if self._should_log(LogLevel.INFO):
            self._write(LogLevel.INFO, message, **extra)

    def warn(self, message: str, **extra):
        if self._should_log(LogLevel.WARN):
            self._write(LogLevel.WARN, message, **extra)

    def error(self, message: str, **extra):
        if self._should_log(LogLevel.ERROR):
            self._write(LogLevel.ERROR, message, **extra)
            self._write_error(message, **extra)

    def exception(
        self,
        message: str,
        exc: Optional[BaseException] = None,
        session_id: Optional[str] = None,
        payload: Optional[str] = None,
        **extra,
    ):
        """Log an exception with full context.

        Args:
            message: Human-readable description.
            exc: The exception object (traceback extracted automatically).
            session_id: Active session ID at time of failure.
            payload: The request payload that caused the error (JSON string).
            extra: Additional key-value pairs.
        """
        tb = ""
        if exc is not None:
            tb = "".join(traceback.format_exception(type(exc), exc, exc.__traceback__))
        full = f"{message}\n{tb}" if tb else message
        self._write(LogLevel.ERROR, full, session=session_id, payload=payload, **extra)
        self._write_error(full, session=session_id, payload=payload, **extra)

    def _write_error(self, message: str, **extra):
        ts = self._timestamp()
        parts = [ts, self._component, "ERROR", message]
        for k, v in extra.items():
            if v is not None:
                parts.append(f"{k}={v}")
        if self._device_id:
            parts.append(f"device={self._device_id}")
        line = " ".join(parts)
        try:
            with open(self._error_path, "a") as f:
                f.write(line + "\n")
        except OSError:
            pass
