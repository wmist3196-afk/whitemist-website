#!/bin/bash
cd "$(dirname "$0")"
node scripts/verify.mjs
read -p "Press Enter to close"
