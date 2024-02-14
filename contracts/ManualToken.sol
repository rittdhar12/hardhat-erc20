// SPDX-License-Identifie: MIT
pragma solidity ^0.8.7;


interface tokenRecipient{
    function receiveApproval(
        address _from, 
        address _to, 
        uint256 _value,
        bytes calldata _extraData
    ) external;
}


contract ManualToken{

    string public name; 
    string public symbol; 
    uint8 public decimals = 18;
    uint256 public totalSupply;
    // uint256 initialSupply; 
    mapping(address => uint256) public balanceOf; 
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Burn(address indexed from, uint256 value);

    constructor(
        uint256 initialSupply, 
        string memory tokenName, 
        string memory tokenSymbol
    ) {
        totalSupply = initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply; 
        name = tokenName; 
        symbol = tokenSymbol;
    }

    function _transfer( address _from, address _to, uint256 _value) internal {
        require(_to != address(0x0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] * balanceOf[_to] == previousBalances);
    }


    //transfer tokens
    // subtract from address akount and add to to address

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

  /**
   * Transfer tokens from other address
   *
   * Send `_value` tokens to `_to` on behalf of `_from`
   *
   * @param _from The address of the sender
   * @param _to The address of the recipient
   * @param _value the amount to send
   */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) { 
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }



    function approve(address _spender, uint256 _value) public returns(bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }


    function approveAndCall(
        address _spender, 
        uint256 _value, 
        bytes calldata _extraData
    ) public returns (bool success){
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)){
            spender.receiveApproval(msg.sender, address(this), _value, _extraData);
            return true;
        }
    }


    function burn(uint256 _value) public returns (bool success){
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success){
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value; 
        totalSupply -= _value; 
        emit Burn(_from, _value);
        return true;
    }
}