---
title: 一次弄懂Event Loop
copyright: true
date: 2019-11-06 14:33:54
tags: [JavaScript, 异步]
category: JavaScript
---

> 最近浏览了一些前端的面试题，发现很多题目里都有问到 Event Loop。正好我收集整理了部分相关的信息，于是也来说说我理解的 Event Loop。

<!--more-->

## 什么是Event Loop?

JS主线程不断的循环往复的任务列表中读取任务并且执行任务，其中运行机制被称为事件循环（Event Loop）。Event Loop是一个执行模型，在不同的地方有不同的实现。浏览器和NodeJS基于不同的技术实现了各自的Event Loop。

* 浏览器的Event Loop是在[html5的规范](https://html.spec.whatwg.org/multipage/webappapis.html#event-loops)中明确定义。
* NodeJS的Event Loop是基于libuv实现的。可以参考Node的[官方文档](https://nodejs.org/en/docs/guides/event-loop-timers-and-nexttick/)以及libuv的[官方文档](http://docs.libuv.org/en/v1.x/design.html)。
* libuv已经对Event Loop做出了实现，而HTML5规范中只是定义了浏览器中Event Loop的模型，具体的实现留给了浏览器厂商。

## 单线程的JavaScript
我们都知道JavaScript是一门单线程的编程语言,也就是说程序的执行顺序是从上到下依次执行的并且同一时间段内只能有一段代码被执行。这是由于JavaScript在设计之初的定位是用来处理用户交互以及操作 DOM,如果 JavaScript 也设计成多线程,势必会带来很复杂的同步问题。

> 假设JavaScript有两个线程,一个线程需要删除某个DOM节点,另一个则要在该DOM节点上添加一些内容。这时候浏览器该以哪个线程为主，所以JavaScript是单线程的。

## 同步、异步

> 但是,单线程的JavaScript为了解决一些大量的一些异步请求,决定着它必须支持异步。虽然JavaScript是单线程的,可是浏览器内部并不是单线程的。

我们假设JavaScript只执行自己程序的代码,当遇到异步操作时把他丢给浏览器来处理,由浏览器的线程去执行,自己继续往下执行。那问题来了，异步之后的程序JavaScript还是需要处理的,那怎么办?没关系,让浏览器执行完异步之后,再把异步执行完的东西在给我们JavaScript,让JavaScript去执行不就好了。

### 同步

> 如果在函数返回结果的时候，调用者能够拿到预期的结果(就是函数计算的结果)，那么这个函数就是同步的.

```javascript
console.log('synchronous') // 执行后,立即返回了结果
```

如果是同步的函数,即使调用函数的过程中执行比较耗时,也会一直等待得到执行结果。
```javascript
function synchronous() {
  var time = +new Date();
  while(+new Date() - time > 2000) {}
  console.log('2秒过去了');
}
synchronous();
console.log('同步函数执行结束');
```

执行结果
```
2秒过去了
同步函数执行结束
```

上面代码中,下面的console.log函数需要等待2s才可以执行, 这就是同步。从函数返回结果的时候,调用者就可以拿到预期的结果。

### 异步

> 如果在函数返回的时候,调用者还不能购得到预期结果,而是将来通过一定的手段得到（例如回调函数）,这就是异步。如果函数是异步的,发出调用之后马上返回,但是不会马上返回预期结果。调用者不必主动等待,当被调用者得到结果之后会通过回调函数主动通知调用者。

```javascript
function asynchronous() {
  setTimeout(function() {
    console.log('2s过去了');
  }, 2000);
}
console.log('异步函数执行结束');
```
执行结果
```
异步函数执行结束
2s过去了
```

上面asynchronous函数内部内容修改成使用setTimeout来延迟2s执行函数内部去的console.log。但实际函数执行的结果却和上面并不一样;是因为setTimeout函数是异步的,匿名函数为它的回调函数。

## 宏任务、微任务
> JavaScript中有microtasks、macrotasks,它们是异步任务的一种类型,microtasks的优先级高于macrotasks。

### 宏任务（macrotasks, 又叫tasks） macrotasks的一些api

* script（整体代码）
* setTimeout
* setInterval
* setImmediate
* I/O
* UI渲染

### 微任务（microtasks） microtasks的一些api
* process.nextTick
* promise
* Object.observe
* MutationObserver

## async await、Promise、setTimeout

### async await
async await是ES7提出的一个异步回调最终解决方案的语法糖。
```javascript
async function asynchronous() {
  return 'asynchronous';
}
console.log(asynchronous()); // Promise。
```

上面代码打印出来的结果发现async 函数实际上还是一个Promise, 我们也可以对它使用thenable的形式获取数据。

```javascript
asynchronous().then(str => console.log(str)); // asynchronous
// 打印出来的结果也证明asynchronous函数其实可以改写成Promise.resolve('asynchronous')。
```

我们在换一种形式观察async await

```javascript
async function asynchronous() {
  console.log('我在asynchronous之前');
  const info = await asynchronous1();
  console.log(info);
}

function asynchronous1() {
  return new Promise(resolve => {
    console.log('await 开始');
    setTimeout(() => {
      resolve('asynchronous');
    }, 2000);
  })
}

// 这里的打印结果为 我在asynchronous之前、await 开始、 asynchronous
```

这里我们可以看到info是需要在asynchronous1返回结果后才会继续执行下去,这和我们的Primise里面的thenable形式一样,这里我们其实可以转化一种写法会更加的清晰。

```javascript
function asynchronous2() {
  console.log('我在asynchronous之前'); // await前面的代码
  new Promise(resolve => {
    console.log('await开始');  // await内部的代码。 永远在Promise内部这是同步执行的
    setTimeout(() => {
      resolve('asynchronous');
    }, 2000);
  }).then(str => console.log(str)); // await下面的代码 通过thenable来执行
}
```

await 的含义为等待,也就是 async 函数需要等待 await 后的函数执行完成并且有了返回结果（ Promise 对象）之后,才能继续执行下面的代码。await通过返回一个Promise对象来实现同步的效果。

### promise

Promise本身是同步的立即执行函数,当在 executor 中执行 resolve 或者 reject 的时候,此时是异步操作,会先执行 then/catch 等,当主栈完成后,才会去调用 resolve/reject 中存放的方法执行,打印 p 的时候是打印的返回结果,一个 Promise 实例。

```javascript
console.log('script start')
let promise1 = new Promise(function (resolve) {
    console.log('promise1')
    resolve()
    console.log('promise1 end')
}).then(function () {
    console.log('promise2')
})
setTimeout(function(){
    console.log('settimeout')
})
console.log('script end')
// 输出顺序: script start->promise1->promise1 end->script end->promise2->settimeout
```

当JS主线程执行到Promise对象时，
promise1.then() 的回调就是一个 task
promise1 是 resolved 或 rejected ：那这个 task 就会放入当前事件循环回合的 microtask queue
promise1 是 pending：这个 task 就会放入 事件循环的未来的某个(可能下一个)回合的 microtask queue 中
setTimeout 的回调也是个 task ，它会被放入 macrotask queue 即使是 0ms 的情况


### setTimeout
``` javascript
console.log('script start')	//1. 打印 script start
setTimeout(function(){
    console.log('settimeout')	// 4. 打印 settimeout
})	// 2. 调用 setTimeout 函数，并定义其完成后执行的回调函数
console.log('script end')	//3. 打印 script start
// 输出顺序：script start->script end->settimeout
```
## Event Loop

主线程循环的从异步队列中读取事件，这个过程其实就是 Event Loop。

![](/uploads/一次弄懂Event Loop/1.png)

> Event Loop就是,执行一个宏任务的过程中遇到微任务时,将其放到微任务的事件队列里,当前宏任务执行完毕后,会查看微任务的事件队列,依次执行里面的微任务。如果还有宏任务的话,再重新开启宏任务。

```javascript
async function async1() {
  console.log('async1 start')
  await async2()
  console.log('async1 end')
}
async function async2() {
  console.log('async2')
}
console.log('script start')
setTimeout(function () {
  console.log('settimeout')
})
async1()
new Promise(function (resolve) {
  console.log('promise1')
  resolve()
}).then(function () {
  console.log('promise2')
})
console.log('script end')
```

1. 执行同步任务console.log打印出script start。
2. 将setTimeout放到宏任务队列,此时宏任务队列为['settimeout']。
3. 执行async1 内部的第一个console.log 打印出async1 start。
4. await执行方法大概同等于Promise.resolve直接同步打印出async2。
5. 将async1内部的await下面的console.log放到微任务列, 此时微任务队列为['async1end']。
6. 函数返回一个Promise,因为这是一个同步任务,打印出promise1。
7. promise.then返回一个微任务,此时微任务队列为 ['async1end','promise2']。
8. 执行同步任务打印出script end。
9. 因为微任务执行优先,打印出async2, promise2。
10. 最后打印async2。

结果 script start -> async1 start -> async2 ->  promise1 -> async1 end -> promise2 -> settimeout
![](/uploads/一次弄懂Event Loop/2.png)
> 注意
> 1 每一个 event loop 都有一个 microtask queue
> 2 每个 event loop 会有一个或多个macrotask queue ( 也可以称为task queue )
> 3 一个任务 task 可以放入 macrotask queue 也可以放入 microtask queue中
> 4 每一次event loop，会首先执行 microtask queue， 执行完成后，会提取 macrotask queue 的一个任务加入 microtask queue， 接着继续执行microtask queue，依次执行下去直至所有任务执行结束。
