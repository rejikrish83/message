package com.contactus.message.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.contactus.message.entity.ContactMessage;
import com.contactus.message.services.ContactMessageService;

@RestController
@RequestMapping("/contact-messages")
public class ContactUsMessageController {

    private final ContactMessageService contactMessageService;

    @Autowired
    public ContactUsMessageController(ContactMessageService contactMessageService) {
        this.contactMessageService = contactMessageService;
    }

    @PostMapping
    public void createContactMessage(@RequestBody ContactMessage message) {
        contactMessageService.createContactMessage(message);
    }

    @GetMapping("/{email}")
    public ContactMessage getContactMessage(@PathVariable String email) {
        return contactMessageService.getContactMessage(email);
    }

    @PutMapping("/{email}")
    public void updateContactMessage(@PathVariable String email, @RequestBody ContactMessage message) {
        message.setEmail(email);
        contactMessageService.updateContactMessage(message);
    }

    @DeleteMapping("/{email}")
    public void deleteContactMessage(@PathVariable String email) {
        contactMessageService.deleteContactMessage(email);
    }
}

