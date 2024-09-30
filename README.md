# 2048

A simple 2048 game written in V with some AI algorithms.

## Prepare

Clone this repository:

```bash
git clone https://github.com/wenxuanjun/2048
cd 2048
```

Install [`V`](https://github.com/vlang/v) and [`just`](https://github.com/casey/just), then use `just -l` to list available recipes.

## Run

Add `-h` to those recipes that have optional flags to see full options of the game.

```bash
just run -h
```

To just play without AI:

```bash
just run -g
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

You can also use `-a` to enable AI with GUI:

```bash
just run -g -a -A expectimax
```

## Build

You can create production build to gain the performance optimized executable.

```bash
just build
```

And replace `just run` with `./2048` of commands mentioned above.

```bash
./2048 -r mt19937 -A monte
```
