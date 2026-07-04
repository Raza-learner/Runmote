import secrets


def generate_pairing_code(existing: set[str]) -> str:
    while True:
        code = f"{secrets.randbelow(1000000):06d}"
        if code not in existing:
            return code
