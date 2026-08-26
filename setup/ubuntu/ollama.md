# Ollama

Runs LLMs locally, using this machine's NVIDIA RTX 3070 (8GB VRAM) for
acceleration. Installed by `manual-installs.sh` via the official installer —
see `README.md`'s "Notable decisions" section for why it's not an apt/snap
package.

## Getting started

The installer enables and starts `ollama.service` automatically — nothing to
launch by hand. Check it's up:

```bash
systemctl status ollama --no-pager
```

Pull and run a model (pulls on first use if you don't `pull` explicitly):

```bash
ollama run llama3.1:8b
```

This drops you into an interactive chat. `/bye` or Ctrl-D to exit. Anything
you `run` or `pull` gets cached under `/usr/share/ollama/.ollama/models` (or
`~/.ollama/models` for a user-scoped install) so it's a one-time download per
model/tag.

## Sizing models to this GPU

8GB of VRAM is the real ceiling. As a rule of thumb, a model fits fully in
VRAM (fast) at roughly `params × bits/8 × 1.2` GB — the `1.2` covers KV cache
overhead. Ollama's default quantization is Q4_K_M (~4.5 bits/param
effective).

| Model | Approx. VRAM (Q4) | Fits in 8GB? |
|---|---|---|
| `llama3.1:8b`, `qwen2.5:7b`, `mistral:7b` | ~5-6GB | Yes, comfortably |
| `gemma2:9b` | ~6-7GB | Yes, tight |
| `qwen2.5:14b`, `phi4:14b` | ~9-10GB | Partial CPU offload, slower |
| 30B+ | 20GB+ | No — heavy offload, not practical here |

Start with `llama3.1:8b` or `qwen2.5:7b` for general use, `qwen2.5-coder:7b`
for coding help.

## Common commands

```bash
ollama pull <model>       # download/update a model without running it
ollama run <model>        # pull if needed, then start an interactive session
ollama list                # models you have locally
ollama ps                  # currently loaded models + GPU/CPU split
ollama rm <model>          # delete a local model to free disk space
ollama show <model>        # model details: params, quantization, template
ollama stop <model>        # unload a model from memory without deleting it
```

Non-interactive one-shot prompt:

```bash
ollama run llama3.1:8b "Summarize this in one sentence: ..."
```

Field-tested: `ollama run` writes its progress spinner directly to the
terminal, which garbles output when captured non-interactively (e.g. run in
a script or captured by another tool). Redirect stderr (`2>/dev/null`) for
one-shot prompts like the above, or use the REST API below — it returns
plain JSON with no spinner at all.

Piping stdin works too:

```bash
cat notes.txt | ollama run llama3.1:8b "Summarize the following:"
```

## Updating

**Ollama itself:** re-run the installer — it detects the existing install and
upgrades in place, no separate "update" subcommand:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

**A model:** `ollama pull <model>` again — it only re-downloads changed
layers (same content-addressed layer model as Docker), so re-pulling an
up-to-date model is cheap.

Check your installed version against latest:

```bash
ollama --version
curl -fsSL https://api.github.com/repos/ollama/ollama/releases/latest | grep tag_name
```

## Using it from code (REST API)

Ollama serves an HTTP API on `localhost:11434` by default — useful for
scripting or hooking into editor/agent tooling without shelling out to the
CLI.

```bash
curl http://localhost:11434/api/generate -d '{
  "model": "llama3.1:8b",
  "prompt": "Why is the sky blue?",
  "stream": false
}'
```

It also exposes an OpenAI-compatible endpoint at `/v1`, so OpenAI SDK clients
work by pointing `base_url` at `http://localhost:11434/v1`.

## Where to find more

- Model library (browse what's available, sizes, tags): https://ollama.com/library
- CLI/API reference: https://github.com/ollama/ollama/blob/main/docs/README.md
- REST API reference: https://github.com/ollama/ollama/blob/main/docs/api.md
- GitHub releases (changelog): https://github.com/ollama/ollama/releases
- Discord (community support): linked from https://ollama.com
