---
title: Weex常见问题解析
date: 2019-03-29 13:56:07
tags: [Weex, Vue]
categories: Weex
copyright: true
# description: 
---

# 什么是 Weex？
>Weex 是使用流行的 Web 开发体验来开发高性能原生应用的框架。

<!-- more -->

Weex 致力于使开发者能基于通用跨平台的 Web 开发语言和开发经验，来构建 Android、ios 和 Web 应用。简单来说，在集成了 WeexSDK 之后，你可以使用 JavaScript 语言和前端开发经验来开发移动应用。

Weex 渲染引擎与 DSL 语法层是分开的，Weex 并不强依赖任何特定的前端框架。目前 Vue.js 和 Rax 这两个前端框架被广泛应用于 Weex 页面开发，同时 Weex 也对这两个前端框架提供了最完善的支持。Weex 的另一个主要目标是跟进流行的 Web 开发技术并将其和原生开发的技术结合，实现开发效率和运行性能的高度统一。在开发阶段，一个 Weex 页面就像开发普通网页一样；在运行时，Weex 页面又充分利用了各种操作系统的原生组件和能力。

# 为什么选择 Weex？

## Weex带给我们的收益
* 迭代速度快，快速上线
* Weex环境下完全Native体验
* Bundle资源大小对比H5小很多
* 富交互体验，长列表性能好
* 上手快且简单、一次编写三段兼容

||H5|WEEX|Native|
|---|---|---|---|
|开发成本|低|中|高|
|维护更新|简单|简单|复杂|
|用户体验|差|优|优|
|发版审核|不需要|不需要|需要|
|跨平台性|优|优|差|

# Weex开发踩坑

## 通用样式

### 1、图片
1、Weex提供了image组件,但只支持远程图片链接(在新weex sdk 已经解决)。图片必须添加宽、高属性否则会不显示出来。
2、避免在image标签上使用v-for，否则会导致安卓上图片渲染异常（如slider中的图片）
```
  <slider class="activity" :autoPlay="true" interval="4000" @change="sliderChange">
    <div class="activity-cell"
      v-for="(item, index) in bannerList" :key="index"
      @click="clickInBanner(item)">
      <image class="activity-wrap-bg" resize="cover" :src="imageRes.bannerBgImg"></image>
      <image class="activity-wrap-image" :src="item.pictureUrl"></image>
    </div>
  </slider>
```
### 2、border
Weex不支持使用border创建三角形，web可以正常显示，而ios和android上显示的是矩形，建议使用图片代替
<table style="border:0;"><tr style="background-color:transparent;"><td style="border:0;"><center><img style="border:0;" src="/uploads/weex常见问题解析/triangle.jpg" width="100">web</center></td><td style="border:0;"><center><img style="border:0;" src="/uploads/weex常见问题解析/rectangular.jpg" width="100">ios、android</center></td></tr></table>

### 3、scale设置为0问题
transform: scale(0)会导致文档流内所有事件扩散到整个html结构，导致文档流事件全部无效。只有脱离文档流的元素（absolute等）可以点击；常用可以设置transform: scale(0,1)，并使元素隐藏起来。

### 4、input标签高度问题
安卓环境中，当input高度设置小于60px时，会导致输入框光标不会显示出来。（ios、web正常）

### 5、v-if问题
在做一些操作切换状态时（如按钮点击置灰），应尽量避免使用v-if，使用v-if会闪，且部分安卓机子会发生不可描述的事情（如部分三星机型会出现按钮文字居顶），可采用添加class的方式

### 6、透明度
目前仅ios支持box-shadow属性，android暂不支持，可以使用图片代替。每个元素只支持设置一个阴影效果，不支持多个阴影同时作用于一个元素。and在日常开发中阴影最好使用图片来代替，避免出现未知的问题。以下是涉及到颜色的相关属性对透明度的支持度列表

|属性|IOS|Android|H5|
|---|---|---|---|
|color|支持|支持|支持|
|opacity|支持|支持|支持|
|border-color|支持|支持|支持|
|box-shadow|支持|不支持|支持|
|background-color|支持|支持|支持|
|background-image|不支持|支持|支持|

### 7、Weex不支持样式简写
```
  .border {
    margin: 0 10px; // 错误
    margin-right: 10px;
    margin-left: 10px; // 正确
    border: 1px solid #000; // 错误
    border-width: 1px;
    border-style: solid;
    border-color: #000; // 正确
  }
```
### 8、 点击态
项目比较常见的点击态多半是透明度的变化，如按钮、列表、链接等，css的做法是添加伪类 (:active)，Weex中也同样支持，但是Weex需要在原样式中添加 opacity:1,否则点击后回不到初始状态；此外，:active使用时,background-image在ios下会失效。
```
<template>
  <div class="btn">
    <text>下载</text>
  </div>
</template>
<style scoped>
  .btn {
    opacity: 1; // 必须添加
  }
  .btn:active {
    opacity: 0.5;
  }
</style>
```

