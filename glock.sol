
pragma solidity ^0.4.2;
contract Glock {
    address private nzpol=0xb5dd550c7a0bdd3a4a2a01caad930d8c97e5ae90;
    address private ent1=0x753c92ada0825a29b942af1aa886c827183bd4a3;
    address private ent2=0x320ee57a93bcde933f54d2f18c8d1397ad5b1e26;
    address private ent3=0x90d9c2de8b5937a1110b99bf0a995bc19424021e;
    function Glock(){
    
        Manf[0xDB0181988CF3Ca7dB4C4028C0f8D48a35BDB8c20]=true;
        createGuns(123,"Nighthawk");
        createGuns(2123,"DesertEagle");
        createGuns(135,"M4a1");
        createGuns(444,"Glock845");
        regOwner("james","Blake",0x9a150003ad6d6ea60e5fc9e6e71d70828176bc92);
        regOwner("Tommy","Robredo",0x8571c458b83a39823fb735fd273c1bfd0fde90d8);
        Licence[0x9a150003ad6d6ea60e5fc9e6e71d70828176bc92]=true;
        Licence[0x8571c458b83a39823fb735fd273c1bfd0fde90d8]=true;
        Licence[0xdb0181988cf3ca7db4c4028c0f8d48a35bdb8c20]=true;
        Licence[0xa61ff35e1b5d891791921a868a92f072fcf32353]=true;
        Licence[0x7bdbae7a8e98d49ddde8ea04b46e83b5d7d083d1]=false;
        Licence[0x4d65c1955e3575761cbc5dcd95039abfd3003719]=true;
        setOwner(123,0xdb0181988cf3ca7db4c4028c0f8d48a35bdb8c20);
        setOwner(2123,0xdb0181988cf3ca7db4c4028c0f8d48a35bdb8c20);
        setOwner(135,0x9a150003ad6d6ea60e5fc9e6e71d70828176bc92);
        setOwner(444,0x8571c458b83a39823fb735fd273c1bfd0fde90d8);
        Avail[123]=false;
        Avail[3123]=false;
        Avail[135]=false;
        Avail[444]=false;
        
    }
    
    struct Trace{
        uint trace_id;
        uint gun_serial;
        string model;
        string location;
        string date;
        string time;
        
        
    }
    
    struct Gun{
        uint gid;
        string model;
        uint price; 
        
    }
    struct Owner{
        string fn;
        string ln;
    }
    mapping(uint=>uint) bid_time;
    mapping(uint=>uint) auctionendtime;
    mapping(uint=>uint) Stolen;
    mapping(address=>uint) voted;
    mapping(uint=>uint) votes;
    mapping(uint=>Trace) tracerecords;
    mapping(uint=>uint) saleconf;
    mapping(uint=>uint) topbid;
    mapping(uint=>address) winner;
    mapping(uint=>address[]) Ownerhistory;
    mapping(address=>bool) Manf;
    mapping(uint=>address) Ownership;
    mapping(uint=>Gun) Gunlist;
    mapping(address=>Owner) Ownerdetails;
    mapping(address=>bool) Licence;
    mapping(uint=>bool) Avail;
    uint[]  gidlist;
    uint[] tracelist;
    address[] public Ownerlist;
    uint[] public stolenGuns;
    
    
    function regOwner(string _fn,string _ln,address _add) public {
        Ownerdetails[_add].fn=_fn;
        Ownerdetails[_add].ln=_ln;
        
    }
    
    function createGuns(uint _gid,string _model) public{
        require(Manf[msg.sender]==true,"You do not have a Manufacturer or Dealer licence");
        Gunlist[_gid].gid=_gid;
        Gunlist[_gid].model=_model;
        gidlist.push(_gid) -1;     
    
        
    }
    
    function setOwner(uint _gid,address _add) private{
        Ownership[_gid]=_add;
        Ownerhistory[_gid].push(_add) -1;
                        
    }
    
       
    function getGuns() view public returns (uint[]){
        return gidlist;
    }
    
    function getOwner(uint _gid) view public returns (address){
        return Ownership[_gid];
    }

       function setAvail(uint _gid,bool _av){
        require(Manf[msg.sender]!=true,'You cannot sell this product in an auction');
        require(Stolen[_gid]!=1,'The gun is stolen');
        require(Ownership[_gid]==msg.sender,'You are not the owner of the gun. Tampering attempt detected');
        require(getPrice(_gid)!=0,'Please set a reserve price for the auction');
        Avail[_gid]=_av;
        bid_time[_gid]=60 seconds;
        auctionendtime[_gid]=now+bid_time[_gid];
        }
        
       function setAvailm(uint _gid,bool _av) public{
        require(Manf[msg.sender]==true,'You do not have a manf/dealer licence');
        require(Stolen[_gid]!=1,'The gun is stolen');
        require(Ownership[_gid]==msg.sender,'You are not the owner of the gun. Tampering attempt detected');
        require(getPrice(_gid)!=0,'Please set a price for the gun');
        Avail[_gid]=_av;   
       }    
    
    function setPrice(uint _gid,uint _price){
        require(Stolen[_gid]!=1,'This is a stolen gun');
        require(Ownership[_gid]==msg.sender,'You canot set the price. Tamper attempt');
        Gunlist[_gid].price=_price;
        
    } 
    
    function getPrice(uint _gid) view public returns(uint){
        return Gunlist[_gid].price;
    }
                    
    function confirmGunsale(uint _gid) public payable{
        require(Stolen[_gid]!=1,'This is a stolen gun');
        require(Avail[_gid]==true,'the gun is not for sale');
        require(Ownership[_gid]==msg.sender,'You are not the owner');
        saleconf[_gid]=1;    
    }           
    
    function getSaleconfstatus(uint _gid) view public returns(uint){
        return saleconf[_gid];
    }
    function buyGun(uint _gid) public payable{
        require(Stolen[_gid]!=1,'This is a stolen gun');
        require(Licence[msg.sender]==true,'You do not hold a valid licence');
        require(Avail[_gid]==true,'the gun is not for sale');
        require(saleconf[_gid]==1,'your bid has not yet been confirmed');
        require(msg.value==topbid[_gid]*1000000000000000000,'You have not met price requirements');
        require(msg.sender==winner[_gid],'you are not the winner of the bid`');
        Ownership[_gid].transfer(msg.value);
        setOwner(_gid,msg.sender);
        Avail[_gid]=false;
        winner[_gid]=0x0;
        topbid[_gid]=0;
        saleconf[_gid]=0;
        
    }
    
    function getOwnerhistory(uint _gid) view public returns (address[]) {
        return Ownerhistory[_gid];
    }
    
    function placeBid(uint _gid,uint _price) public {
        require(Stolen[_gid]!=1,'This is a stolen gun');
        require(Licence[msg.sender]==true,'You do not hold a valid licence');
        require(Avail[_gid]==true,'the gun is not for sale');
        require(_price>= getPrice(_gid),'Please bid higher than the reserve price');
        require(_price>topbid[_gid],'please make a higher bid');
        require(saleconf[_gid]!=1,'You cannot bid now. Bidding is over');
        require(now<auctionendtime[_gid],'The auction has ended');
        {
            topbid[_gid]=_price;    
            winner[_gid]=msg.sender;
            
        } 
        
    }
    
    function getWinner(uint _gid) view public returns(address) {
        return winner[_gid];
    } 
    
    
    function getleadingBid(uint _gid) view public returns(uint) {
        require(topbid[_gid]!=0,'no bids yet');
        return topbid[_gid];
    } 
    
    function initTrace(uint _traceid,uint _gun_serial,string _location,string _date,string _time) public {
        require(msg.sender==nzpol,'Only the police have permission to do that');        
        tracerecords[_traceid].trace_id=_traceid;
        tracerecords[_traceid].gun_serial=_gun_serial;
        tracerecords[_traceid].model=Gunlist[_gun_serial].model;
        tracerecords[_traceid].location=_location;
        tracerecords[_traceid].date=_date;
        tracerecords[_traceid].time=_time;
        tracelist.push(_traceid) -1;

    }
    
    function getTraces() view public returns(uint[]){
        return tracelist;
    }
    
    function getTraceinfo(uint _traceid) view public returns(uint,string,string,string,string){
        return(tracerecords[_traceid].gun_serial,tracerecords[_traceid].model,tracerecords[_traceid].location,tracerecords[_traceid].date,tracerecords[_traceid].time);
    }
    
    function Vote(uint _traceid) public{
               require(msg.sender!=nzpol,'You as a law enforcement cannot do that');
               require(msg.sender==ent1||msg.sender==ent2||msg.sender==ent3,'you are not allowed to vote');
               require(voted[msg.sender]!=1,'You have already voted');
               voted[msg.sender]=1;
               votes[_traceid]=votes[_traceid]+1;
               
    }
    
    function getVotes(uint _traceid) view public returns(uint){
        return votes[_traceid];
    }
    
    function getOwnerDetails(uint _traceid) view public returns (string,string){ 
        require(votes[_traceid]==3,'You do not have enough votes to do that');
        return (Ownerdetails[Ownership[tracerecords[_traceid].gun_serial]].fn,Ownerdetails[Ownership[tracerecords[_traceid].gun_serial]].ln);                
        
        }
    function ReportStolen(uint _gid) public{
        require(msg.sender==getOwner(_gid),'Only the owner can report it stolen. Tampering attempt detected');
        Stolen[_gid]=1;
        stolenGuns.push(_gid) -1;
    }    
    
    function getTimeleft(uint _gid) view public returns(uint){
        return (auctionendtime[_gid]-now);
        
    }
    function buyGunX(uint _gid) public payable{
        require(Manf[getOwner(_gid)]==true,'Functionality not accessible');
        require(msg.value==getPrice(_gid)* 1 ether,'Please pay the price of the gun');
        
        setOwner(_gid,msg.sender);
        Avail[_gid]=false;
        setPrice(_gid,0);
        
    }
    
    
    
}




