#!/usr/bin/env bash
: "${TEST_IMAGE_NAME:?Name of test image to run}"
# NOTE: this "trick" of streaming the test results folder as a tar file does *NOT* work if you add -t flag to docker
# Addition of the TTY features will inject CR characters which corrupt the data.
docker run --rm -i \
    $TEST_IMAGE_NAME \
    | tar -xf - && EXIT_CODE=${PIPESTATUS[0]} && cat testresults/stdout.log && cat testresults/stderr.log 1>&2

exit $EXIT_CODE