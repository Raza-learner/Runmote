import copy
import os
import sys
from unittest import mock

import pytest
from daemon.main import (
    AgentProcess,
    _agent_list_message,
    _capture_agent_info,
    _default_agent_id,
    _extract_agent_id,
    _is_hidden,
    _message_for_agent,
    _normalize_path,
    _tag_agent_response,
)


class TestNormalizePath:
    def test_unix_path_unchanged(self):
        assert _normalize_path("/home/user/file.txt") == "/home/user/file.txt"

    def test_backslashes_converted(self):
        assert _normalize_path("C:\\Users\\test") == "C:/Users/test"

    def test_mixed_separators(self):
        assert _normalize_path("a\\b/c") == "a/b/c"

    def test_empty_string(self):
        assert _normalize_path("") == ""


class TestAgentListMessage:
    def make_agent(self, aid="agent1", name="Agent One", online=True):
        a = mock.Mock(spec=AgentProcess)
        a.id = aid
        a.as_json.return_value = {"id": aid, "name": name, "version": "1.0", "online": online, "command": ["echo"]}
        return a

    def test_without_msg_id_uses_method(self):
        agents = {"a1": self.make_agent("a1")}
        msg = _agent_list_message(agents)
        assert msg["jsonrpc"] == "2.0"
        assert msg["method"] == "agent/list"
        assert "id" not in msg
        assert len(msg["result"]["agents"]) == 1

    def test_with_msg_id_uses_id(self):
        agents = {"a1": self.make_agent("a1")}
        msg = _agent_list_message(agents, msg_id=42)
        assert msg["id"] == 42
        assert "method" not in msg

    def test_lists_all_agents(self):
        agents = {
            "a1": self.make_agent("a1", "Agent 1"),
            "a2": self.make_agent("a2", "Agent 2"),
        }
        msg = _agent_list_message(agents)
        assert len(msg["result"]["agents"]) == 2
        ids = {a["id"] for a in msg["result"]["agents"]}
        assert ids == {"a1", "a2"}

    def test_empty_agents(self):
        msg = _agent_list_message({})
        assert msg["result"]["agents"] == []


class TestDefaultAgentId:
    def make_agent(self, aid="agent1", online=True):
        a = mock.Mock(spec=AgentProcess)
        a.id = aid
        a.online = online
        return a

    def test_returns_first_online_agent(self):
        agents = {
            "a1": self.make_agent("a1", online=False),
            "a2": self.make_agent("a2", online=True),
            "a3": self.make_agent("a3", online=True),
        }
        assert _default_agent_id(agents) == "a2"

    def test_falls_back_to_first_agent_when_none_online(self):
        agents = {
            "a1": self.make_agent("a1", online=False),
            "a2": self.make_agent("a2", online=False),
        }
        assert _default_agent_id(agents) == "a1"

    def test_stopiter_on_empty_dict(self):
        agents = {}
        with pytest.raises(StopIteration):
            _default_agent_id(agents)


class TestExtractAgentId:
    def make_agent(self, aid, online=True):
        a = mock.Mock(spec=AgentProcess)
        a.id = aid
        a.online = online
        return a

    def test_from_top_level_agentId(self):
        agents = {"a1": self.make_agent("a1"), "a2": self.make_agent("a2")}
        msg = {"agentId": "a1"}
        assert _extract_agent_id(msg, agents) == "a1"

    def test_from_params_agentId(self):
        agents = {"a1": self.make_agent("a1"), "a2": self.make_agent("a2")}
        msg = {"params": {"agentId": "a2"}}
        assert _extract_agent_id(msg, agents) == "a2"

    def test_params_overrides_top_level(self):
        agents = {"a1": self.make_agent("a1"), "a2": self.make_agent("a2")}
        msg = {"agentId": "a1", "params": {"agentId": "a2"}}
        assert _extract_agent_id(msg, agents) == "a2"

    def test_fallback_to_default_when_agentId_missing(self):
        agents = {"a1": self.make_agent("a1", online=True)}
        msg = {"method": "session/list"}
        assert _extract_agent_id(msg, agents) == "a1"

    def test_unknown_agentId_falls_back(self):
        agents = {"a1": self.make_agent("a1", online=True)}
        msg = {"agentId": "unknown"}
        assert _extract_agent_id(msg, agents) == "a1"

    def test_params_not_dict(self):
        agents = {"a1": self.make_agent("a1", online=True)}
        msg = {"params": "not a dict", "agentId": "a1"}
        assert _extract_agent_id(msg, agents) == "a1"


