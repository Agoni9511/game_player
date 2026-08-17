package com.peiwan.platform.persistence;
import com.baomidou.mybatisplus.annotation.DbType;import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;import org.springframework.context.annotation.*;
@Configuration public class MybatisPlusConfig{@Bean MybatisPlusInterceptor mybatisPlusInterceptor(){var x=new MybatisPlusInterceptor();x.addInnerInterceptor(new PaginationInnerInterceptor(DbType.MYSQL));return x;}}
