1.客户端首先向 webend 获取平台信息：
    平台运行和维护情况，以及公告，以及GATE服务器地址等

2.维护：
    如果平台维护，则新的玩家不能登陆，直到解除平台维护状态为止。 已经在游戏中的玩家，则等游戏结束后，推出平台。
    如果维护游戏，则新玩家不能加入游戏匹配，知道解除游戏维护状态为止。已经在游戏中的玩家，则等游戏结束后，退出游戏。

    对于维护时，没有处于游戏中的玩家，发送维护通知，使玩家下线


客户端与主要的服务端主要的交互流程：

          获取服务端信息
client --------------------> webend
          连接gated
client --------------------> gate （负责c/s通信数据的加密/解密，以及将客户端消息转发给合适的服务,以及给client发送数据包）

登陆/注册:

client <------------------------> gate <---------------------> auth


登陆成功后：
client <------------------------> gate <----------------------> hall

游戏过程:
client <------------------------> gate <-----------------------> games




玩家加入游戏： joinroom
    百人类游戏，在游戏启动时，就加载机器人到游戏中，

    对战类游戏，在匹配玩家时，才将机器人加入进来，

    单人游戏，没有机器人


匹配：
    
    