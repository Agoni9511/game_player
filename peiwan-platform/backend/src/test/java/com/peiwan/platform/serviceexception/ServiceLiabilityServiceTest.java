package com.peiwan.platform.serviceexception;

import com.peiwan.platform.persistence.entity.PlatformLedgerEntity;
import com.peiwan.platform.persistence.entity.ServiceLiabilityEntity;
import com.peiwan.platform.persistence.mapper.*;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class ServiceLiabilityServiceTest {
  @Test
  void everyTransferredMemberPaysSixteenPercentToPlatform() {
    var liabilities = mock(ServiceLiabilityMapper.class);
    var ledgers = mock(ServicePenaltyLedgerMapper.class);
    var data = mock(ServiceLiabilityDataMapper.class);
    var accounts = mock(PlayerAccountMapper.class);
    var accountTransactions = mock(PlayerAccountTransactionMapper.class);
    var platformLedgers = mock(PlatformLedgerMapper.class);
    var service = new ServiceLiabilityService(liabilities, ledgers, data, accounts, accountTransactions, platformLedgers);

    when(data.liabilityCount(7L, "TRANSFER_COMPENSATION")).thenReturn(0);
    when(data.baseUnitPrice(7L)).thenReturn(new BigDecimal("100.00"));
    when(data.transferLinks(7L)).thenReturn(List.of(
      Map.of("exception_request_id", 101L, "from_order_member_id", 11L, "to_order_member_id", 12L, "from_player_id", 21L, "to_player_id", 22L),
      Map.of("exception_request_id", 102L, "from_order_member_id", 12L, "to_order_member_id", 13L, "from_player_id", 22L, "to_player_id", 23L)
    ));
    when(accounts.selectCount(any())).thenReturn(1L);
    when(data.lockAccount(21L)).thenReturn(Map.of("id", 31L, "available_balance", new BigDecimal("100.00")));
    when(data.lockAccount(22L)).thenReturn(Map.of("id", 32L, "available_balance", new BigDecimal("80.00")));

    service.settleTransferCompensations(7L);

    verify(data).debit(31L, new BigDecimal("16.00"));
    verify(data).debit(32L, new BigDecimal("16.00"));
    verify(data, never()).credit(anyLong(), any());

    var liabilityCaptor = ArgumentCaptor.forClass(ServiceLiabilityEntity.class);
    verify(liabilities, times(2)).insert(liabilityCaptor.capture());
    assertThat(liabilityCaptor.getAllValues()).allSatisfy(x -> {
      assertThat(x.rootOrderMemberId).isEqualTo(11L);
      assertThat(x.beneficiaryOrderMemberId).isNull();
      assertThat(x.beneficiaryPlayerId).isNull();
      assertThat(x.rate).isEqualByComparingTo("0.1600");
      assertThat(x.amount).isEqualByComparingTo("16.00");
    });
    assertThat(liabilityCaptor.getAllValues()).extracting(x -> x.liableOrderMemberId).containsExactly(11L, 12L);

    var platformCaptor = ArgumentCaptor.forClass(PlatformLedgerEntity.class);
    verify(platformLedgers, times(2)).insert(platformCaptor.capture());
    assertThat(platformCaptor.getAllValues()).allSatisfy(x -> {
      assertThat(x.businessType).isEqualTo("SERVICE_TRANSFER_PENALTY");
      assertThat(x.direction).isEqualTo("IN");
      assertThat(x.amount).isEqualByComparingTo("16.00");
    });
  }
}