class TestMessageForAgent:
    def test_removes_top_level_agentId(self):
        msg = {"jsonrpc": "2.0", "method": "session/new", "agentId": "a1", "params": {}}
        result = _message_for_agent(msg)
        assert "agentId" not in result

    def test_removes_agentId_from_params(self):
        msg = {"jsonrpc": "2.0", "method": "session/new", "params": {"agentId": "a1"}}
        result = _message_for_agent(msg)
        assert "agentId" not in result["params"]

    def test_does_not_mutate_original(self):
        msg = {"jsonrpc": "2.0", "method": "session/new", "agentId": "a1", "params": {"x": 1}}
        original = copy.deepcopy(msg)
        _message_for_agent(msg)
        assert msg == original

    def test_preserves_other_fields(self):
        msg = {"jsonrpc": "2.0", "method": "session/new", "id": 1, "params": {"x": 1}}
        result = _message_for_agent(msg)
        assert result["jsonrpc"] == "2.0"
        assert result["method"] == "session/new"
        assert result["id"] == 1
        assert result["params"] == {"x": 1}

    def test_params_not_dict(self):
        msg = {"jsonrpc": "2.0", "method": "session/new", "agentId": "a1", "params": None}
        result = _message_for_agent(msg)
        assert "agentId" not in result
        assert result["params"] is None


class TestTagAgentResponse:
    def make_agent(self, aid="agent1"):
        a = mock.Mock(spec=AgentProcess)
        a.id = aid
        return a

    def test_injects_agentId_into_result(self):
        agent = self.make_agent("a1")
        msg = {"jsonrpc": "2.0", "id": 1, "result": {"sessions": []}}
        tagged = _tag_agent_response(msg, agent)
        assert tagged["result"]["agentId"] == "a1"

    def test_injects_agentId_into_each_session(self):
        agent = self.make_agent("a1")
        msg = {"jsonrpc": "2.0", "id": 1, "result": {"sessions": [{"sessionId": "s1"}, {"sessionId": "s2"}]}}
        tagged = _tag_agent_response(msg, agent)
        for s in tagged["result"]["sessions"]:
            assert s["agentId"] == "a1"

    def test_does_not_overwrite_existing_agentId(self):
        agent = self.make_agent("a1")
        msg = {"jsonrpc": "2.0", "result": {"agentId": "existing"}}
        tagged = _tag_agent_response(msg, agent)
        assert tagged["result"]["agentId"] == "existing"

    def test_injects_into_params(self):
        agent = self.make_agent("a1")
        msg = {"jsonrpc": "2.0", "params": {"sessionId": "s1"}}
        tagged = _tag_agent_response(msg, agent)
        assert tagged["params"]["agentId"] == "a1"

    def test_injects_into_error_data(self):
        agent = self.make_agent("a1")
        msg = {"jsonrpc": "2.0", "error": {"code": -32000, "message": "fail"}}
        tagged = _tag_agent_response(msg, agent)
        assert tagged["error"]["data"]["agentId"] == "a1"

    def test_does_not_mutate_original(self):
        agent = self.make_agent("a1")
        msg = {"jsonrpc": "2.0", "result": {}}
        original = copy.deepcopy(msg)
        _tag_agent_response(msg, agent)
        assert msg == original

    def test_no_result_or_error(self):
        agent = self.make_agent("a1")
        msg = {"jsonrpc": "2.0", "method": "notification"}
        tagged = _tag_agent_response(msg, agent)
        assert tagged == msg


