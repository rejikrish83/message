package com.contactus.message;

import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import org.springframework.boot.test.context.SpringBootTest;

import com.amazonaws.services.ec2.AmazonEC2;

@SpringBootTest


class MessageApplicationTests {

	@Test
	void contextLoads() {
		 AmazonEC2 ec2Client = Mockito.mock(AmazonEC2.class);
	}
	
	

}
