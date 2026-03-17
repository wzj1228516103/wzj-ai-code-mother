package com.wuzijie.wzjaicodeuser;

import org.apache.dubbo.config.spring.context.annotation.EnableDubbo;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@EnableDubbo
@MapperScan("com.wuzijie.wzjaicodeuser.mapper")
@ComponentScan("com.wuzijie")
public class WzjAiCodeUserApplication {
    public static void main(String[] args) {
        SpringApplication.run(WzjAiCodeUserApplication.class, args);
    }
}
