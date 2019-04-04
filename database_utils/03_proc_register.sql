use z2oserver;

drop procedure if exists proc_register;

delimiter ;;

create procedure proc_register(IN cellphone varchar(11), IN passwd varchar(40), IN referrer varchar(30), IN agentcode varchar(30))
lb_reg:begin

    declare errcode int;
    declare newuserid int;
    declare start_userid int;
    declare avatorid = int;
    declare nickname varchar(30);
    
    set start_userid = 300000;

    
    if exists(select userid from User where User.cellphone = cellphone) then
        set errcode = 8;
        select errcode as 'errcode';
        leave lb_reg;
    end if;

    if not exists( select  agentid from Agency where Agency.acode = agentcode ) then
        set agentcode = 'z2o_agent';
    end if;

    if not exists( select userid from User where User.referrer =  referrer ) then
        set referrer = 'z2o_ref';
    end if;

    select max(userid) into newuserid from User where User.isrobot = 0;
    if ifnull(newuserid,start_userid) <=> start_userid then
        set newuserid = start_userid;
    end if;
    set newuserid = start_userid + 1;



end
;;