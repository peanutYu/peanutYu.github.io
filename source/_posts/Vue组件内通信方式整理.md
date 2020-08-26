---
title: Vue组件内通信方式整理
copyright: true
date: 2019-10-23 20:07:11
tags: [Vue, JavaScript]  
category: Vue
---

## props和$emit

父组件向子组件传递数据是通过props来传递的,子组件传递数据给父组件是通过$emit触发事件来做到的,父组件中使用v-on（@）的方式来实现。

<!--more-->

### 父组件向子组件传值
父组件通过v-bind指令向子组件传递一个name为todoList的一个值。
```html
// Parent.vue
<template>
  <div>
    <template v-if="todoList && todoList.length > 0">
      <child v-for="(todo, index) in todoList" :todo="todo" :key="index"></child>
    </template>
  </div>
</template>

<script>
import Child from '@/components/Child'; // 这里的@是由于vue-cli内webpack配置alias别名用以替代src  '@':resolve('src')
export default {
  components: {
    Child,
  },
  data() {
    return {
      todoList: ['吃饭', '睡觉', '打豆豆'],
    };
  },
};
</script>

<style scoped>

</style>
```

子组件通过props来获取父组件传递过来的值
```html
// Child.vue
<template>
  <div>
    <span>{{ todo }}</span>
  </div>
</template>

<script>
export default {
  props: {
    todo: {
      default: '',
      type: [String, Number],
    },
  },
};
</script>

<style scoped>

</style>
```

<!-- ![todoList](/uploads/解析vue内组件通信方式/1.png) -->

父组件通过props向下给子组件传递值,props只能出父组件传递到子组件并且是无法向上传递数据也就是我们常说的单项数据流,props是只能读取的属性,不可以修改，所有修改都会失效;如果一定要将修改props传递下来的数据的话,我们只能把数据存储在子组件的data里面。

``` javascript
export default {
  props: {
    todo: {
      default: '',
      type: [String, Number],
    },
  },
  data () {
    return {
      todoItem: this.todo,
    };
  },
};
```

### 子组件向父组件传值

我们在子组件内部加上一个删除按钮，其功能是点击删除按钮删除对应的内容信息。这里就需要使用到我们的子组件向父组件传值,子组件向父组件传值需要使用到我们的$emit方法。

```html
// 修改Parent.vue
...
<child @delete="deleteTodo" v-for="(todo, index) in todoList" :todo="todo" :key="todo" :index="index"></child> 
...
<script>
export default {
  methods: {
    deleteTodo(index) {
      this.todoList.splice(index, 1);
    }
  },
};
</script>
```

```html
// 修改Child.vue
...
<div>
  <span>{{ todo }}</span>
  <span @click="onDeleteTodo">删除</span>
</div>
...

<script>
export default {
  props: {
    ...,
    index: {
      default: 0,
      type: Number,
    },
  },
  methods: {
    onDeleteTodo() {
      this.$emit('delete', this.index);
    },
  },
};
</script>
```

<!-- ![delete](/uploads/解析vue内组件通信方式/2.gif) -->

> 这里父组件的key值不能再为index。由于key值是一个唯一的值,我们在操作删除操作时数组的索引会重新计算,如果使用index值为key值的话会出现一些视图显示错误的问题;这里就不多阐述了,有兴趣的朋友可以自行研究一下。

子组件通过$emit向父组件发送消息并把需要发送的数据作为参数传递给方法内。这里我们子组件一个按钮上绑定一个删除事件onDeleteTodo,方法内部触发父组件上绑定的delete事件并传递参数为当前点击按钮的index,父组件绑定delete事件的函数deleteTodo会将todoList上对应的index的那项删除掉就完成了我们的子组件向父组件传值的过程。

## $parent和$children($root)

子实例可以通过this.$parent访问父实例,子实例被推入父实例的$children数组中。

> 官网上推动我们节制地使用 $parent 和 $children - 它们的主要目的是作为访问组件的应急方法。更推荐用 props 和 events 实现父子组件通信

```html
// 父组件
<template>
  <div>
    <child></child>
  </div>
</template>
<script>
import Child from '@/components/Child';

export default {
  components: {
    Child,
  },
  data() {
    return {
      msg1: '我是根节点root',
      msg2: '我是从父节点传递过来的信息',
    };
  },
  mounted() {
    console.log(this.$root.msg1); // 假设parent是根节点的话, 这里打印 我是根节点root
    console.log(thihs.$children[0].msg3); // 我是从子节点传递过来的信息
  },
};
</script>
```

```javascript
// 子组件
export default {
  data () {
    return {
      msg3: '我是从子节点传递过来的信息',
    };
  },
  mounted() {
    console.log(this.$parent.msg2); // 我是从父节点传递过来的信息 这里等同于this.$root.msg2
  },
}
```

