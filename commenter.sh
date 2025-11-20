#!/usr/bin/env bash
set -euo pipefail

REF_KIND="${1:?It is necessary to provide an issue or pr.}"
IDENTIFIER="${2:?It is necessary to provide an issue or pr id or url.}"
MESSAGE_CONTENT="${3:?It is necessary to provide comment mensage.}"

case "${REF_KIND}" in
    pr|issue)
        # Valid values.
        ;;
    *)
        # Invalid value, Action failed.
        ERROR_MESSAGE="Validation error: 'ref_kind' must be 'issue' or 'pr'. Received: '${REF_KIND}'"
        echo "${ERROR_MESSAGE}" >&2

        # Exports a failure message to the Action's output before exiting.
        echo "completion-message=${ERROR_MESSAGE}" >> $GITHUB_OUTPUT
        exit 1
        ;;
esac

echo "Executing 'gh'..."
echo "Kind: $REF_KIND, IDENTIFIER: $IDENTIFIER"

gh "${REF_KIND}" comment "${IDENTIFIER}" --body "${MESSAGE_CONTENT}"

# Check the exit status code.
if [ $? -eq 0 ]; then
    FINAL_MESSAGE="Comment successfully posted on ${REF_KIND} ${IDENTIFIER}."
    EXIT_CODE=0
else
    FINAL_MESSAGE="Error posting comment: ${REF_KIND} ${IDENTIFIER}. Check the permissions (GITHUB_TOKEN)."
    EXIT_CODE=1
fi

# Export the completion message to the Action's 'completion-message' output.
echo "completion-message=${FINAL_MESSAGE}" >> $GITHUB_OUTPUT

exit ${EXIT_CODE}
