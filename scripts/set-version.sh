#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
VERSION_FILE="$REPO_DIR/VERSION"
FLUTTER_PUBSPEC="$REPO_DIR/src/flutter_app/pubspec.yaml"
PYPROJECT="$REPO_DIR/pyproject.toml"

if [[ ! -f "$VERSION_FILE" ]]; then
    echo "Error: VERSION file not found at $VERSION_FILE"
    exit 1
fi

VERSION=$(cat "$VERSION_FILE" | tr -d ' \n')

if [[ -z "$VERSION" ]]; then
    echo "Error: VERSION file is empty"
    exit 1
fi

# Derive build number from git commit count
if git -C "$REPO_DIR" rev-parse --git-dir &>/dev/null; then
    BUILD_NUMBER=$(git -C "$REPO_DIR" rev-list --count HEAD)
else
    BUILD_NUMBER=1
fi

# Update Flutter pubspec.yaml
if [[ -f "$FLUTTER_PUBSPEC" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^version:.*/version: $VERSION+$BUILD_NUMBER/" "$FLUTTER_PUBSPEC"
    else
        sed -i "s/^version:.*/version: $VERSION+$BUILD_NUMBER/" "$FLUTTER_PUBSPEC"
    fi
    echo "Flutter: $FLUTTER_PUBSPEC → $VERSION+$BUILD_NUMBER"
fi

# Update pyproject.toml
if [[ -f "$PYPROJECT" ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^version = \".*\"/version = \"$VERSION\"/" "$PYPROJECT"
    else
        sed -i "s/^version = \".*\"/version = \"$VERSION\"/" "$PYPROJECT"
    fi
    echo "Python: $PYPROJECT → $VERSION"
fi