## refs和ref
refs和ref的用法和上面的$children非常的相似,我们的子组件使用上个通信方式定义的文件,修改下我们的父组件

```html
// 父组件
// 父组件
<template>
  <div>
    <child ref="children"></child>
  </div>
</template>
<script>
import Child from '@/components/Child';

export default {
  components: {
    Child,
  },
  mounted() {
    console.log(thihs.$refs.children.msg3); // 我是从子节点传递过来的信息
  },
};
</script>
```



## provide和inject

provide和inject需要放在一起使用,允许一个祖先组件向其所有子孙后代注入一个依赖,不论组件层次有多少深,在其上下游关系中始终生效。

> provider和inject绑定并不是响应式的,这是刻意为之的。然而，如果你传入了一个可监听的对象，那么其对象的属性还是可响应的。

假设父组件设置provide如下
```javascript
// Parent.vue 父组件
export default {
  provide() {
    return {
      name: 'provider和inject',
    };
  },
};
```

后代组件
```javascript
// GrandChild.vue 后代组件
export default {
  inject: ['name'],
  mounted() {
    console.log(this.name); // provider和inject
  },
};
```

这里我们在父组件上设置一个provide,其中属性name的值为'provider和inject',传递给后代组件通过inject获取,在后代组件内获取后,就正常的可以通过this.name属性来访问。

## $attrs和$listeners

$attrs: 包含了父作用域中不作为prop被识别（且获取）的特性绑定（class和style除外）。当一个组件没有声明任何prop时，这里会包含所有父作用域的绑定（class和style除外）,并且可以通过v-bind="$attrs"传入内部组件

$listeners: 包含了父作用域中的（不含.native修饰器的）v-on事件监听器。它可以通过v-on="$listeners"传入内部组件

Vue2.4提供了$attrs , $listeners 来传递数据与事件，跨级组件之间的通讯变得更简单。其中$attr负责整合组件的属性而$listeners负责整合组件的方法,并且两者都以对象形式来保存数据。

假设一个跨级通信情况 A -> B -> C。正常情况下我们都会使用props逐级传递下去,但是使用$attrs以及$listeners后逐级向下传递数据后不在需要以前那样繁琐的重复定义props。需要数据的组件只需要定位一个props,剩余的数据会继续向下进行传递。

### 父组件A

> 父组件A下存在一个子组件B,并传递两条数据bMsg,cMsg以及绑定两个方法bData和cData。

```html
<template>
  <div>
    <p>这是一个父组件</p>
    <B :b-msg="bMsg" :c-msg="cMsg" @bData="getChildData" @cData="getGrandChildData"></B>
  </div>
</template>
<script>
import B from '@/components/B';
export default {
  components: {
    B,
  },
  data() {
    return {
      bMsg: '这是一个子组件',
      cMsg: '这是一个后代组件',
    };
  },
  methods: {
    getChildData(data) {
      console.log(`子组件数据: ${data}`);
    },
    getGrandChildData(data) {
      console.log(`后代组件数据: ${data}`);
    },
  },
};
</script>
```

### 子组件B

> 子组件接受父组件传递的数据bMsg,并调用bData方法;将$attrs绑定到后代组件C上,由于$attrs含了父作用域中不作为prop被识别的特性绑定,所以这时$attr为{ c-msg: '这是一个后代组件' }, $listeners: { bData: f(), cData: f()}。

```html
<template>
  <div>
    <p>
      <span>{{bMsg}}</span><span @click="postData">点我传递数据</span>
    </p>
    <C v-bind="$attrs" v-on="$listeners"></C>
  </div>
</template>
<script>
import C from '@/components/C';
export default {
  components: {
    C,
  },
  props: ['bMsg'],
  methods: {
    postData() {
      this.$emit('bData', '子组件数据'); // 调用A v-on:bData
    },
  },
  created() {
    console.log(this.$attrs, this.$listeners);  // $attr: { c-msg: '这是一个后代组件' } $listeners: { bData: f(), cData: f()}
  },
};
</script>
```

### 后代组件C
> 后代组件C接受来自子组件B传递下来的数据;

```html
<template>
  <p>
    <span>{{cMsg}}</span><span @click="postData">点我传递数据</span>
  </p>
</template>
<script>
export default {
  props: ['cMsg'],
  methods: {
    postData() {
      this.$emit('cData', '后代组件数据'); // 调用A v-on:cData
    },
  },
}
</script>
```

## eventBus

evevntBus是消息传递的一种方式,又被称为事件总线。

### 创建一个实例Bus

首先我们创建一个eventBus 并将其导出。

```javascript
// Bus.js
import Vue from 'vue';
export default new Vue();
```

