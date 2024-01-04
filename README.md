# 2048

Install [`V`](https://github.com/vlang/v) and [`just`](https://github.com/casey/just), then use `just -l` to list available recipes.

Add `-h` to those recipes that have optional flags to see full options of the game.

```bash
just run -h
```

You can create production build to gain the performance optimized executable.

```bash
just build
```

Use `-A` to select the AI algorithm:

```bash
just run -A dfs
```

There are various kinds of AI you can choose:

- dfs
- heuristic
- minmax
- expectimax
- monte
- reinforcement

The default algorithm is `dfs`.
