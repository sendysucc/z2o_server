.package {
    type 0 : integer
    session 1 : integer
}

#获取验证码
verifycode 1 {
    request {
        cellphone 0 : string
    }
    response {
        errcode 0 : integer
        vcode 1 : string
    }
}

#注册
register 2 {
    request {
        cellphone 0 : string
        password 1 : string
        verifycode 2 : string
        referrer 3 : string     #推荐人
        agentcode 4 : string    #代理编码
    }
    response {
        errcode 0 : integer
    }
}

#登录
login 3 {
    request {
        cellphone 0 : string
        password 1 : string
    }
    response {
        errcode 0 : integer
        userid 1 : integer
        nickname 2 : string
        avatorid 3 : integer
        gender 4 : integer
        cellphone 5 : string
        password 6 : string
        gold   7 : integer
        diamond 8 : integer
        promotecode 9 : string
        accountenable 10 : boolean
        gameid    11  : integer
        roomid 12   : integer
    }
}