创建两个兄弟组件A以及B组件以及一个父组件Parent
```html
// Parent.vue
<template>
  <div>
    <a></a>
    <b></b>
  </div>
</template>

<script>
import A from '@/components/A';
import B from '@/components/B';
export default {
  components: {
    A,
    B,
  },
}
</script>
```
### 组件B发送事件
```html
// B.vue
<template>
  <div @click="createRandom">点击生成随机数</div>
</template>
<script>
import Bus from '@/bus/Bus';
export default {
  methods: {
    createRandom() {
      const number = Math.floor(Math.random() * 10);
      Bus.$emit('passNumber', number)
    },
  },  
};
</script>
```

### 组件A接收事件
```html
// A.vue
<template>
  <div>{{ number }}</div>
</template>
<script>
import Bus from '@/bus/Bus';
export default {
  data() {
    return {
      number: null,
    };
  },
  created() {
    Bus.$on('passNumber', (number) => {
      this.number = number;
    });
  },
  beforeDestroy() {
    Bus.$off('passNumber');
  },
}
</script>
```

组件B中有一个按钮并绑定点击事件点击后向组件A传递一个随机数并在组件A上显示。

> eventBus是一种创建一个新的vue实例做观察者的方式,订阅和发布事件;vm实例上存在$on、$once、$off、$emit几个方法。

## localStorage和sessionStorage
这种通信比较简单,缺点是数据和状态比较混乱,不太容易维护。

通过window.localStorage.getItem(key)获取数据
通过window.localStorage.setItem(key, value)存储数据
> localStorage / sessionStorage可以结合vuex, 实现数据的持久保存,同时使用vuex解决数据和状态混乱问题。
<!-- ## .sync -->

## vuex

Vuex 是一个专为 Vue.js 应用程序开发的状态管理模式。它采用集中式存储管理应用的所有组件的状态，并以相应的规则保证状态以一种可预测的方式发生变化。

每一个 Vuex 应用的核心就是 store（仓库）。“store”基本上就是一个容器，它包含着你的应用中大部分的状态 (state)。Vuex 和单纯的全局对象有以下两点不同：

1. Vuex 的状态存储是响应式的。当 Vue 组件从 store 中读取状态的时候，若 store 中的状态发生变化，那么相应的组件也会相应地得到高效更新。

2. 你不能直接改变 store 中的状态。改变 store 中的状态的唯一途径就是显式地提交 (commit) mutation。这样使得我们可以方便地跟踪每一个状态的变化，从而让我们能够实现一些工具帮助我们更好地了解我们的应用。


### Vuex的各个模块
1. state：用于数据的存储，是store中的唯一数据源
2. getters：如vue中的计算属性一样，基于state数据的二次包装，常用于数据的筛选和多个数据的相关性计算
3. mutations：类似函数，改变state数据的唯一途径，且不能用于处理异步事件
4. actions：类似于mutation，用于提交mutation来改变状态，而不直接变更状态，可以包含任意异步操作
5. modules：类似于命名空间，用于项目中将各个模块的状态分开定义和操作，便于维护

### 动手写一个简单的Vuex
命令行执行命令安装vuex
```
npm i -S vuex
```

在src目录下创建一个store文件夹,继续在store文件夹下创建一个index.js文件
```javascript
import Vue from 'vue';
import Vuex from 'Vuex';
const INCREASE = 'INCREASE';
const DECREASE = 'DECREASE';
Vue.use(Vuex);
export default new Vuex.Store({
  state: {
    count: 0,
  },
  mutations: {
    [INCREASE](state) {
      state.count++;
    },
    [DECREASE](state) {
      state.count--;
    },
  },
  actions: {
    increaseCount({ commit }) {
      commit(INCREASE);
    },
    decreaseCount({ commit }) {
      commit(DECREASE);
    },
  },
});
```

main.js添加以下代码
```javascript
import Store from '@/store';
new Vue({
  el: '#app',
  router,
  components: { App },
  template: '<App/>',
  store,
})
```

创建父组件A
```html
<template>
  <div>
    <p>这是一个父组件</p>
    <B></B>
    <span @click="increaseCount">增加</span>
    <span @click="decreaseCount">减少</span>
  </div>
</template>
<script>
import { mapActions } from 'vuex';
import B from '@/components/B';
export default {
  components: {
    B,
  },
  methods: {
    ...mapActions([
      'increaseCount',
      'decreaseCount',
    ]),
  },
};
</script>
```

创建子组件B

```html
<template>
  <div>
    <p>{{count}}</p>
  </div>
</template> 
<script>
import { mapState } from 'vuex';
export default {
  computed: {
    ...mapState([
      'count'
    ]),
  },
};
</script>
```

上面代码简单实现了使用Vuex在父子组件之内传递数据,点击父组件增加减少按钮,子组件内显示count就会同样重新计算。有更多的想要了解Vuex,可以参考一下[Vuex官方文档](https://vuex.vuejs.org/zh/guide/)。







