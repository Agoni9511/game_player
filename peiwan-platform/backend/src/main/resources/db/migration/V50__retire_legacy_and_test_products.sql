-- Keep historical order references intact while removing obsolete products from sale.

update pw_product
set status='OFF_SALE',updated_at=current_timestamp
where product_code in (
  'delta-escort-experience',
  'valorant-ranked-hour',
  'product-mstda3ta-0jbf',
  'product-mstdtxao-rydr'
);
