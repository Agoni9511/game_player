package com.peiwan.platform.order;

import com.peiwan.platform.persistence.entity.OrderMemberEntity;
import com.peiwan.platform.persistence.mapper.*;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class OrderMemberService {
 private final OrderMemberMapper members;
 private final OrderMemberDataMapper data;

 public OrderMemberService(OrderMemberMapper members,OrderMemberDataMapper data){this.members=members;this.data=data;}

 @Transactional
 public JoinResult join(long orderId,long playerId,String source,Long dispatchTaskId){
  var order=data.lockOrder(orderId);
  if(order==null)throw new IllegalArgumentException("订单不存在");
  if(!"WAIT_ASSIGN".equals(order.get("order_status")))throw new IllegalArgumentException("订单已满员或不在待接单状态");
  if(data.memberExists(orderId,playerId)>0)throw new IllegalArgumentException("该陪玩师已经接过此订单");
  int required=order.get("required_player_count")==null?1:Math.max(1,((Number)order.get("required_player_count")).intValue());
  int before=data.joinedCount(orderId);
  if(before>=required)throw new IllegalArgumentException("订单接单人数已满");
  var member=new OrderMemberEntity();member.orderId=orderId;member.playerId=playerId;member.memberStatus="ACCEPTED";member.joinSource=source;member.dispatchTaskId=dispatchTaskId;member.joinedAt=LocalDateTime.now();
  try{members.insert(member);}catch(DuplicateKeyException e){throw new IllegalArgumentException("该陪玩师已经接过此订单");}
  int current=before+1;boolean full=current>=required;
  if(full&&data.fillOrder(orderId)==0)throw new IllegalArgumentException("订单状态已变化，接单失败");
  return new JoinResult(current,required,full);
 }

 public boolean belongs(long orderId,long playerId){return data.activeMemberExists(orderId,playerId)>0;}
 public boolean belongsHistorically(long orderId,long playerId){return data.memberExistsAnyStatus(orderId,playerId)>0;}
 public Map<String,Object> member(long orderId,long playerId){return data.member(orderId,playerId);}
 public List<Map<String,Object>> members(long orderId){return data.members(orderId);}
 public List<Long> activePlayerIds(long orderId){return data.activePlayerIds(orderId);}
 public void updateStatuses(long orderId,String status){data.updateStatuses(orderId,status);}
 public long activeOrderCount(long playerId){return data.activeOrderCount(playerId);}
 public record JoinResult(int memberCount,int requiredCount,boolean full){public int remaining(){return Math.max(0,requiredCount-memberCount);}}
}
