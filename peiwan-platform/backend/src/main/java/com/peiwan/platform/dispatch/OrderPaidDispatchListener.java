package com.peiwan.platform.dispatch;

import com.peiwan.platform.payment.OrderPaidEvent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
public class OrderPaidDispatchListener {
  private static final Logger log = LoggerFactory.getLogger(OrderPaidDispatchListener.class);
  private final DispatchService dispatch;

  public OrderPaidDispatchListener(DispatchService dispatch) {
    this.dispatch = dispatch;
  }

  @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT)
  public void dispatchPaidOrder(OrderPaidEvent event) {
    try {
      dispatch.autoCreate(event.orderId(), event.operatorId());
    } catch (RuntimeException exception) {
      // Payment remains successful; operations can retry the waiting order later.
      log.warn("Unable to auto-dispatch paid order {}: {}", event.orderId(), exception.getMessage());
    }
  }
}
