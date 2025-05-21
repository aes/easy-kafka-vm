#!/usr/bin/python

# Copyright: (c) 2025, Anders Eurenius Runvald <anders@anzr.se>
__metaclass__ = type

import datetime
import random

from ansible_collections.anzr.kafka.plugins.module_utils.time import Timing

DOCUMENTATION = r"""
---
module: anzr.kafka.test

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    name:
        description: This is the message to send to the test module.
        required: true
        type: str
# Specify this value according to your collection
# in format of namespace.collection.doc_fragment_name
# extends_documentation_fragment:
#     - my_namespace.my_collection.my_doc_fragment_name

author:
    - Your Name (@yourGitHubHandle)
"""

EXAMPLES = r"""
# Pass in a message
- name: Test with a message
  my_namespace.my_collection.my_test:
    name: hello world

# pass in a message and have changed true
- name: Test with a message and changed output
  my_namespace.my_collection.my_test:
    name: hello world

# fail the module
- name: Test failure of the module
  my_namespace.my_collection.my_test:
    name: fail me
"""

RETURN = r"""
# These are examples of possible return values, and in general should use other names for return values.
original_message:
    description: The original name param that was passed in.
    type: str
    returned: always
    sample: 'hello world'
message:
    description: The output message that the test module generates.
    type: str
    returned: always
    sample: 'goodbye'
"""

from ansible.module_utils.basic import AnsibleModule


def rand_name(k=12):
    return "".join(
        random.choices(
            population=(
                    "".join(chr(x) for x in range(65, 65 + 26)) +
                    "".join(chr(x) for x in range(97, 97 + 26))
            ),
            k=k,
        )
    )


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        server={"type": "str", "required": False, "default": "localhost:9092"},
        clean={"type": "bool", "required": False, "default": False},
        topic={"type": "str", "required": False, "default": None},
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=False)

    if module.check_mode:
        module.exit_json(changed=False, original_message="", message="")

    server = f"--bootstrap-server={module.params['server']}"
    topic = f"--topic=test_ansible_{rand_name()}"
    one, two = rand_name(), rand_name()

    commands = [
        (["kafka-topics", "--create", "--if-not-exists"], ""),
        (["kafka-console-producer"], f"{one}\n{two}\n"),
        (["kafka-console-consumer", "--from-beginning", "--max-messages=2"], ""),
        (["kafka-topics", "--delete", "--if-exists"], ""),
    ]

    with Timing() as r:
        r["rc"], r["stdout"], r["stderr"] = 0, "", ""
        for args, data in commands:
            rc, out, err = module.run_command(
                args=args + [server, topic],
                data=data)
            r["rc"] |= rc
            r["stdout"] += f"# {args[0]}\n" + out
            r["stderr"] += f"# {args[0]}\n" + err
            if rc != 0:
                break

    result = {
        "changed": rc != 0 and "--create" not in args,
        "original_message": "test",
        "message": "goodbye",
        **r,
    }

    if rc != 0:
        command = " ".join(args)
        module.fail_json(msg=f"Command failed: {command}", **result)

    if one not in r["stdout"]:
        module.fail_json(msg=f"Failed to read written message: {one}", **result)

    if two not in r["stdout"]:
        module.fail_json(msg=f"Failed to read written message: {two}", **result)

    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()
