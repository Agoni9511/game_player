package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("sys_role") public class SystemRoleEntity{@TableId(type=IdType.AUTO)public Long id;public String name;public String code;public String description;public Boolean enabled;public Boolean builtIn;public LocalDateTime createdAt;}
