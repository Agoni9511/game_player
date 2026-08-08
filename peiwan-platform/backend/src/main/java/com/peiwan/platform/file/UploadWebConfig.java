package com.peiwan.platform.file;
import org.springframework.context.annotation.Configuration;import org.springframework.web.servlet.config.annotation.*;
@Configuration public class UploadWebConfig implements WebMvcConfigurer{private final LocalFileStorage storage;public UploadWebConfig(LocalFileStorage s){storage=s;}public void addResourceHandlers(ResourceHandlerRegistry registry){registry.addResourceHandler("/uploads/**").addResourceLocations(storage.root().toUri().toString()).setCachePeriod(3600);}}
