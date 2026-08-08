package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("sys_user") public class SystemUserEntity{@TableId(type=IdType.AUTO)public Long id;public String username;public String password;public String nickname;public String email;public String phone;public String gender;public String avatar;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
