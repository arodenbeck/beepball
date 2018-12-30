@isTest
private class MembershipServiceTest
{

  static testMethod void myUnitTest()
  {
    Account nbbaAccount = new Account(Name = 'National Beep Baseball Association');
    insert nbbaAccount;
    //Tournament__c tournamentWorldSeries2016 = new Tournament__c(Name = 'World Series 2016');
    //insert tournamentWorldSeries2016;
    List<Tournament_Stat__c> tournamentStats = new List<Tournament_Stat__c>();
    for(Integer i = 0; i < 200; i++)
    {
      Tournament_Stat__c testStat = new Tournament_Stat__c();
      testStat.Name = 'World Series 2016';
      testStat.At_Bats__c = 17.0;
      testStat.Games__c = 7.0;
      testStat.Player_Name__c = 'Adam Rodenbeck';
      testStat.Put_Outs__c = 5.0;
      testStat.Runs__c = 7.0;
      testStat.Strike_Outs__c = 0.0;
      testStat.Team_Name__c = 'Indy Thunder';
      testStat.Year__c = '2016';
      tournamentStats.add(testStat);
    }  // End 200 count for loop

    Team__c newTeam = new Team__c(Name='BCA');
    insert newTeam;
    tournamentStats[1].Player_Name__c = 'Vergil Flowers';
    tournamentStats[2].Player_Name__c = 'Vergil Flowers';
    tournamentStats[3].Year__c = '2015';
    tournamentStats[3].Name = 'World Series 2015';
    tournamentStats[3].Team_Name__c = 'BCA';
    tournamentStats[3].Player_Name__c = 'Lucas Davenport';
    Test.startTest();
      insert tournamentStats;
      //TournamentStatService.databaseUpdate(tournamentStats);
      TournamentStatBatchProcess bp = new TournamentStatBatchProcess();
      Id jobId = Database.executeBatch(bp);
    Test.stopTest();
    List<Contact> testContacts = [select Id,Name from Contact];
    List<Team__c> testTeams = [select Id,Name from Team__c];
    List<Member__c> testMembers = [select Id,Name from Member__c];
    List<Tournament__c> testTournaments = [select Id,Name from Tournament__c];
    System.assertEquals(3, testContacts.size());
    System.assertEquals(2, testTeams.size());
    System.assertEquals(3, testMembers.size());
    System.assertEquals(2, testTournaments.size());
  }  // End unit test method
}  // End test class