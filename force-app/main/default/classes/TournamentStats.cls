public with sharing class TournamentStats 
{
  private Map<Id, Tournament_Stat__c> updatedTournamentStatsById;

  public TournamentStats() 
  {
      updatedTournamentStatsById = new Map<Id, Tournament_Stat__c>();
      
  }  // End Constructor
}  // End TournamentStats class
