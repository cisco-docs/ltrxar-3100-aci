import re


class Rule:
    id = "206"
    description = "Verify ACI object names to prevent scientific notation interpretation in string values"
    severity = "HIGH"

    # Regex for detecting scientific notation-like strings (e.g., '421e714314321443')
    SCIENTIFIC_NOTATION_PATTERN = re.compile(r"\b[-+]?\d*\.?\d+[eE][-+]?\d+\b")

    @classmethod
    def _traverse_and_validate(cls, data, path_elements, results):
        """
        Recursively traverses the inventory and validates string values for
        potential scientific notation.
        """
        current_path = ".".join(map(str, path_elements))

        if isinstance(data, dict):
            # Recursively traverse into the values of the dictionary
            for key, value in data.items():
                new_path_elements = path_elements + [key]
                cls._traverse_and_validate(value, new_path_elements, results)

        elif isinstance(data, list):
            # Recursively traverse into the items of the list
            for index, item in enumerate(data):
                new_path_elements = path_elements + [index]
                cls._traverse_and_validate(item, new_path_elements, results)

        elif isinstance(data, str):
            # This is the core validation logic for this rule.
            # Check any string for potential scientific notation.
            sci_matches = cls.SCIENTIFIC_NOTATION_PATTERN.findall(data)
            for match in sci_matches:
                results.append(
                    f"{current_path} - Potential scientific notation detected: '{match}'. "
                    "This can cause `yamldecode` errors."
                )

    @classmethod
    def match(cls, inventory):
        """
        Main method for the rule, called by the validation framework.
        """
        results = []
        try:
            # Start the recursive traversal from the root of the inventory.
            cls._traverse_and_validate(inventory, [], results)
        except Exception as e:
            # Prevent the rule from crashing the entire validation run
            results.append(
                f"Rule {cls.id} - An unexpected error occurred during validation: {e}"
            )
        return results
