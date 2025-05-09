#!/bin/bash
# 各種setupスクリプトをまとめて実行するスクリプト
# dev containerのpostCreateCommandで実行される

set -e # いずれかのコマンドがエラーになった場合, 直ちにスクリプトを終了

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_USER=$1 # 最初の引数としてコンテナユーザー名を受け取る

echo "--- Starting container post-creation setup for user: $TARGET_USER ---"

# copy_host_config.sh の実行
echo "[postCreateCommand] Running copy_host_config.sh..."
if [ -f "${SCRIPT_DIR}/copy_host_config.sh" ]; then
    # postCreateCommand.sh は devcontainer.json の postCreateCommand で sudo により root 権限で実行される
    # copy_host_config.sh は内部で chown などを行うため、それ自体が root 権限を必要とするか、
    # または sudo を内部で使用する設計であるべきだが、現在の copy_host_config.sh は
    # 渡されたユーザーに対してファイルの所有権を変更するため、root権限で実行される必要がある.
    # ここでは postCreateCommand.sh が既に root で動いているので、そのまま実行する.
    bash "${SCRIPT_DIR}/copy_host_config.sh" "$TARGET_USER"
    echo "[postCreateCommand] copy_host_config.sh finished."

    # dvc_setup.sh の実行
    echo "[postCreateCommand] Running dvc_setup.sh..."
    if [ -f "${SCRIPT_DIR}/dvc_setup.sh" ]; then
        sudo -u "$TARGET_USER" bash "${SCRIPT_DIR}/dvc_setup.sh"
        echo "[postCreateCommand] dvc_setup.sh finished."
    else
        echo "[postCreateCommand] Warning: dvc_setup.sh not found at ${SCRIPT_DIR}/dvc_setup.sh."
    fi

    # nbstripout_setup.sh の実行
    echo "[postCreateCommand] Running nbstripout_setup.sh..."
    if [ -f "${SCRIPT_DIR}/nbstripout_setup.sh" ]; then
        sudo -u "$TARGET_USER" bash "${SCRIPT_DIR}/nbstripout_setup.sh"
        echo "[postCreateCommand] nbstripout_setup.sh finished."
    else
        echo "[postCreateCommand] Warning: nbstripout_setup.sh not found at ${SCRIPT_DIR}/nbstripout_setup.sh."
    fi
else
    echo "[postCreateCommand] Warning: copy_host_config.sh not found at ${SCRIPT_DIR}/copy_host_config.sh."
fi

# 他のセットアップスクリプトがあればここに追加して呼び出す
# 通常、ユーザー固有の設定やツールインストールは $TARGET_USER で実行する.
# root権限が必要な場合は、`sudo -u "$TARGET_USER"` を付けずに直接 `bash your_script.sh` で実行する
# (この postCreateCommand.sh 自体が root で実行されているため).
#
# 例: (ユーザーレベルで実行する場合)
# echo "[postCreateCommand] Running another_user_setup.sh for user $TARGET_USER..."
# if [ -f "${SCRIPT_DIR}/another_user_setup.sh" ]; then
#     sudo -u "$TARGET_USER" bash "${SCRIPT_DIR}/another_user_setup.sh"
#     echo "[postCreateCommand] another_user_setup.sh finished for user $TARGET_USER."
# else
#     echo "[postCreateCommand] Warning: another_user_setup.sh not found."
# fi
#
# 例: (rootレベルで実行する場合)
# echo "[postCreateCommand] Running another_root_setup.sh as root..."
# if [ -f "${SCRIPT_DIR}/another_root_setup.sh" ]; then
#     bash "${SCRIPT_DIR}/another_root_setup.sh"
#     echo "[postCreateCommand] another_root_setup.sh finished as root."
# else
#     echo "[postCreateCommand] Warning: another_root_setup.sh not found."
# fi

echo "--- Container post-creation setup finished ---"
