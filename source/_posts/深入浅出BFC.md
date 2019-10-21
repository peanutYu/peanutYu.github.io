---
title: 深入浅出BFC
copyright: true
date: 2019-09-06 16:36:39
tags: Css
category: Css
---

# BFC是什么？

> BFC全称（Block Formatting Context）块级格式化上下文是Web页面的可视化CSS渲染的一部分，它是块级盒子布局过程产生的区域，也是浮动层元素进行交互的区域，可以让处于BFC内部的元素与外部的元素相互隔离，使内外的元素不会相互影响。

<!--more-->

# BFC如何创建？

以下任意一条都会创建块级格式化上下文。

* 浮动元素（元素的**float**不是none）
* 绝对定位元素（元素的position为absolute或fixed）
* 行内块级元素（元素的display为inline-block）
* 表格单元格（元素的display为table-cell,HTML表格单元格默认为该值）
* 表格标题（元素的display为table-caption,HTML表单标题格默认为该值）
* overflow值不为visible的块元素

更多创建BFC布局的方式可以参考[MDN](https://developer.mozilla.org/zh-CN/docs/Web/Guide/CSS/Block_formatting_context)这里就不一一赘述了。


# BFC布局和普通文档流布局区别

## BFC布局规则

1. 浮动的元素会被父级计算高度当父级元素触发了BFC的时候
2. 非浮动元素不会覆盖浮动元素位置（非浮动元素触发了BFC）
3. margin不会传递给父级（父级触发了BFC）
4. 属于同一BFC的两个相邻元素上下margin会重叠

## 普通文档流布局规则

1. 浮动的元素是不会被父级计算高度
2. 非浮动元素会覆盖浮动元素的位置
3. margin会传递给父级元素
4. 两个相邻元素上下的margin会重叠

# BFC的约束规则

* 内部的Box会在垂直方向上一个接一个的放置 （Block元素会与父元素同宽，所以会垂直排列）
* 垂直方向上的距离由margin决定
* 每个元素的左外边距与包含块的左边界相接触（从左向右），即使浮动元素也是如此。（这说明BFC中子元素不会超出他的包含块，而position为absolute的元素可以超出他的包含块边界）（浮动元素的位置也是会尽量接近左上方或右上方）
* BFC的区域不会与float的元素区域重叠
* 计算BFC的高度时，浮动子元素也参与计算
* BFC就是页面上的一个隔离的独立容器，容器里面的子元素不会影响到外面元素，反之亦然




