---
title: IM 即时通讯
copyright: true
date: 2022-04-06 15:56:37
tags: 学习笔记
category: 学习笔记
---

> 即时通讯（Instant Messaging，IM）即实时通信系统，允许两人或多人使用网络实时的传递文字、图片、语音来交流。比如我们每天使用的微信就属于IM系统

<!--more-->

# IM 通信相关的业务场景
1. IM 即时通讯（SaaS 中台客服端）
2. Live 直播聊天室（直播）
3. CS 在线客服（客服页面级）

> IM 不同业务场景通信的差异

IM 聊天场景是以人为中心的通信系统。强调人与人之间的关系，因此才有好友与群的概念，这类系统如果用户量与用户活跃度不错的话，通常每天可以产生百万条消息，如果是群的话，消息还会扩散

Live 直播场景是以群为中心的通信系统，通常称作聊天室。在IM场景中一个群的人数上限通常是 500，达到 1k 就非常高了，这是它的业务特点导致的。而在一个聊天室中，你需要在设计时考虑到一个房间可能有 10w+ 的在线用户，不过在聊天室场景中用户不可能同时在多个 room 中

CS 客服场景是以会话为中心的通信系统。也就是沟通都是以会话为单位，在这个会话中，你可能首先与机器人扯了一会皮，然后与售前妹子沟通了一会，发现问题不对，被转给一个技术支持小哥了。可以看出系统的核心逻辑是基于会话的生命周期来设计，而聊天中的人与 AI 则是被调度的对象

# 实现 IM 通信的几种方式
1. WebSocket
2. FlashSocket
3. http轮询

其中 1 和 2 是用 Tcp 长连接实现的，其消息的实时性很好理解，但这两种方案都存在一些局限性，不通用（服务器长期维护长连接需要一定的成本，各个浏览器支持程度不一）。方案 3 才算是 webim 实现消息推送的“正统”方案，用 http 短连接轮询的方式实现“伪长连接”

