#!/usr/bin/env python3
"""Helper script to convert key formats."""

import os
import sys

from cryptography.hazmat import backends
from cryptography.hazmat.primitives import serialization


def convert_pkcs1_pkcs8(private_key_data: str):
    """Converts a PKCS#1 key loaded in private_key_data to PKCS#8."""
    backend = backends.default_backend()
    # Source data
    private_key_object = serialization.load_pem_private_key(
        private_key_data.encode("utf-8"), None, backend)
    private_key_encoding = serialization.Encoding.PEM

    # Destination data
    target_format = serialization.PrivateFormat.PKCS8
    target_key = private_key_object.private_bytes(
        encoding=private_key_encoding,
        format=target_format,
        encryption_algorithm=serialization.NoEncryption())
    return target_key.decode("utf-8")


if __name__ == "__main__":

    if len(sys.argv) < 2:
        raise Exception(
            'usage: %s [source] [dest] [mode] [owner] [group]' % sys.argv[0])

    with open(sys.argv[1], "r") as source_key, open(sys.argv[2], "w") as dest_key:
        PKCS1_DATA = source_key.read()
        PKCS8_DATA = convert_pkcs1_pkcs8(PKCS1_DATA)
        dest_key.write(PKCS8_DATA)

    # Set mode
    FILE_MODE = int(sys.argv[3], base=8) if len(sys.argv) > 3 else 0o600
    FILE_UID = int(sys.argv[4]) if len(sys.argv) > 4 else os.getuid()
    FILE_GID = int(sys.argv[5]) if len(sys.argv) > 5 else os.getgid()

    os.chmod(sys.argv[2], FILE_MODE)
    os.chown(sys.argv[2], FILE_UID, FILE_GID)
