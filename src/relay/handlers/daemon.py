import json
from fastapi import APIRouter, WebSocket

try:
    from .. import state
    from ..config import RELAY_TOKEN
    from ..pairing import generate_pairing_code
except ImportError:
    import state
    from config import RELAY_TOKEN
    from pairing import generate_pairing_code

router = APIRouter()


def _is_paired(client_id: str) -> bool:
    return RELAY_TOKEN is None or client_id in state.app_to_token


def _paired_clients():
    """Yield (client_id, websocket) for authenticated clients (or all when auth is off)."""
    for cid, ws in list(state.app_clients.items()):
        if RELAY_TOKEN is None or cid in state.app_to_token:
            yield cid, ws


def _register_session(session: dict) -> str:
    sid = session.get("sessionId") or session.get("id") or ""
    if not sid:
        return ""

    # Skip sessions that were explicitly deleted by the user — agents like
    # codex keep returning them in session/list after reconnect.
    if state.store.is_deleted(sid):
        return ""

    name = session.get("name") or session.get("title") or ""
    cwd = session.get("cwd") or ""
    updated_at = session.get("updatedAt") or session.get("createdAt")
    if not isinstance(updated_at, (int, float)):
        updated_at = None

    state.store.register(
        sid,
        client_id=session.get("clientId", ""),
        name=name,
        cwd=cwd,
        agent_id=session.get("agentId", ""),
        updated_at=updated_at,
    )
    return sid


@router.websocket("/daemon")
async def daemon_endpoint(websocket: WebSocket):
    await websocket.accept()
    state.daemon_websocket = websocket
    print("Daemon connected!")

    try:
        async for message in websocket.iter_text():

            try:
                data = json.loads(message)
                method = data.get("method", "")
                msg_id = data.get("id")

                if method == "daemon/identify":
                    params = data.get("params") or {}
                    daemon_id = params.get("daemonId", "unknown")
                    token = params.get("token") or ""

                    if RELAY_TOKEN is not None and token != RELAY_TOKEN:
                        print(f"  → daemon token rejected (got '{token}')")
                        if msg_id:
                            await websocket.send_text(json.dumps({
                                "jsonrpc": "2.0",
                                "id": msg_id,
                                "error": {"code": -32001, "message": "invalid token"},
                            }))
                        state.daemon_websocket = None
                        await websocket.close()
                        return

                    # Remove old pairing code for this token (daemon reconnecting)
                    old_codes = [c for c, t in state.code_to_token.items() if t == token]
                    for old_code in old_codes:
                        del state.code_to_token[old_code]

                    pairing_code = generate_pairing_code(set(state.code_to_token.keys()))
                    state.token_to_daemons[token] = daemon_id
                    state.code_to_token[pairing_code] = token
                    state.store.set_daemon_id(daemon_id)
                    print(f"  → daemon identified as {daemon_id}")
                    print(f"  → pairing code: {pairing_code}")

                    if msg_id:
                        await websocket.send_text(json.dumps({
                            "jsonrpc": "2.0",
                            "id": msg_id,
                            "result": {"pairingCode": pairing_code},
                        }))

                    forward = {
                        "jsonrpc": "2.0",
                        "method": "daemon/identified",
                        "params": {"daemonId": daemon_id},
                    }
                    for cid, client in _paired_clients():
                        try:
                            await client.send_text(json.dumps(forward))
                        except Exception:
                            state.app_clients.pop(cid, None)
                    continue

                result = data.get("result")
                if isinstance(result, dict):
                    sid = _register_session(result)

                    sessions = result.get("sessions")
                    if isinstance(sessions, list):
                        for s in sessions:
                            if isinstance(s, dict):
                                sid = s.get("sessionId") or s.get("id") or ""
                                if state.store.is_deleted(sid):
                                    continue
                                _register_session(s)

                error = data.get("error")
                if isinstance(error, dict):
                    sid = (error.get("data") or {}).get("sessionId")
                    if sid:
                        state.store.remove(sid)
            except Exception as e:
                print(f"  → failed to process daemon message: {e}")

            for cid, client in _paired_clients():
                try:
                    # Filter deleted sessions from forwarded session/list
                    fwd = data
                    if fwd.get("result") and isinstance(fwd["result"], dict):
                        sess_list = fwd["result"].get("sessions")
                        if isinstance(sess_list, list):
                            filtered = [
                                s for s in sess_list
                                if not isinstance(s, dict) or
                                   not state.store.is_deleted(s.get("sessionId") or s.get("id") or "")
                            ]
                            # Fill in sessions from the store that the agent
                            # didn't return (lost e.g. after a daemon restart).
                            agent_sids = {
                                s.get("sessionId") or s.get("id") or ""
                                for s in filtered if isinstance(s, dict)
                            }
                            agent_id = fwd["result"].get("agentId", "")
                            # Only merge cached sessions when we know which
                            # agent the response belongs to. Without a valid
                            # agent_id, merging would leak sessions from other
                            # agents into this list.
                            if agent_id:
                                for cs in state.store.list_sessions(agent_id=agent_id):
                                    if cs["sessionId"] not in agent_sids:
                                        filtered.append(cs)
                            # Patch cwd from store for sessions that lack it
                            # (some agents don't echo cwd in session/list).
                            for s in filtered:
                                if isinstance(s, dict) and not s.get("cwd"):
                                    sid = s.get("sessionId") or s.get("id") or ""
                                    stored = state.store.get(sid)
                                    if stored and stored.get("cwd"):
                                        s["cwd"] = stored["cwd"]
                            fwd["result"]["sessions"] = filtered
                    await client.send_text(json.dumps(fwd))
                except Exception:
                    state.app_clients.pop(cid, None)

    finally:
        if state.daemon_websocket is websocket:
            state.daemon_websocket = None
            state.store.clear_daemon_id()
            print("Daemon disconnected!")
            forward = {
                "jsonrpc": "2.0",
                "method": "daemon/disconnected",
                "params": {},
            }
            for cid, client in _paired_clients():
                try:
                    await client.send_text(json.dumps(forward))
                except Exception:
                    state.app_clients.pop(cid, None)
