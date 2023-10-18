package com.contactus.message.services;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.contactus.message.entity.ContactMessage;

import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeAction;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.AttributeValueUpdate;
import software.amazon.awssdk.services.dynamodb.model.DeleteItemRequest;
import software.amazon.awssdk.services.dynamodb.model.GetItemRequest;
import software.amazon.awssdk.services.dynamodb.model.GetItemResponse;
import software.amazon.awssdk.services.dynamodb.model.PutItemRequest;
import software.amazon.awssdk.services.dynamodb.model.UpdateItemRequest;
import software.amazon.awssdk.services.dynamodb.model.*;

@Service
public class ContactMessageService {

    private final DynamoDbClient dynamoDbClient;
    


    @Value("${contactUsTable}")
	private String contactTableName;
	
	/*
	 * @Autowired private SSMParameterService ssmPara;
	 */
	
    @Autowired
	public ContactMessageService(
			DynamoDbClient dynamoDbClient) {
        this.dynamoDbClient = dynamoDbClient;
       
    }

    public PutItemResponse createContactMessage(ContactMessage message) {
    	if(null!=message) {
    		message.generateId();
    		Map<String, AttributeValue> itemValues = new HashMap<>();
            itemValues.put("email", AttributeValue.builder().s(message.getEmail()).build());
            itemValues.put("id", AttributeValue.builder().s(message.getId()).build());
            itemValues.put("name", AttributeValue.builder().s(message.getName()).build());
            itemValues.put("message", AttributeValue.builder().s(message.getMessage()).build());

            return dynamoDbClient.putItem(PutItemRequest.builder()
                    .tableName(contactTableName)
                    .item(itemValues)
                    .build());
    	}
    	
    	return null;
        
    }

    public ContactMessage getContactMessage(String email) {
        GetItemResponse response = dynamoDbClient.getItem(GetItemRequest.builder()
                .tableName(contactTableName)
                .key(Collections.unmodifiableMap(new HashMap<String, AttributeValue>() {{put("email", AttributeValue.builder().s(email).build());}}))
                .build());

        if (response.hasItem()) {
            Map<String, AttributeValue> item = response.item();
            ContactMessage message = new ContactMessage();
            message.setEmail(item.get("email").s());
            message.setName(item.get("name").s());
            message.setMessage(item.get("message").s());
            message.setId(item.get("id").s());
            return message;
        }
        return null;
    }

    public UpdateItemResponse updateContactMessage(ContactMessage message) {
        Map<String, AttributeValue> itemKey = Collections.unmodifiableMap(new HashMap<String, AttributeValue>() {{put("email", AttributeValue.builder().s(message.getEmail()).build());}});
        Map<String, AttributeValueUpdate> updates = Collections.unmodifiableMap(new HashMap<String, AttributeValueUpdate>() {{put(
                "name", AttributeValueUpdate.builder().value(AttributeValue.builder().s(message.getName()).build()).action(AttributeAction.PUT).build());
                put("message", AttributeValueUpdate.builder().value(AttributeValue.builder().s(message.getMessage()).build()).action(AttributeAction.PUT).build());
        }});

         return dynamoDbClient.updateItem(UpdateItemRequest.builder()
                .tableName(contactTableName)
                .key(itemKey)
                .attributeUpdates(updates)
                .build());
    }

    public DeleteItemResponse deleteContactMessage(String email) {
        return dynamoDbClient.deleteItem(DeleteItemRequest.builder()
                .tableName(contactTableName)
                .key(Collections.unmodifiableMap(new HashMap<String, AttributeValue>() {{put("email", AttributeValue.builder().s(email).build());}}))
                .build());
    }
}

