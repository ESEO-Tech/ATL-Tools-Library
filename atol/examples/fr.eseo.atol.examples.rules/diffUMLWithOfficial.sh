#!/bin/bash

mm=$1
vim=$2

base="testcases/$mm/$mm-out"
expected="$base-official-sorted"
new="$base-sorted"

diff -q {$expected,$new}.uml || ${vim}diff {$expected,$new}.uml
