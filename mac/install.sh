#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------
# カラー出力
# ---------------------------------------------------------------
BOLD="\033[1m"
GREEN="\033[32m"
CYAN="\033[36m"
YELLOW="\033[33m"
RESET="\033[0m"

info()    { echo -e "${CYAN}==>${RESET} $*"; }
success() { echo -e "${GREEN}  ✓${RESET} $*"; }
warn()    { echo -e "${YELLOW}  !${RESET} $*"; }

# ---------------------------------------------------------------
# インストール項目の定義
# ---------------------------------------------------------------
# 各項目: "KEY|表示名|デフォルト(on/off)"
ITEMS=(
  "homebrew|Homebrew + Brewfile (全パッケージ)|on"
  "symlinks|設定ファイルのシンボリックリンク|on"
  "alacritty_themes|Alacritty テーマ集|on"
  "mise|mise で言語ランタイムをインストール (Node / Rust / Python)|on"
  "rust_toolchain|Rust toolchain コンポーネント (rust-analyzer / rustfmt / clippy)|on"
  "nvim_plugins|Neovim プラグインのインストール|on"
  "mkdp_build|markdown-preview.nvim のビルド (npm install)|on"
)

# ---------------------------------------------------------------
# 選択 UI
# ---------------------------------------------------------------
declare -A SELECTED

interactive_select() {
  # デフォルト値をセット
  for item in "${ITEMS[@]}"; do
    local key="${item%%|*}"
    local default="${item##*|}"
    SELECTED[$key]="$default"
  done

  echo ""
  echo -e "${BOLD}インストール項目を選択してください${RESET}"
  echo "  Space: toggle  |  a: 全選択  |  n: 全解除  |  Enter: 決定"
  echo ""

  local cursor=0
  local count=${#ITEMS[@]}

  # make経由でも動作するよう /dev/tty を明示的に使用
  # /dev/tty が使えない場合は非インタラクティブとして全選択で続行
  local TTY=/dev/tty
  if ! [ -r /dev/tty ] || ! [ -w /dev/tty ]; then
    warn "/dev/tty が使用できません。全項目を選択して続行します"
    for item in "${ITEMS[@]}"; do
      local k="${item%%|*}"
      SELECTED[$k]="on"
    done
    return
  fi

  # カーソル非表示
  tput civis > "$TTY" 2>/dev/null || true

  render_menu() {
    for ((i = 0; i < count; i++)); do
      tput el > "$TTY"
      local item="${ITEMS[$i]}"
      local key="${item%%|*}"
      local rest="${item#*|}"
      local label="${rest%%|*}"
      local checked="${SELECTED[$key]}"
      local mark="[ ]"
      [[ "$checked" == "on" ]] && mark="[${GREEN}x${RESET}]"
      if [[ $i -eq $cursor ]]; then
        echo -e "  ${BOLD}${CYAN}▶ ${mark} ${label}${RESET}" > "$TTY"
      else
        echo -e "    ${mark} ${label}" > "$TTY"
      fi
    done
    # カーソルを先頭に戻す
    tput cuu $count > "$TTY" 2>/dev/null || true
  }

  render_menu

  while true; do
    local key
    IFS= read -rsn1 key < "$TTY" 2>/dev/null

    case "$key" in
      $'\x1b')  # エスケープシーケンス (矢印キー)
        read -rsn2 -t 0.1 seq < "$TTY" 2>/dev/null || true
        case "$seq" in
          '[A') ((cursor > 0)) && ((cursor -= 1)); true ;;
          '[B') ((cursor < count - 1)) && ((cursor += 1)); true ;;
        esac
        ;;
      'k') ((cursor > 0)) && ((cursor -= 1)); true ;;
      'j') ((cursor < count - 1)) && ((cursor += 1)); true ;;
      ' ')  # Space: toggle
        local item="${ITEMS[$cursor]}"
        local k="${item%%|*}"
        [[ "${SELECTED[$k]}" == "on" ]] && SELECTED[$k]="off" || SELECTED[$k]="on"
        ;;
      'a')  # 全選択
        for item in "${ITEMS[@]}"; do
          local k="${item%%|*}"
          SELECTED[$k]="on"
        done
        ;;
      'n')  # 全解除
        for item in "${ITEMS[@]}"; do
          local k="${item%%|*}"
          SELECTED[$k]="off"
        done
        ;;
      '')  # Enter: 決定
        break
        ;;
    esac

    render_menu
  done

  # カーソルを最下行に移動してから復元
  tput cud $count > "$TTY" 2>/dev/null || true
  tput cnorm > "$TTY" 2>/dev/null || true
  echo "" > "$TTY"
}

# ---------------------------------------------------------------
# 各インストール処理
# ---------------------------------------------------------------

install_homebrew() {
  if ! command -v brew &>/dev/null; then
    info "Homebrew をインストール中..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  info "brew bundle を実行中 (時間がかかる場合があります)..."
  brew bundle --file="$DOTFILES_DIR/Brewfile"
  success "Homebrew + パッケージのインストール完了"
}

