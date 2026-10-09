#!/usr/bin/env python3
"""Checks that a downloaded Wazuh package is signed with the Wazuh key.

Usage: verify_package_signature.py <key file> <comma-separated fingerprints> <package>

The key file is only trusted if it holds a single armored block with a single primary key whose
fingerprint is in the given list: a key whose expiry date was extended keeps its fingerprint and
still passes. Runs on the target host with the Python interpreter Ansible already needs there, so
it does not depend on gpg, which EL10 does not install.
"""

import base64
import hashlib
import os
import shutil
import subprocess
import sys
import tempfile

BEGIN_KEY = "-----BEGIN PGP PUBLIC KEY BLOCK-----"


def fail(message):
    sys.stderr.write(message + "\n")
    sys.exit(1)


def read_key(key_path, fingerprints):
    """Returns the binary keyring in the armored key file and its fingerprint."""
    with open(key_path) as key_file:
        lines = key_file.read().splitlines()
    # rpm --import would also take a second key appended to the file.
    if sum(line.strip() == BEGIN_KEY for line in lines) != 1:
        fail("The Wazuh GPG key file must hold a single key.")

    # Armor: header lines up to the first blank line, the base64 body, then the =CRC line.
    lines = [line.strip() for line in lines[lines.index(BEGIN_KEY) + 1:]]
    body = []
    for line in lines[lines.index("") + 1 if "" in lines else 0:]:
        if line.startswith("=") or line.startswith("-----"):
            break
        body.append(line)
    try:
        keyring = base64.b64decode("".join(body), validate=True)
    except ValueError:
        fail("The Wazuh GPG key file is not a valid armored key.")

    try:
        primary_fingerprints = list(primary_key_fingerprints(keyring))
    except IndexError:
        fail("The Wazuh GPG key file is not a valid armored key.")
    if len(primary_fingerprints) != 1 or primary_fingerprints[0] not in fingerprints:
        fail("The Wazuh GPG key does not have the expected fingerprint.")
    return keyring, primary_fingerprints[0]


def primary_key_fingerprints(keyring):
    """Yields the fingerprint of each primary key packet in the binary keyring."""
    start = 0
    while start < len(keyring):
        tag_byte = keyring[start]
        if not tag_byte & 0x80:
            fail("The Wazuh GPG key file is not a valid armored key.")
        if tag_byte & 0x40:
            tag = tag_byte & 0x3F
            length_byte = keyring[start + 1]
            if length_byte < 192:
                length, header = length_byte, 2
            elif length_byte < 224:
                length, header = ((length_byte - 192) << 8) + keyring[start + 2] + 192, 3
            elif length_byte == 255:
                length, header = int.from_bytes(keyring[start + 2:start + 6], "big"), 6
            else:
                fail("The Wazuh GPG key file is not a valid armored key.")
        else:
            tag = (tag_byte >> 2) & 0x0F
            size = {0: 1, 1: 2, 2: 4}.get(tag_byte & 3)
            if size is None:
                fail("The Wazuh GPG key file is not a valid armored key.")
            length, header = int.from_bytes(keyring[start + 1:start + 1 + size], "big"), 1 + size
        if tag == 6:
            # v4 fingerprint: SHA-1 of 0x99, the two-octet body length and the public key packet body.
            packet = keyring[start + header:start + header + length]
            yield hashlib.sha1(b"\x99" + len(packet).to_bytes(2, "big") + packet).hexdigest().upper()
        start += header + length


def run(command):
    return subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          universal_newlines=True)


def verify_rpm(package, key_path, fingerprint):
    """rpm -K passes on unsigned packages, so the signer key is checked first. rpm keeps
    verifying with an expired copy of the key, as long as the package was signed before."""
    key_id = fingerprint[-16:].lower()
    if run(["rpm", "-q", "--quiet", "gpg-pubkey-" + key_id[-8:]]).returncode != 0:
        imported = run(["rpm", "--import", key_path])
        if imported.returncode != 0:
            fail("Could not import the Wazuh GPG key: " + imported.stdout.strip())

    signature = run(["rpm", "-qp", "--qf", "%{RSAHEADER:pgpsig}", package]).stdout
    if "key id " + key_id not in signature.lower():
        fail(package + " is not signed with the Wazuh key.")
    if run(["rpm", "-K", package]).returncode != 0:
        fail("The signature of " + package + " is not valid.")


def verify_deb(package, keyring):
    """apt ignores the signature embedded in a .deb, so the _gpgbuilder member is checked with
    gpgv and the hashes it signs are compared with the other members of the ar archive."""
    if shutil.which("gpgv") is None:
        fail("gpgv is required to check the signature of " + package + ".")
    members = set()
    signature = None
    with open(package, "rb") as deb:
        if deb.read(8) != b"!<arch>\n":
            fail(package + " is not a Debian package.")
        while True:
            header = deb.read(60)
            if len(header) < 60:
                break
            name = header[:16].decode("ascii", "replace").rstrip(" /")
            size = int(header[48:58])
            data = deb.read(size)
            deb.read(size % 2)
            if name == "_gpgbuilder":
                signature = data
            elif not name.startswith("_gpg"):
                members.add((hashlib.sha1(data).hexdigest(), str(size), name))

    if signature is None:
        fail(package + " is not signed.")
    work_dir = tempfile.mkdtemp()
    try:
        keyring_path = os.path.join(work_dir, "wazuh.gpg")
        with open(keyring_path, "wb") as keyring_file:
            keyring_file.write(keyring)
        signature_path = os.path.join(work_dir, "_gpgbuilder")
        with open(signature_path, "wb") as signature_file:
            signature_file.write(signature)
        signed_path = os.path.join(work_dir, "signed")
        if run(["gpgv", "--keyring", keyring_path, "--output", signed_path,
                signature_path]).returncode != 0:
            fail(package + " is not signed with the Wazuh key.")
        with open(signed_path) as signed_file:
            signed_lines = [line.split() for line in signed_file]
    finally:
        shutil.rmtree(work_dir)

    # Signed lines: <md5> <sha1> <size> <member>
    signed_members = set(tuple(line[1:]) for line in signed_lines
                         if len(line) == 4 and len(line[0]) == 32
                         and all(c in "0123456789abcdef" for c in line[0]))
    if not signed_members or signed_members != members:
        fail("The contents of " + package + " do not match its signature.")


def main():
    if len(sys.argv) != 4:
        fail("Usage: verify_package_signature.py <key file> <comma-separated fingerprints> <package>")
    key_path, package = sys.argv[1], sys.argv[3]
    fingerprints = [fingerprint.strip().upper() for fingerprint in sys.argv[2].split(",")]
    keyring, fingerprint = read_key(key_path, fingerprints)
    if package.endswith(".rpm"):
        verify_rpm(package, key_path, fingerprint)
    elif package.endswith(".deb"):
        verify_deb(package, keyring)
    else:
        fail("Cannot check the signature of " + package + ": not an .rpm or .deb package.")
    print(package + " is signed with the Wazuh key " + fingerprint + ".")


if __name__ == "__main__":
    main()
