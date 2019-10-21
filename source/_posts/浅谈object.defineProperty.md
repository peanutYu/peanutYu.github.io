---
title: 浅谈Object.defineProperty
copyright: true
date: 2019-08-09 14:10:40
tags: 学习笔记
category: 学习笔记
---

# Object属性描述符

js对象内部有两种属性描述符 数据描述符和存取描述符（访问描述符）;描述符必须是两种形式之一；不能同时是两者。

>注意事项
>数据描述符和存取描述符都具备configurable、enumerable属性。
>描述符不具备value，writetable，set和get任意一个关键字都被认作一个数据描述符。
>（value或writetable）和（get和set）不能同时存在，然后只要定义了set和get或其中一个都是一个存取描述符（描述符只能是其中一种）。

<!--more-->

描述符可同时具有的键值

||configurable|enumerable|value|writetable|get|set|
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
|数据描述符|yes|yes|yes|yes|no|no|
|存取描述符|yes|yes|no|no|yes|yes|

## 数据描述符

>数据描述符是一个拥有可写或不可写值的属性

数据描述符有两个独有的属性(value, writeable)
```
let People = {};
Object.defineProperty(People, 'name', {
  value: 'peanut',
  writable: true, // 值是否可以发生改变
});
console.log(People.name);
```
这里的value就是我们给name这个属性赋的初始值，默认为undefined；我们打印People.name的结果为peanut。
```
Object.defineProperty(People, 'age', { writeable: true });
console.log(People.age);
People.age = 23;
console.log(People.age);
```
这里我们第一次的打印结果就为默认值undefined，第二次打印结果为23.因为我们这时候writeable为true,代表这个值是可以修改的。
## 存取描述符

> 存取描述符是由一对 getter-setter 函数功能来描述的属性。

get: 一个给属性提供getter的方法，如果没有getter则为undefined。该方法返回值被用作属性值。默认为undefined。
set: 一个给属性提供setter的方法，如果没有setter则为undefined。该方法将接受唯一参数，并将该参数的新值分配给该属性。默认值为undefined。

```
let People = {};
let temp = null;
Object.defineProperty(People, 'name', {
  get: function() {
    return temp;
  },
  set: function(value) {
    temp = value;
  },
});

console.log(People.name); // null
People.name = 'peanut';
console.log(People.name); // peanut
```

# Object.defineProperty的使用

```
const o = {};

// 在对象中添加一个属性与数据描述符的示例
Object.defineProperty(o, 'a', {
  value : 1,
  writable : true,
  enumerable : true,
  configurable : true,
});

// 对象o有了一个属性a, 值为1


// 在对象中添加一个属性与存取描述符的示例
let b;

Object.defineProperty(o, 'b', {
  get : function(){
    return b;
  },
  set : function(newValue){
    b = newValue;
  },
  enumerable : true,
  configurable : true
});

o.b = 2;

// 对象o拥有了属性b，值为2
```

1、writable、enumerable、configurable为false的情况
  wirtable：变量不可再被重新赋值
  enumerable： 变量不能在遍历器例如for...in和Object.keys()中被读取出来，不可被遍历
  configurable：变量不可配置，定义为false之后，不能再为该变量定义配置否则报错。变量被删除(delete)、修改都会无效。
2、如果对象的属性是存取描述符，只会调用定义了的set和get（configurable、enumrable）在给一个对象属性做赋值操作，在读取属性值时，这个赋值操作赋值的值会被忽略，会去调用定义的get方法的值