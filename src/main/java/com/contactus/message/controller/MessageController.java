package com.contactus.message.controller;



import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RefreshScope
@RequestMapping("/contactus")

public class MessageController {
	@Value("${contactUsTable}")
	private String contactTableName;
	
	/*
	 * @Autowired private SSMParameterService ssmPara;
	 */
	 @GetMapping()
	    public String retrieveAllStudents() {
	        return "hello welcome";
	    }
}