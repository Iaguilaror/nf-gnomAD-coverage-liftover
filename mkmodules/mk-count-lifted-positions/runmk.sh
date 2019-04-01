#!/bin/bash

find -L . \
  -type f \
  -name "*.bed.gz" \
| sed "s#.bed.gz#.pdf#" \
| xargs mk
