# my-py-container

個人用のPython-JupyterNotebook開発環境 (VS Code & Dev Container 前提) のテンプレート

## 注意

以下の内容およびスクリプト等はおよそ殆どAIにより生成されたものです.
内容の正確性や適切性については保証しませんので, 参考程度にしてください.

このリポジトリは個人用の開発環境テンプレートです.
開発者は一切の責任を負いませんので, 自己責任でご利用ください.

特に, `postCreateCommand.sh` で実行される`git_setup.sh` スクリプトは, ホストマシンの `.gitconfig` や `.ssh` ディレクトリをコンテナにコピーします.
この機能は各自の判断で利用してください.

また, `devcontainer.json` には個人的に使用しているVS Codeの拡張機能や設定が含まれています.
必要に応じて編集してください.

## How to use

このテンプレートを使用して新しい開発環境をセットアップするための手順.

### 前提

* VS Code がインストールされていること
    * Dev Container 拡張機能がインストールされていること
* Docker がインストールされていること

### 手順

1. **リポジトリの作成**
    1. このリポジトリをテンプレートとして新しいリポジトリを GitHub 上に作成する.
    1. または、このリポジトリをクローンした後、`.git` ディレクトリを削除して新しいリポジトリとして初期化する.

1. **必須の設定変更**
    1. `.devcontainer/devcontainer.json` を開く.
        * `name` プロパティをあなたのプロジェクト名に変更する (例: `"My Analysis Project"`) .
    1. `.devcontainer/dvc.json` を開く (DVC を使用する場合).
        * `remote.url` をあなたの DVC リモートストレージの URL に変更する (例: `s3://my-bucket/my-project-dvc`, `/path/to/local/remote`).
        * 必要に応じて `remote.name` も変更する.
    1. `.devcontainer/requirements.txt` を開く.
        * プロジェクトに必要な Python パッケージをリストに追加または編集する.

1. **オプションの設定変更 (必要に応じて)**
    1. `.devcontainer/devcontainer.json`:
        * `extensions` プロパティに必要な VS Code 拡張機能を追加する.
        * `settings` プロパティに必要な VS Code の設定を追加する.
        * `postCreateCommand` プロパティにコンテナ作成後に実行したいコマンドを追加する.
    1. `.devcontainer/Dockerfile`: 追加のシステムパッケージのインストールや環境変数の設定など、Docker イメージのカスタマイズが必要な場合に編集する.
    1. `.devcontainer/scripts/`: 以下のスクリプトはコンテナ作成時に自動実行される. デフォルト設定で多くの場合機能するが、特定の要件がある場合は内容を確認し、カスタマイズする. 各スクリプトの詳細はファイル内のコメントを参照.
        * `postCreateCommand.sh`: 他のセットアップスクリプトを呼び出すメインスクリプト.
        * `git_setup.sh`: ホストマシンの Git や SSH の設定をコンテナ内にコピーする.
        * `dvc_setup.sh`: DVC の初期化とリモート設定を行う.
        * `nbstripout_setup.sh`: Jupyter Notebook の出力セルを Git コミット前に自動除去する `nbstripout` を設定する.
    1. `.github/`: GitHub Actions のワークフローや Issue テンプレートなどをプロジェクトに合わせて編集する.
        * `copilot_instructions.md`: GitHub Copilot への指示をカスタマイズする場合に編集する.
    1. `.gitignore`, `.gitattributes`: プロジェクトの特定の要件に合わせて編集する.

1. **開発開始**
    1. VS Code でリポジトリのフォルダを開く.
    1. VS Code が Dev Container で再度開くことを提案したら、承認する (またはコマンドパレットから `Dev Containers: Reopen in Container` を実行).
    1. Dev Container がビルドされ、起動したら開発を開始できる.
    1. コンテナ初回起動時、または開発中に新しい Python パッケージをインストールした際は、意図しない依存関係の解決によるバージョンの差異を防ぎ、環境の再現性をより厳密に確保するために、以下のコマンドを実行して `.devcontainer/requirements.txt` を実際にインストールされたパッケージのバージョンで更新することを推奨する。これにより、環境の再現性が保たれる。

        ```bash
        pip freeze > .devcontainer/requirements.txt
        ```

## 構成

リポジトリの主要なファイルとディレクトリの構成.

