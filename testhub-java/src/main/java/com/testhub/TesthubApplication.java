package com.testhub;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableAsync
@EnableScheduling
@MapperScan("com.testhub.**.mapper")
public class TesthubApplication {

    public static void main(String[] args) {
        SpringApplication.run(TesthubApplication.class, args);
    }
}