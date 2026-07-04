import os
import sys
import tempfile
from pathlib import Path
from unittest import mock

from common.logger import ACPLogger, LogLevel


class TestLogLevel:
    def test_name_known_levels(self):
        assert LogLevel.name(10) == "DEBUG"
        assert LogLevel.name(20) == "INFO"
        assert LogLevel.name(30) == "WARN"
        assert LogLevel.name(40) == "ERROR"

    def test_name_unknown_level(self):
        assert LogLevel.name(99) == "UNKNOWN"

    def test_constant_values(self):
        assert LogLevel.DEBUG == 10
        assert LogLevel.INFO == 20
        assert LogLevel.WARN == 30
        assert LogLevel.ERROR == 40


class TestACPLogger:
    def test_init_creates_log_dir(self, tmp_path):
        log_dir = tmp_path / "logs"
        logger = ACPLogger("Test", log_dir=log_dir)
        assert log_dir.exists()

    def test_init_default_log_dir(self):
        with mock.patch("common.logger._LOG_DIR", Path("/tmp/acp_test_logs")):
            logger = ACPLogger("Test")
            assert logger._log_dir == Path("/tmp/acp_test_logs")

    def test_device_id_from_env(self):
        with mock.patch.dict(os.environ, {"ACP_DEVICE_ID": "device-123"}, clear=False):
            logger = ACPLogger("Test", log_dir=Path(tempfile.mkdtemp()))
            assert logger.device_id == "device-123"

    def test_device_id_setter(self):
        logger = ACPLogger("Test", log_dir=Path(tempfile.mkdtemp()))
        logger.device_id = "manual-device"
        assert logger.device_id == "manual-device"

    def test_should_log_above_threshold(self):
        logger = ACPLogger("Test", log_dir=Path(tempfile.mkdtemp()))
        logger._min_level = LogLevel.INFO
        assert logger._should_log(LogLevel.ERROR) is True
        assert logger._should_log(LogLevel.INFO) is True
        assert logger._should_log(LogLevel.DEBUG) is False

    def test_debug_does_not_log_below_min_level(self):
        logger = ACPLogger("Test", log_dir=Path(tempfile.mkdtemp()))
        logger._min_level = LogLevel.INFO
        with mock.patch.object(logger, "_write") as mock_write:
            logger.debug("should not appear")
            mock_write.assert_not_called()

    def test_info_logs_at_correct_level(self):
        logger = ACPLogger("Test", log_dir=Path(tempfile.mkdtemp()))
        logger._min_level = LogLevel.DEBUG
        with mock.patch.object(logger, "_write") as mock_write:
            logger.info("hello world", key1="val1")
            mock_write.assert_called_once_with(LogLevel.INFO, "hello world", key1="val1")

    def test_error_logs_to_error_file(self):
        logger = ACPLogger("Test", log_dir=Path(tempfile.mkdtemp()))
        logger._min_level = LogLevel.DEBUG
        with (
            mock.patch.object(logger, "_write") as mock_write,
            mock.patch.object(logger, "_write_error") as mock_write_error,
        ):
            logger.error("something failed", session_id="s1")
            mock_write.assert_called_once()
            mock_write_error.assert_called_once()

    def test_exception_logs_traceback(self):
        logger = ACPLogger("Test", log_dir=Path(tempfile.mkdtemp()))
        logger._min_level = LogLevel.DEBUG
        try:
            raise ValueError("test error")
        except ValueError as exc:
            with (
                mock.patch.object(logger, "_write") as mock_write,
                mock.patch.object(logger, "_write_error") as mock_write_error,
            ):
                logger.exception("handler failed", exc=exc, session_id="s1")
                assert mock_write.call_count == 1
                written = mock_write.call_args[0][1]
                assert "test error" in written

    def test_write_appends_to_file(self, tmp_path):
        log_dir = tmp_path / "logs"
        logger = ACPLogger("Test", log_dir=log_dir)
        logger._min_level = LogLevel.DEBUG
        logger._write(LogLevel.INFO, "file write test", extra="val")
        content = (log_dir / "test.log").read_text()
        assert "file write test" in content
        assert "extra=val" in content

    def test_write_extra_skips_none_values(self, tmp_path):
        log_dir = tmp_path / "logs"
        logger = ACPLogger("Test", log_dir=log_dir)
        logger._min_level = LogLevel.DEBUG
        logger._write(LogLevel.INFO, "message", key=None, other="val")
        content = (log_dir / "test.log").read_text()
        assert "key=None" not in content
        assert "other=val" in content

    def test_write_includes_device_id(self, tmp_path):
        log_dir = tmp_path / "logs"
        logger = ACPLogger("Test", log_dir=log_dir)
        logger.device_id = "dev-1"
        logger._write(LogLevel.INFO, "msg")
        content = (log_dir / "test.log").read_text()
        assert "device=dev-1" in content

    def test_write_error_appends_to_errors_file(self, tmp_path):
        log_dir = tmp_path / "logs"
        logger = ACPLogger("Test", log_dir=log_dir)
        logger._write_error("critical failure", session="s1")
        content = (log_dir / "errors.log").read_text()
        assert "critical failure" in content
        assert "session=s1" in content

    def test_write_silently_handles_oserror(self):
        with mock.patch.object(Path, "mkdir"):
            logger = ACPLogger("Test", log_dir=Path("/nonexistent/path"))
        logger._file_path = Path("/nonexistent/path/test.log")
        logger._error_path = Path("/nonexistent/path/errors.log")
        logger._write(LogLevel.INFO, "should not crash")
