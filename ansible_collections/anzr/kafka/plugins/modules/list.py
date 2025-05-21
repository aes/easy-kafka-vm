#!/usr/bin/python

# Copyright: (c) 2025, Anders Eurenius Runvald <anders@anzr.se>
__metaclass__ = type

from ansible_collections.anzr.kafka.plugins.module_utils.time import (
    run_with_timing,
)

DOCUMENTATION = r"""
---
module: anzr.kafka.list

short_description: This is my test module

# If this is part of a collection, you need to use semantic versioning,
# i.e. the version is of the form "2.5.0" and not "2.4".
version_added: "1.0.0"

description: This is my longer description explaining my test module.

options:
    # name:
    #     description: This is the message to send to the test module.
    #     required: true
    #     type: str
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


def run_module():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        exclude={"type": "bool", "required": False, "default": True},
        server={"type": "str", "required": False, "default": "localhost:9092"},
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(argument_spec=module_args, supports_check_mode=True)

    # seed the result dict in the object
    # we primarily care about changed and state
    # changed is if this module effectively modified the target
    # state will include any data that you want your module to pass back
    # for consumption, for example, in a subsequent task
    # if the user is working with this module in only check mode we do not
    # want to make any changes to the environment, just return the current
    # state with no modifications
    if module.check_mode:
        module.exit_json(changed=False, original_message="", message="")

    server = f"--bootstrap-server={module.params['server']}"

    r = run_with_timing(
        module=module,
        args=["kafka-topics", server, "--list"],
        encoding="utf-8",
        data="",
        binary_data=False,
        expand_user_and_vars=False,
    )

    r["topics"] = [
        topic
        for topic in r["stdout"].strip().split("\n")
        if topic[:1] != "_" or not module.params["exclude"]
    ]

    result = {
        "changed": False,
        "original_message": "list",
        "message": "goodbye",
        **r,
    }

    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()
