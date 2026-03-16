package io.storeyes.storeyes_coffee;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class StoreyesCoffeeApplication {

	public static void main(String[] args) {
		SpringApplication.run(StoreyesCoffeeApplication.class, args);
	}

}
