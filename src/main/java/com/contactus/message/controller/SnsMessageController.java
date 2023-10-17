package com.contactus.message.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.contactus.message.services.SSMParameterService;
import com.contactus.message.services.SnsMessageService;

@RestController
public class SnsMessageController {
    private final SnsMessageService snsService;
    
    @Value("${contactustopicArn}")
	private String contactustopicArn;
	
	@Autowired
	private SSMParameterService ssmPara;
	
    public SnsMessageController(SnsMessageService snsService) {
        this.snsService = snsService;
    }

    @PostMapping("/publish")
    public void publishMessage(@RequestBody String message) {
        snsService.publishMessageToTopic(ssmPara.getSSMParameter(contactustopicArn), message);
    }
    
    @GetMapping("/")
    public ResponseEntity<String> getExampleData() {
        String data = "This is an example response.";
        
        return ResponseEntity.ok("Success...");
    }
}

