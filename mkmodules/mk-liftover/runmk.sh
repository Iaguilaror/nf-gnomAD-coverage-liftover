#!/bin/bash

find -L . \
  -type f \
  -name "*.bed" \
  ! -name "*.liftover.bed" \
| sed "s#.bed#.liftover.bed#" \
| xargs mk
