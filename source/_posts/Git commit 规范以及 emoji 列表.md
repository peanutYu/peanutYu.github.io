---
title: Git Commit 规范以及 emoji 列表
date: 2019-04-10 16:19:42
tags: [Git,实战经验] 
categories: Git
copyright: true
# description: 
---
<!-- # Git 版本规范 -->
# 分支

* **master**分支为主分支（保护分支），不能直接在master上进行修改代码或提交,通过**MR**(merge Request)或者**PR**(pull Request)的方式进行提交。
* **preview**分支为预发分支， 所有测试完成需要上线的功能合并到该分支
* **develop、 test**分支为测试分支，所有开发完成需要提交测试的功能合并到该分支
* **feature/xxx**分支为功能开发分支，根据不同需求创建独立的功能分支，开发完成后合并到develop或test分支
* **hotfix**分支为bug修复分支，需要根据实际情况对已发布的版本进行漏洞修复

<!--more-->

# Tag

## 采用三段式，v版本.里程碑.序号，例如**v1.0.0**

* 架构升级或架构重大调整，修改第1位
* 新功能上线或者模块大的调整，修改第2位
* bug修复上线，修改第3位


# Commit message的格式
每次提交，Commit message 都包括三个部分：header，body 和 footer。

```
<type>(<scope>): <subject>
// 空一行
<body>
// 空一行
<footer>
```

其中，Header 是必需的，Body 和 Footer 可以省略。
不管是哪一个部分，任何一行都不得超过72个字符（或100个字符）。这是为了避免自动换行影响美观。

## Header
Header部分只有一行，包括三个字段：**type**（必需）、**scope**（可选）和**subject**（必需）。

  1. type
**type**用于说明 commit 的类别，只允许使用下面7个标识。
* feat：新功能（feature）
* fix：修补bug
* docs：文档（documentation）
* style： 格式（不影响代码运行的变动）
* refactor：重构（即不是新增功能，也不是修改bug的代码变动）
* test：增加测试
* chore：构建过程或辅助工具的变动
如果type为feat和fix，则该 commit 将肯定出现在 Change log 之中。其他情况（docs、chore、style、refactor、test）由你决定，要不要放入 Change log，建议是不要。
  2. scope
  **scope**用于说明 commit 影响的范围，比如数据层、控制层、视图层等等，视项目不同而不同。
  3. subject
  **subject**是 commit 目的的简短描述，不超过50个字符。
  * 以动词开头，使用第一人称现在时，比如change，而不是changed或changes
  * 第一个字母小写
  * 结尾不加句号（.）

## Body
Body 部分是对本次 commit 的详细描述，可以分成多行。下面是一个范例。
```
More detailed explanatory text, if necessary.  Wrap it to 
about 72 characters or so. 

Further paragraphs come after blank lines.

- Bullet points are okay, too
- Use a hanging indent
```
有两个注意点。
（1）使用第一人称现在时，比如使用**change**而不是**changed**或**changes**。
（2）应该说明代码变动的动机，以及与以前行为的对比。

## Footer
Footer 部分只用于两种情况。
 1. 不兼容变动
  如果当前代码与上一个版本不兼容，则 Footer 部分以***BREAKING CHANGE***开头，后面是对变动的描述、以及变动理由和迁移方法。
  ```
  BREAKING CHANGE: isolate scope bindings definition has changed.
      To migrate the code follow the example below:

      Before:

      scope: {
        myAttr: 'attribute',
      }

      After:

      scope: {
        myAttr: '@',
      }

      The removed `inject` wasn't generaly useful for directives so there should be no code using it
  ```
 2. 关闭 Issue
 如果当前 commit 针对某个issue，那么可以在 Footer 部分关闭这个 issue 。
 ```
 Closes #234
 ```

## Revert
还有一种特殊情况，如果当前 commit 用于撤销以前的 commit，则必须以**revert:**开头，后面跟着被撤销 Commit 的 Header。
```
revert: feat(pencil): add 'graphiteWidth' option

This reverts commit 667ecc1654a317a13331b17617d973392f415f02.
```

Body部分的格式是固定的，必须写成**This reverts commit &lt;hash>.**，其中的**hash**是被撤销 commit 的 SHA 标识符。

如果当前 commit 与被撤销的 commit，在同一个发布（release）里面，那么它们都不会出现在 Change log 里面。如果两者在不同的发布，那么当前 commit，会出现在 Change log 的**Reverts**小标题下面。

# Commitizen

