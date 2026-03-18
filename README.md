# codex-keys

Automatic key rotation for [OpenAI Codex CLI](https://github.com/openai/codex).

When you have multiple OpenAI accounts, `codex-keys` silently picks the one with the most remaining quota every time you launch `codex`. No menus, no prompts — it just works.

## How it works

1. Probes all your keys in parallel (~4s for 7 keys, cached for 5 minutes)
2. Scores each key: available > 5h-limited > weekly-limited > error
3. Among equally-scored keys, picks the one whose limit resets soonest
4. Sets `CODEX_HOME` and launches codex transparently

When `CODEX_HOME` is already set (e.g., by automation scripts), the wrapper passes through instantly with zero overhead.

## Install

```bash
# Prerequisites: codex CLI, jq
npm install -g @openai/codex
which jq || sudo apt install jq  # or brew install jq

# Install codex-keys
git clone https://github.com/happybigmtn/codex-keys.git
cd codex-keys
bash install.sh
```

## Add keys

```bash
# OAuth login (opens browser)
codex-key-add personal
codex-key-add work

# API key (paste from stdin)
codex-key-add service --api-key

# Check status
codex-key-status
```

Each key slot lives in `~/.codex-keys/<name>/` with its own `auth.json` and symlinks to shared config from `~/.codex/`.

## Usage

Just use codex normally. The wrapper is transparent:

```bash
codex --yolo                    # auto-selects best key
codex "fix the tests"           # same — auto-selects
CODEX_HOME=~/.codex codex       # bypass — uses specified key directly
```

## Key scoring

| Status | Score | Meaning |
|--------|-------|---------|
| `ok` | 100 | Key has credits, use it |
| `limited` (reset passed) | 90 | Was limited but reset time elapsed — likely available |
| `limited` (5h only) | 50 | 5-hour window hit, resets soon |
| `limited` (weekly) | 10 | Weekly limit hit, long wait |
| `error` | 5 | Probe failed (timeout, auth error) |

Among equal scores, the key whose limit resets soonest wins.

## After updating codex

`npm update -g @openai/codex` recreates the `codex` symlink, overwriting the wrapper. Re-run the installer:

```bash
cd codex-keys && bash install.sh
```

## Uninstall

```bash
cd codex-keys && bash uninstall.sh
```

Restores the original codex binary. Key slots in `~/.codex-keys/` are preserved.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `CODEX_KEYS_DIR` | `~/.codex-keys` | Key slots directory |
| `CODEX_HOME` | (auto-selected) | Set to skip auto-selection |

Cache lives in `$CODEX_KEYS_DIR/.cache/` with a 5-minute TTL.

## Requirements

- bash 4+
- [OpenAI Codex CLI](https://github.com/openai/codex)
- `jq`
- `timeout` (coreutils)

## License

MIT
