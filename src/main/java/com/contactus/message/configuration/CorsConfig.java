package com.contactus.message.configuration;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.filter.CorsFilter;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig implements WebMvcConfigurer {

	 @Bean
	    public CorsFilter corsFilter() {
	        CorsConfiguration corsConfig = new CorsConfiguration();
	        corsConfig.addAllowedOrigin("http://localhost:4200");  // Replace with your frontend origin
	        corsConfig.addAllowedMethod("GET");
	        corsConfig.addAllowedMethod("POST");
	        corsConfig.addAllowedMethod("PUT");
	        corsConfig.addAllowedMethod("DELETE");
	        corsConfig.addAllowedHeader("*");

	        org.springframework.web.cors.UrlBasedCorsConfigurationSource source = new org.springframework.web.cors.UrlBasedCorsConfigurationSource();
	        source.registerCorsConfiguration("/**", corsConfig);

	        return new CorsFilter(source);
	    }
}
