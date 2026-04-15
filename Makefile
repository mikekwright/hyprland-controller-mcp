.PHONY: new-scenario

new-scenario:
	@if [ -z "$(strip $(NAME))" ]; then \
		echo 'NAME is required. Usage: make new-scenario NAME="Feature Name"' >&2; \
		exit 1; \
	fi
	@./scripts/create-spec.sh "$(NAME)"
