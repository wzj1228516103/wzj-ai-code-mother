
package com.wuzijie.wzjaicodemother;

import org.apache.dubbo.config.spring.context.annotation.EnableDubbo;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@EnableDubbo
public class WzjAiCodeScreenshotApplication {
    public static void main(String[] args) {
        SpringApplication.run(WzjAiCodeScreenshotApplication.class, args);
    }
}
