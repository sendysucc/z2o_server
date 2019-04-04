.package {
    type 0 : integer
    session 1 : integer
}

#获取验证码
verifycode 4 {
    request {
        cellphone 0 : string
    }
    response {
        errcode 0 : integer
        vcode 1 : string
    }
}

#注册
register 5 {
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
login 6 {
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
        gamingservice 9 : string
        gaminghandle 10 : integer
    }
}