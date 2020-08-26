---
title: 纯Css(Scroll Indicator)滚动指示器实现
copyright: true
date: 2019-08-05 19:11:52
tags: Css
category: Css
---

>Scroll Indicator称之为滚动指示器,是web页面中我们经常见到的一个效果。用户触发垂直方向上的滚动时，页面顶部会有一个类似进度条的效果，当内容滚动到页面最底部，则进度条填满页面的整个页面宽度。

<!--more-->


# Scroll Indicator

Scroll Indicator：滚动指示器。通俗来说，就是当前可视区域距离页面顶部的占比。阮老师的《ECMAScript 6 入门》官网的每个章节的页面都使用了这样一个滚动指示器，效果如下图：

<img width="70%" src="http://www.peanutyu.site/uploads/纯css滚动进度条实现/ryf.gif">

# Javascript的实现方法

1. 页面加载完成之后，首先需要获取到页面文档高度（domHeight)、视窗高度（winHeight),则可计算成页面滚动到底部所需的高度scrollHeight = domHeight - winHeight以及可视区域距离页面顶部的高度scrollTop;

2. 监听页面scroll事件，通过当前的scrollTop / scrollHeight * 100%, 即为进度条的百分比。

代码如下
```javascript
var $window = $(window);
var domHeight = $(document).height();
var winHeight = $window.height();
var scrollHeight = domHeight - winHeight;
$window.on('scroll', function() {
  var per = $(this).scrollTop() / scrollHeight;
  $('进度条dom').css({ width: per * 100 + '%' });
});
```

阮一峰老师es6官网的实现源码

```javascript
(function() {
  var $w = $(window);
  var $prog2 = $('.progress-indicator-2');
  var wh = $w.height();
  var h = $('body').height();
  var sHeight = h - wh;
  $w.on('scroll', function() {
    window.requestAnimationFrame(function(){
      var perc = Math.max(0, Math.min(1, $w.scrollTop() / sHeight));
      updateProgress(perc);
    });
  });

  function updateProgress(perc) {
    $prog2.css({width: perc * 100 + '%'});
  }

}());
```

实现代码方法大同小异，都是通过判断实际滚动距离与页面实际滚动高度的差值来进行比较。

# Css的实现方法

Css的实现方法主要是运用线性渐变来实现这个功能。首先假设我们的页面被包裹在**body**内，并且**body**是可以滚动的，我们可以给它添加一个从左下角到右上角的线性渐变。
```css
body {
  background-image: linear-gradient(to right top, #ffcc00 50%, #eee 50%);
  background-repeat: no-repeat;
}
```

<img width="70%" src="http://www.peanutyu.site/uploads/纯css滚动进度条实现/test1.gif">

浅蓝色块的颜色变化已经可以展示出我们进度条的一些形状了。我们继续加上一个伪元素，把多余的部分遮住。加上之后的效果如下图：
```css
body::after {
  content: "";
  position: fixed;
  top: 5px;
  left: 0;
  bottom: 0;
  right: 0;
  background: rgba(0,0,0,.6);
  z-index: -1;
}
```
<img width="70%" src="http://www.peanutyu.site/uploads/纯css滚动进度条实现/test2.gif">

这里我们可以发现其实当页面滑到最底部的时候，我们的进度条并没有到达最底部。因为body的线性渐变高度设置了整个 body 的大小，我们调整一下渐变的高度：

```css
body {
  background-image: linear-gradient(to right top, #ffcc00 50%, #eee 50%);
  background-repeat: no-repeat;
  background-size: 100% calc(100% - 100vh + 5px);
}
```

这里使用了 calc 进行了运算，减去了 100vh，也就是减去一个屏幕的高度，这样渐变刚好在滑动到底部的时候与右上角贴合。而 + 5px 则是滚动进度条的高度，预留出 5px 的高度。

<img width="70%" src="http://www.peanutyu.site/uploads/纯css滚动进度条实现/test3.gif">

到现在为止这个用Css实现滚动进度条已经实现了，不过这个实现方法确有一些缺陷。
1. 页面内容不能有背景色或背景图
2. body自身也不能有背景图

# CSS更好的实现

由于对角线性渐变不能写在body上，我们可以假设将他写在一个div上。[张鑫旭](https://www.zhangxinxu.com)大神给我们提供了一套更好的实现方案。

1. 在<body>标签内插入指示器元素：
```html
<div class="indicator"></div>
```

2. 粘贴如下所示的CSS代码：
```css
body {
  position: relative;
}
.indicator {
  position: absolute;
  top: 0; right: 0; left: 0; bottom: 0;
  background: linear-gradient(to right top, teal 50%, transparent 50%) no-repeat;
  background-size: 100% calc(100% - 100vh);
  z-index: 1;
  pointer-events: none;
  mix-blend-mode: darken;
}
.indicator::after {
  content: '';
  position: fixed;
  top: 5px; bottom: 0; right: 0; left: 0;
  background: #fff;
  z-index: 1;
}
```
这样一个更好的CSS滚动指示器效果就实现了。 这种更好的实现方法的核心在于mix-blend-mode: darken,也就是darken模式。darken混合模式的混合方式很好理解，两个颜色进行混合，哪个颜色深就使用哪个颜色。要知道所有的颜色里面最浅的就是白色，于是我们只要把我们的白色覆盖层的混合模式设置为darken，那必然最终呈现出来的颜色一定是覆盖层下面元素内容的颜色，换句话说我们的白色透明覆盖层变透明了。相关darken文章参考[darken](https://developer.mozilla.org/zh-CN/docs/Web/CSS/mix-blend-mode)。

# 参考链接
* [更好的纯CSS滚动指示器技术实现](https://www.zhangxinxu.com/wordpress/2019/06/better-css-scroll-indicator/)






