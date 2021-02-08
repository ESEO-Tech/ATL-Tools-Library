#!/bin/bash

mm=$1
vim=$2

base="testcases/$mm/$mm-out"
expected="$base-original-adapted"
new="$base-adapted"

diff -q {$expected,$new}.ecore || ${vim}diff {$expected,$new}.ecore
