# frs-xofi-menus

0xferrous' DeFiLlama protocol selectors for xofi (wofi/rofi)

## Installation

Using Nix flakes:

```bash
# Run rofi version (default)
nix run github:0xferrous/frs-xofi-menus

# Run wofi version
nix run github:0xferrous/frs-xofi-menus#wofi-dfl-dir

# Run rofi version explicitly
nix run github:0xferrous/frs-xofi-menus#rofi-dfl-dir
```

Or build locally:

```bash
nix build .#rofi-dfl-dir
./result/bin/rofi-dfl-dir

# Or wofi version
nix build .#wofi-dfl-dir
./result/bin/wofi-dfl-dir
```

## Usage

Both scripts provide a fuzzy-searchable menu of DeFiLlama protocols:

- `wofi-dfl-dir` - Uses wofi for the menu interface
- `rofi-dfl-dir` - Uses rofi for the menu interface

Select a protocol to open its website in your default browser.