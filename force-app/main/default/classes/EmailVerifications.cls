public without sharing class EmailVerifications
{
  private Map<String, Email_Verification__c> verificationsByEmail;
  private List<Email_Verification__c> emailVerifications;
  private fflib_SObjectUnitOfWork uow;

  public EmailVerifications(List<Email_Verification__c> verifications, fflib_SObjectUnitOfWork uow)
  {
    verificationsByEmail = new  Map<String, Email_Verification__c>();
    emailVerifications = new List<Email_Verification__c>();
    emailVerifications.addAll(verifications);
    this.uow = uow;
    createVerificationMap();
  }  // End constructor

  public List<Email_Verification__c> createVerificationsFromAddresses(List<String> emails)
  {
    List<Email_Verification__c> validEmailVerifications = new List<Email_Verification__c>();
    for(String emailAddress : emails)
    {
      Email_Verification__c newEmailVerification = verificationsByEmail.get(emailAddress);
      if(newEmailVerification == null)
      {
        newEmailVerification = new Email_Verification__c();
        newEmailVerification.Name = emailAddress;
        newEmailVerification.Email__c = emailAddress;
        newEmailVerification.Verification_Code__c = generateRandomDigits(6);
        verificationsByEmail.put(newEmailVerification.Name, newEmailVerification);
        uow.registerNew(newEmailVerification);    
      }  // End if emailAddress is not blank
      validEmailVerifications.add(newEmailVerification);
    }  // End emails loop
    return validEmailVerifications;
  }  // End createVerificationsFromAddresses method

  private Integer generateRandomDigits(Integer numDigits)
  {
    Integer returnDigits = 0;
    for(Integer i = 0; i < numDigits; i++)
    {
      Integer randomNumber = (Math.random() * 10).intValue();
      returnDigits += (randomNumber * Math.pow((Double)10.0, (Double)i)).intValue();
    }  // End numDigits loop
    return returnDigits;
  }  // End generateRandomDigits method

  private void createVerificationMap()
  {
    for(Email_Verification__c verification : emailVerifications)
    {
      verificationsByEmail.put(verification.Name, verification);
    }  // End emailVerifications loop
  }  // End createVerificationMap helper method
}  // End class EmailVerifications