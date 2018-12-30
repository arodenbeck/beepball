public with sharing class TeamService
{
  private static List<Team__c> newTeams;
  private static Map<String, Team__c> teamsById;
  private static Map<String, Team__c> teamsByName;
  private static boolean upToDate;
  private static Set<String> teamNames;
  private static String teamsQuery;

  /***
  * Returns the Team__c sObject of the passed in teamName.
  * Returns a new Team__c sObject if the team does not yet exist
  ***/
  public static List<SelectOption> getListSelectOptions()
  {
    List<SelectOption> newSelectOptions = new List<SelectOption>();
    for(Team__c team : [select Id,Name from Team__c Order By Name asc])
    {
      newSelectOptions.add(new SelectOption(team.Id, team.Name));
    }  // End teams loop
    return newSelectOptions;
  }  // End getListSelectOptions
  public static String getAccountIdFromTeamId(String teamId)
  {
    List<Team__c> teams = [select Id,Account__c from Team__c where Id = :teamId];
    if(!teams.isEmpty())
    {
      return teams[0].Account__c;
    }  // End if teams is not empty
    return '';
  }  // End getAccountIdFromTeamId

  public static List<Tournament_Stat__c> findOrCreateTeams(List<Tournament_Stat__c> tournamentStats)
  {
    List<Tournament_Stat__c> updatedStats = new List<Tournament_Stat__c>();
    Set<String> statTeamNames = new Set<String>();
    for(Tournament_Stat__c ts : tournamentStats)
    {
      statTeamNames.add(ts.Team_Name__c);
    }  // End tournamentStats loop
    loadTeams(statTeamNames);
    for(Tournament_Stat__c ts : tournamentStats)
    {
      if(ts.Team__c == null)
      {
        ts.Team__r = TeamService.findTeamByName(ts.Team_Name__c);
        updatedStats.add(ts);
      }  // End if Team__c is null
    }  // End tournamentStats loop
    if(!upToDate)
    {
      updateTeams();
    }  // End if the internal database had commits pending
    if(!updatedStats.isEmpty())
    {
      System.debug('TeamService: Stats to Update: ' + updatedStats.size());
      setStatTeamIds(updatedStats);
    }  // End if updatedStats is not empty
    return updatedStats;
  }  // End findOrCreateTeams method

  private static void loadTeams(Set<String> teams)
  {
    newTeams = new List<Team__c>();
    teamsQuery = 'select Id,Name from Team__c';
    if(!teams.isEmpty())
    {
      teamNames = new Set<String>(teams);
      teamsQuery += ' where Name in :teamNames';
    }  // End if teams is not empty
    populateTeamMaps();
  }  // End loadTeams method

  /***
  * Returns the Team__c sObject of the passed in teamName.
  * Returns null if the team does not yet exist
  ***/
  public static Team__c findTeamByName(String teamName)
  {
    if(teamsByName.get(teamName) != null)
    {
      return teamsByName.get(teamName);
    }  // End if teamName exists
    return createTeam(teamName);
  }  // End findTeamByName method

  public static void updateTeams()
  {
    insertRecords();
  }  // End updateTeams method

  public static boolean upToDate()
  {
    return upToDate;
  }  // End upToDate method

  private static Team__c createTeam(String teamName)
  {
    Team__c newTeam = new Team__c(name = teamName);
    newTeams.add(newTeam);
    teamsByName.put(teamName, newTeam);
    // signal that a team has been created
    upToDate = false;
    return newTeam;
  }  // End createTeam method

  private static void populateTeamMaps()
  {
    List<Team__c> databaseTeams = Database.query(teamsQuery);
    teamsById = new Map<String, Team__c>();
    teamsByName = new Map<String, Team__c>();
    for(Team__c team : databaseTeams)
    {
      teamsById.put(team.Id, team);
      teamsByName.put(team.Name, team);
    }  // End databaseTeams loop
    upToDate = true;
  }  // End populateTeamMaps method

  private static void insertRecords()
  {
    if(!upToDate)
    {
      try
      {
        if(!newTeams.isEmpty())
        {
          insert newTeams;
        }  // End if teams is not empty
        syncTeamsById();
        upToDate = true;
      }  // End try block
      catch(DMLException e)
      {
        System.debug('Error inserting teams: ' + e.getMessage());
      }  // End DMLException catch block
      catch(Exception e)
      {
        
      }  // End catch block
    }  // End if upToDate is false
  }  // End insertRecords method

  private static void syncTeamsById()
  {
    for(Team__c team : teamsByName.values())
    {
        if(!teamsById.containsKey(team.Id))
        {
          teamsById.put(team.Id, team);
        }  // End if teamsById does not contain this team
    }  // End teamsByName loop
  }  // End syncTeamsById method

  private static void setStatTeamIds(List<Tournament_Stat__c> tournamentStats)
  {
    for(Tournament_Stat__c ts : tournamentStats)
    {
      if(ts.Team__r != null)
      {
        ts.Team__c = ts.Team__r.Id;
        ts.Team__r = null;
        System.debug('Team Id: ' + ts.Team__c + ' Name: ' + ts.Team_Name__c);
      }  // End if Team__r is not null
    }  // End TournamentStats loop
  }  // End setStatTeamIds
}  // End TeamService class