// SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

contract CrowdFunding{

    mapping (address=>uint) public contributors;   // uint is the value of ether they are donating
    address public manager;
    uint public minContribution;
    uint public target;
    uint public deadline;
    uint public  raisedAmount;         //To compare with target amount
    uint public  noofContributors;    // For voting
    constructor(uint _deadline,uint _target, uint _minContribution){    // Remeber time is in seconds
        
        manager = msg.sender;
        deadline=block.timestamp+_deadline;
        target=_target;
        minContribution = _minContribution;
        
    }
    function sendEthertocontract() public payable {
        require(deadline>block.timestamp,"Sorry!Deadline has already reached");  //To check if the deadline is not crossed na
        require(msg.value>=minContribution,"Minimum Contribution is not met");
        

        // So ab yaha pe yeh if chech karege ki mere address pe value agar 0 hai toh mera yeh first contribution hoga so noofcontributors ++ honge now contributors mein naya address create hua and uspe msg.vlaue (ethers donated) gaye and by deafult us address pe 0 hi hoga so = 0 + msg.value. and raised amount jo bhi hui hogi usme add hoga yeh msg.value .Now if he redontes then if check hoga but is baar contributors meinalready vlaue hai at that address so noofcontributors ++ nhai honge aur baki ka procedure same hi hoga 

        if (contributors[msg.sender]==0) {    // Till this time our contribution is empty and as soon as if likha , contributions mein msg.sender store hua.Also agar as it doesnt store anything so even if we write just if(contributors[msg.sender]){noofcontributors++;} then also code will run as by default usme kuch nahi hai  
            noofContributors++;
        }

        // Noofcontributors ++ is imp bec in its absence  ppl  can send 500 wei 5 times as 100 wie and then their vote would inc so if condition is there
        contributors[msg.sender] = contributors[msg.sender] +msg.value;  //Contributors mein jisne send kiya uska ddress store hua at index and then us index pe uske ether store hua
         raisedAmount =raisedAmount + msg.value;
    }

    function getBalance() public view returns(uint)
    {
        return address(this).balance;
    }

    //Now refunding the money  
    function refund() public {

    require(deadline<block.timestamp && raisedAmount<target,"Right now you are not eligiblre for refund ");
    require(contributors[msg.sender]>0,"You didnt participated only");   // THis is for those who didnt participated but are taking money

    address payable user = payable(msg.sender);   // By this we made the user payable ie now trhe user can take money 
    user.transfer(contributors[msg.sender]);       // Now we refunded the money 
    contributors[msg.sender]=0;                    //Bec we refunded money so account balance 0 kiya 


    }

    // Jo funds collect hore hai till deadline usse hum bahot saare kaam karne wale hai like charity, business, projects etc



    struct request{
        string description;   // manager will describe the project for which he need money  
        address payable recepient;   // woh sab money is project ke address ko jane wali hai 
        uint value; /// kitne money dene wale hai hum recepient ko 
        bool compeleted;  //To check if this request is complete or not
        uint noofVoters;  // To check how many voted 
        mapping (address=>bool) voters;   //For storing the ones which have doine voting. we are storing yes or no for a specific address
    }

    mapping (uint=>request) public noofrequest;    // THi one is storing the no fo requests. Eg- manager requested one for charity, one for business etc etc . So we are storing at different indexes the different request.

    uint public numrequest;   // bec unlike array mapping mein incrmenet wali chhez possible nahi hoti so we are using this .This is like a pointer in arrays 



    modifier onlyManager(){    // INstead of modifier we can write this in our createrequest also
        require(msg.sender==manager,"Only manager can call rgis function");
        _;
    }





    function createRequest(string memory _description, address payable _recepient, uint _value)  public onlyManager{     //This request can only be created by manager  

     request storage newRequest = noofrequest[numrequest];  // So here we created a newreuest pf type request(so we wrote request storage newrequest) and stored it in our noofrequest mapping. numrequest is 0 initially and phir increment kiya.
    numrequest++;
    newRequest.description = _description;
    newRequest.recepient =_recepient;
    newRequest.value= _value;
    newRequest.compeleted= false;   // jab request bani hai tab wo
    newRequest.noofVoters=0;       // as function jab bana hoga tab noofvoters 0 honge
    }

    //Now we will start to vote

    function voteRequest(uint _numrequest) public 
    {
        require(contributors[msg.sender]>0,"You must be a contributor to participate in voting");  
        request storage thisRequest = noofrequest[_numrequest];   // We are pointing ki that specific request to vote karna hai so we stored that request in a new struc(of type request) ie thisRequest
        require(thisRequest.voters[msg.sender]==false,"You have already voted");   // voters is an mapping and in that we checked if that address ne vote kiya hai ya nahi.And initially bool mein false higa agar 3vote nahi kiya hoga 
        thisRequest.voters[msg.sender]=true;  // now person voted
        thisRequest.noofVoters++; 


    }

    // Now if noofvotes 



























}