package com.sherpa.core.utils;

import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.AddressException;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import sun.net.smtp.SmtpClient;
import java.io.*;


/**
 * Created by akhtar on 07/10/2015.
 */
public class EmailUtils {

    private static final Logger log = LoggerFactory.getLogger(EmailUtils.class);

    private  Properties mailServerProperties;
    private  Session getMailSession;
    private  MimeMessage generateMailMessage;
    public static final String EXPORT_SUBJECT = "Hbase Export Report";
    public static final String IMPORT_SUBJECT = "Hbase Import Report";





    public void sendEmail(String subject, String taskName, String dateTime, Map<String, Integer> map) {

        log.info("Sending Email for Task: "  + taskName + "\t DateTime: " + dateTime + "\t Stats: " + map);

        try {
            mailServerProperties = System.getProperties();
            mailServerProperties.put("mail.smtp.port", "587");
            mailServerProperties.put("mail.smtp.auth", "true");
            mailServerProperties.put("mail.smtp.starttls.enable", "true");


            getMailSession = Session.getDefaultInstance(mailServerProperties, null);
            generateMailMessage = new MimeMessage(getMailSession);
            generateMailMessage.addRecipient(Message.RecipientType.TO, new InternetAddress(SystemPropertiesLoader.getProperty("export.to.email.id")));
            generateMailMessage.setSubject(subject);


            StringBuilder builder = new StringBuilder();

            builder.append("<strong> Task: </strong> ").append(taskName).append("  <br />");
            builder.append("<strong> Date Time: </strong> ").append(dateTime).append("  <br />");

            for (java.util.Map.Entry<String, Integer> e : map.entrySet()) {
                builder.append("<strong> Records Count ( " + e.getKey() + " ) :</strong>").append(e.getValue()).append(" <br />");
            }

            builder.append("<br /> <br />").append("<h3>Sherpa Performance Service</h3>");

            String emailBody = builder.toString();
            generateMailMessage.setContent(emailBody, "text/html");

            Transport transport = getMailSession.getTransport("smtp");

            transport.connect("smtp.gmail.com", SystemPropertiesLoader.getProperty("service.email.id"), SystemPropertiesLoader.getProperty("service.email.password"));
            transport.sendMessage(generateMailMessage, generateMailMessage.getAllRecipients());
            transport.close();
            log.info("Email sent successfully ...");
        }catch (AddressException ex){
            ex.printStackTrace();
        }
        catch (MessagingException me){
            me.printStackTrace();
        }
    }



    public static void main(String[] args){
        /*Map<String, Integer> map = new HashMap<String, Integer>();
        map.put("T1", 10);
        map.put("T2", 20);
        new EmailUtils().sendEmail(EXPORT_SUBJECT, "Export", "Oct 8, 2015", map);*/



    }


}