```text
./
├── .devcontainer/
│   ├── devcontainer.json      # Dev Container 設定 (コンテナ名, 拡張機能, etc.)
│   ├── .env                   # 環境変数設定
│   ├── Dockerfile             # Docker イメージ定義
│   ├── dvc.json               # DVCリモートストレージ設定
│   ├── requirements.txt       # Python パッケージリスト
│   └── scripts/               # コンテナ初期化用スクリプト群
│       ├── git_setup.sh
│       ├── postCreateCommand.sh
│       ├── dvc_setup.sh
│       └── nbstripout_setup.sh
├── .github/                   # GitHub 関連設定 (Actions, Issue Templates, etc.)
│   ├── copilot_instructions.md
│   └── ISSUE_TEMPLATE/
│       ├── fix.yml
│       ├── todo.yml
│       └── idea.yml
├── .gitattributes             # Git属性 (nbstripout設定など)
├── .gitignore                 # Git無視ファイルリスト
├── LICENSE
└── README.md                  # このファイル
```

## 各ファイルの概要説明

各設定ファイルと主要スクリプトの簡単な説明. 詳細な設定や動作については、各ファイル内のコメントを参照すること.

### `.devcontainer/devcontainer.json`

Dev Container の主要な設定ファイル. コンテナ名, 使用する Dockerfile, VS Code 拡張機能, VS Code の設定, コンテナ起動後のコマンドなどを定義する.

**利用開始時に `name` 他, 必要な部分を編集すること.**

### `.devcontainer/.env`

Dev Container 内で使用する環境変数を定義するファイル. `.env` ファイルに記述された環境変数は, Dev Container 内で自動的に読み込まれる. 初期状態では空のファイル. git追跡対象外.

**必要に応じて環境変数を追加すること.**

### `.devcontainer/Dockerfile`

Dev Container で使用する Docker イメージをビルドするための指示書. ベースとなる Python イメージ, 環境変数, OS パッケージのインストール, Python パッケージのインストールなどを定義する.

**必要に応じてカスタマイズする.**

### `.devcontainer/dvc.json`

DVC (Data Version Control) のリモートストレージ設定を記述する JSON ファイル. `dvc_setup.sh` スクリプトがこのファイルを読み込み, DVC のリモート設定を行う.

**DVC を利用する場合は `remote.url` を自身の環境に合わせて編集すること.**

### `.devcontainer/requirements.txt`

プロジェクトで使用する Python パッケージのリスト. `pip install -r requirements.txt` コマンドでインストールされる.

**プロジェクトに必要なパッケージをここに記述する.**

### `.devcontainer/scripts/postCreateCommand.sh`

Dev Container の初回ビルド後 (コンテナ作成後) に一度だけ実行されるメインのセットアップスクリプト. `devcontainer.json` の `postCreateCommand` から呼び出される. このスクリプト内で, `git_setup.sh`, `dvc_setup.sh`, `nbstripout_setup.sh` などの個別のセットアップスクリプトを呼び出す.

**詳細はスクリプト内のコメントを参照.**

### `.devcontainer/scripts/git_setup.sh`

ホストマシンの `.gitconfig` ファイルと `.ssh` ディレクトリの内容を, Dev Container 内のユーザーのホームディレクトリにコピーし, 適切なパーミッションを設定するスクリプト. これにより, ホストマシンの Git 設定や SSH 鍵を Dev Container 内で利用できるようにする. `postCreateCommand.sh` から呼び出される.

**注意: SSH 鍵のセキュリティに注意し, 必要な場合のみ実行すること.**

**詳細はスクリプト内のコメントを参照.**

### `.devcontainer/scripts/dvc_setup.sh`

DVC (Data Version Control) の初期化 (`dvc init`) とリモートストレージの設定を行うスクリプト. リモートストレージの情報は `.devcontainer/dvc.json` ファイルから読み込まれる. `postCreateCommand.sh` から呼び出される.

**詳細はスクリプト内のコメントを参照.**

### `.devcontainer/scripts/nbstripout_setup.sh`

Jupyter Notebook の出力セル除去ツール `nbstripout` のための Git config 設定を行うスクリプト. `nbstripout`のインストールされていないホストでも動作するよう, コンテナのglobal設定を変更している. `postCreateCommand.sh` から呼び出される.

**詳細はスクリプト内のコメントを参照.**

### `.gitattributes`

Git リポジトリ内のファイルパスに対して属性を指定するためのファイル. このテンプレートでは、主に `nbstripout` の設定が記述されており, Jupyter Notebook ファイルの出力をコミットに含めないようにする.

**通常は編集不要.**
