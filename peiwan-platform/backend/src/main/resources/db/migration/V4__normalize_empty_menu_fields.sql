update sys_menu set auth_mark=null where auth_mark is not null and trim(auth_mark)='';
