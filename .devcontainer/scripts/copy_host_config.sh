#!/bin/bash

# DevContainerのホスト側の設定をコンテナ内のユーザにコピーするスクリプト
# このスクリプトは, ホスト側の .gitconfig と .ssh ディレクトリをコンテナ内の指定されたユーザにコピーする
# これにより, コンテナ内でのGit操作やSSH接続でホスト側の設定を利用できるようになる

set -e

TARGET_USER=$1
TARGET_USER_HOME="/home/$TARGET_USER"

echo "Copying host .gitconfig and .ssh configuration for user $TARGET_USER..."

# Copy .gitconfig
if [ -f /tmp/.host-gitconfig ]; then
    echo "Copying .gitconfig..."
    cp /tmp/.host-gitconfig "$TARGET_USER_HOME/.gitconfig"
    chown "$TARGET_USER:$TARGET_USER" "$TARGET_USER_HOME/.gitconfig"
    chmod 644 "$TARGET_USER_HOME/.gitconfig"
    echo ".gitconfig copied."
else
    echo "Host .gitconfig not found at /tmp/.host-gitconfig or is not a file, skipping."
fi

# Copy .ssh directory
if [ -d /tmp/.host-ssh ] && [ -n "$(ls -A /tmp/.host-ssh)" ]; then
    echo "Copying .ssh directory..."
    mkdir -p "$TARGET_USER_HOME/.ssh"
    # -T オプションは cp が /tmp/.host-ssh をディレクトリとして扱うことを保証
    cp -R -T /tmp/.host-ssh "$TARGET_USER_HOME/.ssh/"
    chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_USER_HOME/.ssh"
    chmod 700 "$TARGET_USER_HOME/.ssh"
    find "$TARGET_USER_HOME/.ssh" -type f -exec chmod 600 {} \;
    # known_hosts と config は 644 でも可
    if [ -f "$TARGET_USER_HOME/.ssh/config" ]; then
        chmod 644 "$TARGET_USER_HOME/.ssh/config"
    fi
    if [ -f "$TARGET_USER_HOME/.ssh/known_hosts" ]; then
        chmod 644 "$TARGET_USER_HOME/.ssh/known_hosts"
    fi
    echo ".ssh directory copied and permissions set."
else
    echo "Host .ssh directory not found at /tmp/.host-ssh, is not a directory, or is empty, skipping."
fi

echo "Host configuration copy process finished."
