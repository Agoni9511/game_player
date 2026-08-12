package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_customer_game_profile") public class CustomerGameProfileEntity{@TableId(type=IdType.AUTO)public Long id;public Long userId;public Long gameId;public Long serverId;public String gameAccount;public String gameNickname;public Boolean isDefault;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
