#!/bin/bash

export SLURM_HOME=$HOME/Slurm.io

if ! grep -E '^s[0-9]{6}$' <<<$SLURM_USERNAME
then
  if grep -E '^s[0-9]{6}$' <<<$USERNAME
  then
    export SLURM_USERNAME=$USERNAME
  else
    printf 'Enter your slurm username (e.g. s000123): '
    read name
    until grep -E '^s[0-9]{6}$' <<<$name
    do
      printf "$name does not seem to match expected regex, please try again: "
      read name
    done
    export SLURM_USERNAME=$name
    unset name
  fi
fi


