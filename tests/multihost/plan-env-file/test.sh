#!/bin/bash
. /usr/share/beakerlib/beakerlib.sh || exit 1

rlJournalStart
    rlPhaseStartSetup
        rlRun "run=\$(mktemp -d)" 0 "Create run directory"
        rlRun "pushd data"
        rlRun "set -o pipefail"
    rlPhaseEnd

    rlPhaseStartTest "Check identity of variables, but uniqueness of env files"
        rlRun -s "tmt -vvv run --scratch --id $run discover provision execute finish cleanup plan -n plan"

        rlAssertEquals "Four different guest+role reported the CLIENTS variable" "$(grep 'stdout: CLIENTS:' $rlRun_LOG | sed 's/.*\[\(.*\)\].*/\1/' | sort -u | wc -l)" "4"
        rlAssertEquals "All guests see same CLIENTS" "$(grep 'stdout: CLIENTS:' $rlRun_LOG | sed 's/.*stdout: CLIENTS: //' | sort -u | wc -l)" "1"

        rlAssertEquals "Four different guest+role reported the SERVERS variable" "$(grep 'stdout: SERVERS:' $rlRun_LOG | sed 's/.*\[\(.*\)\].*/\1/' | sort -u | wc -l)" "4"
        rlAssertEquals "All guests see same SERVERS" "$(grep 'stdout: SERVERS:' $rlRun_LOG | sed 's/.*stdout: SERVERS: //' | sort -u | wc -l)" "1"

        rlAssertEquals "Four different guest+role reported the TMT_PLAN_ENVIRONMENT_FILE variable" "$(grep 'stdout: TMT_PLAN_ENVIRONMENT_FILE:' $rlRun_LOG | sed 's/.*\[\(.*\)\].*/\1/' | sort -u | wc -l)" "4"
        rlAssertEquals "All guests see unique TMT_PLAN_ENVIRONMENT_FILE" "$(grep 'stdout: TMT_PLAN_ENVIRONMENT_FILE:' $rlRun_LOG | sed 's/.*stdout: TMT_PLAN_ENVIRONMENT_FILE: //' | sort -u | wc -l)" "4"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm -r $run" 0 "Remove run directory"
    rlPhaseEnd
rlJournalEnd
