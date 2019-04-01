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
