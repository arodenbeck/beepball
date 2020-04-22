public with sharing class VotingController 
{
  public List<Vote__c> votesForSubmission { get;set; }
  public List<SelectOption> availableInitiatives { get;set; }
  public String pageVoterId { get;set; }
public String ballotInitiativeTitle { get;set; }
public String selectedInitiative { get;set; }
  public boolean isVoterIdSearchVisible { get;set; }
  public boolean isElectionVisible { get;set; }
  public boolean isVoteVerificationVisible { get;set; }
  public boolean isNextDisabled { get;set; }
  public boolean isPreviousDisabled { get;set; }
  public boolean isVoteInError { get;set; }
  private Ballot__c ballot;
  private Ballot_Initiative__c currentInitiative;
  private Integer initiativeCount;
  private Integer intCurrentInitiative;
  private Id currentInitiativeId;
  private String setFocusId;
  private List<Ballot_Initiative__c> ballotInitiatives;
  private map<id, List<Vote__c>> votesByInitiativeId;
  private Map<Id, List<VotingSelection>> votingSelectionsByInitiativeId;

  public VotingController()
  {
    this.votingSelectionsByInitiativeId = new Map<Id, List<VotingSelection>>();  
    votesForSubmission = new List<Vote__c>();
    availableInitiatives = new List<SelectOption>();
    isVoterIdSearchVisible = true;
    isElectionVisible = false;
    isVoteInError = false;
    ballotInitiativeTitle = '';
    setFocusId = 'initiativeTitle';
    String urlVoterId = ApexPages.currentPage().getParameters().get('voterId');
    if(!String.isBlank(urlVoterId))
    {
      pageVoterId = urlVoterId;
      PageReference findBallotPage = findBallot();
    }  // End if urlVoterId is not blank
  }  // End constructor

  public List<VotingSelection> getInitiativeSelections()
  {
    return votingSelectionsByInitiativeId.get(currentInitiativeId);
  }  // End initiativeSelections getter method
  public void setInitiativeSelections(List<VotingSelection> newVotingSelections)
  {
    List<VotingSelection> internalVotingSelections = votingSelectionsByInitiativeId.get(currentInitiativeId);
    internalVotingSelections.clear();
    internalVotingSelections.addAll(newVotingSelections);
  }  // End InitiativeSelections setter method
  public String getSetFocusId()
  {
    return setFocusId;
  }  // End setFocusId getter method
  public Integer getVotesAllowed()
  {
    Integer votesAllowed = currentInitiative.Votes_Allowed__c.intValue();
    if(votesAllowed != null)
    {
      return votesAllowed;
    }  // End if votesAllowed is not null
    return 1;
  }  // End votesAllowed getter method
  public PageReference findBallot()
  {
    List<Ballot__c> databaseBallots = [select Id,Name,Election__c from Ballot__c where Name like :pageVoterId];
    if(databaseBallots.isEmpty())
    {
      ApexPages.Message searchError = new ApexPages.Message(ApexPages.Severity.ERROR, 'Your ballot could not be located!', '', 'voterIdInput');
    }  // End if databaseBallots is empty
    else
    {
      ballot = databaseBallots[0];
      isElectionVisible = true;
      isVoterIdSearchVisible = false;
      fetchBallotInitiatives(ballot.Election__c);
      renderCurrentInitiative();
    }  // End else databaseBallots is not empty
    return null;
  }  // End findBallot method
  public PageReference renderNext()
  {
    validate(1);
    return renderCurrentInitiative();
  }  // End renderNext method
  public PageReference renderPrevious()
  {
    validate(-1);
    return renderCurrentInitiative();
  }  // End renderPrevious method
  public PageReference renderCurrentInitiative()
  {
    currentInitiative = ballotInitiatives[intCurrentInitiative];
    currentInitiativeId = currentInitiative.Id;
    ballotInitiativeTitle = currentInitiative.Name;
    if(intCurrentInitiative > 0)
    {
      isPreviousDisabled = false;
    }  // End if intCurrentInitiative is not 0
    else
    {
      isPreviousDisabled = true;
    }  // End else intCurrentInitiative is 0
    if((intCurrentInitiative + 1) < initiativeCount)
    {
      isNextDisabled = false;
    }  // End if intCurrentInitiative +1 is less than initiativeCount
    else 
    {
      isNextDisabled = true;
    }  // End else disable Next
    return null;
  }  // End renderCurrentInitiative method
  public PageReference skipToInitiative()
  {
    intCurrentInitiative = Integer.valueOf(selectedInitiative);
    return renderCurrentInitiative();
  }  // End skipToInitiative method
  public PageReference displayVotes()
  {
    isVoteVerificationVisible = true;
    isElectionVisible = false;
    for(List<VotingSelection> votingSelections : votingSelectionsByInitiativeId.values())
    {
      for(VotingSelection votingSelection : votingSelections)
      {
        Vote__c newVote = new Vote__c();
        newVote.Name = votingSelection.voteTitle;
        newVote.Ballot_Id__c = votingSelection.ballotId;
        newVote.Ballot_Initiative__c = votingSelection.ballotInitiativeId;
        if(votingSelection.candidateId == null)
        {
            newVote.Affirmative__c = votingSelection.Vote;
        }  // End if voteSelection does not have a candidate assigned
        else
        {
          newVote.Candidate__c = votingSelection.CandidateId;
        }  // End else a candidate was assigned
        votesForSubmission.add(newVote);
      }  // End votingSelection loop
    }  // End VotingSelections list loop
    return null;
  }  // End displayVotes method
  private void validate(Integer intNextOrPrev)
  {
    Ballot_Initiative__c ballotInitiative = ballotInitiatives[intCurrentInitiative];
    Integer intNumChosenVotes = 0;
    String errorString = 'You may only check ' + ballotInitiative.Votes_Allowed__c + ' items.';
    ApexPages.Message voteErrorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, errorString);
    for(VotingSelection votingSelection : votingSelectionsByInitiativeId.get(currentInitiativeId))
    {
      if(votingSelection.vote)
      {
        intNumChosenVotes++;
      }  // End if vote selected
    }  // End votingSelections loop
    if(intNumChosenVotes > ballotInitiative.Votes_Allowed__c)
    {
      isVoteInError = true;
      ApexPages.addMessage(voteErrorMessage);
    }  // End if intNumChosenVotes is greater than votes allowed
    else 
    {
      intCurrentInitiative += intNextOrPrev;
    }  // End else advance the page
  }  // End validate method
  public PageReference submitVote()
    {
    try 
    {
      upsert votesForSubmission;
    }  // End try to upsert
    catch(Exception e)
    {

    }  // End catch exception
    return null;
    }  // End submitVote method
  private void fetchBallotInitiatives(Id electionId)
  {
    ballotInitiatives = [select Id,Name,Description__c,Election__c,Has_Selections__c,Number_of_Candidates__c,Votes_Allowed__c, 
     (select Id,Name,Candidate_Profile__c from Ballot_Selections__r)
    from Ballot_Initiative__c where Election__c = :electionId];
    initiativeCount = ballotInitiatives.size();
    intCurrentInitiative = 0;
    Integer intCounter = 0;
    for(Ballot_Initiative__c ballotInitiative : ballotInitiatives)
    {
      availableInitiatives.add(new SelectOption(intCounter.format(), ballotInitiative.Name));
      intCounter++;
      List<VotingSelection> votingSelections = votingSelectionsByInitiativeId.get(ballotInitiative.Id);
      if(votingSelections == null)
      {
        votingSelectionsByInitiativeId.put(ballotInitiative.Id, new List<VotingSelection>());
      }  // End if votingSelections is null
      if(ballotInitiative.Has_Selections__c)
      {
        for(Ballot_Selection__c ballotSelection : ballotInitiative.Ballot_Selections__r)
        {
          votingSelectionsByInitiativeId.get(ballotInitiative.Id).add(new VotingSelection(false, ballotSelection.Name, ballot.Id, ballotInitiative.Id, ballotSelection.Candidate_Profile__c));
        }  // End ballotSelections loop
      }  // End if has_selections is true
      else {
        votingSelectionsByInitiativeId.get(ballotInitiative.Id).add(new VotingSelection(false, ballotInitiative.Name, ballot.Id, ballotInitiative.Id));
      }  // End else This is a single option Initiative
    }  // End ballot initiatives loop
    selectedInitiative = availableInitiatives[0].getLabel();
  }  // End fetchBallotInitiatives method

  public class VotingSelection
  {
    public boolean vote { get;set; }
    public String voteTitle { get;set; }
  public String ballotId { get;set; }
  public String ballotInitiativeId { get;set; }
  public String candidateId { get;set; }
    //public String voteId { get;set; }

    public VotingSelection()
    {
      this.vote = false;
      this.voteTitle = '';
    }  // End default constructor
    public VotingSelection(boolean chosenVote, String paramVoteTitle, String paramBallotId, String paramBallotInitiativeId)
    {
      this.vote = chosenVote;
      this.voteTitle = paramVoteTitle;
      this.ballotId = paramBallotId;
      this.ballotInitiativeId = paramBallotInitiativeId;
    }  // End constructor method
    public VotingSelection(boolean chosenVote, String paramVoteTitle, String paramBallotId, String paramBallotInitiativeId, String paramCandidateId)
    {
      this.vote = chosenVote;
      this.voteTitle = paramVoteTitle;
      this.ballotId = paramBallotId;
      this.ballotInitiativeId = paramBallotInitiativeId;
      this.candidateId = paramCandidateId;
    }  // End constructor method
  }  // End class VotingSelection
}  // End class VotingController
