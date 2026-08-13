package com.peiwan.platform.finance;

import com.peiwan.platform.common.ApiResponse;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/business/finance")
@PreAuthorize("hasAuthority('business:finance:list') or hasRole('admin')")
public class FinanceController {
 private final FinanceService service;
 public FinanceController(FinanceService service){this.service=service;}

 @GetMapping("/summary") public ApiResponse<?> summary(@RequestParam(required=false)String dateFrom,@RequestParam(required=false)String dateTo){return ApiResponse.ok(service.summary(dateFrom,dateTo));}
 @GetMapping("/payments") public ApiResponse<?> payments(@RequestParam(defaultValue="1")int current,@RequestParam(defaultValue="20")int size,@RequestParam(required=false)String keyword,@RequestParam(required=false)String businessType,@RequestParam(required=false)String status,@RequestParam(required=false)String channel,@RequestParam(required=false)String dateFrom,@RequestParam(required=false)String dateTo){return ApiResponse.ok(service.payments(current,size,keyword,businessType,status,channel,dateFrom,dateTo));}
 @GetMapping("/platform-ledger") public ApiResponse<?> platformLedger(@RequestParam(defaultValue="1")int current,@RequestParam(defaultValue="20")int size,@RequestParam(required=false)String keyword,@RequestParam(required=false)String businessType,@RequestParam(required=false)String direction,@RequestParam(required=false)String dateFrom,@RequestParam(required=false)String dateTo){return ApiResponse.ok(service.platformLedger(current,size,keyword,businessType,direction,dateFrom,dateTo));}
 @GetMapping("/wallet-transactions") public ApiResponse<?> walletTransactions(@RequestParam(defaultValue="1")int current,@RequestParam(defaultValue="20")int size,@RequestParam(required=false)String keyword,@RequestParam(required=false)String businessType,@RequestParam(required=false)String direction,@RequestParam(required=false)String balanceType,@RequestParam(required=false)String dateFrom,@RequestParam(required=false)String dateTo){return ApiResponse.ok(service.walletTransactions(current,size,keyword,businessType,direction,balanceType,dateFrom,dateTo));}
 @GetMapping("/player-transactions") public ApiResponse<?> playerTransactions(@RequestParam(defaultValue="1")int current,@RequestParam(defaultValue="20")int size,@RequestParam(required=false)String keyword,@RequestParam(required=false)String businessType,@RequestParam(required=false)String direction,@RequestParam(required=false)String balanceType,@RequestParam(required=false)String dateFrom,@RequestParam(required=false)String dateTo){return ApiResponse.ok(service.playerTransactions(current,size,keyword,businessType,direction,balanceType,dateFrom,dateTo));}
 @GetMapping("/settlements") public ApiResponse<?> settlements(@RequestParam(defaultValue="1")int current,@RequestParam(defaultValue="20")int size,@RequestParam(required=false)String keyword,@RequestParam(required=false)String status,@RequestParam(required=false)String dateFrom,@RequestParam(required=false)String dateTo){return ApiResponse.ok(service.settlements(current,size,keyword,status,dateFrom,dateTo));}
}
