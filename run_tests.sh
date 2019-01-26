#!/usr/bin/env bash
# Check for mandatory build arguments
mkdir -p testresults

python -m pytest \
    --junitxml testresults/test-results.xml \
    --cov site \
    --cov-report=xml:testresults/coverage.xml \
    --cov-report=html:testresults/coverage-report \
    -v tests

exit $?