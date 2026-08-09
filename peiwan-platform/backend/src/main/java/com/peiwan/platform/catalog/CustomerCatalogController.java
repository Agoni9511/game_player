package com.peiwan.platform.catalog;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.player.PlayerService;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customer/catalog")
public class CustomerCatalogController {
  private final ProductService products;
  private final CatalogService catalog;
  private final PlayerService players;

  public CustomerCatalogController(ProductService products, CatalogService catalog, PlayerService players) {
    this.products = products;
    this.catalog = catalog;
    this.players = players;
  }

  @GetMapping("/games")
  public ApiResponse<?> games() {
    return ApiResponse.ok(players.gameOptions());
  }

  @GetMapping("/categories")
  public ApiResponse<?> categories() {
    return ApiResponse.ok(catalog.categoryTree());
  }

  @GetMapping("/products")
  public ApiResponse<?> products(@RequestParam(defaultValue = "1") int current,
                                 @RequestParam(defaultValue = "20") int size,
                                 @RequestParam(required = false) String keyword,
                                 @RequestParam(required = false) Long gameId,
                                 @RequestParam(required = false) Long categoryId,
                                 @RequestParam(required = false) String productType) {
    return ApiResponse.ok(products.list(current, size, keyword, gameId, categoryId, "ON_SALE", productType));
  }

  @GetMapping("/products/{id}")
  public ApiResponse<?> product(@PathVariable long id) {
    return ApiResponse.ok(products.customerDetail(id));
  }

  @GetMapping("/players")
  public ApiResponse<?> players(@RequestParam(defaultValue = "1") int current,
                                @RequestParam(defaultValue = "50") int size,
                                @RequestParam(required = false) String keyword,
                                @RequestParam(required = false) String workStatus) {
    return ApiResponse.ok(players.customerPlayers(current, size, keyword, workStatus));
  }
}
