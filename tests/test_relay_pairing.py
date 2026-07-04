from unittest import mock

from relay.pairing import generate_pairing_code


class TestGeneratePairingCode:
    def test_returns_six_digit_string(self):
        with mock.patch("relay.pairing.secrets.randbelow", return_value=123456):
            code = generate_pairing_code(set())
            assert code == "123456"
            assert len(code) == 6

    def test_avoids_existing_codes(self):
        calls = []

        def randbelow(n):
            calls.append(n)
            if len(calls) == 1:
                return 111111
            return 222222

        with mock.patch("relay.pairing.secrets.randbelow", side_effect=randbelow):
            code = generate_pairing_code({"111111"})
            assert code == "222222"
            assert code not in {"111111"}

    def test_handles_no_existing(self):
        with mock.patch("relay.pairing.secrets.randbelow", return_value=42):
            code = generate_pairing_code(set())
            assert code == "000042"
