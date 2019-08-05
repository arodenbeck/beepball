@isTest
private class VotingTest
{
  @testSetup static void setup()
  {
    Account nbbaAccount = new Account(Name='NBBA');
    insert nbbaAccount;
    // Insert contacts
    List<Contact> contacts = new List<Contact>();
    for(Integer i = 0, i < 3, i++)
    {
      Contact playerContact = new Contact(FirstName='player', LastName=i.format(), Account=nbbaAccount);
      contacts.add(playerContact);
    }  // End Contacts loop
    insert contacts;
    // Create teams
    List<Team__c> teams = new List<Team__c>();
    for(Integer i = 0, i < 3, i++)
    {
      Team__c team = new Team__c();
      team.Name = i.format();
      team.Account__c = nbbaAccount;
      teams.add(team);
    }  // End teams loop
    insert teams;
    // Create Members
    List<Member__c> members = new List<Member__c>();
    for(Integer i = 0, i < 3, i++)
    {
      Member__c member = new Member__c();
      member.Team__c = teams[i];
      member.Contact__c = contacts[i];
      member.Year__c = '2019';
      member.Name = contact.Name + ' ' + member.Team__r.Name + ' ' + member.Year__c;
      members.add(member);
    }  // End member method
    insert members;
  }  // End setup method
  @isTest static void testSearchField()
  {
    
  }  // End testSearchField method
}  // End VotingTest class