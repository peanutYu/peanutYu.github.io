---
title: git高级用法——git cherry-pick
date: 2019-04-20 15:47:12
tags: [git,实战经验] 
categories: git
---

# 前言

最近正巧看了一些面试题，其中有一道令我比较好奇，也就是我们今天要说到的**git cherry-pick**;我们在简历当中都会写上精通或者熟练掌握git工作技巧。但绝大多数人也许只掌握一些简单的类似**git status | pull | push | log**等操作,又或是使用**sourcetree**等一些辅助工具来支持我们日常的工作需求，这篇博客主要记录和**git cherry-pick**与之相关的git操作。

<!-- more -->

# 使用场景及其作用

git cherry-pick可以选择某一个分支的一个或几个commit(s)来进行操作（操作的对象就是commit）。假设这样一个场景，产品提出某个功能需求，你开发完毕，然后commit了；第二天，产品通知你那个功能可能不要了，于是你把代码reset回去；又过了几天，产品告诉你说，之前reset的功能我们要重新加回来；这时候应该怎么办？代码在reset之后又进行开发了其他的功能，已经修改过并且有了新的commit，你是应该重新开发还是回退呢？

这种时候就是git cherry-pick发挥效果的时候了。

## git log

查询commit id 的查询可以使用git log查询（查询版本的历史），最简单的语法就是
```
git log
```

详细的git log语法如下: 
```
  git log [<options>] [<since>..<until>] [[--] <path>...]
    主要参数选项如下：
      -p：按补丁显示每个更新间的差异
      --stat：显示每次更新的修改文件的统计信息
      --shortstat：只显示--stat中最后的行数添加修改删除统计
      --name-only：尽在已修改的提交信息后显示文件清单
      --name-status：显示新增、修改和删除的文件清单
      --abbrev-commit：仅显示SHA-1的前几个字符，而非所有的40个字符
      --relative-date：使用较短的相对时间显示（例如："two weeks ago"）
      --graph：显示ASCII图形表示的分支合并历史
      --pretty：使用其他格式显示历史提交信息
```

## git reflog

git reflog 可以查看所有分支的所有操作记录（包括已经被删除的 commit 记录和 reset 的操作）

## 场景一
首先我们通过**git log**查看所有的commit信息。

![](http://www.peanutyu.site/uploads/git高级用法——git-cherry-pick/gitlog1.png)

commit的信息很简单，就是做了3个功能开发，每个功能对应一个commit的提交，分别是feature-1 => feature-4。假设这时候可能产品说功能2、3、4不需要上线了。我们需要将代码回滚到1上面。

```
git reset --hard dbe570bf1bf9c5f5777b39b242f90e3eb16a1aec
```

![](http://www.peanutyu.site/uploads/git高级用法——git-cherry-pick/gitlog2.png)

现在我们看到我们的commit信息只剩下了最开始的feature-1功能还保留在上面了；此时产品需要我们上线一个称之为功能5的commit,一个星期后产品需要我们把之前的2、3、4重新合并到代码里头上线；这时候我们需要怎么做呢？

首先我们可以看到现在的git log打印出来的信息是只有feature-1和feature-5提交的代码

![](http://www.peanutyu.site/uploads/git高级用法——git-cherry-pick/gitlog3.png)

这时候我们首先通过**git reflog**命令查看分支上的所有操作记录

![](http://www.peanutyu.site/uploads/git高级用法——git-cherry-pick/gitreflog1.png)

这时候要记好两个值：c8f4403和45ec9b1，他们分别是feature-5和feature-4的hash码。然后执行回滚，回到feature-4上。

```
git reset --hard 45ec9b1
```
现在我们回到了feature-4上，如下图

![](http://www.peanutyu.site/uploads/git高级用法——git-cherry-pick/gitlog4.png)

但是我们现在feature-5的代码丢失了，如何将它找回来呢？这时候就需要我们的git cherry-pick。刚刚我们知道git cherry-pick的hash码为c8f4403

```
git cherry-pick c8f4403
```
输入好了之后feature-5的代码就找回来了。 期间可能会产生一些代码的冲突，只需要按正在的步骤解决就好了。 最后的结果如下图

![](http://www.peanutyu.site/uploads/git高级用法——git-cherry-pick/gitlog5.png)

到这里feature-1到feature-5的代码就找回来了。这就是git cherry-pick的用法。


## 场景二

在一个分支branch1开发，进行多次提交，这时我们切换到branch2，想把之前的branch1分支上的commit复制过来。

首先我们切换到branch1分支，然后查看提交历史记录，可以用sourceTree查看，也可以使用命令Git log

例如的我branch1 git log如下图

![](http://www.peanutyu.site/uploads/git高级用法——git-cherry-pick/gitlog6.png)

这时候我只想把branch-1-feature-1的提交复制到branch2里面，只需要切换到branch2分支，然后执行
```
git cherry-pick e8ae0307b4d2775922c0a2cbd3930ef4c4dca353
```
branch2 git log如下图

![](http://www.peanutyu.site/uploads/git高级用法——git-cherry-pick/gitlog7.png)

git cherry-pick 也可以同时合并多个branch； 假设branch2需要合并branch1的branch-1-feature-1，branch-1-feature-2；就可以使用

```
git cherry-pick e8ae0307b4d2775922c0a2cbd3930ef4c4dca353,cc6b772ea79ecf54f9df18dd8f0ebf868dfe9170
```

# 参考链接
* [女神的侧颜---git时光穿梭机](https://github.com/airuikun/blog/issues/5)












