use z2oserver;
drop procedure if exists proc_createrobot;

delimiter ;;

create procedure proc_createrobot(IN counts int)
lb_robot:begin

    declare rob_startid int;
    declare rob_nickname varchar(30);
    declare rob_username varchar(12);
    declare rob_avatorid int;
    declare rob_cellphone varchar(11);
    declare rob_gender int;
    declare rob_passwd varchar(40);
    declare rob_gold int;
    declare rob_diamond int;
    declare rob_promotecode varchar(10);
    declare agent_code varchar(15);
    declare agentid int;

    declare rob_newid int;
    
    set rob_startid = 400000;

    set agent_code = 'agent_system';
    
    select Agency.agentid into agentid from Agency where Agency.acode = agent_code;
    while counts > 0 do
        select max(userid) into rob_newid from User where User.isrobot = 1;
        if ifnull(rob_newid,0) <=> 0 then
            set rob_newid = rob_startid ;
        end if;
        set rob_newid = rob_newid + 1;

        set rob_nickname = concat('玩家', rob_newid);
        set rob_username = concat('u',rob_newid);
        set rob_diamond = 0;

        set rob_avatorid = floor(rand() *100) % 6 +1;
        set rob_gender = floor(rand() *100) % 7 +1;
        if rob_gender < 2 then
            set rob_gender = 0;
        else
            set rob_gender = 1;
        end if;

        insert into User(userid,     username,      nickname,      avatoridx,   gender,     cellphone,       password,         gold,diamond,createtime,promotecode,referrer,accountenable,isrobot,agentid) values  (  
            rob_newid, rob_username, rob_nickname , rob_avatorid ,  rob_gender  , rob_newid ,  sha1(rob_newid) ,   0,      0,    now(),         '',      '', 1, 1, agentid    );

        set counts = counts - 1;

    end while;
    



end

;;