.package {
    type 0 : integer
    session 1 : integer
}


handshake 1 {
    response {
        challenge 0 : string
    }
}

#交换key
exkey 2 {
    request {
        ckey 0 : string
    }
    response {
        skey 0 : string
    }
}

#验证secret
exsec 3 {
    request {
        cse 0 : string
    }
    response {
        errcode 0 : integer
    }
}

#获取验证码
verifycode 4 {
    request {
        cellphone 0 : string
    }
    response {
        errcode 0 : integer
    }
}

#注册
register 5 {
    request {
        cellphone 0 : string
        password 1 : string
        verfycode 2 : string
        promotecode 3 : string
        agentcode 4 : string
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