# ベースイメージの指定
### 要件に応じてPythonのバージョンを変更
FROM python:3.12-slim

# 環境変数の設定
ENV LANG=ja_JP.UTF-8 \
    LC_ALL=ja_JP.UTF-8 \
    TZ=Asia/Tokyo \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# rootではなく、非rootユーザーで実行するための設定
# ユーザーの作成
ARG USERNAME=pyuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
# ユーザーの切り替え
USER $USERNAME

# 作業ディレクトリの設定
WORKDIR /workspace

# 必要なパッケージのインストール
### 要件に応じてパッケージを変更
### パッケージ情報 ###
# - bash-completion: Bashの補完機能
# - build-essential: C/C++コンパイラやビルドツール
# - curl: データ転送ツール
# - git: Gitリポジトリのクローンや管理
# - graphviz: グラフ描画ツール
# - libatlas-base-dev: 数値計算ライブラリ
# - locales: ロケール設定ツール (日本語環境のため追加)
# - openssh-client: SSHクライアント
# - jq: JSONプロセッサ (dvc_setup.shで使用)
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash-completion \
    build-essential \
    curl \
    git \
    graphviz \
    libatlas-base-dev \
    locales \
    openssh-client \
    jq \
    && localedef -f UTF-8 -i ja_JP ja_JP.UTF-8 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# bash-completionの設定
RUN echo '\n# Enable bash-completion\nif [ -f /usr/share/bash-completion/bash_completion ]; then\n  . /usr/share/bash-completion/bash_completion\nelif [ -f /etc/bash_completion ]; then\n  . /etc/bash_completion\nfi' >> /home/$USERNAME/.bashrc

# Python関連パッケージのインストール
### 要件に応じて.devcontainer/requirements.txtを変更
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# 作業ディレクトリ
### コンテナ内の作業ディレクトリを指定 要件に応じて変更
WORKDIR /workspace

# コンテナ起動時のコマンド設定
CMD ["/bin/bash"]