install_symlinks() {
  info "シンボリックリンクを作成中..."

  symlink() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
      warn "スキップ (既にリンク済み): $dst"
    elif [ -e "$dst" ]; then
      warn "バックアップ: $dst → $dst.bak"
      mv "$dst" "$dst.bak"
      ln -s "$src" "$dst"
      success "リンク作成: $dst"
    else
      ln -s "$src" "$dst"
      success "リンク作成: $dst"
    fi
  }

  # Shell
  symlink "$DOTFILES_DIR/.zshrc"                            "$HOME/.zshrc"
  symlink "$DOTFILES_DIR/.zprofile"                         "$HOME/.zprofile"

  # Config files
  symlink "$DOTFILES_DIR/.config/starship.toml"             "$HOME/.config/starship.toml"
  symlink "$DOTFILES_DIR/.config/alacritty/alacritty.toml"  "$HOME/.config/alacritty/alacritty.toml"
  symlink "$DOTFILES_DIR/.config/zellij/config.kdl"         "$HOME/.config/zellij/config.kdl"
  symlink "$DOTFILES_DIR/.config/mise/config.toml"          "$HOME/.config/mise/config.toml"
  symlink "$DOTFILES_DIR/.config/git/ignore"                "$HOME/.config/git/ignore"

  # Neovim (ディレクトリごとシンボリックリンク)
  if [ -L "$HOME/.config/nvim" ]; then
    warn "スキップ (既にリンク済み): ~/.config/nvim"
  elif [ -d "$HOME/.config/nvim" ]; then
    warn "バックアップ: ~/.config/nvim → ~/.config/nvim.bak"
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
    ln -s "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
    success "リンク作成: ~/.config/nvim"
  else
    ln -s "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"
    success "リンク作成: ~/.config/nvim"
  fi
}

install_alacritty_themes() {
  local themes_dir="$HOME/.config/alacritty/themes"
  if [ ! -d "$themes_dir" ]; then
    info "alacritty-theme をインストール中..."
    git clone https://github.com/alacritty/alacritty-theme "$themes_dir"
  else
    info "alacritty-theme を更新中..."
    git -C "$themes_dir" pull --quiet
  fi
  success "Alacritty テーマ完了"
}

install_mise() {
  info "mise で言語ランタイムをインストール中..."
  mise install
  success "言語ランタイムのインストール完了"
}

install_rust_toolchain() {
  if command -v rustup &>/dev/null; then
    info "Rust toolchain コンポーネントを追加中..."
    rustup component add rust-analyzer rustfmt clippy
    success "Rust toolchain 完了"
  else
    warn "rustup が見つかりません。mise で Rust をインストール後に再実行してください"
  fi
}

install_nvim_plugins() {
  info "Neovim プラグインをインストール中 (headless)..."
  nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
  success "Neovim プラグインのインストール完了"
}

install_mkdp_build() {
  local mkdp_app="$HOME/.local/share/nvim/lazy/markdown-preview.nvim/app"
  if [ -d "$mkdp_app" ]; then
    info "markdown-preview.nvim をビルド中 (npm install)..."
    (cd "$mkdp_app" && npm install)
    success "markdown-preview.nvim ビルド完了"
  else
    warn "markdown-preview.nvim が見つかりません。Neovim プラグインのインストール後に再実行してください"
  fi
}

# ---------------------------------------------------------------
# メイン処理
# ---------------------------------------------------------------

echo ""
echo -e "${BOLD}dotfiles setup: macOS${RESET}"
echo "  source: $DOTFILES_DIR"

# --all フラグの場合は全選択してスキップ
if [[ "$1" == "--all" ]]; then
  echo ""
  info "--all フラグ: 全項目をインストールします"
  for item in "${ITEMS[@]}"; do
    key="${item%%|*}"
    SELECTED[$key]="on"
  done
else
  interactive_select
fi

# 選択結果を表示
echo -e "${BOLD}実行する項目:${RESET}"
any_selected=false
for item in "${ITEMS[@]}"; do
  key="${item%%|*}"
  rest="${item#*|}"
  label="${rest%%|*}"
  if [[ "${SELECTED[$key]}" == "on" ]]; then
    echo -e "  ${GREEN}✓${RESET} $label"
    any_selected=true
  fi
done

if [[ "$any_selected" == "false" ]]; then
  echo "  (なし) — 何も選択されていません"
  echo ""
  info "セットアップをスキップしました"
  exit 0
fi

echo ""
read -rp "実行しますか？ [Y/n]: " confirm < /dev/tty
[[ "$confirm" =~ ^[Nn] ]] && { echo "キャンセルしました"; exit 0; }
echo ""

# ---------------------------------------------------------------
# 選択された項目を順に実行
# ---------------------------------------------------------------
[[ "${SELECTED[homebrew]}"       == "on" ]] && install_homebrew
[[ "${SELECTED[symlinks]}"       == "on" ]] && install_symlinks
[[ "${SELECTED[alacritty_themes]}" == "on" ]] && install_alacritty_themes
[[ "${SELECTED[mise]}"           == "on" ]] && install_mise
[[ "${SELECTED[rust_toolchain]}" == "on" ]] && install_rust_toolchain
[[ "${SELECTED[nvim_plugins]}"   == "on" ]] && install_nvim_plugins
[[ "${SELECTED[mkdp_build]}"     == "on" ]] && install_mkdp_build

# ---------------------------------------------------------------
# 完了メッセージ
# ---------------------------------------------------------------
echo ""
echo -e "${GREEN}${BOLD}==> セットアップ完了！${RESET}"
echo ""
echo "手動で必要な設定:"
echo "  1. Git ユーザー情報:"
echo "       git config --global user.name  'Your Name'"
echo "       git config --global user.email 'you@example.com'"
echo "  2. GCP 認証:"
echo "       Google Cloud SDK をインストール後: glogin"
echo "  3. GitHub CLI 認証:"
echo "       gh auth login"
echo "  4. dbt インストール:"
echo "       pip install dbt-bigquery"
echo "  5. Neovim を開いて :Mason で LSP ツールを確認"
