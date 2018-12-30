trigger ValidateTournamentStat on Tournament_Stat__c (before insert)
{
  List<Tournament_Stat__c> statsWithoutMembers = new List<Tournament_Stat__c>();
  for(Tournament_stat__c ts : trigger.new)
  {
    if(ts.Year__c != null && ts.Player_Name__c != null && ts.Team_Name__c != null && ts.Member__c == null)
    {
      statsWithoutMembers.add(ts);
    }  // End if ts meets criteria for linking to a member
  }  // End trigger.new loop
  //TournamentStatService.createTeamMembers(statsWithoutMembers);
}  // End trigger