package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_customer_game_rank") public class CustomerGameRankEntity{@TableId(type=IdType.AUTO)public Long id;public Long profileId;public Long rankSystemId;public Long rankId;public LocalDateTime updatedAt;}
