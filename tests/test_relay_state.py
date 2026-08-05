from unittest import mock

import pytest
from fastapi import WebSocket

import relay.state
from relay.state import DaemonSession, issue_app_token


@pytest.fixture(autouse=True)
def _reset_state():
    relay.state.known_tokens = {}
    relay.state.daemons = {}
    yield
    relay.state.known_tokens = {}
    relay.state.daemons = {}


def _session(daemon_id="pc-host", token="SHARED_SECRET"):
    ws = mock.AsyncMock(spec=WebSocket)
    return DaemonSession(websocket=ws, daemon_id=daemon_id, token=token)


class TestIssueAppToken:
    def test_token_is_deterministic(self):
        a = issue_app_token("pc-host", "SHARED_SECRET")
        b = issue_app_token("pc-host", "SHARED_SECRET")
        assert a == b
        assert a.startswith("v1.")

    def test_different_daemons_get_different_tokens(self):
        assert issue_app_token("pc-a", "secret") != issue_app_token("pc-b", "secret")

    def test_different_tokens_for_different_secrets(self):
        assert issue_app_token("pc-host", "secret-a") != issue_app_token("pc-host", "secret-b")


class TestResolveDeterministic:
    def test_resolves_against_online_daemon(self):
        relay.state.daemons["pc-host"] = _session()
        tok = issue_app_token("pc-host", "SHARED_SECRET")
        assert relay.state.get_daemon_id_by_token(tok) == "pc-host"

    def test_rejects_when_daemon_offline_and_db_empty(self):
        # Simulates a relay restart with a wiped DB and a daemon that has not
        # reconnected yet — the token cannot be proven, so it must fail.
        tok = issue_app_token("pc-host", "SHARED_SECRET")
        assert relay.state.get_daemon_id_by_token(tok) is None

    def test_rejects_tampered_signature(self):
        relay.state.daemons["pc-host"] = _session()
        tok = issue_app_token("pc-host", "SHARED_SECRET")
        prefix, _, _ = tok.split(".", 2)
        tampered = f"{prefix}.deadbeef"
        assert relay.state.get_daemon_id_by_token(tampered) is None

    def test_rejects_wrong_daemon_secret(self):
        # App token issued when the daemon used secret A; daemon now presents
        # secret B (mismatch) -> must not authenticate.
        relay.state.daemons["pc-host"] = _session(token="SECRET_B")
        tok = issue_app_token("pc-host", "SECRET_A")
        assert relay.state.get_daemon_id_by_token(tok) is None

    def test_rejects_malformed_token(self):
        assert relay.state.get_daemon_id_by_token("garbage") is None
        assert relay.state.get_daemon_id_by_token("v1.notbase64.sig") is None

    def test_still_uses_known_tokens_first(self):
        relay.state.known_tokens["legacy-token"] = "some-daemon"
        assert relay.state.get_daemon_id_by_token("legacy-token") == "some-daemon"
