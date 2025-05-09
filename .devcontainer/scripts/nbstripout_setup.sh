#!/bin/bash
# nbstripoutをgitにフックし、Jupyter Notebookの出力をコミット前に自動的に除去するための設定を行うスクリプト
# ホスト側での実行は想定していない
set -e

echo "Setting up nbstripout for Git hooks..."

# nbstripoutがインストールされていることを確認
# requirements.txtでインストールされる想定だが、念のため確認
if ! command -v nbstripout &> /dev/null; then
    echo "nbstripoutがインストールされていません。pip install nbstripout でインストールしてください。"
    exit 1
fi

# Gitの設定を行う
git config --global filter.nbstripout.clean nbstripout
git config --global filter.nbstripout.smudge cat
git config --global filter.nbstripout.required true
git config --global diff.ipynb.textconv "nbstripout -t"

echo "nbstripout Git config setup completed successfully."
echo "Ensure .gitattributes file is present in the repository root with nbstripout configurations."
