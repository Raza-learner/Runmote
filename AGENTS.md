# AGENTS.md

## Development Principles

- Never guess implementation details.
- Read the relevant files before modifying code.
- Keep functions small and focused.
- Add type hints everywhere.
- Write docstrings for public APIs.
- Do not break ACP compatibility.
- Never remove logging.
- Never swallow exceptions.
- Every new feature must include tests.

## Logging

Every module must use the shared logger.

Every exception must include:
- stack trace
- session id
- request payload
- device id

## Before finishing any task

The agent MUST:

1. Run formatting
2. Run linting
3. Run unit tests
4. Run integration tests
5. Verify relay ↔ daemon communication
6. Verify daemon ↔ agent communication
7. Verify Flutter ↔ relay communication
8. Check all log files for errors
9. Fix any discovered errors
10. Repeat until all tests pass

A task is complete only when:
- No failing tests
- No unhandled exceptions
- No ERROR entries in logs
- No broken functionality