class TestCaptureAgentInfo:
    def make_agent(self, aid="agent1", name="Test Agent"):
        a = mock.Mock(spec=AgentProcess)
        a.id = aid
        a.name = name
        a.version = ""
        a.info = {"name": name, "version": ""}
        a.capabilities = {}
        return a

    def test_captures_agentInfo(self):
        agent = self.make_agent("a1", "From Config")
        msg = {"result": {"agentInfo": {"name": "@scope/package", "version": "1.2.3"}}}
        _capture_agent_info(msg, agent)
        assert agent.info["name"] == "From Config"
        assert agent.info["version"] == "1.2.3"
        assert agent.version == "1.2.3"

    def test_captures_capabilities(self):
        agent = self.make_agent("a1")
        msg = {"result": {"agentCapabilities": {"streaming": True}}}
        _capture_agent_info(msg, agent)
        assert agent.capabilities == {"streaming": True}

    def test_ignores_missing_fields(self):
        agent = self.make_agent("a1")
        msg = {"result": {}}
        _capture_agent_info(msg, agent)
        assert agent.info == {"name": "Test Agent", "version": ""}
        assert agent.capabilities == {}

    def test_ignores_non_dict_result(self):
        agent = self.make_agent("a1")
        msg = {"result": None}
        _capture_agent_info(msg, agent)
        assert agent.info == {"name": "Test Agent", "version": ""}

    def test_handles_no_result_key(self):
        agent = self.make_agent("a1")
        msg = {"jsonrpc": "2.0", "method": "notification"}
        _capture_agent_info(msg, agent)
        assert agent.capabilities == {}


class TestAgentProcess:
    def test_constructor_sets_fields(self):
        config = {"id": "my-agent", "name": "My Agent", "command": ["echo", "hi"]}
        a = AgentProcess(config)
        assert a.id == "my-agent"
        assert a.name == "My Agent"
        assert a.command == ["echo", "hi"]
        assert a.proc is None
        assert a.online is False
        assert a.version == ""
        assert a.info == {"name": "My Agent", "version": ""}
        assert a.capabilities == {}

    def test_constructor_default_name_from_id(self):
        config = {"id": "my-agent", "command": ["echo"]}
        a = AgentProcess(config)
        assert a.name == "my-agent"

    def test_as_json_reflects_state(self):
        config = {"id": "agent1", "name": "Agent One", "command": ["echo"]}
        a = AgentProcess(config)
        a.online = True
        a.version = "2.0"
        a.info = {"name": "Display Name", "version": "2.0"}
        j = a.as_json()
        assert j["id"] == "agent1"
        assert j["name"] == "Display Name"
        assert j["version"] == "2.0"
        assert j["online"] is True
        assert j["command"] == ["echo"]

    def test_as_json_falls_back_to_construct_name(self):
        config = {"id": "agent1", "name": "Agent One", "command": ["echo"]}
        a = AgentProcess(config)
        j = a.as_json()
        assert j["name"] == "Agent One"

    def test_initial_info_has_construct_name(self):
        config = {"id": "agent1", "name": "Agent One", "command": ["echo"]}
        a = AgentProcess(config)
        assert a.info == {"name": "Agent One", "version": ""}


class TestIsHidden:
    def test_dot_prefix_is_hidden(self):
        entry = mock.MagicMock(spec=os.DirEntry)
        entry.name = ".hidden_file"
        assert _is_hidden(entry) is True

    @pytest.mark.skipif(sys.platform == "win32", reason="Windows file attributes make mock return True")
    def test_non_dot_not_hidden_on_unix(self):
        entry = mock.MagicMock(spec=os.DirEntry)
        entry.name = "visible_file"
        assert _is_hidden(entry) is False
