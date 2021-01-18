---
title: 使用karma+mocha构建web测试环境
copyright: true
date: 2020-09-18 15:47:47
tags: 学习笔记
category: 学习笔记
---

# 什么是karma

<strong>karma是一个基于Node.js的JavaScript测试执行过程管理工具（Test Runner）。</strong>换句话说，karma为测试框架准备宿主环境，可以让测试用例在真正的浏览器中运行。
<!--more-->

* karma启动一个web服务器，生成包含js源代码和js测试脚本的页面
* 运行浏览器加载页面，并显示测试的结果
* 如果开启watch，则每当有文件修改时，继续执行以上过程


# 安装karma

由于输入./node_modules/karma/bin/karma start比较繁琐，所以我们首先在全局安装karma-cli

```shell
npm install -g karma-cli
```

然后我们就可以在任何地方简单的运行karma，它将始终运行本地版本。

首先我们在创建一个空的文件夹,并进入该文件夹内 执行npm init -y命令

```shell
mkdir karma-demo && cd karma-demo && npm init -y
```

在karma-demo目录下执行
```shell
npm install karma -D
```

接下来在karma-demo目录中运行karma init命令来进行初始化，并根据指示完成操作
![示例图](/uploads/单元测试框架-karma/tips.jpg)

上图是init选项的示例图，这里我们使用mocha测试框架，Chrome作为宿主环境提供给代码运行（也可以使用其他浏览器作为宿主环境，比如PhantomJS、IE、Firefox等）最后我们的项目内生成了一个karma.conf.js文件。

最后由于我们选择了mocha测试框架需要把mocha以及断言库chai安装在我们的项目本地
```
npm install mocha chai karma-chai -D
```

# 运行karma

我们在src内创建一个index.js，里面编写了一个简单的add函数
```javascript
function add(x, y) {
  return x + y;
};
```

