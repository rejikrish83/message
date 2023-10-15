package com.contactus.message.services;

import org.springframework.stereotype.Service;

import com.amazonaws.services.simplesystemsmanagement.AWSSimpleSystemsManagement;
import com.amazonaws.services.simplesystemsmanagement.AWSSimpleSystemsManagementClientBuilder;
import com.amazonaws.services.simplesystemsmanagement.model.GetParameterRequest;
import com.amazonaws.services.simplesystemsmanagement.model.GetParameterResult;

@Service
public class SSMParameterService {

    private final AWSSimpleSystemsManagement ssmClient;

    public SSMParameterService() {
        this.ssmClient = AWSSimpleSystemsManagementClientBuilder.defaultClient();
    }

    public String getSSMParameter(String parameterName) {
        GetParameterRequest request = new GetParameterRequest()
                .withName(parameterName)
                .withWithDecryption(true); // Decrypt the parameter if it's encrypted

        GetParameterResult result = ssmClient.getParameter(request);
        return result.getParameter().getValue();
    }
}

