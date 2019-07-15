---
title: 通过document.referrer返回前一个页面
date: 2019-06-30 22:47:07
tags: [JavaScript, 实战经验]
categories: 实战经验
---

# 前言

> 在JavaScript中，document对象有很多属性，其中有3个与对网页的请求有关的属性，它们分别是URL、domain和referrer。URL属性包含页面完整的URL，domain属性中只包含页面的域名，而referrer属性中则保存着链接到当前页面的那个页面的URL。



# JS获取前一个访问页面的URL地址document.referrer

要获取前一个访问页面的URL地址前后端语言都可以，例如PHP的是$_SERVER['HTTP_REFERER']，JavaScript的就是**document.referrer**。

