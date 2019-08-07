@isTest
private class VotingTest
{
  @testSetup static void setup()
  {
    Account nbbaAccount = new Account(Name='NBBA');
    insert nbbaAccount;
    // Insert contacts
    List<Contact> contacts = new List<Contact>();
    for(Integer i = 0; i < 3; i++)
    {
      Contact playerContact = new Contact(FirstName='player', LastName=i.format(), Account=nbbaAccount);
      contacts.add(playerContact);
    }  // End Contacts loop
    insert contacts;
    // Create teams
    List<Team__c> teams = new List<Team__c>();
    for(Integer i = 0; i < 3; i++)
    {
      Team__c team = new Team__c();
      team.Name = i.format();
      team.Account__c = nbbaAccount.Id;
      teams.add(team);
    }  // End teams loop
    insert teams;
    // Create Members
    List<Member__c> members = new List<Member__c>();
    for(Integer i = 0; i < 3; i++)
    {
      Member__c member = new Member__c();
      member.Team__c = teams[i].Id;
      member.Contact__c = contacts[i].Id;
      member.Year__c = '2019';
      member.Name = contact.Name + ' ' + member.Team__r.Name + ' ' + member.Year__c;
      members.add(member);
    }  // End member method
    insert members;
    // Create Candidates
    List<Candidate_Profile__c> candidates = new List<Candidate_Profile__c>();
    for(Contact contact : contacts)
    {
      Candidate_Profile__c candidate = new Candidate_Profile__c();
      candidate.Name = contact.Name;
      candidate.Contact__c = contact.Id;
      candidates.add(candidate);
    }
    // Create Election__c
    Election__c election = new election__c();
    election.name = 'test election';
    election.start_Date__c = System.today();
    election.Start_Time__c = System.now().time();
    election.End_Date__c = System.today();
    election.End_Time__c = System.now().time().addHours(1);
    insert election;
    // Create Ballot Initiatives
    List<Ballot_initiative__c> ballotInitiatives = new List<Ballot_Initiative__c>();
    for(Integer i = 0; i < 3; i++)
    {
      Ballot_Initiative__c ballotInitiative = new Ballot_Initiative__c();
      BallotInitiative.Name = i.format();
      ballotInitiative.Description__c = 'My long descriptive speech';
      ballotInitiative.Election__c = election.Id;
      ballotInitiative.Has_Selections__c = True;
      ballotInitiative.Votes_Allowed__c = 1;
       BallotInitiatives.add(ballotInitiative);
    }  // End teams loop
    ballotInitiatives[1].Votes_Allowed__c = 2;
    ballotInitiatives[2].Has_Selections__c = false;
    ballotInitiatives[2].Description__c = 'This is a yes/no question.';
    insert ballotInitiatives;
    // Create Ballot_Selection__c
    List<Ballot_Selection__c> ballotSelections = new List<Ballot_Selection__c>();
    for(Candidate_Profile__c candidate : candidates)
    {
      for(Integer i = 0; i < 2; i++)
      {
        Ballot_Selection__c ballotSelection = new Ballot_Selection__c();
        ballotSelection.Ballot_Initiative__c = ballotInitiatives[i].Id;
        ballotSelection.Candidate_Profile__c = candidate.Id;
        ballotSelection.Name = candidate.Name;
        ballotSelections.add(ballotSelection);
      }  // End double for loop
    }  // End candidates loop
    insert ballotSelections;
  }  // End setup method
  @isTest static void testSearchField()
  {
    
  }  // End testSearchField method
}  // End VotingTest class