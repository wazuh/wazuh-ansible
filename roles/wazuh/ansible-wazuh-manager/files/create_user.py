import logging
import sys
import json
import random
import string
import argparse
import os

# Set framework path
sys.path.append("/var/ossec/framework")

try:
    from wazuh.security import (
        create_user,
        get_users,
        get_roles,
        set_user_role,
        update_user,
    )
except Exception as e:
    logging.error("No module 'wazuh' found.")
    sys.exit(1)


def db_users():
    users_result = get_users()
    return {user["username"]: user["id"] for user in users_result.affected_items}


def db_roles():
    roles_result = get_roles()
    return {role["name"]: role["id"] for role in roles_result.affected_items}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='add_user script')
    parser.add_argument('--username', action="store", dest="username")
    parser.add_argument('--password', action="store", dest="password")
    results = parser.parse_args()

    username = results.username
    password = results.password

    initial_users = db_users()
    if username not in initial_users:
        # create a new user
        create_user(username=username, password=password)
        users = db_users()
        uid = users[username]
        roles = db_roles()
        rid = roles["administrator"]
        set_user_role(
            user_id=[
                str(uid),
            ],
            role_ids=[
                str(rid),
            ],
        )
    else:
        # modify an existing user ("wazuh" or "wazuh-wui")
        uid = initial_users[username]
        update_user(
            user_id=[
                str(uid),
            ],
            password=password,
        )
    # set a random password for all other users
    for name, id in initial_users.items():
        if name != username:
            specials = "@$!%*?&-_"
            random_pass = "".join(
                [
                    random.choice(string.ascii_uppercase),
                    random.choice(string.ascii_lowercase),
                    random.choice(string.digits),
                    random.choice(specials),
                ] +
                random.choices(
                    string.ascii_uppercase
                    + string.ascii_lowercase
                    + string.digits
                    + specials,
                    k=14,
                )
            )
            update_user(
                user_id=[
                    str(id),
                ],
                password=random_pass,
            )
