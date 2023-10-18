package com.contactus.message.controller;

import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.contactus.message.entity.ContactMessage;
import com.contactus.message.services.ContactMessageService;

import software.amazon.awssdk.services.dynamodb.model.PutItemResponse;

@RestController
@RequestMapping("/contact-messages")
public class ContactUsMessageController {

    private final ContactMessageService contactMessageService;

    @Autowired
    public ContactUsMessageController( ContactMessageService contactMessageService) {
        this.contactMessageService = contactMessageService;
    }

    @PostMapping
    public ResponseEntity<ContactMessage> createContactMessage(@RequestBody ContactMessage message) {
    	
        Optional<PutItemResponse> optionalItemResponse= Optional.ofNullable(contactMessageService.createContactMessage(message));
        System.out.println(optionalItemResponse +",   "+optionalItemResponse.isPresent());
        if (!optionalItemResponse.isEmpty()){
        return ResponseEntity.ok(message);
        }else {
        	System.out.println(optionalItemResponse +",   "+optionalItemResponse.isPresent());
        	return  ResponseEntity.badRequest().body(null);
        }
        
    }

    @GetMapping("/{email}")
    public ResponseEntity<ContactMessage> getContactMessage(@PathVariable String email) {
    	Optional<String> emailOptional= Optional.ofNullable(email);
    	if (emailOptional.isPresent()) {
    		return ResponseEntity.ok(contactMessageService.getContactMessage(email));
    		
    	}else {
    		return ResponseEntity.badRequest().body(null);
    	}
        
    }

}

