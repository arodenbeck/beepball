public with sharing class MembershipRegistrationController
{
  private String year;
  private Contact searchContact;
  //public String searchContactId { get;set; } 
  private String contactId;
  private String emailVerificationId;
  private String memberId;
  private String emailVerificationCode;
  public String responseVerificationCode { get;set; }
  public String searchEmail { get;set; }
  public String contactFirstName { get;set; }
  public String contactLastName { get;set; }
  public List<SelectOption> teams { get;set; }
  public String selectedTeam { get;set; }
  public boolean isEmailSearchVisible { get;set; }
  public boolean isNewContactVisible { get;set; }
  public boolean isSuccessVisible { get;set; }
  public boolean isTeamSelectionVisible { get;set; }
  public boolean isVerificationCodeVisible { get;set; }
 
  public MembershipRegistrationController()
  {
    searchContact = new Contact();
    contactId = '000000000000000000';
    emailVerificationId = '';
    searchEmail = '';
    contactFirstName = '';
    contactLastName = '';
    teams = new List<SelectOption>();
    teams.addAll(TeamService.getListSelectOptions());
    selectedTeam = '';
    year = '2018';
    isEmailSearchVisible = true;
    isVerificationCodeVisible = false;
    isNewContactVisible = false;
    isSuccessVisible = false;
    isTeamSelectionVisible = false;
  }  // End constructor

  public PageReference submitSearch()
  {
    List<String> emailAddresses = new List<String>();
    emailAddresses.add(searchEmail);
    List<Email_Verification__c> emailVerification = EmailVerificationService.createVerificationFromEmails(emailAddresses);
    if(!emailVerification.isEmpty())
    {
      isEmailSearchVisible = false;
      emailVerificationId = emailVerification[0].Id;
      emailVerificationCode = String.valueOf((Integer) emailVerification[0].Verification_Code__c);
      contactId = emailVerification[0].Contact__c;
      if(!emailVerification[0].Verified__c)
      {
        isVerificationCodeVisible = true;
        EmailVerificationService.sendVerificationEmail(searchEmail, emailVerificationCode);
        return null;
      }  // End if the Email hasn't been verified
      return findExistingContact();
    }  // End if verificationEmail is not empty
    return null;
  }  // End submitSearch method

  private PageReference findExistingContact()
  {
    if(contactId != null)
    {
      return findExistingMembership();
    }  // End if searchContact is null
    isNewContactVisible = true;
    return null;
  }  // End findExistingContact

  private void createContact()
  {
    String accountId = TeamService.getAccountIdFromTeamId(selectedTeam);
    searchContact = ContactService.createContact(contactFirstName, contactLastname, searchEmail, accountId);
    contactId = searchContact.Id;
    EmailVerificationService.updateEmailVerificationContact(emailVerificationId, contactId);
  }  // End createContact method

  public PageReference showTeamSelection()
  {
    isNewContactVisible = false;
    isTeamSelectionVisible = true;
    return null;
  }  // End showTeamSelection method

  public PageReference verifyEmail()
  {
    if(responseVerificationCode.containsOnly(emailVerificationCode))
    {
      isVerificationCodeVisible = false;
      EmailVerificationService.verifyEmail(emailVerificationId);
      return findExistingContact();
    }  // End if responseVerificationCode equals emailVerificationCode
    return null;
  }  // End verifyEmail method

  private PageReference findExistingMembership()
  {
    isTeamSelectionVisible = true;
    List<Member__c> existingMembers = MembershipService.searchExistingMembers(contactId, year);
    if(!existingMembers.isEmpty())
    {
      memberId = existingMembers[0].Id;
      return continueToEthicsPage();
    }  // End if existingMembers is not empty
    
    return null;
  }  // End findExistingMembership method

  public PageReference createMembershipRecord()
  {
    isTeamSelectionVisible = false;
    if(contactId == null)
    {
      createContact();
    }  // End if contactId is null
    MembershipService.createManualMember(contactId, selectedTeam, year);
    return continueToEthicsPage();
  }  // End createMembershipRecord Method

  public PageReference continueToEthicsPage()
  {
    return null;
  }  // End continueToEthics method
}  // End class