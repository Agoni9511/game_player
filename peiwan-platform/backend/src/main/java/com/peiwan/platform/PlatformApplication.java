package com.peiwan.platform;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.mybatis.spring.annotation.MapperScan;
@SpringBootApplication
@EnableScheduling
@MapperScan("com.peiwan.platform.persistence.mapper")
public class PlatformApplication { public static void main(String[] args) { SpringApplication.run(PlatformApplication.class, args); } }
