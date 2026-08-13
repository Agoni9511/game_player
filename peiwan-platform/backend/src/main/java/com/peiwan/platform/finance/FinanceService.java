package com.peiwan.platform.finance;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.peiwan.platform.persistence.mapper.FinanceDataMapper;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.Map;

@Service
public class FinanceService {
 private final FinanceDataMapper data;
 public FinanceService(FinanceDataMapper data){this.data=data;}

 public Map<String,Object> summary(String dateFrom,String dateTo){var range=range(dateFrom,dateTo);return data.summary(range.startAt,range.endAt);}
 public Map<String,Object> payments(int current,int size,String keyword,String businessType,String status,String channel,String dateFrom,String dateTo){var r=range(dateFrom,dateTo);return page(data.payments(page(current,size),text(keyword),text(businessType),text(status),text(channel),r.startAt,r.endAt),current,size);}
 public Map<String,Object> platformLedger(int current,int size,String keyword,String businessType,String direction,String dateFrom,String dateTo){var r=range(dateFrom,dateTo);return page(data.platformLedger(page(current,size),text(keyword),text(businessType),text(direction),r.startAt,r.endAt),current,size);}
 public Map<String,Object> walletTransactions(int current,int size,String keyword,String businessType,String direction,String balanceType,String dateFrom,String dateTo){var r=range(dateFrom,dateTo);return page(data.walletTransactions(page(current,size),text(keyword),text(businessType),text(direction),text(balanceType),r.startAt,r.endAt),current,size);}
 public Map<String,Object> playerTransactions(int current,int size,String keyword,String businessType,String direction,String balanceType,String dateFrom,String dateTo){var r=range(dateFrom,dateTo);return page(data.playerTransactions(page(current,size),text(keyword),text(businessType),text(direction),text(balanceType),r.startAt,r.endAt),current,size);}
 public Map<String,Object> settlements(int current,int size,String keyword,String status,String dateFrom,String dateTo){var r=range(dateFrom,dateTo);return page(data.settlements(page(current,size),text(keyword),text(status),r.startAt,r.endAt),current,size);}

 private Page<Map<String,Object>> page(int current,int size){return new Page<>(Math.max(1,current),Math.min(200,Math.max(1,size)));}
 private Map<String,Object> page(IPage<Map<String,Object>> result,int current,int size){return Map.of("records",result.getRecords(),"current",Math.max(1,current),"size",Math.min(200,Math.max(1,size)),"total",result.getTotal());}
 private String text(String value){return value==null?"":value.trim();}
 private Range range(String from,String to){
  try{
   LocalDateTime start=from==null||from.isBlank()?null:LocalDate.parse(from).atStartOfDay();
   LocalDateTime end=to==null||to.isBlank()?null:LocalDate.parse(to).plusDays(1).atStartOfDay();
   if(start!=null&&end!=null&&!start.isBefore(end))throw new IllegalArgumentException("开始日期不能晚于结束日期");
   return new Range(start,end);
  }catch(DateTimeParseException e){throw new IllegalArgumentException("日期格式必须为 yyyy-MM-dd");}
 }
 private record Range(LocalDateTime startAt,LocalDateTime endAt){}
}
