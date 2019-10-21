#!/user/bin/env bash

set -e

echo ''
echo ''

echo "shell脚本本身的名字: $0"
# echo "传给shell的第一个参数: $1"

branch=$(git symbolic-ref --short HEAD)

echo "[publishing] now we are in $branch branch"

# SOURCE="$1"

# if [ "$SOURCE" == "github" ] ; then
#   echo "您要发布的npm包版本号： $SOURCE"
# elif [ "$SOURCE" == "server" ] ; then
#   echo "您要发布的npm包版本号： $SOURCE"
# else 
#   echo "[publishing error]"
#   exit 1
# fi

# hexo clean

# hexo g

# hexo d

echo "[publishing success] 已成功替换线上服务内容"

git add .

git commit -m "[publish]"

git push origin $branch

