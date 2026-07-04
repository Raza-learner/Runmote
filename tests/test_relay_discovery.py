import socket
from unittest import mock

from relay.discovery import _get_ip


class TestGetIp:
    def test_returns_socket_ip(self):
        mock_sock = mock.MagicMock(spec=socket.socket)
        mock_sock.getsockname.return_value = ("192.168.1.5", 12345)
        with mock.patch("relay.discovery.socket.socket", return_value=mock_sock):
            ip = _get_ip()
            assert ip == "192.168.1.5"
        mock_sock.connect.assert_called_once_with(("10.255.255.255", 1))
        mock_sock.close.assert_called_once()

    def test_fallback_on_exception(self):
        mock_sock = mock.MagicMock(spec=socket.socket)
        mock_sock.connect.side_effect = OSError("network unreachable")
        with mock.patch("relay.discovery.socket.socket", return_value=mock_sock):
            ip = _get_ip()
            assert ip == "127.0.0.1"
        mock_sock.close.assert_called_once()
