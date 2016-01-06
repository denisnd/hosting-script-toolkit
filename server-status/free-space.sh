#!/bin/sh

df --output="pcent" / | tail -1 | grep -E -o "[0-9]+%" | grep -E -o "([0-9]+)"