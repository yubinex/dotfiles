# Required Installations

## Base init.lua

### Python
```sh
pip install --user pyright  # LSP for Python
```

### Go
```sh
go install golang.org/x/tools/gopls@latest  # LSP for Go
go install golang.org/x/tools/cmd/gofmt@latest  # Formatter for Go
```

## Extended init.lua

### Install using `npm`
```sh
# TypeScript Language Server (LSP)
npm install -g typescript typescript-language-server

# ESLint (for JavaScript & TypeScript linting)
npm install -g eslint

# Prettier (for JavaScript, TypeScript, HTML, CSS formatting)
npm install -g prettier

# HTML, CSS, and JSON Language Servers
npm install -g vscode-langservers-extracted
```

### Or install using `bun`
```sh
# TypeScript Language Server (LSP)
bun add -g typescript typescript-language-server

# ESLint (for JavaScript & TypeScript linting)
bun add -g eslint

# Prettier (for JavaScript, TypeScript, HTML, CSS formatting)
bun add -g prettier

# HTML, CSS, and JSON Language Servers
bun add -g vscode-langservers-extracted
```
> **Note**: `bun` is often faster than `npm`, but make sure it's installed first:
```sh
curl -fsSL https://bun.sh/install | bash
```
