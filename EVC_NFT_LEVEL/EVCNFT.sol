// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Counters.sol";
import "./ERC721.sol";
import "./ERC721Enumerable.sol";
import "./Ownable.sol";
import "./Strings.sol";
import "./SafeERC20.sol";

contract Avtars is Ownable, ERC721Enumerable {

    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    using Strings for uint256;

    address public _token = 0xd9145CCE52D386f254917e481eB44e9943F39138; //busd
    address public delegateAddress = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;

    uint256[8] public costs = [100 ether, 500 ether, 1000 ether, 2500 ether, 5000 ether, 10000 ether, 25000 ether, 50000 ether];
    uint256[8] public NFT_Quantities = [10, 10, 10, 10, 10, 10, 10, 10];
    
    uint256 public maxSupply = 113600;
    uint256 public maxMintAmount = 10;

    string public baseExtension = ".json";
    string public baseURI = "ipfs://QmZLfZHMA5bXDPWRAeMvBAGokxgm1rF2DbgyrFrTfeoAv4/";


    bool public paused = false;
    bool public delegate = false;

    // mapping(address => bool) public _hasToken1;
    // mapping(address => bool) public _hasToken2;
    // mapping(address => bool) public _hasToken3;
    // mapping(address => bool) public _hasToken4;
    // mapping(address => bool) public _hasToken5;
    // mapping(address => bool) public _hasToken6;
    // mapping(address => bool) public _hasToken7;
    // mapping(address => bool) public _hasToken8;

    mapping(address => bool) public whitelisted;
    uint256[] public NFTidArray;

/////////////////////////

    mapping(address => uint256) public referralCount;
    mapping(address => uint256) referralRank;
    mapping(address => address) myReferrer;
    mapping(address => address[]) referrals;

    mapping(address => mapping(address => uint)) public userInvsetment;
    mapping(address => address[]) public upgradingRank;
    mapping(address => uint) public teamVloume;
    mapping(address => bool)[8] public hasTokens;
    mapping(address => mapping(address => uint)) public userInvestment;

    mapping(address => individualLevel) public individualLevelinfo;
    uint public rankTarget = 10000 ether ;

    struct individualLevel{
        bool level1;
        bool level2;
        bool level3;
        bool level4;
        bool level5;
        bool level6;
        bool level7;
    }

    struct teamStatistic{
        address _user;
        uint _rank;
        uint _totalPartners;
        string nftLevel;
        uint totalTeamSales;
    }

    // mapping(address => teamStatistic) public teamStatistics;
    // teamStatistic[] public myArray;
    // mapping(address => teamStatistic[]) public myTeamArray;
    Counters.Counter[8] public NFT_Counters;


////////////////////////

    constructor(
        string memory _name,
        string memory _symbol
    ) ERC721(_name, _symbol) {
        NFT_Counters[1]._value = 20;
        NFT_Counters[2]._value = 30;
        NFT_Counters[3]._value = 40;
        NFT_Counters[4]._value = 50;
        NFT_Counters[5]._value = 60;
        NFT_Counters[6]._value = 70;
        NFT_Counters[7]._value = 80;
    }

///////////////////

    // function setReferrer(address referrer) internal {
    //     require(referrer != msg.sender, "Cannot refer yourself");
    //     myReferrer[msg.sender] = referrer;
    //     referrals[referrer].push(msg.sender);
    // }

    function setReferrer(address referrer) internal {
        if (myReferrer[msg.sender]==address(0)){
        require(referrer != msg.sender, "Cannot refer yourself");
        myReferrer[msg.sender] = referrer;
        referrals[referrer].push(msg.sender);
        referralCount[referrer]++;}
        else if(myReferrer[msg.sender]!=address(0)){
            require(myReferrer[msg.sender]==referrer,"fill correct reffral address");
        }
    }

    function getReferrals(address referrer) public view returns(address[] memory) {
        return referrals[referrer];
    }

    function upLifting(address _referrer) internal {

        address three;
        address four;
        address five;
        address six;
        address seven;

        referralRank[_referrer] = 1;

        if (_referrer != address(0)) {
            referralCount[_referrer]++;
        }
        bool isExist = false;
        for (uint i = 0; i < upgradingRank[_referrer].length; i++) {
            if (upgradingRank[_referrer][i] == msg.sender) {
                isExist = true;
                break;
            }
        }
        if (userInvsetment[msg.sender][_referrer] >= rankTarget && !isExist){
            upgradingRank[_referrer].push(msg.sender);
        }

        if (upgradingRank[_referrer].length >= 3){
            referralRank[_referrer] = 2;

            three = myReferrer[_referrer] ;
            four = myReferrer[three];
            five = myReferrer[four];
            six = myReferrer[five];
            seven = myReferrer[six];

            referralRank[three] = 3;
            referralRank[four] = 4;
            referralRank[five] = 5;
            referralRank[six] = 6;
            referralRank[seven] = 7;
        }


    }


    // function updateTEAMsalesvolume(address user) public {
    //     for (uint i=0;i< referrals[user].length; i++){
    //         address member = referrals[user][i];
    //         if (referrals[member].length > 0){
    //             teamVloume[user] = userInvsetment[member] + teamVloume[member];

    //         }
    //     }
    // }
// //function uses lot of gas so not in use
//     function updateTEAMsalesvolume(address user) public {
//     for (uint i=0; i<referrals[user].length; i++){
//         address member = referrals[user][i];
//         uint totalInvestment = 0;
//         if (referrals[member].length > 0){
//             // Iterate over keys of userInvsetment[member] and add up values
//             address[] memory keys = referrals[member];
//             for (uint j=0; j<keys.length; j++) {
//                 address key = keys[j];
//                 totalInvestment += userInvsetment[key][member];
//             }
//             teamVloume[user] = totalInvestment + userInvsetment[member][user];
//         }else{
//             totalInvestment += userInvsetment[member][user];
//             teamVloume[user] = totalInvestment;
//         }
//     }
    
// }

    function getTeamSaleVolume(address user) public view returns(uint) {
        uint totalInvestment = userInvestment[user][user];
        for (uint i = 0; i < referrals[user].length; i++) {
            address member = referrals[user][i];
            totalInvestment += userInvestment[member][user];
            if (referrals[member].length > 0) {
                totalInvestment += getTeamSaleVolume(member);
            }
        }
        return totalInvestment;
    }


    function rankupLifting(address _user) public {
        if (referralRank[_user] == 6) {
            if (getTeamSaleVolume(_user) >= 700 && checkRank(_user) && hasTokens[6][_user]) {
                referralRank[_user] = 7;
            }
        } else if (referralRank[_user] == 5) {
            if (getTeamSaleVolume(_user) >= 600 && checkRank(_user) && hasTokens[5][_user]) {
                referralRank[_user] = 6;
            }
        } else if (referralRank[_user] == 4) {
            if (getTeamSaleVolume(_user) >= 500 && checkRank(_user) && hasTokens[4][_user]) {
                referralRank[_user] = 5;
            }
        } else if (referralRank[_user] == 3) {
            if (getTeamSaleVolume(_user) >= 400 && checkRank(_user) && hasTokens[3][_user]) {
                referralRank[_user] = 4;
            }
        } else if (referralRank[_user] == 2) {
            if (getTeamSaleVolume(_user) >= 300 && checkRank(_user) && hasTokens[2][_user]) {
                referralRank[_user] = 3;
            }
        } else if (referralRank[_user] == 1) {
            if (getTeamSaleVolume(_user) >= 200 && checkRank(_user) && hasTokens[1][_user]) {
                referralRank[_user] = 2;
            }
        } else if (referralRank[_user] == 0) {
            if (getTeamSaleVolume(_user) >= 100 && hasTokens[0][_user]) {
                referralRank[_user] = 1;
            }
        }
    }




    // function rankupLifting(address _user)public {
        
    //     if (referralRank[_user] == 6){
    //         if (getTeamSaleVolume(_user)>=700 && checkRank(_user) && _hasToken7[_user]){
    //         referralRank[_user] = 7;
    //     }
    // }
    //     else if(referralRank[_user] == 5){
    //         if (getTeamSaleVolume(_user)>=600 && checkRank(_user) && _hasToken6[_user]){
    //         referralRank[_user] = 6;
    //     }
    // }
    //     else if(referralRank[_user] == 4){
    //         if (getTeamSaleVolume(_user)>=500 && checkRank(_user) && _hasToken5[_user]){
    //         referralRank[_user] = 5;
    //     }
    // }
    //     else if(referralRank[_user] == 3){
    //         if (getTeamSaleVolume(_user)>=400 && checkRank(_user) && _hasToken4[_user]){
    //         referralRank[_user] = 4;
    //     }
    // }
    //      else if(referralRank[_user] == 2){
    //          if (getTeamSaleVolume(_user)>=300 && checkRank(_user) && _hasToken3[_user]){
    //         referralRank[_user] = 3;
    //     }
    // }
    //      else if(referralRank[_user] == 1){ 
    //         if (getTeamSaleVolume(_user)>=200 && checkRank(_user) && _hasToken2[_user]){
    //         referralRank[_user] = 2;
    //     }
    // }
    //      else if(referralRank[_user] == 0){
    //         if (getTeamSaleVolume(_user)>=100  && _hasToken1[_user]){
    //         referralRank[_user] = 1;
    //     }
    // }

    // } 

   function checkRank(address _user) public view returns(bool){
       uint usercurrentrank= referralRank[_user];
       uint memberrankCount;
       for (uint i = 0 ; i<referrals[_user].length; i++){
           address member = referrals[_user][i];
           
           if( referralRank[member] >= usercurrentrank){
               memberrankCount++;
              }

            if(memberrankCount>=3){
                return true;               
            }
       }
       if(memberrankCount < 3){
           for (uint i = 0 ; i<referrals[_user].length; i++){
               address member = referrals[_user][i];
               if(referralRank[member] < usercurrentrank){
                   bool found = legSearch(member, usercurrentrank);
                   if(found == true){
                       memberrankCount++;
                   }
               }
               if(memberrankCount>=3){
                return true;               
            }
           }
       }

       return false;


   }

//    function legSearch(address member, uint currentrank) internal view returns(bool){
//        bool found = false;
//        if(referrals[member].length > 0){
//            for(uint i = 0; i < referrals[member].length; i++){
//                if(referralRank[referrals[member][i]] >= currentrank){
//                    found = true;
//                    break;
//                }
//                if(referrals[referrals[member][i]].length > 0){
//                    found = legSearch(referrals[member][i], currentrank);
//                }
//                if(found == true){
//                    break;
//                }
//            }
//        }
//        return found;
//    }



    function legSearch(address member, uint currentrank) internal view returns(bool) {
        if (referrals[member].length == 0) {
            return false;
        }
        for (uint i = 0; i < referrals[member].length; i++) {
            address referrer = referrals[member][i];
            if (referralRank[referrer] >= currentrank) {
                return true;
            }
            if (legSearch(referrer, currentrank)) {
                return true;
            }
        }
        return false;
    }


    function getNFTCost(uint _level) public view returns(uint){
        uint level = _level - 1;
        return costs[level];
    }


    function getTotalPartners(address _user) public view returns(uint){
       uint totalPartners;
       if(referrals[_user].length > 0){
           totalPartners += referrals[_user].length;
           for(uint i = 0; i < referrals[_user].length; i++){
               uint partnersTotal = getTotalPartners(referrals[_user][i]);
               totalPartners += partnersTotal;
       }
       }
       return totalPartners;
    }

    function teamSalesINformation(address _user) public view returns(teamStatistic[] memory){
       teamStatistic[] memory teamStatisticsArray = new teamStatistic[](referrals[_user].length);
       for(uint i = 0; i < referrals[_user].length; i++){
        address user = referrals[_user][i];
        uint userRank = referralRank[user];
        uint Totalpartner = getTotalPartners(user);
        uint teamTurnover = getTeamSaleVolume(user);
        string memory ownNFT;
            if (hasTokens[7][user]) {
                ownNFT = "CryptoCap Tycoon";
            } else if (hasTokens[6][user]) {
                ownNFT = "Bitcoin Billionaire";
            } else if (hasTokens[5][user]) {
                ownNFT = "Blockchain Mogul";
            } else if (hasTokens[4][user]) {
                ownNFT = "Crypto King";
            } else if (hasTokens[3][user]) {
                ownNFT = "Crypto Investor";
            } else if (hasTokens[2][user]) {
                ownNFT = "Crypto Entrepreneur";
            } else if (hasTokens[1][user]) {
                ownNFT = "Crypto Enthusiast";
            } else if (hasTokens[0][user]) {
                ownNFT = "Crypto Newbies";
            }
        teamStatistic memory teamStatisticsInfo = teamStatistic(user, userRank, Totalpartner, ownNFT, teamTurnover);
        teamStatisticsArray[i] = teamStatisticsInfo;
        }
        return teamStatisticsArray;
       }


/////////////////// admin function 

    function createReffralarray(address _ref ,address[] memory to ) public onlyOwner{
        for(uint i = 0; i < to.length; i++){
            referrals[_ref].push(to[i]);
        }
    }

    function changeRank(address _user , uint _rank) public onlyOwner{
        require(_rank <= 7 ,"rank cannot be more than 7" );
        referralRank[_user] = _rank;

    }

    function changeinvestment(address _user , uint _value,address _referrer)  public onlyOwner{
        userInvsetment[_user][_referrer] = _value;

    }

    function setNftLevel(address _useradd, uint _level) public {
        if (_level == 1) {
            hasTokens[0][_useradd] = true;
        }
        if (_level == 2) {
            hasTokens[1][_useradd] = true;
        }
        if (_level == 3) {
            hasTokens[2][_useradd] = true;
        }
        if (_level == 4) {
            hasTokens[3][_useradd] = true;
        }
        if (_level == 5) {
            hasTokens[4][_useradd] = true;
        }
        if (_level == 6) {
            hasTokens[5][_useradd] = true;
        }
        if (_level == 7) {
            hasTokens[6][_useradd] = true;
        }
        if (_level == 8) {
            hasTokens[7][_useradd] = true;
        }
    }
//////////////////



    //User


    function mintNFT(uint _level, uint _mintPrice, bool _delegate, address _referrer) public {
        uint level = _level - 1;
        require(level >= 0 && level <= 7, "Invalid NFT level");
        require(!hasTokens[level][msg.sender], "You already have an NFT of this level!");
        require(!paused, "Minting is paused");
        require(totalSupplyOfLevel(_level) < NFT_Quantities[level], "Cannot mint more NFTs of this level");
        setReferrer(_referrer); // constant referrer
        if (msg.sender != owner()) {
            if (!whitelisted[msg.sender]) {
                uint requiredPrice = costs[level];
                require(_mintPrice >= requiredPrice, "Insufficient payment amount");
                if (_delegate == true) {
                    uint sharePrice = requiredPrice * 10 / 100;
                    uint newMintPrice = requiredPrice + sharePrice;
                    require(_mintPrice >= newMintPrice, "Insufficient payment amount; if delegate is true, add 10% more.");
                    uint256 transferValue = _mintPrice - requiredPrice - sharePrice;
                    uint shareToDelegate = sharePrice + transferValue;
                    IERC20(_token).safeTransferFrom(msg.sender, address(this), requiredPrice);
                    IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, shareToDelegate);
                } else {
                    IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
                }
            }
        }
        NFT_Counters[level].increment();
        uint256 tokenId = NFT_Counters[level].current();
        NFTidArray.push(tokenId);
        userInvestment[msg.sender][_referrer] += _mintPrice;
        _safeMint(msg.sender, tokenId);
        hasTokens[level][msg.sender] = true;
        // rankupLifting(msg.sender);
        rankUpdate();
    }


    // function mint_Level1_NFT(uint _mintPrice, bool _delegate, address _referrer) public {
    //     require(!_hasToken1[msg.sender], "You already have a Level 1 NFT!");
    //     delegate = _delegate;
    //     /////////////////////
    //    // myReferrer[msg.sender] = _referrer;
    //     setReferrer(_referrer);
        
    //     //////////////////////
    //     // uint256 supply = totalSupplyOfLevel(0);
    //     require(!paused);
    //     // require(supply <= maxSupply);
    //     require(totalSupplyOfLevel(0) < NFT_Quantities[0], "can't mint more than this level");
    //     if (msg.sender != owner()) {
    //         if (whitelisted[msg.sender] != true) {
    //             require(_mintPrice >= costs[0], "pay amount can't be low");
    //             if (delegate == true) {
    //                 uint _sharePrice = costs[0] * 10 / 100;
    //                 uint _newmint = costs[0] + _sharePrice;
    //                 require(_mintPrice >= _newmint, "pay amount can't be low; if delegate is true, add 10% more.");
    //                 uint _transfervalue = (_mintPrice - _sharePrice) - costs[0];
    //                 uint sharetodelegate = _sharePrice + _transfervalue;
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), costs[0]);
    //                 IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, sharetodelegate);
    //             } else {
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
    //             }
    //         }
    //     }
        
    //     NFT_Counters[0].increment();
    //     uint256 tokenId = NFT_Counters[0].current();
    //     ///////////////////
    //     userInvsetment[msg.sender][_referrer]+= _mintPrice; 
    //     rankupLifting(_referrer);
    //     // increment referral count of the referrer
    //     // check if referrer's rank needs to be uplifted
    //     // if (referralCount[_referrer] >= 3 && referralRank[_referrer] == 1) {
    //     //     referralRank[_referrer] = 2;
    //     // }
    //     ///////////////////
    //     _safeMint(msg.sender, tokenId);
    //     _hasToken1[msg.sender] = true;
    // }



    // function mint_Level2_NFT(uint _mintPrice, bool _delegate, address _referrer) public {
    //     require(!_hasToken2[msg.sender], "You already have a Level 2 NFT!");
    //     delegate = _delegate;
    //     /////////////////////
    //     //myReferrer[msg.sender] = _referrer;
    //     setReferrer(_referrer);
        
    //     //////////////////////
    //     uint256 supply = totalSupply();
    //     require(!paused);
    //     require(supply <= maxSupply);
    //     require(totalSupplyOfLevel(1) < NFT_Quantities[1], "can't mint more than this level");
    //     if (msg.sender != owner()) {
    //         if (whitelisted[msg.sender] != true) {
    //             require(_mintPrice >= costs[1], "pay amount can't be low");
    //             if (delegate == true) {
    //                 uint _sharePrice = costs[1] * 10 / 100;
    //                 uint _newmint = costs[1] + _sharePrice;
    //                 require(_mintPrice >= _newmint, "pay amount can't be low; if delegate is true, add 10% more.");
    //                 uint _transfervalue = (_mintPrice - _sharePrice) - costs[1];
    //                 uint sharetodelegate = _sharePrice + _transfervalue;
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), costs[1]);
    //                 IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, sharetodelegate);
    //             } else {
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
    //             }
    //         }
    //     }
    //     NFT_Counters[1].increment();
    //     uint256 tokenId = NFT_Counters[1].current();
    //      /////////////
    //     userInvsetment[msg.sender][_referrer]+= _mintPrice;       //
    //     upLifting(_referrer);
    //     ////////////
    //     _safeMint(msg.sender, tokenId);
    //     _hasToken2[msg.sender] = true;
    // }

    // function mint_Level3_NFT(uint _mintPrice, bool _delegate, address _referrer) public {
    //     require(!_hasToken3[msg.sender], "You already have a Level 3 NFT!");
    //     delegate = _delegate;
    //     /////////////////////
    //     //myReferrer[msg.sender] = _referrer;
    //     setReferrer(_referrer);
        
    //     //////////////////////
    //     uint256 supply = totalSupply();
    //     require(!paused);
    //     require(supply <= maxSupply);
    //     require(totalSupplyOfLevel(2) < NFT_Quantities[2], "can't mint more than this level");
    //     if (msg.sender != owner()) {
    //         if (whitelisted[msg.sender] != true) {
    //             require(_mintPrice >= costs[2], "pay amount can't be low");
    //             if (delegate == true) {
    //                 uint _sharePrice = costs[2] * 10 / 100;
    //                 uint _newmint = costs[2] + _sharePrice;
    //                 require(_mintPrice >= _newmint, "pay amount can't be low; if delegate is true, add 10% more.");
    //                 uint _transfervalue = (_mintPrice - _sharePrice) - costs[2];
    //                 uint sharetodelegate = _sharePrice + _transfervalue;
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), costs[2]);
    //                 IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, sharetodelegate);
    //             } else {
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
    //             }
    //         }
    //     }
    //     NFT_Counters[2].increment();
    //     uint256 tokenId = NFT_Counters[2].current();
    //      /////////////
    //     userInvsetment[msg.sender][_referrer]+= _mintPrice;       //
    //     upLifting(_referrer);

    //     ////////////
    //     _safeMint(msg.sender, tokenId);
    //     _hasToken3[msg.sender] = true;
    // }

    // function mint_Level4_NFT(uint _mintPrice, bool _delegate, address _referrer) public {
    //     require(!_hasToken4[msg.sender], "You already have a Level 4 NFT!");
    //     delegate = _delegate;
    //     /////////////////////
    //     //myReferrer[msg.sender] = _referrer;
    //     setReferrer(_referrer);
        
    //     //////////////////////
    //     uint256 supply = totalSupply();
    //     require(!paused);
    //     require(supply <= maxSupply);
    //     require(totalSupplyOfLevel(3) < NFT_Quantities[3], "can't mint more than this level");
    //     if (msg.sender != owner()) {
    //         if (whitelisted[msg.sender] != true) {
    //             require(_mintPrice >= costs[3], "pay amount can't be low");
    //             if (delegate == true) {
    //                 uint _sharePrice = costs[3] * 10 / 100;
    //                 uint _newmint = costs[3] + _sharePrice;
    //                 require(_mintPrice >= _newmint, "pay amount can't be low; if delegate is true, add 10% more.");
    //                 uint _transfervalue = (_mintPrice - _sharePrice) - costs[3];
    //                 uint sharetodelegate = _sharePrice + _transfervalue;
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), costs[3]);
    //                 IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, sharetodelegate);
    //             } else {
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
    //             }
    //         }
    //     }
    //     NFT_Counters[3].increment();
    //     uint256 tokenId = NFT_Counters[3].current();
    //      /////////////
    //     userInvsetment[msg.sender][_referrer]+= _mintPrice;       //
    //     upLifting(_referrer);

    //     ////////////
    //     _safeMint(msg.sender, tokenId);
    //     _hasToken4[msg.sender] = true;
    // }

    // function mint_Level5_NFT(uint _mintPrice, bool _delegate, address _referrer) public {
    //     require(!_hasToken5[msg.sender], "You already have a Level 5 NFT!");
    //     delegate = _delegate;
    //     /////////////////////
    //     //myReferrer[msg.sender] = _referrer;
    //     setReferrer(_referrer);
        
    //     //////////////////////
    //     uint256 supply = totalSupply();
    //     require(!paused);
    //     require(supply <= maxSupply);
    //     require(totalSupplyOfLevel(4) < NFT_Quantities[4], "can't mint more than this level");
    //     if (msg.sender != owner()) {
    //         if (whitelisted[msg.sender] != true) {
    //             require(_mintPrice >= costs[4], "pay amount can't be low");
    //             if (delegate == true) {
    //                 uint _sharePrice = costs[4] * 10 / 100;
    //                 uint _newmint = costs[4] + _sharePrice;
    //                 require(_mintPrice >= _newmint, "pay amount can't be low; if delegate is true, add 10% more.");
    //                 uint _transfervalue = (_mintPrice - _sharePrice) - costs[4];
    //                 uint sharetodelegate = _sharePrice + _transfervalue;
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), costs[4]);
    //                 IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, sharetodelegate);
    //             } else {
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
    //             }
    //         }
    //     }
    //     NFT_Counters[4].increment();
    //     uint256 tokenId = NFT_Counters[4].current();
    //      /////////////
    //     userInvsetment[msg.sender][_referrer]+= _mintPrice;       //
    //     upLifting(_referrer);

    //     ////////////
    //     _safeMint(msg.sender, tokenId);
    //     _hasToken5[msg.sender] = true;
    // }

    // function mint_Level6_NFT(uint _mintPrice, bool _delegate, address _referrer) public {
    //  //   require(!_hasToken6[msg.sender], "You already have a Level 6 NFT!");
    //     delegate = _delegate;
    //  //////////
    //    // myReferrer[msg.sender] = _referrer;
    //     setReferrer(_referrer);

    //  //////////

    //     uint256 supply = totalSupply();
    //     require(!paused);
    //     require(supply <= maxSupply);
    //     require(totalSupplyOfLevel(5) < NFT_Quantities[5], "can't mint more than this level");
    //     if (msg.sender != owner()) {
    //         if (whitelisted[msg.sender] != true) {
    //             require(_mintPrice >= costs[5], "pay amount can't be low");
    //             if (delegate == true) {
    //                 uint _sharePrice = costs[5] * 10 / 100;
    //                 uint _newmint = costs[5] + _sharePrice;
    //                 require(_mintPrice >= _newmint, "pay amount can't be low; if delegate is true, add 10% more.");
    //                 uint _transfervalue = (_mintPrice - _sharePrice) - costs[5];
    //                 uint sharetodelegate = _sharePrice + _transfervalue;
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), costs[5]);
    //                 IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, sharetodelegate);
    //             } else {
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
    //             }
    //         }
    //     }
    //     NFT_Counters[5].increment();
    //     uint256 tokenId = NFT_Counters[5].current();

    //     /////////////
    //     userInvsetment[msg.sender][_referrer]+= _mintPrice;       //
    //     upLifting(_referrer);

    //     ////////////
    //     _safeMint(msg.sender, tokenId);
    //     _hasToken6[msg.sender] = true;
    // }

    // function mint_Level7_NFT(uint _mintPrice, bool _delegate, address _referrer) public {
    //    // require(!_hasToken7[msg.sender], "You already have a Level 7 NFT!");
    //     delegate = _delegate;
    //     /////////////////////
    //     //myReferrer[msg.sender] = _referrer;
    //     setReferrer(_referrer);
        
    //     //////////////////////
    //     uint256 supply = totalSupply();
    //     require(!paused);
    //     require(supply <= maxSupply);
    //     require(totalSupplyOfLevel(6) < NFT_Quantities[6], "can't mint more than this level");
    //     if (msg.sender != owner()) {
    //         if (whitelisted[msg.sender] != true) {
    //             require(_mintPrice >= costs[6], "pay amount can't be low");
    //             if (delegate == true) {
    //                 uint _sharePrice = costs[6] * 10 / 100;
    //                 uint _newmint = costs[6] + _sharePrice;
    //                 require(_mintPrice >= _newmint, "pay amount can't be low; if delegate is true, add 10% more.");
    //                 uint _transfervalue = (_mintPrice - _sharePrice) - costs[6];
    //                 uint sharetodelegate = _sharePrice + _transfervalue;
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), costs[6]);
    //                 IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, sharetodelegate);
    //             } else {
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
    //             }
    //         }
    //     }
    //     NFT_Counters[6].increment();
    //     uint256 tokenId = NFT_Counters[6].current();
    //      /////////////
    //     userInvsetment[msg.sender][_referrer]+= _mintPrice;       //
    //     upLifting(_referrer);

    //     ////////////
    //     _safeMint(msg.sender, tokenId);
    //     _hasToken7[msg.sender] = true;
    // }

    // function mint_Level8_NFT(uint _mintPrice, bool _delegate, address _referrer) public {
    //     require(!_hasToken8[msg.sender], "You already have a Level 8 NFT!");
    //     delegate = _delegate;
    //     /////////////////////
    //     //myReferrer[msg.sender] = _referrer;
    //     setReferrer(_referrer);
        
    //     //////////////////////
    //     uint256 supply = totalSupply();
    //     require(!paused);
    //     require(supply <= maxSupply);
    //     require(totalSupplyOfLevel(7) < NFT_Quantities[7], "can't mint more than this level");
    //     if (msg.sender != owner()) {
    //         if (whitelisted[msg.sender] != true) {
    //             require(_mintPrice >= costs[7], "pay amount can't be low");
    //             if (delegate == true) {
    //                 uint _sharePrice = costs[7] * 10 / 100;
    //                 uint _newmint = costs[7] + _sharePrice;
    //                 require(_mintPrice >= _newmint, "pay amount can't be low; if delegate is true, add 10% more.");
    //                 uint _transfervalue = (_mintPrice - _sharePrice) - costs[7];
    //                 uint sharetodelegate = _sharePrice + _transfervalue;
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), costs[7]);
    //                 IERC20(_token).safeTransferFrom(msg.sender, delegateAddress, sharetodelegate);
    //             } else {
    //                 IERC20(_token).safeTransferFrom(msg.sender, address(this), _mintPrice);
    //             }
    //         }
    //     }
    //     NFT_Counters[7].increment();
    //     uint256 tokenId = NFT_Counters[7].current();
    //      /////////////
    //     userInvsetment[msg.sender][_referrer]+= _mintPrice;       //
    //     upLifting(_referrer);

    //     ////////////
    //     _safeMint(msg.sender, tokenId);
    //     _hasToken8[msg.sender] = true;
    // }

    //View
    function walletOfOwner(address _owner) public view returns(uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns(string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension));
    }

    function totalSupplyOfLevel(uint256 _level) public view returns(uint256) {
        uint level = _level - 1;
        uint256 total = NFT_Counters[level].current();
        if (level == 0) {
            return total;
        } else if (level == 1) {
            return total - 20;
        } else if (level == 2) {
            return total - 30;
        } else if (level == 3) {
            return total - 40;
        } else if (level == 4) {
            return total - 50;
        } else if (level == 5) {
            return total - 60;
        } else if (level == 6) {
            return total - 70;
        } else if (level == 7) {
            return total - 80;
        } else {
            return total;
        }
    }



    //Internal
    function rankUpdate() internal {
        for (uint i = 0; i < NFTidArray.length; i++) {
            address owner = ERC721.ownerOf(NFTidArray[i]);
            rankupLifting(owner);
        }
    }
    // function totalSupplyOf_L1_NFT() public view returns(uint256) {
    //     return NFT_Counters[0].current();
    // }

    // function totalSupplyOf_L2_NFT() public view returns(uint256) {
    //     uint256 total = NFT_Counters[1].current();
    //     return (total - 20);
    // }

    // function totalSupplyOf_L3_NFT() public view returns(uint256) {
    //     uint256 total = NFT_Counters[2].current();
    //     return (total - 30);
    // }

    // function totalSupplyOf_L4_NFT() public view returns(uint256) {
    //     uint256 total = NFT_Counters[3].current();
    //     return (total - 40);
    // }

    // function totalSupplyOf_L5_NFT() public view returns(uint256) {
    //     uint256 total = NFT_Counters[4].current();
    //     return (total - 50);
    // }

    // function totalSupplyOf_L6_NFT() public view returns(uint256) {
    //     uint256 total =NFT_Counters[5].current();
    //     return (total - 60);
    // }

    // function totalSupplyOf_L7_NFT() public view returns(uint256) {
    //     uint256 total = NFT_Counters[6].current();
    //     return (total - 70);
    // }

    // function totalSupplyOf_L8_NFT() public view returns(uint256) {
    //     uint256 total = NFT_Counters[7].current();
    //     return (total - 80);
    // }

    // function totalSupply() public view override(ERC721Enumerable) returns(uint256) {
    //     uint256 supplyOfLevel1 = totalSupplyOf_L1_NFT();
    //     uint256 supplyOfLevel2 = totalSupplyOf_L2_NFT();
    //     uint256 supplyOfLevel3 = totalSupplyOf_L3_NFT();
    //     uint256 supplyOfLevel4 = totalSupplyOf_L4_NFT();
    //     uint256 supplyOfLevel5 = totalSupplyOf_L5_NFT();
    //     uint256 supplyOfLevel6 = totalSupplyOf_L6_NFT();
    //     uint256 supplyOfLevel7 = totalSupplyOf_L7_NFT();
    //     uint256 supplyOfLevel8 = totalSupplyOf_L8_NFT();
    //     return (supplyOfLevel1 + supplyOfLevel2 + supplyOfLevel3 + supplyOfLevel4 + supplyOfLevel5 + supplyOfLevel6 + supplyOfLevel7 + supplyOfLevel8);
    // }

    function getMyReferrer(address _user) public view returns(address){
        return myReferrer[_user];
    }

    function getReferralCount(address _user) public view returns(uint){
        return referralCount[_user];
    }

    //Admin
    function setBaseURI(
        string memory _baseURI

    ) external onlyOwner {
baseURI=_baseURI;
    }

   function setCost(uint256[] memory newCosts) public onlyOwner {
        require(newCosts.length == 8, "Invalid number of cost values");
        for (uint256 i = 0; i < newCosts.length; i++) {
            costs[i] = newCosts[i];
        }
    }

    function burn(uint256 tokenId_) public onlyOwner {
        _burn(tokenId_);
        uint256 level = tokenId_ / 10; // Integer division to determine the level
        if (level >= 0 && level <= 7) {
            NFT_Counters[level].decrement();
        }
    }

    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }

    function setToken(address _newtoken) public onlyOwner {
        _token = _newtoken;
    }

    function setDelegateAddress(address _delegateAddress) public onlyOwner {
        delegateAddress = _delegateAddress;
    }

    function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
        baseExtension = _newBaseExtension;
    }

    function pause(bool _state) public onlyOwner {
        paused = _state;
    }

    function whitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }

    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    function withdraw() public payable onlyOwner {
        IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this)));
    }

}

