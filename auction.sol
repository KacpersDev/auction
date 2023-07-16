pragma solidity >=0.7.0 <=0.9.0;

contract TimedAuction {

    uint public finishTime;

    uint currentBid;

    address owner;
    address currentBidder;

    uint current;

    event Bid(address indexed sender, uint256 amount, uint256 timestamp);

    mapping(address => uint) bidders;

    constructor() {
        finishTime = block.timestamp + 5 minutes;
        owner = msg.sender;
    }

    function bid() external payable {
        require(block.timestamp < finishTime, "Auction has finished");
        require(msg.value > currentBid, "Value needs to be larger then current bid");

        if (currentBidder != address(0)) {
            bidders[currentBidder] = currentBid;
        }

        currentBid = msg.value;
        currentBidder = msg.sender;

        emit Bid(msg.sender, msg.value, block.timestamp);
        current += 1;
    }

    function withdraw() public {
        uint bidAmount = bidders[msg.sender];
        bidders[msg.sender] = 0;
        (bool sent,) = payable(msg.sender).call{value: bidAmount}("");
        require(sent, "Failed to send transaction");
        current -= 1;
    }

    function claim() public {
        require(msg.sender == owner, "You must be owner");
        require(block.timestamp > finishTime, "Auction has not finished yet");
        require(current == 0, "Not everybody withdrew yet");        
        (bool sent,) = payable(owner).call{value: currentBid}("");
        require(sent, "Failed to claim");
    }

    function getHighestBidder() public view returns (address) {
        return currentBidder;
    }
}
