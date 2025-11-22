# -*- coding: utf-8 -*-
"""
This module defines a Rule class for verifying configuration against golden config templates.

Classes:
    Rule: A class that encapsulates methods for loading inventory, merging dictionaries, comparing configurations, and matching inventory against rules.

Methods:
    merge_dict_list(source: dict, destination: dict) -> dict:
        Merges a source dictionary into a destination dictionary, handling nested dictionaries and lists.

    load_inventory(path: str) -> CommentedMap:
        Loads YAML files from a specified directory path into a CommentedMap, supporting custom YAML tags.

    compare_attributes(config, rules, path):
        Compares attributes of a configuration against rules and returns a dictionary of incorrect attributes.

    compare(config, rules, path=[]):
        Recursively compares a configuration against rules and populates the INCORRECT list with violations.

    match(inventory):
        Matches the given inventory against loaded rules and returns a list of violation strings.
"""

import os

from ruamel.yaml import add_constructor
from ruamel.yaml import SafeConstructor
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap

"""
The IAC_VALIDATE_RULES_FILE_PATH environmental variable is set to the folder where the golden rules are located (YAML format based in same structure as data model).

Example Rule:
apic:
  tenants:
    - bridge_domains:
        - unicast_routing: true
          arp_flooding: true
          unknown_unicast: proxy
          unknown_ipv4_multicast: opt-flood
          unknown_ipv6_multicast: opt-flood
          subnets:
            - public: false
              private: true
              shared: false

See https://netascode.cisco.com/tools/golden-config/overview for more information.
"""


class Rule:
    id = "401"
    description = "Verify Configuration against Golden Config Templates"
    severity = "HIGH"

    DEFAULTS_FILE_PATH = (
        os.getenv("IAC_VALIDATE_DEFAULTS_FILE_PATH")
        if os.getenv("IAC_VALIDATE_DEFAULTS_FILE_PATH")
        else "defaults.yaml"
    )
    RULES_FILE_PATH = (
        os.getenv("IAC_VALIDATE_RULES_FILE_PATH")
        if os.getenv("IAC_VALIDATE_RULES_FILE_PATH")
        else ".golden_rules"
    )

    DEFAULTS = {}
    INCORRECT = []

    @classmethod
    def merge_dict_list(cls, source: dict, destination: dict) -> dict:
        for key, value in source.items():
            if isinstance(value, dict):
                node = destination.setdefault(key, {})
                cls.merge_dict_list(value, node)
            elif isinstance(value, list):
                if key not in destination:
                    destination[key] = []
                if isinstance(destination[key], list):
                    destination[key].extend(value)
            else:
                destination[key] = value
        return destination

    @classmethod
    def load_inventory(cls, path: str) -> CommentedMap:
        class VaultTag:
            yaml_tag = "!vault"

            def __init__(self, vault_var):
                self.vault_var = vault_var

            def __repr__(self):
                return self.vault_var

            @staticmethod
            def yaml_constructor(loader, node):
                return VaultTag(loader.construct_scalar(node))

        data = CommentedMap()
        if path != "":
            for filename in sorted(os.listdir(path)):
                file_path = os.path.join(path, filename)
                if os.path.isfile(file_path) and (
                    filename.endswith(".yaml") or filename.endswith(".yml")
                ):
                    with open(file_path, "r") as yaml_file:
                        yaml = YAML(typ="safe")
                        add_constructor(
                            VaultTag.yaml_tag,
                            VaultTag.yaml_constructor,
                            constructor=SafeConstructor,
                        )
                        data_dict = yaml.load(yaml_file.read())
                        cls.merge_dict_list(data_dict, data)
        return data

    @classmethod
    def compare_attributes(cls, config, rules, path):
        incorrect_attributes = {}

        d = cls.DEFAULTS.get("defaults", {}).copy()
        for p in path:
            if isinstance(p, int):
                continue
            d = d.get(p, {})

        for key, value in rules.items():
            if isinstance(value, list):
                if key not in config:
                    incorrect_attributes[key] = value
                else:
                    for r in value:
                        violations = []
                        for c in config[key]:
                            violated = cls.compare_attributes(c, r, path + [key])
                            if violated:
                                violations.append(violated)
                            else:
                                violations = []
                                break
                        if violations:
                            incorrect_attributes[key] = violated
            else:
                if key not in config:
                    if key not in d:
                        incorrect_attributes[key] = value
                    elif value != d.get(key, value):
                        incorrect_attributes[key] = value
                else:
                    if value != config[key]:
                        incorrect_attributes[key] = value

        return incorrect_attributes

    @classmethod
    def compare(cls, config, rules, path=[]):
        if isinstance(rules, dict):
            for r in rules:
                if rules[r] is None:
                    continue
                if isinstance(config, dict):
                    if r in config:
                        cls.compare(config[r], rules[r], path + [r])
                elif isinstance(config, list):
                    for i, c in enumerate(config):
                        if r in c:
                            cls.compare(c[r], rules[r], path + [str(i), r])
        elif isinstance(rules, list) and isinstance(config, list):
            for r in rules:
                for mo in r:
                    if isinstance(config, list):
                        for a, c in enumerate(config):
                            if mo in c:
                                if isinstance(r[mo], list):
                                    violations = []
                                    for i, c2 in enumerate(c[mo]):
                                        for j, r2 in enumerate(r[mo]):
                                            violated = cls.compare_attributes(
                                                c2, r2, path + [mo, a]
                                            )
                                            if violated:
                                                violations.append(violated)
                                            else:
                                                violations = []
                                                break
                                        if violations:
                                            cls.INCORRECT.append(
                                                {
                                                    "path": path + [str(a), mo, str(i)],
                                                    "expected": violations,
                                                    "actual": c2,
                                                }
                                            )
                                            # cls.INCORRECT.append(
                                            #     {
                                            #         "path": path
                                            #         + list(conf.location)
                                            #         + [i],
                                            #         "expected": violations,
                                            #         "actual": conf.value[0],
                                            #     }
                                            # )
                                else:
                                    raise NotImplementedError(
                                        "Only supports list of dicts"
                                    )
                    else:
                        pass
                        # TODO: Fix logic in future release
                        # raise NotImplementedError("Only supports list of dicts")
        else:
            raise NotImplementedError("Only supports dict rules")

    @classmethod
    def match(cls, inventory):
        if not cls.RULES_FILE_PATH or not cls.DEFAULTS_FILE_PATH:
            return []
        if not os.path.exists(cls.RULES_FILE_PATH) or not os.path.exists(
            cls.DEFAULTS_FILE_PATH
        ):
            return []
        try:
            rules = cls.load_inventory(cls.RULES_FILE_PATH)
            cls.DEFAULTS = YAML(typ="safe").load(open(cls.DEFAULTS_FILE_PATH))

            cls.compare(inventory, rules)

            result = []

            for i in cls.INCORRECT:
                res_string = (
                    ".".join([str(x) for x in i["path"]])
                    + " - Is violating Golden Config rules. Rule Violations:"
                )
                for j, rule in enumerate(i["expected"]):
                    res_string += f" Rule #{j + 1}: {rule}"
                result.append(res_string)
            return result

        except KeyError:
            pass
        return []
