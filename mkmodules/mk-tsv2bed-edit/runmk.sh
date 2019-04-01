#!/bin/bash

find -L . \
  -type f \
  -name "*.tsv" \
| sed "s#.tsv#.bed#" \
| xargs mk
