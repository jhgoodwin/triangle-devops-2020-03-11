#!/usr/bin/env bash
# folder for the test results
TESTRESULTS="testresults"
mkdir -p $TESTRESULTS
./run_tests.sh > $TESTRESULTS/stdout.log 2> $TESTRESULTS/stderr.log

EXIT_CODE=$?

tar cf - "$TESTRESULTS" | cat
exit $EXIT_CODE