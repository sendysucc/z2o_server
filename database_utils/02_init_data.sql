
insert into Agency(name,acode,cellphone,password,gold,diamond,createtime) value(
    '系统', 'agent_system','18665672920', sha1('system'),0,0,now());

call proc_createrobot(200);