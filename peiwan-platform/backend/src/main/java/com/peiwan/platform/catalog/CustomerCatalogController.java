package com.peiwan.platform.catalog;

import com.peiwan.platform.common.ApiResponse;
import com.peiwan.platform.player.PlayerService;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

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
                                 @RequestParam(required = false) String productType,
                                 @RequestParam(required = false) String serviceType,
                                 @RequestParam(required = false) Long playerLevelId,
                                 @RequestParam(required = false) BigDecimal minPrice,
                                 @RequestParam(required = false) BigDecimal maxPrice,
                                 @RequestParam(defaultValue = "DEFAULT") String sort) {
    return ApiResponse.ok(products.customerList(current, size, keyword, gameId, categoryId, productType,
      serviceType, playerLevelId, minPrice, maxPrice, sort));
  }

  @GetMapping("/player-levels")
  public ApiResponse<?> playerLevels(@RequestParam(required = false) Long gameId) {
    return ApiResponse.ok(products.playerLevels(gameId));
  }

  @GetMapping("/player-tags")
  public ApiResponse<?> playerTags() {
    return ApiResponse.ok(players.tagOptions());
  }

  @GetMapping("/products/{id}")
  public ApiResponse<?> product(@PathVariable long id) {
    return ApiResponse.ok(products.customerDetail(id));
  }

  @GetMapping("/players")
  public ApiResponse<?> players(@RequestParam(defaultValue = "1") int current,
                                @RequestParam(defaultValue = "50") int size,
                                @RequestParam(required = false) String keyword,
                                @RequestParam(required = false) String workStatus,
                                @RequestParam(required = false) Long gameId,
                                @RequestParam(required = false) Long playerLevelId,
                                @RequestParam(required = false) Long skuId,
                                @RequestParam(required = false) Long tagId,
                                @RequestParam(required = false) String gender,
                                @RequestParam(defaultValue = "DEFAULT") String sort) {
    return ApiResponse.ok(players.customerPlayers(current, size, keyword, workStatus, gameId, playerLevelId,
      skuId, tagId, gender, sort));
  }

  @GetMapping("/players/{id}")
  public ApiResponse<?> player(@PathVariable long id) {
    return ApiResponse.ok(players.customerPlayer(id));
  }
}
