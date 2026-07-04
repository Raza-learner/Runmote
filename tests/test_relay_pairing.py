import time
from unittest import mock

import pytest

from relay.pairing import (
    CODES_TTL,
    cleanup_expired_codes,
    generate_pairing_code,
    is_code_expired,
    _code_created_at,
)


@pytest.fixture(autouse=True)
def _clear_code_timestamps():
    _code_created_at.clear()
    yield


class TestGeneratePairingCode:
    def test_returns_eight_char_string(self):
        with mock.patch("relay.pairing.secrets.choice", return_value="X"):
            code = generate_pairing_code(set())
            assert code == "XXXXXXXX"
            assert len(code) == 8

    def test_uses_alphanumeric_alphabet(self):
        code = generate_pairing_code(set())
        assert len(code) == 8
        assert all(c in "ABCDEFGHJKLMNPQRSTUVWXYZ23456789" for c in code)

    def test_avoids_existing_codes(self):
        values = iter(["A"] * 8 + ["B"] * 8)
        with mock.patch("relay.pairing.secrets.choice", side_effect=lambda _: next(values)):
            code = generate_pairing_code({"AAAAAAAA"})
            assert code == "BBBBBBBB"

    def test_handles_no_existing(self):
        with mock.patch("relay.pairing.secrets.choice", return_value="A"):
            code = generate_pairing_code(set())
            assert code == "AAAAAAAA"
            assert len(code) == 8


class TestCodeExpiry:
    def test_fresh_code_not_expired(self):
        code = generate_pairing_code(set())
        assert not is_code_expired(code)

    def test_expired_code_returns_true(self):
        code = generate_pairing_code(set())
        _code_created_at[code] = 0
        assert is_code_expired(code)

    def test_unknown_code_is_expired(self):
        assert is_code_expired("NONEXIST")

    def test_cleanup_removes_expired_codes(self):
        code = generate_pairing_code(set())
        existing = {code}
        _code_created_at[code] = 0
        cleanup_expired_codes(existing)
        assert code not in existing