### 9、 文本截断
文本从限制一行到不限制可以使用lines:0来控制;
```
<template>
  <text class="text" @click="onClickText" :style="textStyle">
    这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，这是一段测试文本，
  </text>
</template>
<style scoped>
.text {
  text-overflow: ellipsis;
  lines: 1;
}
</style>
<script>
 export default {
   data () {
     return {
       textStyle: {},
     };
   },
   methods: {
     onClickText() {
       this.textStyle = {
         lines: 0,
       };
     },
   },
 }
</script>
```

### 10、html顺序在不同设备上的显示
例如有a、b、c、d 四层结构，其中a、b、c均为absolute定位,z-index由大到小，d为普通结构，我们知道在css中a层应该是处于最上方，d在最下方，那么在weex中表现如何呢？
```
<template>
  <div>
    <div>A(绿)</div> 
    <div>B(蓝)</div>
    <div>C(紫)</div>
    <div>D(红)</div>
  </div>
</template>
```

<table style="border:0;"><tr style="background-color:transparent;"><td style="border:0;"><center><img style="border:0;" src="/uploads/weex常见问题解析/web.png" width="200">web</center></td><td style="border:0;"><center><img style="border:0;" src="/uploads/weex常见问题解析/native.png" width="200">ios、android</center></td></tr></table>

可以看到web和ios、android的表现不一致，ios、android中是以代码中dom顺序来依次添加的，和z-index无关，后面加载的视图会覆盖前面的视图。
所以要保证web、ios、android三端表现一致，改变dom书写顺序即可。

```
<template>
  <div>
    <div>D(红)</div>
    <div>C(紫)</div>
    <div>B(蓝)</div>
    <div>A(绿)</div> 
  </div>
</template>
```

### 11、安卓下遮挡问题
安卓下容器如果设置了宽高，那么子元素不能超出容器范围

### 12、微信环境输入框失焦时，当前页面的视图偏移量未回复到初始位置。
微信环境输入框收起会改变页面dom结构布局，可以采取捕获失去焦点事件， 执行window.scrollTo(0, 0);

### 13、微信环境下超过一屏的长图在加载时渲染不出来
可以对图片的父容器（scroller、 list）设置一个背景颜色，即可成功加载。

### 14、渐变
weex不支持径向渐变radial-gradient,只支持创建线性渐变。并且只支持两种颜色的渐变，渐变方向如下：
* to right: 从左向右渐变
* to left: 从右向左渐变
* to bottom: 从上向下渐变
* to top: 从下向上渐变
* to bottom right: 从左上角向右下角渐变
* to top left: 从右下角向左上角渐变

> **注意**
> * background-image优先级高于background-color，这意味着同时设置background-image和background-color,后者会被覆盖。
> * background不支持简写。

### 15、富文本
weex在0.20版本添加一个新的标签richtext即富文本标签。但在之前的版本内weex是不支持富文本功能的，基本富文本功能都是使用图片来代表，因为weex的字体标签只有text，并且都是weex所有的标签结构都是弹性布局；但是weex也提供了一个方案，即在weex中空格也是占据一定空间的，所以可以支持一些特定的富文本功能。


<table style="border:0;"><tr style="background-color:transparent;"><td style="border:0;"><center><img style="border:0;" src="/uploads/weex常见问题解析/richtext.png" width="400">富文本</center></td><td style="border:0;"></td></tr></table>

```
<template>
  <div>
    <image class="tag-image" :src="data.userType | typeImg" :style="{ top: `${getEnvValue(17,18,13)}px`}"></image>
    <text class="item-title">{{'      ' + getEnvValue('  ','',' ')+ data.title}}</text>
  </div>
</template>
<script>
export default {
  methods: {
    // 根据环境不同返回不同的三个值
    getEnvValue(webValue, iOSValue, androidValue) {
      if (this.isWeb) {
        return webValue;
      } else if (this.isIos) {
        return iOSValue;
      } else if (this.isAndroid) {
        return androidValue;
      }
      return iOSValue;
    },
  }
}
</script>
```

## 输入事件

### 1、输入框不能清空内容
需要清空输入框内已经输入的内容时，不能直接将绑定的值置为空，而是应该先隐藏输入框内显示的值，在一次渲染之后将在将值置为空。
```
<template>
  <div class="input-wrap">
    <wxs-icon name="search" size='40px' color='#b2b2b2'></wxs-icon>
    <input
      :value="searchKeyWord"
      returnKeyType="search"
      @focus="onInputFocus"
      @blur="onInputBlur"
      @input="onInputInput"
      @return="onInputReturn"
      class="input-hint"
      ref="input"
      placeholder-color="#cccccc"
      :singleline="true"
      :lines="1" />
    <div class="erase" @click="onClickErase">
      <wxs-icon v-if="isInputFocus || isWeb" name="erase" size='36px' color='#b2b2b2' ></wxs-icon>
    </div>
  </div>
</template>
<script>
export default {
  data() {
    return {
      searchKeyWord: '',
    };
  },
  methods: {
    onClickErase() {
      this.searchKeyWord = ' ';
      this.$nextTick(() => {
        this.searchKeyWord = '';
      });
    },
  }
}
</script>
```

