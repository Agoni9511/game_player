package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.time.LocalDateTime;
@TableName("pw_player_tag") public class PlayerTagEntity{@TableId(type=IdType.AUTO)public Long id;public String tagCode;public String tagName;public String tagColor;public String tagGroup;public Integer sortNo;public Boolean enabled;public LocalDateTime createdAt;public LocalDateTime updatedAt;}