# 通过 WebSocket 呈现一个简单的 IM 通信过程
[egg Socket.io](https://www.eggjs.org/zh-CN/tutorials/socketio#%E5%AE%89%E8%A3%85-egg-socketio)
[Socket.io](https://socket.io/get-started/chat)

```javascript
// app.js
const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require("socket.io");
const io = new Server(server);

app.get('/huasheng', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

app.get('/baiyang', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

io.on('connection', (socket) => {
  console.log('a user connected');
  socket.broadcast.emit('chat message', '有人进入了聊天室');

  socket.on('chat message', (msg) => {
    io.emit('chat message', msg);
  });

  socket.on('disconnect', () => {
    console.log('user disconnected');
  });
});
server.listen(3000, () => {
  console.log('listening on *:3000');
});
```

```html
<!-- index.html -->
<!DOCTYPE html>
<html>
  <head>
    <title>Socket.IO chat</title>
    <style>
      body { margin: 0; padding-bottom: 3rem; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }

      #form { background: rgba(0, 0, 0, 0.15); padding: 0.25rem; position: fixed; bottom: 0; left: 0; right: 0; display: flex; height: 3rem; box-sizing: border-box; backdrop-filter: blur(10px); }
      #input { border: none; padding: 0 1rem; flex-grow: 1; border-radius: 2rem; margin: 0.25rem; }
      #input:focus { outline: none; }
      #form > button { background: #333; border: none; padding: 0 1rem; margin: 0.25rem; border-radius: 3px; outline: none; color: #fff; }

      #messages { list-style-type: none; margin: 0; padding: 0; }
      #messages > li { padding: 0.5rem 1rem; }
      #messages > li:nth-child(odd) { background: #efefef; }
    </style>
  </head>
  <body>
    <ul id="messages"></ul>
    <form id="form" action="">
      <input id="input" autocomplete="off" /><button>Send</button>
    </form>
  </body>
  <script src="/socket.io/socket.io.js"></script>
  <script>
    var socket = io();
    const enumsPeople = {
      '/huasheng': '花生',
      '/baiyang': '白杨',
    };
  
    var messages = document.getElementById('messages');
    var form = document.getElementById('form');
    var input = document.getElementById('input');
  
    form.addEventListener('submit', function(e) {
      e.preventDefault();
      if (input.value) {
        socket.emit('chat message', `${enumsPeople[location.pathname]}: ${input.value}`);
        input.value = '';
      }
    });
  
    socket.on('chat message', function(msg) {
      var item = document.createElement('li');
      item.textContent = msg;
      messages.appendChild(item);
      window.scrollTo(0, document.body.scrollHeight);
    });
  </script>
</html>
```



# IM 在 SaaS 中台的应用
SaaS 中台通过使用腾讯云IM作为通信中间件来与服务端交互完成涂色或逆向交互与微信消息的打通，为完成前后端的业务数据传输需要在IM通信中间件协议上定制应用协议
![流程图](/uploads/IM即时通讯/process.jpg)

## 技术选型
[即时通信 IM](https://cloud.tencent.com/document/product/269)
[TIM SDK文档](https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html)
[阿里百川](https://bigdata.taobao.com/api.htm?docId=24164&docType=2)

## 核心代码
```javascript
import TIM from "tim-js-sdk";
import COS from "cos-js-sdk-v5";

export const SDK_READY = TIM.EVENT.SDK_READY;

class Communication {
  // 必须参数注入
  inject(communicationInfo = {}) {
    const { sdkAppID, userID, userSig } = communicationInfo;
    if (
      utils.isNull(sdkAppID) ||
      utils.isNull(userID) ||
      utils.isNull(userSig)
    ) {
      throw new Error("sdkAppID、userId、userSign 为必须值");
    }
    this.sdkAppID = sdkAppID;
    this.userID = userID;
    this.userSig = userSig;
  }

  // 创建实例
  create() {
    if (this.instance) return;
    this.instance = TIM.create({ SDKAppID: this.sdkAppID });
    this.instance.registerPlugin({ "cos-wx-sdk": COS });
    this.instance.setLogLevel(process.env.NODE_ENV === "development" ? 0 : 1);
  }

  // 登录账号
  async login() {
    // await this.instance.logout();
    const { userID, userSig } = this;
    this.instance.login({
      userID,
      userSig
    });
  }

  // 登出账号
  async logout() {
    this.instance.logout();
  }

  async destory() {
    await this.logout();
    this.instance = null;
  }

  // 接收消息
  consuIMMessage() {
    this.instance.on(TIM.EVENT.MESSAGE_RECEIVED, this.onMessageReceived, this);
  }

  // 取消接受消息
  cancelConsuIMMessage() {
    this.instance.off(TIM.EVENT.MESSAGE_RECEIVED, this.onMessageReceived, this);
  }

  // 消息接受处理
  onMessageReceived(event) {
    if (event.name === "onMessageReceived" && event.data) {
      const messageListFromIM = event.data;
      messageListFromIM.forEach(item => {
        item._elements.forEach(jtem => {
          this.parseImMessage(jtem?.content?.data);
        });
      });
    }
  }

  // 解析消息
  parseImMessage(messageString) {
    if (messageString) {
      const messageData = JSON.parse(messageString);
      const { protocol, protocolContent } = messageData;
      switch (protocol) {
        case "chat_msg":
          this.chatMessage(protocolContent);
          break;
        case "send_callback":
          this.sendCallback(protocolContent);
          break;
        case "recall_msg_callback":
          this.recallMsgCallback(protocolContent)
          break;
        case "chat_error":
          this.chatError(protocolContent);
          break;
        case "miniprogram_cover_url_callback":
          this.miniprogramCallback(protocolContent);
          break;
        case "external_apply":
          this.externalApply(protocolContent);
          break;
        default:
          break;
      }
    }
  }

  // 聊天消息
  chatMessage(messageInfo) {}

  // 发送消息回调
  sendCallback(messageInfo) {}

  // 撤回消息回调
  recallMsgCallback(messageInfo) {}

  // 退出了群聊
  chatError(messageInfo) {}

  // 小程序异步获取file体回调
  miniprogramCallback(messageInfo) {}

  // 好友申请异步获取申请状态
  externalApply(messageInfo) {}
}

export default Reflect.construct(Communication, []);
```

## IM 消息类型
|企微消息类型|前端解析消息值|是否支持|
|---|---|
|聊天消息|chat_msg|是|
|发送消息回调|send_callback|是|
|撤回消息回调|recall_msg_callback|是|
|退群消息|chat_error|是|
|异步获取小程序fileCode回调|miniprogram_cover_url_callback|是|
|异步获取好友申请状态|external_apply|是|

## IM 企微消息类型
|企微消息类型|前端解析消息值|是否支持|
|---|---|
|系统消息|system|是|
|文本消息|text|是|
|图片消息|image|是|
|语音消息|voice|是|
|视频消息|video|是|
|图文链接|image_text|是|
|文件消息|file|是|
|小程序消息|miniprogram|是|
|好友名片|friend|否|
|视频号消息|video_platform_live|否|
|视频号直播间消息|video_platform_live|否|
|视频号名片消息|video_platform_card|否|
|音乐消息|music|否|
|其他消息|other|否|

## 后续规划 & 未来展望
1. 接入更多的消息类型以及企微消息类型
2. 抽象IM方法、业务封装TIM包 以支持各个业务线使用 IM 能力
