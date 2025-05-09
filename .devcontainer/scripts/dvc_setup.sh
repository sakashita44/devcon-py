#!/bin/bash
# DVCの初期化とリモートリポジトリ設定を行うスクリプト
# このスクリプトは、Dev ContainerのpostCreateCommandで実行されることを想定
# DVC自体はrequirements.txt経由でインストールされている前提
# jqコマンドがインストールされている必要がある

# スクリプトのエラーハンドリング
set -e  # エラーが発生した場合、スクリプトを終了します。

# スクリプトの説明
echo "DVCのセットアップを開始します..."

# jqコマンドの存在確認
if ! command -v jq &> /dev/null; then
    echo "エラー: jq コマンドが見つかりません。Dockerfileに jq のインストールを追加してください。"
    exit 1
fi

# DVCの初期化（既に初期化されている場合はスキップ）
if [ ! -d ".dvc" ]; then
    echo "DVCを初期化します..."
    dvc init --no-scm # Gitリポジトリは既に存在するため、--no-scmオプションを追加することが推奨される場合がある
    echo "DVCの初期化が完了しました。"
else
    echo "DVCは既に初期化されています。"
fi

# DVCリモートストレージの設定
DVC_CONFIG_FILE=".devcontainer/dvc.json"

if [ ! -f "$DVC_CONFIG_FILE" ]; then
    echo "警告: DVC設定ファイル ($DVC_CONFIG_FILE) が見つかりません。リモート設定をスキップします。"
    echo "DVC設定が完了しました。"
    exit 0
fi

REMOTE_NAME=$(jq -r '.remote.name' "$DVC_CONFIG_FILE")
REMOTE_URL=$(jq -r '.remote.url' "$DVC_CONFIG_FILE")

if [ -z "$REMOTE_NAME" ] || [ "$REMOTE_NAME" == "null" ] || [ -z "$REMOTE_URL" ] || [ "$REMOTE_URL" == "null" ]; then
    echo "警告: $DVC_CONFIG_FILE からDVCリモート名またはURLを読み取れませんでした。"
    echo "リモート名: '$REMOTE_NAME', リモートURL: '$REMOTE_URL'"
    echo "ファイルの内容を確認してください: $DVC_CONFIG_FILE"
    echo "例: { \"remote\": { \"name\": \"myremote\", \"url\": \"/path/to/remote\" } }"
elif [ "$REMOTE_URL" == "<your-remote-url>" ]; then
    echo "警告: DVCリモートURLがデフォルト値のままです。$DVC_CONFIG_FILE 内の remote.url を編集してください。"
else
    echo "DVCリモートを設定します: $REMOTE_NAME -> $REMOTE_URL"
    # 既存の同名リモートがある場合、上書きするためにまず削除を試みる
    dvc remote remove "$REMOTE_NAME" 2>/dev/null || true
    dvc remote add -d "$REMOTE_NAME" "$REMOTE_URL"
    echo "DVCリモートの設定が完了しました。"
fi

echo "DVC設定が完了しました。"
