# RTK Installation

Install RTK before using this skill.

## Linux/macOS

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

## Ubuntu/Debian

```bash
sudo apt update
sudo apt install -y curl ca-certificates
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

## Fedora

```bash
sudo dnf install -y curl ca-certificates
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

## Arch

```bash
sudo pacman -S --needed curl ca-certificates
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
```

## Cargo

```bash
cargo install --git https://github.com/rtk-ai/rtk --force
```

## Verify

```bash
rtk --version
rtk gain
```
