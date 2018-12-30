public with sharing class TournamentService
{
  private static List<Tournament__c> newTournaments;
  private static Map<String, Tournament__c> tournamentsById;
  private static Map<String, Tournament__c> tournamentsByName;
  private static boolean upToDate;
  private static Set<String> tournamentNames;
  private static  String databaseQuery;
  private static List<Tournament__c> databaseTournaments;

  public static List<Tournament_Stat__c> findOrCreateTournaments(List<Tournament_Stat__c> tournamentStats)
  {
    List<Tournament_Stat__c> updatedStats = new List<Tournament_Stat__c>();
    Set<String> currentNames = new Set<String>();
    for(Tournament_Stat__c ts : tournamentStats)
    {
      currentNames.add(ts.Name);
    }  // End tournamentStats loop
    queryForTournaments(currentNames);
    for(Tournament_Stat__c ts : tournamentStats)
    {
      if(ts.Tournament__c == null)
      {
        ts.Tournament__r = findTournamentByName(ts.Name);
        updatedStats.add(ts);
      }  // End if Tournament__c is null
    }  // End tournamentStats loop
    if(!upToDate)
    {
      insertRecords();
    }  // End if upToDate is false
    if(!updatedStats.isEmpty())
    {
      setStatTournamentIds(updatedStats);
    }  // End if updatedStats is not empty
    return updatedStats;
  }  // End findOrCreateTournaments method

  private static Tournament__c findTournamentByName(String tournamentName)
  {
    if(tournamentsByName.get(tournamentName) != null)
    {
      return tournamentsByName.get(tournamentName);
    }  // End if tournamentsByName does not contain the given tournament
    return createTournament(tournamentName);
  }  // End findTournamentByName method

  private static Tournament__c createTournament(String tournamentName)
  {
    Tournament__c newTournament = new Tournament__c(name = tournamentName);
    newTournaments.add(newTournament);
    tournamentsByName.put(newTournament.Name, newTournament);
    upToDate = false;
    return newTournament;
  }  // End createTournament method

  private static void queryForTournaments(Set<String> currentNames)
  {
    String baseQuery = 'select Id,Name from Tournament__c';
    String whereClause = ' where';
    boolean addWhereClause = false;
    if(!currentNames.isEmpty())
    {
      tournamentNames = new Set<String>(currentNames);
      whereClause += ' Name in :tournamentNames';
      addWhereClause = true;
    }  // End if contactNames is not empty
    databaseQuery = baseQuery;
    if(addWhereClause)
    {
      databaseQuery += whereClause;
    }  // End if addWhereClause has been set
    populateTournamentMaps(databaseQuery);
  }  // End refreshData method

  private static void populateTournamentMaps(String tournamentsQuery)
  {
    newTournaments = new List<Tournament__c>();
    databaseTournaments = Database.query(tournamentsQuery);
    tournamentsById = new Map<String, tournament__c>();
    tournamentsByName = new Map<String, tournament__c>();
    for(Tournament__c tournament : databaseTournaments)
    {
      tournamentsById.put(tournament.Id, tournament);
      tournamentsByName.put(tournament.Name, tournament);
    }  // End tournaments loop
    upToDate = true;
  }  // End populateTournamentMaps method

  private static void insertRecords()
  {
    if(!upToDate)
    {
      try
      {
        if(!newTournaments.isEmpty())
        {
          insert newTournaments;
        }  // End if tournaments is not empty
        syncTournamentsById();
        upToDate = true;
      }  // End try block
      catch(exception e)
      {
        
      }  // End catch block
      syncTournamentsById();
    }  // End if upToDate is false
  }  // End insertRecords method

  private static void syncTournamentsById()
  {
    for(Tournament__c tournament : TournamentsByName.values())
    {
      if(!TournamentsById.containsKey(Tournament.Id))
      {
        TournamentsById.put(Tournament.Id, Tournament);
      }  // End if contactsById does not contain c
    }  // End contactsByName loop
  }  // End syncTournamentsById method

  private static void setStatTournamentIds(List<Tournament_Stat__c> tournamentStats)
  {
    for(Tournament_Stat__c ts : tournamentStats)
    {
      if(ts.Tournament__r != null)
      {
        ts.Tournament__c = ts.Tournament__r.Id;
        ts.Tournament__r = null;
      }  // End if Contact__r is not null
    }  // End TournamentStats loop
  }  // End setStatTournamentIds method
}  // End tournamentService class