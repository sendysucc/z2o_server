use z2oserver;

drop procedure if exists proc_login;

delimiter ;;

create procedure proc_login(IN cellphone varchar(11),IN passwd varchar(40))
lb_login:begin

    declare errcode int;

    declare _userid int;
    declare _username varchar(15);
    declare _nickname varchar(30);
    declare _avatoridx int;
    declare _gender int;
    declare _cellphone varchar(11);
    declare _password varchar(40);
    declare _gold int;
    declare _diamond int;
    declare _createtime datetime(6);
    declare _agentid int;
    declare _agentcode varchar(30);
    declare _promotecode varchar(10);
    declare _referrer varchar(10);
    declare _accountenable boolean;
    declare _isrobot boolean;

    set _password = '';
    set errcode = 0;

    if not exists(select userid from User where User.cellphone = cellphone) then
        set errcode = 11;
        select errcode as 'errcode';
        leave lb_login;
    end if;

    select password into _password from User where User.cellphone = cellphone;
    if ifnull(_password,'') <=> '' then
        set errcode = 11;
        select errcode as 'errcode';
        leave lb_login;
    end if;

    if passwd != _password then
        set errcode = 12;
        select errcode as 'errcode';
        leave lb_login;
    end if;

    select userid,username,nickname,avatoridx,gender,cellphone,password,gold,diamond,createtime,
            promotecode,referrer,accountenable,isrobot,agentid 
    into 
    _userid, _username, _nickname, _avatoridx ,_gender, _cellphone, _password , _gold , _diamond , _createtime, 
    _promotecode, _referrer, _accountenable, _isrobot, _agentid
     from User where User.cellphone = cellphone;

     select acode into _agentcode from Agency where Agency.agentid = _agentid;


     select errcode as 'errcode', _userid as 'userid', _username as 'username', _nickname as 'nickname', _avatoridx as 'avatorid', _gender as 'gender',
        _cellphone as 'cellphone', _password as 'password', _gold as 'gold', _diamond as 'diamond', _promotecode as 'promotecode',
        _referrer as 'referrer', _accountenable as 'accountenable', _isrobot as 'isrobot', _agentcode as 'agentcode';

end

;;