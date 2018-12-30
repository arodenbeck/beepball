public without sharing class ContactService
{
  private static String nbbaAccountId;
  private static Map<String, Contact> contactsByName;
  private static Map<Id, Contact> contactsById;
  private static List<Contact> databaseContacts;
  private static String databaseQuery;
  private static Set<String> contactNames;
  private static List<Contact> newContacts;
  private static boolean upToDate;

  public static Contact searchByEmail(String emailAddress)
  {
    List<Contact> contacts = [select Id,firstName,lastName,Email from Contact where Email = :emailAddress];
    if(contacts.isEmpty())
    {
      return null;
    }  // End if contacts.isEmpty
    return contacts[0];
  }  // End searchByEmail method

  public static Contact searchById(String contactId)
  {
    List<Contact> contacts = [select Id,firstName,lastName,Email from Contact where Id = :contactId];
    if(contacts.isEmpty())
    {
      return null;
    }  // End if contacts.isEmpty
    return contacts[0];
  }  // End searchById method

  public static Contact createContact(String contactFirstName, String ContactLastName, String contactEmail, String accountId)
  {
    Contact newContact = new Contact(FirstName = contactFirstName, LastName = contactLastName, Email = contactEmail, AccountId = accountId);
    insert newContact;
    return newContact;
  }  // End createContact method

  public static List<Tournament_Stat__c> findOrCreateContacts(List<Tournament_Stat__c> tournamentStats)
  {
    List<Tournament_Stat__c> updatedStats = new List<Tournament_Stat__c>();
    Set<String> currentNames = new Set<String>();
    for(Tournament_Stat__c ts : tournamentStats)
    {
      currentNames.add(ts.Player_Name__c);
    }  // End tournamentStats loop
    queryForContacts(currentNames);
    for(Tournament_Stat__c ts : tournamentStats)
    {
      if(ts.Contact__c == null)
      {
        ts.Contact__r = findContactByName(ts.Player_Name__c);
        updatedStats.add(ts);
      }  // End if Contact__c is null
    }  // End tournamentStats loop
    if(!upToDate)
    {
      insertRecords();
    }  // End if upToDate is false
    if(!updatedStats.isEmpty())
    {
      setStatContactIds(updatedStats);
    }  // End if updatedStats is not empty
    return updatedStats;
  }  // End findOrCreateContacts method

  public static Contact findContactByName(String contactName)
  {
    if(contactsByName.get(contactName) != null)
    {
      return contactsByName.get(contactName);
    }  // End if teamName exists
    return createContact(contactName);
  }  // End findContactByName

  private static Contact createContact(String playerName)
  {
    //List<String> names = playerName.split(' ', 1);
    //String firstName = names[0];
    //String lastName = names[1];
    String firstName = playerName.substringBefore(' ');
    String lastName = playerName.substringAfter(' ');
    System.debug('firstName: ' + firstName);
    System.debug('lastName: ' + lastName);
    Contact newContact = new Contact(FirstName=firstName, LastName=lastName, AccountId=nbbaAccountId);
    newContacts.add(newContact);
    contactsByName.put(firstName + ' ' + lastName, newContact);
    System.debug('Contacts name: ' + newContact.Name);
    upToDate = false;
    return newContact;
  }  // End createContactFromPlayerName

  private static void queryForContacts(Set<String> currentNames)
  {
    String baseQuery = 'select Id,Name from Contact';
    String whereClause = ' where ';
    boolean addWhereClause = false;
    Account nbbaAccount = [select Id,Name from Account where Name = 'National Beep Baseball Association' limit 1];
    nbbaAccountId = '';
    if(nbbaAccount != null)
    {
      nbbaAccountId = nbbaAccount.Id;
      whereClause += 'accountId = :nbbaAccountId';
      addWhereClause = true;
    }  // End if nbbaAccount is not null
    if(!currentNames.isEmpty())
    {
      if(addWhereClause)
      {
        whereClause += ' and';
      }  // End if addWhereClause has been set
      contactNames = new Set<String>(currentNames);
      whereClause += ' Name in :contactNames';
      addWhereClause = true;
    }  // End if contactNames is not empty

    databaseQuery = baseQuery;
    if(addWhereClause)
    {
      databaseQuery += whereClause;
    }  // End if addWhereClause has been set
    populateContactMaps(databaseQuery);
  }  // End queryForContacts

  private static void populateContactMaps(String contactsQuery)
  {
    newContacts = new List<Contact>();
    databaseContacts = Database.query(contactsQuery);
    contactsByName = new Map<String, Contact>();
    contactsById = new Map<Id, Contact>();
    for(Contact c : databaseContacts)
    {
      contactsById.put(c.Id, c);
      contactsByName.put(c.Name, c);
    }  // End databaseContacts loop
    upToDate = true;
  }  // End populateDatabaseMaps

  private static void insertRecords()
  {
    if(!upToDate)
    {
      try
      {
        if(!newContacts.isEmpty())
        {
          insert newContacts;
        }  // End if newContacts is not empty
        syncContactsById();
        upToDate = true;
      }  // End try block
      catch(Exception  e)
      {
        
      }  // End catch block
    }  // End if upToDate is false
  }  // End insertRecords method

  private static void syncContactsById()
  {
    for(Contact c : contactsByName.values())
    {
      if(!contactsById.containsKey(c.Id))
      {
        contactsById.put(c.Id, c);
      }  // End if contactsById does not contain c
    }  // End contactsByName loop
  }  // End syncContactsById method

  private static void setStatContactIds(List<Tournament_Stat__c> tournamentStats)
  {
    for(Tournament_Stat__c ts : tournamentStats)
    {
      if(ts.Contact__r != null)
      {
        ts.Contact__c = ts.Contact__r.Id;
        ts.Contact__r = null;
      }  // End if Contact__r is not null
    }  // End TournamentStats loop
  }  // End setStatContactIds method
}  // End ContactService class