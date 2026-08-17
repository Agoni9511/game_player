package com.peiwan.platform.file;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
@ConditionalOnProperty(name = "app.storage.type", havingValue = "local", matchIfMissing = true)
public class UploadWebConfig implements WebMvcConfigurer {
  private final LocalFileStorage storage;

  public UploadWebConfig(LocalFileStorage storage) {
    this.storage = storage;
  }

  @Override
  public void addResourceHandlers(ResourceHandlerRegistry registry) {
    registry
        .addResourceHandler("/uploads/**")
        .addResourceLocations(storage.root().toUri().toString())
        .setCachePeriod(3600);
  }
}
