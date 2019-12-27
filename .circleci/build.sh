#!/bin/bash

set -e

hab install "core/python" --binlink
source "functions/callbacks.sh"

for plan in plans/*
do
    pkg_origin="$(grep "pkg_origin=" "${plan}/plan.sh" | cut -d= -f2)"
    export HAB_ORIGIN="${pkg_origin}"
    pkg_name="$(grep "pkg_name=" "${plan}/plan.sh" | cut -d= -f2)"
    export pkg_name

if hab pkg install ${pkg_origin}/${pkg_name}/$(current_pypi_version ${pkg_name}) &> "/dev/null"
then
    echo ""
    echo "\`${pkg_name}==$(current_pypi_version ${pkg_name})\` already vendored"
    echo "to Habitat Builder:"
    echo "   ${pkg_origin}/${pkg_name}/$(current_pypi_version ${pkg_name})"
    echo ""
else
    hab pkg build "${plan}"
    source results/last_build.env
    hab pkg upload results/"${pkg_artifact}"
    hab pkg promote "${pkg_ident}" stable
fi
done
