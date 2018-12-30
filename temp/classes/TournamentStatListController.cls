public with sharing class TournamentStatListController
{
  public ApexPages.StandardSetController stdController;

  public TournamentStatListController(ApexPages.StandardSetController controller)
  {
    stdController = controller;
  }  // End constructor

  public PageReference submitStats()
  {
    //Set<Id> tournamentStatIds = new Set<Id>();
    //for(Tournament_Stat__c ts : (List<Tournament_Stat__c>)stdController.getSelected())
    //{
      //tournamentStatIds.add(ts.Id);
    //}  // End selected loop
    //TournamentStatService.processTournamentStats(tournamentStatIds);
    TournamentStatBatchProcess tournamentStatBatch = new TournamentStatBatchProcess((List<Tournament_Stat__c>)stdController.getSelected());
    Id batchId = Database.executeBatch(TournamentStatBatch);
    return stdController.save();
  }  // End submitStats method
}  // End TournamentStatListController class