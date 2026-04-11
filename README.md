# dotfiles

macOS 開発環境の設定ファイル一式。新しい Mac でも `make mac` 一発で同じ環境を再現できる。

## 構成

```
dotfiles/
├── mac/
│   ├── install.sh          # セットアップスクリプト (make mac で実行)
│   ├── Brewfile            # Homebrew パッケージ一覧
│   ├── .zshrc              # Zsh 設定
│   ├── .zprofile           # Zsh プロファイル
│   └── .config/
│       ├── alacritty/      # ターミナルエミュレーター設定
│       ├── zellij/         # ターミナルマルチプレクサー設定
│       ├── nvim/           # Neovim (LazyVim) 設定
│       ├── starship.toml   # プロンプト設定
│       ├── mise/           # 言語バージョン管理設定
│       └── git/            # Git グローバル設定
└── ubuntu/                 # Ubuntu 用設定 (別途)
```

## セットアップ手順

### 前提条件

- macOS (Apple Silicon)
- インターネット接続
- Xcode Command Line Tools: `xcode-select --install`

### 1. リポジトリをクローン

```bash
git clone https://github.com/<your-username>/dotfiles.git ~/codes/dotfiles
cd ~/codes/dotfiles
```

### 2. セットアップ実行

```bash
make mac
```

インタラクティブなメニューが表示され、インストールする項目を選択できる。

| キー | 操作 |
|---|---|
| `j` / `k` または ↑↓ | カーソル移動 |
| `Space` | 項目の on/off 切替 |
| `a` | 全選択 |
| `n` | 全解除 |
| `Enter` | 決定して実行 |

全項目を選択してスキップしたい場合（CI・自動化向け）:

```bash
cd mac && bash install.sh --all
```

選択できる項目:

| 項目 | 内容 |
|---|---|
| Homebrew + Brewfile | 未インストールの場合のみ Homebrew を導入し、Brewfile の全パッケージをインストール |
| シンボリックリンク | dotfiles → `~/.config/` および `~/` にリンクを作成 |
| Alacritty テーマ集 | `~/.config/alacritty/themes/` にクローン |
| mise 言語ランタイム | Node 20 / Rust latest / Python をインストール |
| Rust toolchain | `rust-analyzer`, `rustfmt`, `clippy` を追加 |
| Neovim プラグイン | LazyVim プラグインを headless でインストール |
| markdown-preview ビルド | `npm install` で依存関係をインストール |

### 3. 手動設定 (スクリプト後に実施)

#### Git ユーザー情報

```bash
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"
```

#### Google Cloud SDK

1. [公式サイト](https://cloud.google.com/sdk/docs/install) からインストーラーをダウンロードして `~/Downloads/` に展開
2. 認証:

```bash
glogin
```

#### GitHub CLI

```bash
gh auth login
```

#### dbt

```bash
# BigQuery の場合
pip install dbt-bigquery

# dbt プロジェクトのルートに .sqlfluff を配置
# [sqlfluff]
# dialect = bigquery
# templater = dbt
```

#### sqls (DB接続設定)

```bash
mkdir -p ~/.config/sqls
# ~/.config/sqls/config.yml に接続情報を記述
```

#### Neovim LSP ツール確認

Neovim を起動して `:Mason` を開き、以下がインストールされているか確認:

- `basedpyright` (Python LSP)
- `ruff` (Python formatter/linter)
- `debugpy` (Python DAP)
- `codelldb` (Rust DAP)
- `sqls` (SQL LSP)
- `sqlfluff` (SQL formatter)
- `yaml-language-server` (YAML LSP)

## インストールされるもの

### CLI ツール

| ツール | 用途 |
|---|---|
| `git`, `gh` | バージョン管理 / GitHub CLI |
| `mise` | 言語バージョン管理 (Node, Rust, Python) |
| `neovim` | エディター |
| `starship` | シェルプロンプト |
| `zellij` | ターミナルマルチプレクサー |
| `terraform` | インフラ管理 |
| `uv` | Python パッケージマネージャー |
| `mysql-client` | MySQL クライアント |
| `laminate` | コードスクリーンショット |
| `silicon` (cargo) | コードスクリーンショット |

### アプリ (cask)

| アプリ | 用途 |
|---|---|
| Alacritty | GPU ターミナルエミュレーター |
| FiraCode Nerd Font | 開発用フォント |
| Visual Studio Code | エディター (サブ) |

### Neovim 環境 (LazyVim ベース)

| 機能 | ツール |
|---|---|
| Python LSP / lint / format | basedpyright / ruff |
| Python デバッグ | nvim-dap + debugpy |
| Rust LSP / format | rust-analyzer (rustaceanvim) / rustfmt |
| Rust デバッグ | nvim-dap + codelldb |
| SQL LSP / format | sqls / sqlfluff |
| YAML LSP / schema | yamlls + SchemaStore |
| DB ブラウザ | vim-dadbod-ui |
| テスト実行 | neotest (python + rust) |
| Markdown プレビュー | markdown-preview.nvim (mermaid 対応) |
| Markdown レンダリング | render-markdown.nvim |

## キーマップ早見表 (Neovim)

### デバッグ `<leader>d`

| キー | アクション |
|---|---|
| `<leader>db` | ブレークポイント toggle |
| `<leader>dc` | デバッグ開始 / Continue |
| `<leader>di` / `do` / `dO` | Step into / out / over |
| `<leader>dt` | デバッグ終了 |
| `<leader>du` | DAP UI toggle |

### テスト `<leader>t`

| キー | アクション |
|---|---|
| `<leader>tt` | 最近傍テスト実行 |
| `<leader>tT` | ファイル全テスト |
| `<leader>td` | DAP でテストデバッグ |
| `<leader>ts` | Summary パネル |
| `]t` / `[t` | 失敗テスト間ジャンプ |

### データベース `<leader>D`

| キー | アクション |
|---|---|
| `<leader>Du` | DB UI toggle |

### Markdown `<leader>m`

| キー | アクション |
|---|---|
| `<leader>mp` | ブラウザプレビュー |
| `<leader>mf` | フォーマット |
| `<leader>tm` | テーブル整形 toggle |
| `<leader>um` | Neovim 内レンダリング toggle |

## dotfiles の更新

設定を変更した場合はこのリポジトリに反映してコミットする。
シンボリックリンク経由のため、`~/.config/nvim/` を直接編集するとリポジトリにも即時反映される。

```bash
cd ~/codes/dotfiles
git add -p
git commit -m "Update config"
git push
```
