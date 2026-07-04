import secrets
import time

CODES_TTL = 120  # seconds — codes expire 2 minutes after creation
_code_created_at: dict[str, float] = {}


def generate_pairing_code(existing: set[str]) -> str:
    alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  # no 0/O, 1/I/L to avoid confusion
    while True:
        code = "".join(secrets.choice(alphabet) for _ in range(8))
        if code not in existing:
            _code_created_at[code] = time.time()
            return code


def is_code_expired(code: str) -> bool:
    created = _code_created_at.get(code)
    if created is None:
        return True
    return time.time() - created > CODES_TTL


def cleanup_expired_codes(existing: set[str]):
    now = time.time()
    expired = [c for c in existing if now - _code_created_at.get(c, 0) > CODES_TTL]
    for c in expired:
        existing.discard(c)
        _code_created_at.pop(c, None)
