#!/usr/bin/env bash

crystal build spec/run_specs.cr && \
kcov --clean --include-path=src coverage ./run_specs