### 2、Weex input输入框组件 在安卓下input事件BUG

当使用v-model绑定值时，还原到绑定值原始状态时，无法触发input事件，此时还影响到v-model的绑定。在android上的表现为对输入框的input事件进行监听；打开页面选中输入框，对输入框输入一串文字，此时成功的触发了input事件。按键盘上的删除，最初也是成功的触发input事件，当最后一个字符被删除时，input事件并不会触发。如果不使用value来设置值，改使用v-model，也会出现这样的情况。通过查阅资料，发现这个是weex android sdk存在的一个坑点（作者没太接触过安卓开发）[https://segmentfault.com/q/1010000010238162/a-1020000010276364](https://segmentfault.com/q/1010000010238162/a-1020000010276364)里面给出了一张修改源码的方式来解决该BUG。主要问题是在WXInput的父类AbstractEditComponent类中, mIgnoreNextOnInputEvent 这个变量在组件初始化的时候被设置为了TRUE，导致了第一次输入input内容显示不出来。使用上一个问题的方法也可以成功的解决该问题，也可以将searchKeyWord的初始值置为undefined也可以很好的规避该问题。

## 组件

### 命令
组件命名应避免使用JS关键字和保留字，以及weex提供的组件名称，如用loading作为组件名称，在ios与android中将呈现空白。

```
<template>
  <div>
    <Loading></Loading> /* 改用其他名称 */
  </div>
</template>
```

### 自定义slider组件
weex本身提供了slider组件，但轮播图指示器（indicator）只能修改颜色与位置，大小却无法更改，所以需要自定义slider组件
```
<template>
  <!-- 首页banner区块 -->
  <div class="activity-wrap" :style="{ top: (topSafeAreaHeight + 123) + 'px' }">
    <slider class="activity" :autoPlay="true" interval="4000" @change="sliderChange">
      <div class="activity-cell"
        v-for="(item, index) in bannerList" :key="index"
        @click="clickInBanner(item)">
        <image class="activity-wrap-bg" resize="cover" :src="imageRes.bannerBgImg"></image>
        <image class="activity-wrap-image" :src="item.pictureUrl"></image>
      </div>
    </slider>
    <div class="slider-indicator-wrap" v-if="bannerList && bannerList.length > 1">
      <div
        v-for="(icon, index) in bannerList"
        :key="index"
        ref="activeSliderKey"
        class="slider-indicator"
        :class="[index === 0 ? 'slider-indicator-left' : '']"
      ></div>
    </div>
  </div>
</template>
<script>
export default {
  ...,
  methods: {
    // 首页banner切换回调
    sliderChange({ index }) {
      const self = this;
      if (self.bannerList.length > 0) {
        for (let i = 0; i < self.bannerList.length; i += 1) {
          animation.transition(self.$refs.activeSliderKey[i], {
            styles: {
              backgroundColor: 'rgba(255, 255, 255, 0.3)',
            },
            delay: 0,
          });
        }
        animation.transition(self.$refs.activeSliderKey[index], {
          styles: {
            backgroundColor: 'rgba(255, 255, 255)',
          },
          delay: 0,
        });
      }
    },
  },
}
</script>
```

## 动画
weex不支持帧动画，但本身自带的transition可以传入对应的style，并通过setInterval来控制动画循环播放

**animation.js**
```
const animation = weex.requireModule('animation');

export function transition(el, opts, dd) {
  const duration = dd || 400;
  if (!el) {
    return Promise.resolve();
  }
  return new Promise((resolve) => {
    animation.transition(el, {
      duration,
      timingFunction: 'linear',
      delay: 0,
      ...opts,
    }, resolve);
  });
}

export function run(el) {
  transition(el, {
    styles: {
      transform: 'scale(1.02)',
    },
  }, 100).then(() => {
    transition(el, {
      styles: {
        transform: 'scale(1.08)',
      },
    }, 200);
  }).then(() => {
    transition(el, {
      styles: {
        transition: 'scale(1)',
      },
    }, 300);
  });
}
```

**page.vue**
```
<template>
  <div ref="btn"></btn>
</template>
<script>
export default {
  ...
  mounted() {
    setTimeout(() => {
      setInterval(() => {
        animation.run(this.$refs.btn);
      }, 600);
    }, 300);
  },
}
</script>
```

# 参考链接
* [企鹅电竞weex实践——UI开发篇](https://juejin.im/post/5bed1477e51d456c57127b30)
* [weex 中Android的v-model双向绑定 输入第一个字符时无响应](https://segmentfault.com/q/1010000010238162/a-1020000010276364n)





