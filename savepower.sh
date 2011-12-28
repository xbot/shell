#!/bin/bash
# Description: Set cpufreq to powersave mode, dual core only
# Depends on: cpufreq

for i in 0 1; do sudo cpufreq-set -c $i -g powersave; done