/*
0x5B38Da6a701c568545dCfcB03FcB875f56beddC4 - owner
0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB
0x617F2E2fD72FD9D5503197092aC168c91465E7f2
0x17F6AD8Ef982297579C203069C1DbfFE4348c372
0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678
0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7
0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C
0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC

0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c
0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB
0x583031D1113aD414F02576BD6afaBfb302140225
0xdD870fA1b7C4700F2BD7f44238821C26f7392148


                                  5B3
                                /  |  \
                              /    |    \
                           Ab8    4B2      787
                           /\     /  \      / \
                          /  \   |    |    /   \
                       dD8  583  4B0 147  CA3   0A0
                        |         |               |
                        |         |               |
                        1aE       03C            5c6
                        |                         |
                        |                         |
                        617                       17F

0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2","0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db","0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,["0xdD870fA1b7C4700F2BD7f44238821C26f7392148","0x583031D1113aD414F02576BD6afaBfb302140225"]

0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db,["0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB","0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C"]

0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,["0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c","0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC"]

0xdD870fA1b7C4700F2BD7f44238821C26f7392148,["0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C"]

0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB,["0x03C6FcED478cBbC9a4FAB34eF9f40767739D1Ff7"]

0x0A098Eda01Ce92ff4A4CCb7A4fFFb5A43EBC70DC,["0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678"]
0x1aE0EA34a72D944a8C7603FfB3eC30a6669E454C,["0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]
0x5c6B0f7Bf3E7ce046039Bd8FABdfD3f9F5021678,["0x17F6AD8Ef982297579C203069C1DbfFE4348c372"]
*/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
95000000000000000000000
31000000000000000000000

100000000000000000000 false ether;
500000000000000000000 false ether;
1000000000000000000000 false ether;
2500000000000000000000 false ether;
5000000000000000000000 false ether;
10000000000000000000000 false ether;
25000000000000000000000 false ether;
50000000000000000000000 false ether;


                5B3
              /  |  \
           Ab8  4B2   787
         /  |   |  |   |   \
      dD8 583  4B0 147 CA3  0A0
       |         |           |
      1aE       03C         5c6
*/
