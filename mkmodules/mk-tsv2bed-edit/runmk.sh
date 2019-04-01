#!/bin/bash

find -L . \
  -type f \
  -name "*.tsv" \
| sed "s#.tsv#.edited.tsv#" \
| xargs mk
