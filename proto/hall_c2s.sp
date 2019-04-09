.package {
    type 0 : integer
    session 1 : integer
}

.game {
        gameid 0 : integer
        name 1 : string
        url 2 : string
        status 3 : integer
}

#游戏列表
gamelist 1 {
    response {
        errcode 0 : integer
        games 1 : *game
    }
}

.room {
    roomid 1 : integer
    name 2 : string
    gamemode 3 : integer
    entry 4 : integer
    taxrate 5 : integer(2)
    limitBet 6 : string
    chips 7 : *integer
}

#房间列表
roomlist 2 {
    request {
        gameid 0 : integer
    }
    response {
        errcode 0 : integer
        rooms 1 : *room
    }
}

#邮件列表
maillist 3 {
    request {

    }
    response {

    }
}

#通知列表
noticelist 4 {
    request {

    }
    response {

    }
}

#充值
charge 5 {
    request {

    }
    response {

    }
}

#注销登陆
logout 6 {
    response {
        errcode 0 : integer
    }
}