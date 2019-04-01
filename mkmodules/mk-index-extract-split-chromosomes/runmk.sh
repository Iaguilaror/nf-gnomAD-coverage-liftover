#!/bin/bash

find -L . \
  -type f \
  -name "*.tsv.bgz" \
| sed "s#.tsv.bgz#.SPLIT#" \
| xargs mk
