public with sharing class VotingController 
{
  public List<Vote__c> votesForSubmission { get;set; }
  public String pageVoterId { get;set; }
public String ballotInitiativeTitle { get;set; }
  public boolean isVoterIdSearchVisible { get;set; }
  public boolean isElectionVisible { get;set; }
  public boolean isVoteVerificationVisible { get;set; }
  public boolean isNextDisabled { get;set; }
  public boolean isPreviousDisabled { get;set; }
  private Ballot__c ballot;
  private Integer initiativeCount;
  private Integer intCurrentInitiative;
  private Id currentInitiativeId;
  private List<Ballot_Initiative__c> ballotInitiatives;
  private map<id, List<Vote__c>> votesByInitiativeId;
  private Map<Id, List<VotingSelection>> votingSelectionsByInitiativeId;

  public VotingController()
  {
    this.votingSelectionsByInitiativeId = new Map<Id, List<VotingSelections>>();  
    votesForSubmission = new List<Vote__c>();
    isVoterIdSearchVisible = true;
    isElectionVisible = false;
    ballotInitiativeTitle = '';
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
  public PageReference findBallot()
  {
    List<Ballot__c> databaseBallots = [select Id,Name,Election__c from Ballot__c where Name like :pageVoterId];
    if(databaseBallots.isEmpty())
    {
      
    }  // End if databaseBallots is empty
    else
    {
      ballot = databaseBallots[0];
     isElectionVisible = true;
      isVoterIdSearchVisible = false;
      votesByInitiativeId = new Map<id, List<Vote__c>>();
      for(Vote__c vote : [select Id,Name,Affirmative__c,Ballot_Initiative__c,Candidate__c from Vote__c where Ballot_Id__c = :ballot.Id)
      {
          List<Vote__c> votesByInitiative = votesByInitiativeId.get(vote.Ballot_Initiative__c)
          if(votesByInitiative == null)
          {
            votesByInitiativeId.put(vote.Ballot_Initiative__c, new List<Vote__c>());
          }  // End if votesByInitiative is null
          votesByInitiativeIds.get(vote.Ballot_Initiative__c).add(vote);
      }  // End votes loop

      fetchBallotInitiatives(ballot.Election__c);
    }  // End else databaseBallots is not empty
    return renderCurrentInitiative();
  }  // End findBallot method
  public PageReference renderNext()
  {
    intCurrentInitiative++;
    if(intCurrentInitiative => initiativeCount)
    {
      isNextDisabled = true;
      intCurrentInitiative = (initiativeCount - 1);
    }  // End if intCurrentInitiative greater or equal to intiaitiveCount
    return null;
  }  // End renderNext method
  public PageReference renderPrevious()
  {
    intCurrentInitiative--;
    if(intCurrentInitiative > 0)
    {
      isPreviousDisabled = true;
      intCurrentInitiative = 0;
    }  // End if intCurrentInitiative less than 0
    return null;
  }  // End renderPrevious method
  public PageReference renderCurrentInitiative()
  {
    currentInitiativeId = ballotInitiatives[intCurrentInitiative].Id;
    ballotInitiativeTitle = ballotInitiatives[intCurrentInitiative].Name;
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
  }  // End renderCurrentInitiative method
  public PageReference displayVotes()
  {
    isVoteSubmissionVisible = true;
    isElectionVisible = false;
    for(List<VotingSelection> votingSelections : votingSelectionsByInitiativeId.values())
    {
      for(VotingSelection votingSelection : votingSelections)
      {
        Vote__c newVote = new Vote__c();
        newVote.Name = voteSelection.voteTitle;
        newVote.Ballot_Id__c = voteSelection.ballotId;
        newVote.Ballot_Initiative__c = voteSelection.ballotInitiativeId;
        if(voteSelection.candidateId == null)
        {
            newVote.Affirmative__c = voteSelection.Vote;
        }  // End if voteSelection does not have a candidate assigned
        else
        {
          newVote.Candidate__c = voteSelection.CandidateId;
        }  // End else a candidate was assigned
        votesForSubmission.add(newVote);
      }  // End votingSelection loop
    }  // End VotingSelections list loop
    return null;
  }  // End displayVotes method
  public PageReference validate()
  {
    
    return null;
  }  // End validate method
  public PageReference submitVote()
    {

    }  // End submitVote method
  private void fetchBallotInitiatives(Id electionId)
  {
    ballotInitiatives = [select Id,Name,Description__c,Election__c,Has_Selections__c,Number_of_Candidates__c,Votes_Allowed__c, 
     (select Id,Name,Candidate_Profile__c from Ballot_Selections__r)
    from Ballot_Initiative__c where Election__c = :electionId];
    initiativeCount = ballotInitiatives.size();
    intCurrentInitiative = 0;
    for(Ballot_Initiative__c ballotInitiative : ballotInitiatives)
    {
      if(ballotInittiative.Has_Selections__c)
      {
        for(Ballot_Selection__c ballotSelection : ballotInitiative.Ballot_Selections__r)
        {
          List<VotingSelection> votingSelections = votingSelectionsByInitiativeId.get(ballotInitiative.Id);
          if(votingSelections == null)
          {
            votingSelectionsByInitiativeId.put(ballotInitiative, new List<VotingSelection>());
          }  // End if votingSelections is null
          votingSelectionsByInitiativeId.get(ballotInitiative.Id).add(new VotingSelection(false, ballotSelection.Name, ballot.Id, ballotInitiative.Id, ballotInitiative.Candidate_Profile__c));
        }  // End ballotSelections loop
      }  // End if has_selections is true
      votingSelectionsByInitiativeId.put(ballotInitiative.Id, new List<VotingSelection>(new VotingSelection(false, ballotSelection.Name, ballot.Id, ballotInitiative.Id)));
    }  // End ballot initiatives loop
  }  // End fetchBallotInitiatives

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
