from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

from collections import MutableMapping, MutableSequence
from ansible.errors import AnsibleFilterError

def to_csp_header(definition):
    """Convert a dict of values to a CSP header"""

    if not isinstance(definition, MutableMapping):
        raise AnsibleFilterError("|to_csp_header expects dictionary, got " + repr(definition))

    QUOTED_PARAMS = ("self", "none", "unsafe-inline", "unsafe-eval")

    parts = []
    for key in definition:
        if isinstance(definition[key], bool) and definition[key]:
            if definition[key]:
                parts.append(key)
            continue

        if not isinstance(definition[key], MutableSequence):
            raise AnsibleFilterError("|expects dictionary values to be lists or boolean, got" + repr(definition[key]))

        if len(definition[key]) == 0:
            parts.append("{} 'none'".format(key))
            continue

        params = map(lambda param: "'{}'".format(param) if param in QUOTED_PARAMS else param, definition[key])

        parts.append("{} {}".format(key, " ".join(params)))

    return "; ".join(parts)

class FilterModule(object):
    """Filter for generating CSP header"""

    def filters(self):
        return {
            "to_csp_header": to_csp_header,
        }
