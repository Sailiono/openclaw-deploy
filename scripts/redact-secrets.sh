#!/usr/bin/env bash
# Redact secrets from pipe input — safe for logs and reports.
sed -E \
  -e 's#(https?://[^/? ]+)[^ ]*#\1/***REDACTED***#g' \
  -e 's/(sk-[A-Za-z0-9._-]{6})[A-Za-z0-9._-]+([A-Za-z0-9._-]{4})/\1***REDACTED***\2/g' \
  -e 's/(OPENCODE_API_KEY=).+/\1***REDACTED***/g' \
  -e 's/(OPENAI_API_KEY=).+/\1***REDACTED***/g' \
  -e 's/(ANTHROPIC_API_KEY=).+/\1***REDACTED***/g' \
  -e 's/(Authorization:[[:space:]]*Bearer[[:space:]]+)[A-Za-z0-9._-]+/\1***REDACTED***/gi' \
  -e 's/(appSecret["'\''"[:space:]]*[:=]["'\''"[:space:]]*)[^"'\'' ,}]+/\1***REDACTED***/gi' \
  -e 's/(secret["'\''"[:space:]]*[:=]["'\''"[:space:]]*)[^"'\'' ,}]+/\1***REDACTED***/gi' \
  -e 's/(token["'\''"[:space:]]*[:=]["'\''"[:space:]]*)[^"'\'' ,}]+/\1***REDACTED***/gi' \
  -e 's/(password["'\''"[:space:]]*[:=]["'\''"[:space:]]*)[^"'\'' ,}]+/\1***REDACTED***/gi'
