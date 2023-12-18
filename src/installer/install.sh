#!/bin/bash

####関数
#レスポンスエラー判定関数
check_response_status() {

    # ステータスコードの取得
    status=$(curl -o /dev/null -w '%{http_code}\n' -s "$1")

    # ステータスコードが200系でない場合はエラー
    if [[ ! "$status" =~ ^2[0-9][0-9]$ ]]; then
        printf "\n■■${RED}[エラー]${NC}\n■■GitHabリポジトリからの情報の取得に失敗しました。\n■■詳細は公式ドキュメントをご確認をよろしくお願い致します。\n"
        exit 1
    fi
}

#bin処理用の変数
bin=$(true)

#binのパス設定関数
setting_bin_path() {
    bin="$1"
    # ~/binの確認
    if [ "$bin" == "false" ]; then
        echo "export PATH=\$PATH:~/bin" >> ~/.bashrc
    fi
}

RED='\033[0;31m'
Yellow='\033[0;33m'
NC='\033[0m'


#初期表示
printf "
--------------------------------------------------------------
            [ toolbox.sh ]インストーラーへようこそ!!             
--------------------------------------------------------------

"

# バージョンの選択肢
options=("beta(試験リリース版)" "main(開発版)" "キャンセル")

# プロンプト表示文字
PS3=$'\nインストールバージョンをご選択下さい: '

select opt in "${options[@]}"; do
    case $opt in
        "beta(試験リリース版)")
            printf "\n■■${Yellow}[システム]${NC}\n■■beta(試験リリース版)バージョンが選択されました。\n■■GitHabリポジトリより最新情報を取得します。\n\n"
            select_version="beta"
            break
            ;;
        "main(開発版)")
            printf "\n■■${Yellow}[システム]${NC}\n■■main(開発版)バージョンが選択されました。\n■■GitHabリポジトリより最新情報を取得します。\n\n"
            select_version="main"
            break
            ;;
        "キャンセル")
            printf "\n■■${Yellow}[システム]${NC}\n■■キャンセルが選択されました。インストールを中止します。\n\n"
            exit 1
            ;;
        *) # 不正な値
            printf "\n■■${RED}[エラー]${NC}\n■■指定外の値です。選択項目よりお選び下さい。\n\n"
            ;;
    esac
done


#リリースバージョン情報の取得
githab_url="https://raw.githubusercontent.com/ryota1207/toolbox.sh/"

version_url="${githab_url}${select_version}/src/installer/info/version.txt"
version=$(curl -s "${version_url}")
check_response_status "${version_url}"

commands_url="${githab_url}${select_version}/src/installer/info/commands.txt"
commands=$(curl -s "${commands_url}")
check_response_status "${commands_url}"

license_url="${githab_url}${select_version}/src/installer/info/license.txt"
license=$(curl -s "${license_url}")
check_response_status "${license_url}"


printf "
● 公開バージョン $version
● 搭載コマンド数 $commands
● 提供ライセンス $license

"

echo "上記の内容でtoolbox.shをインストールします。よろしいですか？ (y/n)"
read -r response
if [[ ! $response =~ ^[Yy]$ ]]; then
    printf "\n■■${Yellow}[システム]${NC}\n■■キャンセルが選択されました。インストールを中止します。\n\n"
    exit 1
fi


#実行ユーザー格納変数
current_user=$(whoami)


#~/binの確認
if [ ! -d ~/bin ]; then
    printf "\n■■${Yellow}[システム]${NC}\n■■~/binファイルが存在しない為、システムにて作成を行います。\n\n"
    mkdir ~/bin
    chmod 700 ~/bin
    chown $current_user:$current_user ~/bin
fi

#~/binのパス確認
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  export PATH=$PATH:~/bin
  bin=false
fi


#/bin/toolboxの作成
printf "\n■■${Yellow}[システム]${NC}\n■■~/binファイル配下にtoolboxディレクトリを作成します。\n\n"

mkdir ~/bin/toolbox
export PATH=$PATH:~/bin/toolbox


#コマンドの設置
curl -s URL https://raw.githubusercontent.com/ryota1207/toolbox.sh/main/src/commands/digs > ~/bin/toolbox/digs
export PATH=$PATH:~/bin/toolbox/digs

#所有者、権限の変更
chmod -R 700 ~/bin/toolbox
chown $current_user:$current_user ~/bin/toolbox


#.bashrcの確認
if [ -f ~/.bashrc ]; then
    echo ".bashrcが存在します"

    #binのパスチェック
    setting_bin_path "$bin"

    #コマンドパスの追加
    echo "export PATH=\$PATH:~/bin/toolbox" >> ~/.bashrc
    echo "export PATH=\$PATH:~/bin/toolbox/digs" >> ~/.bashrc

else
    printf "\n■■${Yellow}[システム]${NC}\n■■~/.bashrcファイルが存在しない為、システムにて作成を行います。\n\n"
    echo "" > ~/.bashrc

    #binのパスチェック
    setting_bin_path "$bin"

    #コマンドパスの追加
    echo "export PATH=\$PATH:~/bin/toolbox" >> ~/.bashrc
    echo "export PATH=\$PATH:~/bin/toolbox/digs" >> ~/.bashrc
    
fi