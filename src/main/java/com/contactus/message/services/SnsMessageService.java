package com.contactus.message.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.sns.SnsClient;
import software.amazon.awssdk.services.sns.model.PublishRequest;
import software.amazon.awssdk.services.sns.model.PublishResponse;

@Service
public class SnsMessageService {
    private final SnsClient snsClient;
    
    
    @Autowired
    public SnsMessageService(@Value("${aws.region}") String region) {
        // Initialize the SNS client with your desired AWS region
        snsClient = SnsClient.builder()
            .region(Region.of(region))
            .build();
    }

    public void publishMessageToTopic(String topicArn, String message) {
        PublishRequest request = PublishRequest.builder()
            .topicArn(topicArn)
            .message(message)
            .build();

        PublishResponse response = snsClient.publish(request);

        // You can handle the response or log it if needed
        System.out.println("Published message with message ID: " + response.messageId());
    }
}

