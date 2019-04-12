
local RoomData = {
    [20001] = {
        id=20001, 
        gameid=200,
        gametype='brnn',
        name = '体验房',
        gamemode =1,        --游戏模式
        entry=10,           --最小进入
        roomnum = 1,        --房间数量
        taxrate = 0.05,     --抽水
        limitBet = {        --下注点限红
            [1] = 100,[2]=100,[3]=100,[4]=100
        } ,
        chips={             --筹码
            10,20,50,100
        }, 
        robotScoreRate = {  --机器人身上分数
            [1] = { min=30,max=300,weight=70 }, 
            [2] = { min=300,max=600,weight=25 }, 
            [3] = { min=600,max=1200,weight=5 } ,
        } ,
    },
    [20002] = {
        id = 20002,
        gameid = 200,
        gametype = 'brnn',
        name = '初级房',
        gamemode = 1,
        entry = 60,
        roomnum = 1,
        taxrate = 0.05,
        limitBet = {
            [1] = 500,[2]=500,[3]=500,[4]=500
        },
        chips={             --筹码
            10,50,100,200,
        }, 
        robotScoreRate = {  --机器人身上分数
            [1] = { min=60,max=500,weight=70 }, 
            [2] = { min=500,max=1000,weight=25 }, 
            [3] = { min=1000,max=3000,weight=5 } 
        } ,
    },
    [20003] = {
        id = 20003,
        gameid = 200,
        gametype = 'brnn',
        name = '中级房',
        gamemode = 1,
        entry = 150,
        roomnum = 1,
        taxrate = 0.05,
        limitBet = {
            [1] = 1000,[2]=1000,[3]=1000,[4]=1000
        },
        chips={             --筹码
            50,100,200,500
        }, 
        robotScoreRate = {  --机器人身上分数
            [1] = { min=60,max=500,weight=70 }, 
            [2] = { min=500,max=1000,weight=25 }, 
            [3] = { min=1000,max=3000,weight=5 } 
        } ,
    },
    
}

return RoomData