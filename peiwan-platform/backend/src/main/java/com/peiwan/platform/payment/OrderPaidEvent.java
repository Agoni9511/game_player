package com.peiwan.platform.payment;

public record OrderPaidEvent(long orderId, long operatorId) {}
