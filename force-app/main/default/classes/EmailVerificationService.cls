public without sharing class EmailVerificationService
{
  public static List<Email_Verification__c> createVerificationFromEmails(List<String> emails)
  {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Email_Verification__c.SObjectType });
    List<String> validAddresses = new List<String>();
    for(String emailAddress : emails)
    {
      if(!String.isBlank(emailAddress))
      {
        validAddresses.add(emailAddress);
      }  // End if emailAddress is not blank
    }  // End emails loop
    List<Email_Verification__c> databaseVerifications = [select Id,Name,Email__c,Verified__c,Verification_Code__c,Contact__c from Email_Verification__c where Email__c in :validAddresses];
    EmailVerifications verificationsHandler = new EmailVerifications(databaseVerifications, uow);
    List<Email_Verification__c> emailVerifications = verificationsHandler.createVerificationsFromAddresses(validAddresses);
    uow.commitWork();
    return emailVerifications;
  }  // End createVerificationFromEmail method

  public static void updateEmailVerificationContact(String emailVerificationId, String contactId)
  {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Email_Verification__c.SObjectType });
    Email_Verification__c emailVerification = new Email_Verification__c();
    if(!String.isBlank(emailVerificationId) && !String.isBlank(contactId))
    {
      emailVerification.Id = emailVerificationId;
      emailVerification.Contact__c = contactId;
      uow.registerDirty(emailVerification);
    }  // End verify parameters are not blank
    uow.commitWork();
  }  // End updateVerificationContact
  public static void  sendVerificationEmail(String emailAddress, String emailVerificationCode)
  {
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] { emailAddress };
    mail.setToAddresses(toAddresses);
    mail.setReplyTo('secretary@nbba.org');
    mail.setSenderDisplayName('NBBA Member Registration System');
    mail.setSubject('Your email verification code');
    mail.setBccSender(false);
    String bodyString = 'Your NBBAemail verification code is: ' + emailVerificationCode;
    mail.setPlainTextBody(bodyString);
    mail.setHtmlBody(bodyString);
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
  }  // End sendVerificationEmail
  public static void verifyEmail(String emailVerificationId)
  {
    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType> { Email_Verification__c.SObjectType });
    Email_Verification__c emailVerification = new Email_Verification__c();
    if(!String.isBlank(emailVerificationId))
    {
      emailVerification.Id = emailVerificationId;
      emailVerification.Verified__c = true;
      uow.registerDirty(emailVerification);
    }  // End verify parameters are not blank
    uow.commitWork();
  }  // End verifyEmail method

}  // End EmailVerificationService class