在test目录下编写一个简单的测试脚本，我们使用的mocha测试框架，具体的api可以参考[mocha中文网](https://mochajs.cn/)，[测试框架 Mocha 实例教程](http://www.ruanyifeng.com/blog/2015/12/a-mocha-tutorial-of-examples.html)，测试脚本内容如下
```javascript
const assert = chai.assert;

describe('加法函数的测试', function() {
  it('1加1应该等于2', function() {
    assert.equal(add(1, 1), 2);
  });
});
```

然后我们在项目根目录下运行karma start命令, 会自动帮我们唤起一个浏览器去执行测试脚本，最终我们可以看到运行的结果如下
![结果图](/uploads/单元测试框架-karma/result.jpg)

可以看到，运行的结果是测试成功的，由于我们之前设置了监控文件的修改，所以当我们修改源文件或者测试脚本的时候，karma会自动帮我们再次运行，无需我们手动操作

我们尝试修改add方法
```javascript
function add(x, y) {
  return x + y + 1;
}
```

可以看到，文件发生了改变 返回的测试结果提示我们测试错误。
![结果图](/uploads/单元测试框架-karma/result-failed.jpg)

# coverage
如何衡量测试脚本的质量呢？其中一个参考指标就是代码覆盖率（coverage）。

什么是代码覆盖率？简而言之就是测试中运行到的代码占所有代码的比率。其中又可以分为行数覆盖率，分支覆盖率等。具体的含义不再细说，有兴趣的可以自行查阅资料。

虽然并不是说代码覆盖率越高，测试的脚本写得越好），但是代码覆盖率对撰写测试脚本还是有一定的指导意义的。因此接下来我们在karma环境中添加coverage。

首先安装好karma覆盖率工具

```shell
npm install karma-coverage -D
```

修改配置文件karma.conf.js
```javascript
// Karma configuration
// Generated on Sat Sep 19 2020 10:12:50 GMT+0800 (China Standard Time)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['mocha', 'chai'],


    // list of files / patterns to load in the browser
    files: [
      'src/**/*.js',
      'test/**/*.js'
    ],


    // list of files / patterns to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      'src/**/*.js': ['coverage'],
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress', 'coverage'],

    coverageReporter: {
      type: 'html',
      dir: 'coverage/',
    },

    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome'],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity
  })
}
```

我们添加好coverage功能，并且把coverage文件的最终生成文件目录设置到/coverage里，重新输入命令karma start，我们发现这次我们的目录内生成了一个coverage文件夹。

![目录](/uploads/单元测试框架-karma/directory.jpg)

里面有一个index.html文件 打开告知我们代码覆盖率为100%，那是因为我们只有一个add函数。

![报告](/uploads/单元测试框架-karma/reporter.jpg)

我们修改src/index.js 添加一个sub函数
```
function add(x, y) {
  return x + y;
};

function sub(x, y) {
  return x - y;
}
```

重新执行karma-start方法，得到的代码覆盖率只有50%，因为我们的sub方法没有被测试用例使用。

![报告](/uploads/单元测试框架-karma/reporter-half.jpg)

# 使用webpack + babel

在实际项目中，我们一般都会使用webpack和ES6相关的内容，所以接下来将Webpack和Babel集成进Karma环境中。

安装karma-webpack
```shell
npm i karma-webpack webpack -D
```

安装babel
```shell
npm i babel-loader babel-core babel-preset-es2015 -D
```

src目录下index.js文件修改为
```javascript
export default function add(x, y) {
  return x + y;
};
```

test目录下index.js文件修改为
```javascript
import indexAdd from '../src/index';
const assert = chai.assert;

describe('加法函数的测试', function() {
  it('1加1应该等于2', function() {
    assert.equal(indexAdd(1, 1), 2);
  });
});
```

接下来修改配置文件
```javascript
// Karma configuration
// Generated on Sat Sep 19 2020 10:12:50 GMT+0800 (China Standard Time)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['mocha', 'chai'],


    // list of files / patterns to load in the browser
    files: [
      'test/**/*.js'
    ],


    // list of files / patterns to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      'test/**/*.js': ['webpack', 'coverage'],
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress', 'coverage'],

    coverageReporter: {
      type: 'html',
      dir: 'coverage/',
    },

    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome'],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    // Concurrency level
    // how many browser should be started simultaneous
    concurrency: Infinity,
    webpack: {
      module: {
        rules: [
          {
            test: /\.js$/,
            exclude: /node_modules/,
            use: [
              {
                loader: 'babel-loader',
                options: {
                  presets: ['es2015'],
                }
              }
            ]
          },
        ]
      }
    },
  })
}

```

> 注意一下配置文件的修改
* files只留下test文件。因为webpack会自动把需要的其它文件都打包进来，所以只需要留下入口文件。
* preprocessors也修改为test文件，并加入webpack域处理器
* 加入webpack配置选项。可以自己定制配置项，但是不需要entry和output。这里加上babel-loader来编译ES6代码

运行karma start 测试结果依然是正确的。

再看看coverage

![报告](/uploads/单元测试框架-karma/reporter-webpack.jpg)

原因很简单，webpack会加入一些代码，影响了代码的Coverage。如果我们引入了一些其它的库，比如jquery之类的，将源代码和库代码打包在一起后，覆盖率会更难看。。这样的Coverage就没有了参考的价值。

安装 babel-plugin-istanbul
```shell
npm install babel-plugin-istanbul -D
```

修改webpack中的babel-loader的配置
```javascript
{
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: [
          {
            loader: 'babel-loader',
            options: {
              presets: ['es2015'],
              plugins: ['istanbul'],
            }
          }
        ]
      },
    ]
  }
}
```

执行karma start查看coverage结果得到
![报告](/uploads/单元测试框架-karma/reporter-istanbul.jpg)

我们看到存在两个coverage的报告其中一个是我们src目录下的，一个是test目录下的。但实际我们只需要关注最终test文件下方法使用率的结果，所以删除preprocessors里的coverage

```javascript
{
  preprocessors: {
    'test/**/*.js': ['webpack'],
  },
}
```
最终输出报告

![报告](/uploads/单元测试框架-karma/reporter-finally.jpg)

# Vue项目内使用karma

我们的Vue-cli已经允许选择集成karma。

HelloWorld.spec.js如下
```javascript
import Vue from 'vue'
import HelloWorld from '@/components/HelloWorld'

describe('HelloWorld.vue', () => {
  it('should render correct contents', () => {
    const Constructor = Vue.extend(HelloWorld)
    const vm = new Constructor().$mount()
    expect(vm.$el.querySelector('.hello h1').textContent)
      .to.equal('Welcome to Your Vue.js App')
  })
})
```

HelloWorld.vue
```vue
<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <h2>Essential Links</h2>
  </div>
</template>

<script>
export default {
  name: 'HelloWorld',
  data () {
    return {
      msg: 'Welcome to Your Vue.js App'
    }
  }
}
</script>
```

karma允许我们去测试某个组件使用Vue直接$mount生成dom 然后获取dom内的文本节点来判断测试是否成功。当然在Vue内使用karma进行测试还有比较多的测试内容可以进行测试，例如[Vue单元测试---Karma+Mocha+Chai实践](https://www.ctolib.com/topics-123266.html)

# 参考链接
* [测试框架 Mocha 实例教程](http://www.ruanyifeng.com/blog/2015/12/a-mocha-tutorial-of-examples.html)
* [前端单元测试之Karma环境搭建](https://segmentfault.com/a/1190000006895064)
















