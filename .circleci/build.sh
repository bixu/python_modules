#!/bin/bash

set -e

source "functions/callbacks.sh"

for plan in plans/*
do
    pkg_origin="$(grep "pkg_origin=" "${plan}/plan.sh" | cut -d= -f2)"
    export HAB_ORIGIN="${pkg_origin}"
    pkg_name="$(grep "pkg_name=" "${plan}/plan.sh" | cut -d= -f2)"
    export pkg_name

    hab pkg build "${plan}"
done
