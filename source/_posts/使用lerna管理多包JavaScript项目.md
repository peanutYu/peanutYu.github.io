---
title: 使用lerna管理多包JavaScript项目
copyright: true
date: 2021-01-07 17:04:50
tags: [学习笔记, JavaScript, npm]
category: 学习笔记
---

> 最近由于业务架构的调整我从公司业务前端组调到中台前端组，今年开始拥抱变化在新的部门可以取得更好的结果;言归正传由于我们这边中台架构使用的是微应用架构体系，基础代码都是从[qiankun](https://github.com/umijs/qiankun)(**蚂蚁金服微应用体系架构**)源码fork出来跟着我们自己的业务来进行一些定制化改造的,随着库代码量慢慢增加之后，单个包的管理就显得比较麻烦，为了方便库代码的共享，需要将代码库拆分成独立的包，比如qiankun、qiankun-router、qiankun-config、qiankun-micro-app、qiankun-micro-main(**这里不暴露公司信息，统一以qiankun代替**)等包模块，于是我们就需要[lerna](https://github.com/lerna/lerna)来优化以及管理多包项目。

<!--more-->

# lerna入门
首先为了使用lerna，我们需要去全局安装lerna
> npm i -g lerna

或

> yarn global add lerna

lerna安装完之后，我们需要去创建一个简单的代码仓库并进入其中
> mkdir lerna-repo && cd lerna-repo

进入仓库后我们将该仓库转变为一个lerna仓库
> lerna init

现在你的代码仓库目前结构应该是这样的
>lerna-repo
├── lerna.json
├── package.json
└── packages

我们看到这个时候lerna在我们的项目仓库内自动生成packages文件夹和lerna.json,并在package.json文件中的devDependencies字段中生成lerna对应的依赖信息

# 命令

## lerna init

**lerna**管理项目的时候可以选择两种模式。默认的为固定模式（Fixed mode），当使用**lerna init**命令初始化项目时，就默认为固定模式，也可以手动输入命令**lerna init --independent/-i**来设置。固定模式中，packages下的所有包共用一个版本号，会自动将所有的包绑定到一个版本号上。所以任意一个包发生了更新，这个共用的版本号就会发生改变。而独立模式允许每一个包有自己独立的版本号，在使用lerna publish命令时，可以为每个包单独制定具体的操作，同时可以只更新某一个包的版本号。

```json
{
  "packages": [
    "packages/*"
  ],
  // 该版本号也就是lerna.json中的version字段
  // 独立模式下为"version": "independent"
  "version": "0.0.0"
}
```

## lerna create <name> [loc]

> 创建一个由lerna管理的包，name为包的名称，loc为可选内容表示包的位置。

```json
// 根目录的package.json
{
  "packages": [
    "packages/*",
    "packages/peanutYu/*",
  ],
}

// 创建一个包cli默认放在packages[0]所指位置
lerna create cli

// 创建一个包cli-util指定放在packages/peanutYu文件夹下，必须先在packages里先写入packages/peanutYu/*
lerna create cli-util packages/peanutYu
```

这里的话packages内的数组调换位置也是可以的，但是命令不额外增加loc的话，安装的位置默认就会使packages数组的第一个目录内。


## lerna add <package>[@version] [--dev] [--exact]

> 新增本地或远程的package作为当前项目内包的依赖

* --dev devDependencies 替代 dependencies
* --exact 安装准确版本，就是安装的包版本前面不带^

```
// 为所有 package 添加babel模块
lerna add babel
// 为cli-util 添加lodash模块
lerna add lodash --scope cli-util
// 新增模块内部之间的依赖
lerna add cli-util --scope cli
```

## lerna bootstrap

默认是使用npm install，我们也可以手动指定，例如
```
lerna bootstrap --npm-client=yarn
```

也可以在lerna.json内直接修改配置
```json
{
  "packages": [
    "packages/*",
    "packages/peanutYu/*",
  ],
  "npmClient": "yarn",
}
```
一样可以指定使用yarn来安装我们每个包所需要的依赖。

## lerna run 
```
lerna run < script > -- [..args] # 运行所有包里面的有这个script的命令
lerna run --scope cli-util test
```

## lerna exec
在每个包中运行我们的命令

```
lerna exec -- < command > [..args] # runs the command in all packages
lerna exec -- rm -rf ./node_modules
lerna exec --scope cli-util -- ls -la
```

## lerna link
项目包建立软链，类似npm link

## lerna clean
删除所有包的node_modules目录

## lerna changed
列出下次发版lerna publish 要更新的包。

原理：
需要先git add,git commit 提交。
然后内部会运行git diff --name-only v版本号 ，搜集改动的包，就是下次要发布的。

## lerna publish
会打tag，上传git,上传npm。
如果你的包名是带scope的例如："name": "@gp0320/gpwebpack",
那需要在packages.json添加

```json
"publishConfig": {
  "access": "public"
},
```