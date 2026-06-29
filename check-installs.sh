#!/usr/bin/env bash
# Checks that all required dependencies are installed in the Docker image. If any are missing, the script will exit with a non-zero status code.
#   - openjdk-21-jdk        → Java / Kotlin analysis
#   - maven, gradle         → Java build tools (autobuild heuristics)
#   - python3, python3-pip  → Python 3 analysis
#   - nodejs (22.x pinned)  → JavaScript / TypeScript analysis
#   - gcc, g++, clang, build-essential → C / C++ analysis & autobuild
#   - ruby-full             → Ruby analysis
#   - golang-go             → Go analysis
#   - rustup                → Rust analysis

set -euo pipefail

MISSING=()

check_command() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        echo "MISSING: $cmd"
        MISSING+=("$cmd")
    else
        echo "OK:      $cmd ($(command -v "$cmd"))"
    fi
}

check_java_version() {
    if ! command -v java &>/dev/null; then
        echo "MISSING: java"
        MISSING+=("java")
        return
    fi
    local version
    version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -d'.' -f1)
    if [[ "$version" -ge 21 ]]; then
        echo "OK:      java (version $version)"
    else
        echo "MISSING: java >= 21 (found version $version)"
        MISSING+=("java>=21")
    fi
}

echo "=== Checking required dependencies ==="

# Java / Kotlin
check_java_version
check_command javac

# Java build tools
check_command mvn
check_command gradle

# Python 3
check_command python3
check_command pip3

# JavaScript / TypeScript
check_command node
check_command npm

# C / C++
check_command gcc
check_command g++
check_command clang

# Ruby
check_command ruby
check_command gem

# Go
check_command go

# Rust
check_command rustup
check_command cargo
check_command rustc

echo ""
if [[ ${#MISSING[@]} -eq 0 ]]; then
    echo "All required dependencies are installed."
    exit 0
else
    echo "The following dependencies are missing: ${MISSING[*]}"
    exit 1
fi

