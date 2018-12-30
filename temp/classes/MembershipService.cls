public with sharing class MembershipService
{
  private static List<Member__c> newMembers;
  private static Map<Id, Member__c> membersById;
  private static Map<String, Member__c> membersByName;
  private static Set<Id> teamIds;
  private static Set<Id> contactIds;
  private static Set<String> membershipYears;
  private static String databaseQuery;
  private static Boolean upToDate;

  public static Member__c createManualMember(String contactId, String teamId, String year)
  {
    List<Member__c> existingMembers = searchExistingMembers(contactId, year);
    Member__c returnMember;
    if(existingMembers.isEmpty())
    {
      Member__c newMember = new Member__c(Name=year, Contact__c=contactId, Team__c=teamId, Year__c=year);
      insert newMember;
      returnMember = newMember;
    }  // End if existingMembers is empty
    else returnMember = existingMembers[0];
    return returnMember;
  }  // End createManualMember method

  public static List<Member__c> searchExistingMembers(String contactId, String year)
  {
    List<Member__c> existingMembers = [select Id,Contact__c,Team__c,Year__c from Member__c where Contact__c = :contactId and Year__c = :year];
    return existingMembers;
  }  // End searchExistingMembers
  public static List<Tournament_Stat__c> findOrCreateMembers(List<Tournament_Stat__c> tournamentStats)
  {
    Set<Id> teams = new Set<Id>();
    Set<Id> contacts = new Set<Id>();
    Set<String> years = new Set<String>();
    List<Tournament_Stat__c> updatedStats = new List<Tournament_Stat__c>();
    // Team processing
    TeamService.findOrCreateTeams(tournamentStats);
    ContactService.findOrCreateContacts(tournamentStats);
    for(Tournament_Stat__c ts : tournamentStats)
    {
      if(ts.Team__c != null)
      {
        teams.add(ts.Team__c);
      }  // End if Team__c is not  null
      if(ts.Contact__c != null)
      {
        contacts.add(ts.Contact__c);
      }  // End if Contact__c is not null
      if(ts.Year__c != null)
      {
        years.add(ts.Year__c);
      }  // End if Year__c is not null
    }  // End tournamentStats loop
    queryForMembers(teams, contacts, years);
    for(Tournament_Stat__c ts : tournamentStats)
    {
      String memberName = ts.Team_Name__c + ' ' + ts.Year__c;
      if(ts.Member__c == null)
      {
        ts.Member__r = findOrCreateMember(ts.Team__c, ts.Contact__c, ts.Year__c, memberName);
        updatedStats.add(ts);
      }  // End if Member__c is null
    }  // End tournamentStats loop
    if(!upToDate)
    {
      insertRecords();
    }  // End if upToDate is false
    if(!updatedStats.isEmpty())
    {
      setStatMemberIds(updatedStats);
    }  // End if updatedStats is not empty
    return updatedStats;
  }  // End findOrCreateMembers method

  public static void updateMembers()
  {
    insertRecords();
  }  // End commit method

  public static Member__c findOrCreateMember(Id teamId, Id contactId, String year, String memberName)
  {
    String nameKey = memberName + (String)contactId;
    if(membersByName.get(nameKey) != null)
    {
      return membersByName.get(nameKey);
    }  // End if teamName exists
    return createMember(teamId, contactId, year, memberName);
  }  // End findOrCreateMembers method

  private static Member__c createMember(Id teamId, Id contactId, String year, String memberName)
  {
    String nameKey = memberName + (String)contactId;
    Member__c newMember = new Member__c();
    newMember.year__c = year;
    newMember.Name = memberName;
    newMember.Team__c = teamId;
    newMember.Contact__c = contactId;
    newMembers.add(newMember);
    membersByName.put(nameKey, newMember);
    upToDate = false;
    return newMember;
  }  // End createMember method

  private static void queryForMembers(Set<Id> teams, Set<Id> contacts, Set<String> years)
  {
    String baseQuery = 'select Id,Name,Team__c,Contact__c,Year__c from Member__c';
    String whereClause = ' where';
    Boolean addWhereClause = false;
    if(!teams.isEmpty())
    {
      teamIds = new Set<Id>(teams);
      addWhereClause = true;
      whereClause += ' Team__c in :teamIds';
    }  // End if teams is not empty
    if(!contacts.isEmpty())
    {
      contactIds = new Set<Id>(contacts);
      if(addWhereClause)
      {
        whereClause += ' and';
      }  // End if addWhereClause is set
      whereClause += ' Contact__c in :contactIds';
      addWhereClause = true;
    }  // End if contacts is not empty
    if(!years.isEmpty())
    {
      membershipYears = new Set<String>(years);
      if(addWhereClause)
      {
        whereClause += ' and';
      }  // End if addWhereClause is set
      whereClause += ' Year__c in :membershipYears';
      addWhereClause = true;
    }  // End if years is not empty
    databaseQuery = baseQuery;
    if(addWhereClause)
    {
      databaseQuery += whereClause;
    }  // End if addWhereClause is set
    populateMemberMaps(databaseQuery);
  }  // End queryForMembers method

  private static void populateMemberMaps(String query)
  {
    newMembers = new List<Member__c>();
    List<Member__c> databaseMembers = Database.query(query);
    membersById = new Map<Id, Member__c>();
    membersByName = new Map<String, Member__c>();
    for(Member__c teamMember : databaseMembers)
    {
      String nameKey = teamMember.Name + (String)teamMember.Contact__c;
      membersById.put(teamMember.Id, teamMember);
      membersByName.put(nameKey, teamMember);
    }  // End members loop
    upToDate = true;
  }  // End populateMemberMaps method

  /***
  * Looks at the newContacts, and new teams lists to see 
  * if any records should be inserted.
  * Maps any new member records with the Id's of the  team and/or it pairs with, and inserts the new member records.
  * Catches all exceptions.
  ***/
  private static void insertRecords()
  {
    if(!upToDate)
    {
      try
      {
        if(!newMembers.isEmpty())
        {
          insert newMembers;
        }  // End if newMembers is not empty
        syncMembersById();
        upToDate = true;
      }  // End try block
      catch(exception e)
      {
      
      }  // End catch block
    }  // End if UpToDate is false
  }  // End insertRecords method

  private static void syncMembersById()
  {
    for(Member__c teamMember : membersByName.values())
    {
      if(!membersById.containsKey(teamMember.Id))
      {
        membersById.put(teamMember.Id, teamMember);
      }  // End if membersById does not contain teamMember
    }  // End membersByName loop
  }  // End syncMembersById method
  private static void setStatMemberIds(List<Tournament_Stat__c> tournamentStats)
  {
    for(Tournament_Stat__c ts : tournamentStats)
    {
      if(ts.Member__r != null)
      {
        ts.Member__c = ts.Member__r.Id;
        ts.Member__r = null;
      }  // End if Member__r is not null
    }  // End TournamentStats loop
  }  // End setStatMemberIds method
}  // End MembershipService class