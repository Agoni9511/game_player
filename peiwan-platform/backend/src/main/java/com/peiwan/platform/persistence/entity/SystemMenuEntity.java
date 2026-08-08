package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("sys_menu") public class SystemMenuEntity{@TableId(type=IdType.AUTO)public Long id;public Long parentId;public String type;public String name;public String path;public String component;public String title;public String icon;public String authMark;public Integer sortNo;public Boolean hidden;public Boolean enabled;public Boolean keepAlive;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
