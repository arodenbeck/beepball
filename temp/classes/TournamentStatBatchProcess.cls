public class TournamentStatBatchProcess implements Database.Batchable<sObject>
{
  private String queryString;
  private Set<Id> tournamentStatIds;
  private String whereClause;
  private String andClause;

  public TournamentStatBatchProcess()
  {
    initializeClassVariables();
  }  // End default constructor
  public TournamentStatBatchProcess(List<Tournament_Stat__c> tournamentStats)
  {
    initializeClassVariables();
    for(Tournament_Stat__c ts : tournamentStats)
    {
      tournamentStatIds.add(ts.Id);
    }  // End tournamentStats loop
    if(!tournamentStatIds.isEmpty())
    {
      queryString += andClause;
    }  // End if tournamentStatIds is not empty
  }  // End Constructor
  private void initializeClassVariables()
  {
    tournamentStatIds = new Set<Id>();
    queryString = 'select Id,Name,At_Bats__c,Games__c,Contact__c,Player_Name__c,Member__c,Put_Outs__c,Runs__c,Strike_Outs__c,Team__c,Team_Name__c,Tournament__c,Year__c from Tournament_Stat__c';
    whereClause = ' where (Team__c = null OR Tournament__c = null OR Member__c = null OR Contact__c = null)';
    andClause = ' AND Id in :tournamentStatIds';
    queryString += whereClause;
  }  // EndinitializeClassVariables method
  public Database.QueryLocator start(Database.batchableContext bc)
  {
    return Database.getQueryLocator(queryString);
  }  // End start method
  public void execute(Database.BatchableContext bc, List<Tournament_Stat__c> tournamentStats)
  {
    update TournamentStatService.databaseUpdate(tournamentStats);
  }  // End execute method
  public void finish(Database.BatchableContext bc)
  {
    AsyncApexJob a = [select Id,Status,NumberOfErrors,JobItemsProcessed,TotalJobItems,CreatedBy.Email from AsyncApexJob where Id = :bc.getJobId()];
    Messaging.SingleEmailMessage mail = new  Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {a.CreatedBy.Email};
    mail.setToAddresses(toAddresses);
    mail.setSubject('Tournament Stat Processing ' + a.Status);
    mail.setPlainTextBody('The batch processed ' + a.TotalJobItems + ' records, with ' + a.NumberOfErrors + ' failures.');
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  }  // End finish method
}  // End TournamentStatBatchProcess class