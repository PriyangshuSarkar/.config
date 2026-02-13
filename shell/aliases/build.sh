# ===============================
# build & test helper
# ===============================
bt() {
  echo "🔍 detecting build system..."

  # node.js
  if [ -f package.json ]; then
    if command -v bun >/dev/null 2>&1; then
      echo "🥟 $ bun run build && bun run test"
      bun run build && bun run test || return 1
    elif command -v npm >/dev/null 2>&1; then
      echo "📦 $ npm run build && npm run test"
      npm run build && npm run test || return 1
    elif command -v yarn >/dev/null 2>&1; then
      echo "🧶 $ yarn run build && yarn run test"
      yarn run build && yarn run test || return 1
    fi
  # python
  elif [ -f pyproject.toml ] || [ -f setup.py ]; then
    if command -v hatch >/dev/null 2>&1; then
      echo "🐍 $ hatch build && hatch run test"
      hatch build && hatch run test || return 1
    elif command -v poetry >/dev/null 2>&1; then
      echo "📖 $ poetry build && poetry run pytest"
      poetry build && poetry run pytest || return 1
    else
      echo "🐍 $ python -m build && pytest"
      python -m build && pytest || return 1
    fi
  # rust
  elif [ -f Cargo.toml ]; then
    echo "🦀 $ cargo build --release && cargo test"
    cargo build --release && cargo test || return 1
  # go
  elif [ -f go.mod ]; then
    echo "🐹 $ go build ./... && go test ./..."
    go build ./... && go test ./... || return 1
  # java (maven/gradle)
  elif [ -f pom.xml ]; then
    echo "☕ $ mvn package -DskipTests && mvn test"
    mvn package -DskipTests && mvn test || return 1
  elif [ -f build.gradle ] || [ -f build.gradle.kts ]; then
    echo "🐘 $ gradle build -x test && gradle test"
    gradle build -x test && gradle test || return 1
  else
    echo "⚠️  no known build system detected — skipping build and tests."
    return 1
  fi

  echo "✅ build and tests passed."
}
