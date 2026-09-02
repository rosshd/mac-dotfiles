SHELL := /bin/bash

.PHONY: check

check:
	@set -euo pipefail; \
	for test_file in tests/test-*.sh; do \
		printf '==> %s\n' "$$test_file"; \
		bash "$$test_file"; \
	done
	@printf '==> %s\n' tests/test-networking.py
	@PYTHONDONTWRITEBYTECODE=1 python3 -m unittest -v tests/test-networking.py
	@printf '==> %s\n' plugins/workflow-core/scripts/audit_catalog.py
	@PYTHONDONTWRITEBYTECODE=1 python3 plugins/workflow-core/scripts/audit_catalog.py
