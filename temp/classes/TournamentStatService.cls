public with sharing class TournamentStatService
{
  private static Map<Id, Tournament_Stat__c> updatedTournamentStatsById;

  @future
  public static void processTournamentStats(Set<Id> tournamentStatIds)
  {
    List<Tournament_Stat__c> tournamentStats = [select Id,Name,At_Bats__c,Games__c,Contact__c,Player_Name__c,Member__c,Put_Outs__c,Runs__c,Strike_Outs__c,Team__c,Team_Name__c,Tournament__c,Year__c from Tournament_Stat__c where Id in :tournamentStatIds];
    update databaseUpdate(tournamentStats);
  }  // End processTournamentStats method

  public static List<Tournament_Stat__c> databaseUpdate(List<Tournament_Stat__c> tournamentStats)
  {
    updatedTournamentStatsById = new Map<Id, Tournament_Stat__c>();
    addIfNotPresent(TournamentService.findOrCreateTournaments(tournamentStats));
    addIfNotPresent(TeamService.findOrCreateTeams(tournamentStats));
    addIfNotPresent(ContactService.findOrCreateContacts(tournamentStats));
    addIfNotPresent(MembershipService.findOrCreateMembers(tournamentStats));
    return updatedTournamentStatsById.values();
  }  // End databaseUpdate method

  private static void addIfNotPresent(List<Tournament_Stat__c> tournamentStats)
  {
    for(Tournament_Stat__c ts : tournamentStats)
    {
      if(!updatedTournamentStatsById.containsKey(ts.Id))
      {
        updatedTournamentStatsById.put(ts.Id, ts);
      }  // End if updatedTournamentStatsById does not contain this stat record
    }  // End tournamentStats loop
  }  // End addIfNotPresent method 

}  // End TournamentStatService class