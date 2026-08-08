package com.peiwan.platform.persistence.mapper;import com.baomidou.mybatisplus.core.metadata.IPage;import com.baomidou.mybatisplus.extension.plugins.pagination.Page;import org.apache.ibatis.annotations.*;import java.util.*;
public interface WalletDataMapper{
 @Select("select * from pw_wallet_account where owner_type='USER' and owner_id=#{uid} for update") Map<String,Object> lockUserWallet(long uid);
 @Update("update pw_wallet_account set cash_balance=cash_balance+#{cash},bonus_balance=bonus_balance+#{bonus},version=version+1,updated_at=current_timestamp where id=#{id}") int creditRecharge(long id,java.math.BigDecimal cash,java.math.BigDecimal bonus);
 @Select("select m.*,l.level_code,l.level_name,l.discount_rate,l.benefit_description from pw_user_member m join pw_member_level l on l.id=m.level_id where m.user_id=#{uid}") Map<String,Object> member(long uid);
 @Select("select * from pw_member_level where enabled=true and min_recharge_amount<=#{amount} order by min_recharge_amount desc limit 1") Map<String,Object> matchedLevel(java.math.BigDecimal amount);
 @Select("<script>select * from pw_wallet_transaction where owner_type='USER' and owner_id=#{uid}<if test='businessType != null and businessType != &quot;&quot;'> and business_type=#{businessType}</if> order by id desc</script>") IPage<Map<String,Object>> transactions(Page<Map<String,Object>> page,@Param("uid")long uid,@Param("businessType")String businessType);
}
