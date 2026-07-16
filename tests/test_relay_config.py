import os
from unittest import mock

import relay.config


class TestRelayConfig:
    def test_defaults(self):
        assert relay.config.HOST == "0.0.0.0"
        assert relay.config.PORT == 8000
        assert relay.config.DAEMON_PATH == "/daemon"
        assert relay.config.APP_PATH == "/app"
        assert relay.config.RELAY_TOKEN is None

    def test_host_from_env(self):
        with mock.patch.dict(os.environ, {"ACP_RELAY_HOST": "127.0.0.1"}, clear=False):
            import importlib

            importlib.reload(relay.config)
            assert relay.config.HOST == "127.0.0.1"
            assert relay.config.PORT == 8000

    def test_port_from_env(self):
        with mock.patch.dict(os.environ, {"ACP_RELAY_PORT": "9000"}, clear=False):
            import importlib

            importlib.reload(relay.config)
            assert relay.config.PORT == 9000

    def test_token_from_env(self):
        with mock.patch.dict(os.environ, {"ACP_RELAY_TOKEN": "my-secret"}, clear=False):
            import importlib

            importlib.reload(relay.config)
            assert relay.config.RELAY_TOKEN == "my-secret"

    def test_token_unset_is_none(self):
        with mock.patch.dict(os.environ, {}, clear=False):
            if "ACP_RELAY_TOKEN" in os.environ:
                del os.environ["ACP_RELAY_TOKEN"]
            import importlib

            importlib.reload(relay.config)
            assert relay.config.RELAY_TOKEN is None
