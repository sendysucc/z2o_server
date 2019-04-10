use z2oserver;

drop procedure if exists proc_register;

delimiter ;;

create procedure proc_register(IN cellphone varchar(11), IN passwd varchar(40), IN referrer varchar(30), IN agentcode varchar(30))
lb_reg:begin

    declare errcode int;
    declare newuserid int;
    declare start_userid int;
    declare avatorid int;
    declare nickname varchar(30);
    declare gender int;
    declare gold int;
    declare diamond int;
    declare agentid int;
    
    
    set start_userid = 300100;
    set agentid = 0;
    
    if exists(select userid from User where User.cellphone = cellphone) then
        set errcode = 8;
        select errcode as 'errcode';
        leave lb_reg;
    end if;

    if not exists( select  agentid from Agency where Agency.acode = agentcode ) then
        set agentcode = 'agent_system';
    end if;

    select Agency.agentid into agentid from Agency where Agency.acode = agentcode;

    if not exists( select userid from User where User.referrer =  referrer ) then
        set referrer = 'ref_system';
    end if;

    select max(User.userid) into newuserid from User where User.isrobot = 0;
    if ifnull(newuserid,start_userid) <=> start_userid then
        set newuserid = start_userid;
    end if;
    set newuserid = newuserid + 1;

    select concat('玩家', newuserid) into nickname;

    set avatorid = floor(rand() *100) % 6 +1;
    
    set gender = floor(rand()*100) %2;
    set gold = 0;
    set diamond = 0;

    insert into User(userid,username,nickname,avatoridx,gender,cellphone,password,gold,diamond,createtime,agentid,promotecode,referrer,accountenable,isrobot) value(
        newuserid,cellphone, nickname,avatorid,gender,cellphone,passwd,gold,diamond,now(),agentid,' ', referrer, 1,0);

    set errcode = 0;

    select errcode as 'errcode';
end
;;