#!/bin/bash
set -e

cd "$1"
tar -czvf "../$1.tar.gz" .
