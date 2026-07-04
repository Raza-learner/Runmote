import json
from unittest import mock

import pytest
from fastapi import WebSocket


@pytest.fixture(autouse=True)
def _reset_state():
    import relay.state
    relay.state.store = mock.MagicMock()
    relay.state.store.is_deleted.return_value = False
    relay.state.store.register.return_value = None
    relay.state.app_clients = {}
    relay.state.app_to_token = {}
    relay.state.code_to_token = {}
    relay.state.token_to_daemons = {}
    relay.state.daemon_websocket = None
    yield


class TestDaemonIsPaired:
    def _import(self):
        import relay.handlers.daemon as m
        return m

    def test_paired_when_relay_token_is_none(self):
        mod = self._import()
        with mock.patch.object(mod, "RELAY_TOKEN", None):
            assert mod._is_paired("any-client") is True

    def test_paired_when_client_in_app_to_token(self):
        mod = self._import()
        with mock.patch.object(mod, "RELAY_TOKEN", "secret"):
            with mock.patch.object(mod.state, "app_to_token", {"client-1": "tok"}):
                assert mod._is_paired("client-1") is True

    def test_not_paired_when_client_not_in_app_to_token(self):
        mod = self._import()
        with mock.patch.object(mod, "RELAY_TOKEN", "secret"):
            assert mod._is_paired("unknown") is False


class TestDaemonPairedClients:
    def _import(self):
        import relay.handlers.daemon as m
        return m

    def test_yields_all_when_auth_disabled(self):
        mod = self._import()
        mod.state.app_clients = {"c1": mock.MagicMock(), "c2": mock.MagicMock()}
        with mock.patch.object(mod, "RELAY_TOKEN", None):
            clients = list(mod._paired_clients())
            assert len(clients) == 2

    def test_yields_only_authenticated(self):
        mod = self._import()
        ws1, ws2 = mock.MagicMock(), mock.MagicMock()
        mod.state.app_clients = {"c1": ws1, "c2": ws2}
        mod.state.app_to_token = {"c1": "tok1"}
        with mock.patch.object(mod, "RELAY_TOKEN", "secret"):
            clients = list(mod._paired_clients())
            assert len(clients) == 1
            assert clients[0][0] == "c1"
            assert clients[0][1] is ws1

    def test_skips_removed_clients(self):
        mod = self._import()
        ws = mock.MagicMock()
        mod.state.app_clients = {"c1": ws}
        mod.state.app_to_token = {"c1": "tok1"}
        with mock.patch.object(mod, "RELAY_TOKEN", "secret"):
            clients = list(mod._paired_clients())
            assert len(clients) == 1


class TestRegisterSession:
    def _import(self):
        import relay.handlers.daemon as m
        return m

    def test_register_with_sessionId(self):
        mod = self._import()
        session = {"sessionId": "s1", "name": "Test", "cwd": "/home", "agentId": "a1"}
        mod._register_session(session)
        mod.state.store.register.assert_called_once_with(
            "s1", client_id="", name="Test", cwd="/home", agent_id="a1", updated_at=None
        )

    def test_register_with_id_fallback(self):
        mod = self._import()
        session = {"id": "s1", "title": "Test"}
        mod._register_session(session)
        mod.state.store.register.assert_called_once_with(
            "s1", client_id="", name="Test", cwd="", agent_id="", updated_at=None
        )

    def test_register_empty_sid_returns_empty(self):
        mod = self._import()
        result = mod._register_session({})
        assert result == ""

    def test_skips_deleted_session(self):
        mod = self._import()
        mod.state.store.is_deleted.return_value = True
        result = mod._register_session({"sessionId": "deleted-s1"})
        assert result == ""
        mod.state.store.register.assert_not_called()

    def test_register_with_updated_at(self):
        mod = self._import()
        session = {"sessionId": "s1", "name": "Test", "updatedAt": 1234567890}
        mod._register_session(session)
        mod.state.store.register.assert_called_once_with(
            "s1", client_id="", name="Test", cwd="", agent_id="", updated_at=1234567890
        )

    def test_register_with_created_at_fallback(self):
        mod = self._import()
        session = {"sessionId": "s1", "name": "Test", "createdAt": 1000000000}
        mod._register_session(session)
        mod.state.store.register.assert_called_once_with(
            "s1", client_id="", name="Test", cwd="", agent_id="", updated_at=1000000000
        )

    def test_register_non_numeric_updated_at(self):
        mod = self._import()
        session = {"sessionId": "s1", "name": "Test", "updatedAt": "not-a-number"}
        mod._register_session(session)
        mod.state.store.register.assert_called_once_with(
            "s1", client_id="", name="Test", cwd="", agent_id="", updated_at=None
        )


class TestAppIsAuthenticated:
    def _import(self):
        import relay.handlers.app as m
        return m

    def test_authenticated_when_token_is_none(self):
        mod = self._import()
        with mock.patch.object(mod, "RELAY_TOKEN", None):
            assert mod._is_authenticated("any-client") is True

    def test_authenticated_when_client_in_app_to_token(self):
        mod = self._import()
        with mock.patch.object(mod, "RELAY_TOKEN", "secret"):
            with mock.patch.object(mod.state, "app_to_token", {"client-1": "tok"}):
                assert mod._is_authenticated("client-1") is True

    def test_not_authenticated_when_not_paired(self):
        mod = self._import()
        with mock.patch.object(mod, "RELAY_TOKEN", "secret"):
            assert mod._is_authenticated("unknown") is False


class TestSendError:
    def _import(self):
        import relay.handlers.app as m
        return m

    @pytest.mark.asyncio
    async def test_sends_valid_error(self):
        mod = self._import()
        ws = mock.AsyncMock(spec=WebSocket)
        await mod._send_error(ws, 1, -32000, "test error")
        ws.send_text.assert_awaited_once()
        sent = json.loads(ws.send_text.call_args[0][0])
        assert sent["jsonrpc"] == "2.0"
        assert sent["id"] == 1
        assert sent["error"]["code"] == -32000
        assert sent["error"]["message"] == "test error"

    @pytest.mark.asyncio
    async def test_send_with_none_id(self):
        mod = self._import()
        ws = mock.AsyncMock(spec=WebSocket)
        await mod._send_error(ws, None, -1, "msg")
        ws.send_text.assert_awaited_once()


class TestRequireAuth:
    def _import(self):
        import relay.handlers.app as m
        return m

    @pytest.mark.asyncio
    async def test_returns_true_when_authenticated(self):
        mod = self._import()
        ws = mock.AsyncMock(spec=WebSocket)
        with mock.patch.object(mod, "_is_authenticated", return_value=True):
            result = await mod._require_auth(ws, "client-1", 1)
            assert result is True
            ws.send_text.assert_not_called()

    @pytest.mark.asyncio
    async def test_returns_false_and_sends_error_when_not_auth(self):
        mod = self._import()
        ws = mock.AsyncMock(spec=WebSocket)
        with mock.patch.object(mod, "_is_authenticated", return_value=False):
            result = await mod._require_auth(ws, "client-1", 1)
            assert result is False
            ws.send_text.assert_awaited_once()
