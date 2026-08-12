package com.peiwan.platform.persistence.entity;
import com.baomidou.mybatisplus.annotation.*;import java.math.BigDecimal;import java.time.LocalDateTime;
@TableName("pw_service_penalty_ledger") public class ServicePenaltyLedgerEntity{@TableId(type=IdType.AUTO)public Long id;public String ledgerNo;public Long liabilityId;public Long orderId;public Long playerId;public Long counterpartyPlayerId;public String entryType;public String direction;public BigDecimal amount;public BigDecimal balanceBefore;public BigDecimal balanceAfter;public LocalDateTime createdAt;}
