# zsh-helper-scripts


## hist Command — Shell History Search Utility

The `hist` function searches your shell history for commands matching a given term.  
It automatically:
- Ignores any `hist` commands to avoid self-matches
- Removes duplicates (keeping only the most recent occurrence)
- Supports time-based filtering
- Works in both **zsh** and **bash**

---

### Usage
```bash
hist <search-term> [OPTIONS]
```

| Option       | Description                                      |
| ------------ | ------------------------------------------------ |
| `--days N`   | Show commands from the last **N days**           |
| `--hours N`  | Show commands from the last **N hours**          |
| `--min N`    | Show commands from the last **N minutes**        |
| `-n N`       | Limit results to the latest **N** unique entries |
| `-h, --help` | Show this help message                           |
