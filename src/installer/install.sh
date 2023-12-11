#!/bin/bash

version=$(curl -s "https://ryota1207.github.io/toolbox.sh/src/installer/info/version.txt")
commands=$(curl -s "https://ryota1207.github.io/toolbox.sh/src/installer/info/commands.txt")
license=$(curl -s "https://ryota1207.github.io/toolbox.sh/src/installer/info/license.txt")


#初期表示
printf "
--------------------------------------------------------------
            [ toolbox.sh ]インストーラーへようこそ!!             
--------------------------------------------------------------
"


printf "
● 公開バージョン $version
● 搭載コマンド数 $commands
● 提供ライセンス $license

"

echo "このスクリプトを使用してtoolbox.shをインストールします。よろしいですか？ (y/n)"
read -r response
if [[ ! $response =~ ^[Yy]$ ]]; then
    echo "インストールを中止しました。"
    exit 1
fi

#実行ユーザーの確認
current_user=$(whoami)

#bin処理用の変数
bin=$(true)

#~/binの確認
if [ ! -d ~/bin ]; then
    echo "~/binファイルが存在しない為作成を行います。"
    mkdir ~/bin
    chmod 700 ~/bin
    chown $current_user:$current_user ~/bin
    export PATH=$PATH:~/bin
    bin=$(false)
fi


curl -s URL https://raw.githubusercontent.com/ryota1207/toolbox.sh/main/src/commands/digs > ~/bin/digs
chmod 700 ~/bin/digs
chown $current_user:$current_user ~/bin/digs
export PATH=$PATH:~/bin/digs

#.bashrcの確認
if [ -f ~/.bashrc ]; then
    echo ".bashrcが存在します"
    echo "export PATH=$PATH:~/bin/digs" >> ~/.bashrc
else
    echo ".bashrcが存在しません"
    echo "" > ~/.bashrc
    #~/binの確認
    if [ "$bin" == false ]; then
        echo "export PATH=$PATH:~/bin" >> ~/.bashrc
    fi
    echo "export PATH=$PATH:~/bin/digs" >> ~/.bashrc
    
fi