[Commitizen](https://github.com/commitizen/cz-cli)是一个撰写合格 Commit message 的工具。

安装命令如下。

```
$ npm install -g commitizen
```

然后，在项目目录里，运行下面的命令，使其支持 Angular 的 Commit message 格式。

```
$ commitizen init cz-conventional-changelog --save --save-exact
```

以后，凡是用到**git commit**命令，一律改为使用**git cz**。这时，就会出现选项，用来生成符合格式的 Commit message。

![terminal](/uploads/Git commit 规范以及 emoji 列表/terminal.png)


# validate-commit-msg

[validate-commit-msg](https://github.com/conventional-changelog-archived-repos/validate-commit-msg) 用于检查 Node 项目的 Commit message 是否符合格式。

它的安装是手动的。首先，拷贝下面这个JS文件，放入你的代码库。文件名可以取为**validate-commit-msg.js**。

接着，把这个脚本加入 Git 的 hook。下面是在**package.json**里面使用 ghooks，把这个脚本加为**commit-msg**时运行。

```
  "config": {
    "ghooks": {
      "commit-msg": "./validate-commit-msg.js"
    }
  }
```

然后，每次**git commit**的时候，这个脚本就会自动检查 Commit message 是否合格。如果不合格，就会报错。

```
$ git add -A 
$ git commit -m "edit markdown" 
INVALID COMMIT MSG: does not match "<type>(<scope>): <subject>" ! was: edit markdown
```

# 生成 Change log

如果你的所有 Commit 都符合 Angular 格式，那么发布新版本时， Change log 就可以用脚本自动生成

生成的文档包括以下三个部分。

* New features
* Bug fixes
* Breaking changes.

每个部分都会罗列相关的 commit ，并且有指向这些 commit 的链接。当然，生成的文档允许手动修改，所以发布前，你还可以添加其他内容。

[conventional-changelog](https://github.com/conventional-changelog/conventional-changelog) 就是生成 Change log 的工具，运行下面的命令即可。

```
$ npm install -g conventional-changelog
$ cd my-project
$ conventional-changelog -p angular -i CHANGELOG.md -w
```

上面命令不会覆盖以前的 Change log，只会在**CHANGELOG.md**的头部加上自从上次发布以来的变动。

如果你想生成所有发布的 Change log，要改为运行下面的命令。

```
$ conventional-changelog -p angular -i CHANGELOG.md -w -r 0
```

为了方便使用，可以将其写入**package.json**的**scripts**字段。

```
{
  "scripts": {
    "changelog": "conventional-changelog -p angular -i CHANGELOG.md -w -r 0"
  }
}
```
以后，直接运行下面的命令即可。
```
$ npm run changelog
```

# git commit中使用emoji

## emoji规范格式
**git commit** 时，提交信息遵循以下格式：
```
:emoji1: :emoji2: 主题

提交信息主体

Ref <###>
```

初次提交示例：
```
git commit -m ":tada: Initialize Repo"
```
## emoji指南

| emoji | emoji代码 | Commit说明 |
|---|---|---|
| 🎨 (调色板)| :art: | 改进代码结构/代码格式 |
| ⚡️ (闪电) | :zap: | 提升性能 |
| 🐎 (赛马) | :racehorse: | 提升性能 |
|🔥 (火焰) | :fire: | 移除代码或文件 |
| 🐛 (bug) | :bug: | 修复 bug |
| 🚑 (急救车) | :ambulance: | 重要补丁 |
| ✨ (火花) | :sparkles: | 引入新功能 |
| 📝 (铅笔) | :pencil: | 撰写文档 | 
| 🚀 (火箭) | :rocket: | 部署功能 |
| 💄 (口红) | :lipstick: | 更新 UI 和样式文件 |
| 🎉 (庆祝) | :tada: | 初次提交 |
| ✅ (白色复选框) | :white_check_mark: | 增加测试 |
| 🔒 (锁) | :lock: | 修复安全问题 |
| 🍎 (苹果) | :apple: | 修复 macOS 下的问题 |
| 🐧 (企鹅) | :penguin: | 修复 Linux 下的问题 |
| 🏁 (旗帜) | :checked_flag: | 修复 Windows 下的问题|
| 🔖 (书签) | :bookmark: | 发行/版本标签 |
| 🚨 (警车灯) | :rotating_light: | 移除 linter警告 |
| 🚧 (施工) | :construction: | 工作进行中 |
| 💚 (绿心) | :green_heart: | 修复 CI 构建问题 |
| ⬇️ (下降箭头) | :arrow_down: | 降级依赖 |
| ⬆️ (上升箭头) | :arrow_up: | 升级依赖 |
| 👷 (工人) | :construction_worker: | 添加 CI 构建系统 |
| 📈 (上升趋势图) | :chart_with_upwards_trend: | 添加分析或跟踪代码 |
| 🔨 (锤子) | :hammer: | 重大重构 |
| ➖ (减号) | :heavy_minus_sign: | 减少一个依赖 |
| 🐳 (鲸鱼) | :whale: |  Docker 相关工作 |
| ➕ (加号) | :heavy_plus_sign: | 增加一个依赖 |
| 🔧 (扳手) | :wrench: | 修改配置文件 |
| 🌐 (地球) | :globe_with_meridians: | 国际化与本地化 |
| ✏️ (铅笔) | :pencil2: | 修复 typo |


# 参考文献

* [Commit message 和 Change log 编写指南](http://www.ruanyifeng.com/blog/2016/01/commit_message_change_log.html)