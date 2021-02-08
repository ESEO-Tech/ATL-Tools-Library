#!/bin/bash

mm=$1
vim=$2

base="testcases/$mm/$mm-out"
expected="$base-expected"
new="$base"

echo Comparing UML models
diff -q {$expected,$new}.uml || ${vim}diff {$expected,$new}.uml
echo Comparing Ecore metamodels
diff -q {$expected,$new}.ecore || ${vim}diff {$expected,$new}.ecore
