package com.peiwan.platform.persistence.mapper;
import com.peiwan.platform.persistence.entity.OrderEntity;import org.apache.ibatis.annotations.*;import java.math.BigDecimal;
public interface OrderPaymentDataMapper{
 @Select("select * from pw_order where id=#{id} for update") OrderEntity lockOrder(long id);
 @Update("update pw_wallet_account set cash_balance=cash_balance-#{cash},bonus_balance=bonus_balance-#{bonus},version=version+1,updated_at=current_timestamp where id=#{id} and cash_balance>=#{cash} and bonus_balance>=#{bonus}") int debit(long id,BigDecimal cash,BigDecimal bonus);
 @Update("update pw_wallet_account set cash_balance=cash_balance+#{cash},bonus_balance=bonus_balance+#{bonus},version=version+1,updated_at=current_timestamp where id=#{id}") int refund(long id,BigDecimal cash,BigDecimal bonus);
 @Update("update pw_order set order_status='WAIT_ASSIGN',paid_amount=#{amount},paid_at=current_timestamp,updated_at=current_timestamp where id=#{id} and order_status='PENDING_PAYMENT'") int markPaid(long id,BigDecimal amount);
}
