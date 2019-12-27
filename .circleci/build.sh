#!/bin/bash

set -e

type pip
source "functions/callbacks.sh"

for plan in plans/*
do
    pkg_origin="$(grep "pkg_origin=" "${plan}/plan.sh" | cut -d= -f2)"
    export HAB_ORIGIN="${pkg_origin}"
    pkg_name="$(grep "pkg_name=" "${plan}/plan.sh" | cut -d= -f2)"
    export pkg_name

if sudo hab pkg install ${pkg_origin}/${pkg_name}/$(current_pypi_version ${pkg_name}) &> "/dev/null"
then
    echo "Module \`${pkg_name}\` already vendored to Habitat Builder."
else
    hab pkg build "${plan}"
    source results/last_build.env
    hab pkg upload results/"${pkg_artifact}"
    hab pkg promote "${pkg_ident}" stable
fi
done
