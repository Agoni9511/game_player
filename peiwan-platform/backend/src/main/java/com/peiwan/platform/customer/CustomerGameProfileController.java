package com.peiwan.platform.customer;
import com.peiwan.platform.common.ApiResponse;import org.springframework.security.core.Authentication;import org.springframework.web.bind.annotation.*;import java.util.Map;
@RestController @RequestMapping("/api/customer/game-profiles") public class CustomerGameProfileController{private final CustomerGameProfileService service;public CustomerGameProfileController(CustomerGameProfileService service){this.service=service;}
 @GetMapping public ApiResponse<?> list(Authentication a,@RequestParam(required=false)Long gameId){return ApiResponse.ok(service.list((Long)a.getPrincipal(),gameId));}
 @PostMapping public ApiResponse<?> create(Authentication a,@RequestBody CustomerGameProfileService.Command b){return ApiResponse.ok(Map.of("id",service.save(null,(Long)a.getPrincipal(),b)));}
 @PutMapping("/{id}") public ApiResponse<?> update(Authentication a,@PathVariable long id,@RequestBody CustomerGameProfileService.Command b){service.save(id,(Long)a.getPrincipal(),b);return ApiResponse.ok();}
 @DeleteMapping("/{id}") public ApiResponse<?> delete(Authentication a,@PathVariable long id){service.delete(id,(Long)a.getPrincipal());return ApiResponse.ok();}
}
