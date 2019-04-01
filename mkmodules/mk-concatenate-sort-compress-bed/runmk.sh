#!/usr/bin/env bash
find -L . \
  -type f \
  -name "*.subsampled*.liftover.bed" \
| sed -r 's#\.subsampled.*\.liftover\.bed#\.bed.gz#' \
| sort -Vu \
| xargs mk
