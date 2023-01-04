// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SampleToken {
    
    string public name = "Sample Token";
    string public symbol = "TOK";
    uint8 public decimals = 18;
    uint256 private totalSupply;
    address private owner;

    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowed;
    
    constructor (uint256 _initialSupply) {
        owner = msg.sender;
        balances[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    modifier isOwner() {
        require(msg.sender == owner, "Only the owner has permission to perform this action");
        _;
    }

     function getOwner() public view returns (address) {
        return owner;
    }

    function getTotalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function balanceOf(address _addr) public view returns (uint256) {
        return balances[_addr];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from,
                   address indexed _to,
                   uint256 _value);

    event Approval(address indexed _owner,
                   address indexed __spender,
                   uint256 _value);

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf(msg.sender) >= _value, "You cannot transfer more than your balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Spender cannot be Address Zero (0)");

        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public payable returns (bool success) {
        require(_value <= balanceOf(_from), "You cannot transfer more than your balance");
        require(_value <= allowance(_from, _to), "You cannot transfer more than you are allowed to");
        require(_to != address(0), "The recipient cannot be Address Zero (0)");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][_to] -= _value;

        emit Transfer(_from, _to, _value);

        return true;
    }

    function mint(uint256 _amount) public isOwner {
        require(_amount % 10000 == 0, "Amount must be a multiple of 10000");

        uint256 newTokens = _amount / 10000;

        balances[msg.sender] += newTokens;
        totalSupply += newTokens;
        allowed[msg.sender][msg.sender] += newTokens;

        emit Approval(msg.sender, msg.sender, newTokens);
    }

    fallback() external payable {}
    
    receive() external payable {}
}