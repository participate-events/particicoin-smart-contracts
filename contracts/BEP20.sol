// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import  "./IBEP20.sol";
import  "./Ownable.sol";
import  "./SafeMath.sol";

contract BEP20 is Context, IBEP20, Ownable {
  using SafeMath for uint256;

  uint256 constant thirtyDays      = 2592000;
  uint256 constant cliffSixM       = 6;
  uint256 constant cliffFourM      = 4;
  uint256 constant cliffThreeM     = 3;
  uint256 constant cliffOneM       = 1;

  uint8   constant _decimals       = 9;
  string  constant _name           = "Particicoin";
  string  constant _symbol         = "PTC";

  uint256 constant  _wallet1MonthlySupply        = 115694444           * (10 ** uint256(_decimals)); // Reserve
  uint256 constant  _wallet2MonthlySupply        = 95000000            * (10 ** uint256(_decimals)); // Associates and Team (52 777 778 + 42 222 222)
  uint256 constant  _wallet3MonthlySupply        = 214583334           * (10 ** uint256(_decimals)); // Platform, Private Sale and Marketing (35 416 667 + 37 500 000 + 141 666 667)
  uint256 constant  _wallet4MonthlySupply        = 106250000           * (10 ** uint256(_decimals)); // ICO Round 1
  uint256 constant  _wallet5MonthlySupply        = 200000000           * (10 ** uint256(_decimals)); // ICO Round 2

  uint256 constant  _wallet1EndOfIcoSupply       = 367500008           * (10 ** uint256(_decimals));
  uint256 constant  _wallet2EndOfIcoSupply       = 90000000            * (10 ** uint256(_decimals)); // Associates and Team (50 000 000 + 40 000 000)
  uint256 constant  _wallet3EndOfIcoSupply       = 424999992           * (10 ** uint256(_decimals)); // Platform, Private Sale and Marketing (75 000 000 + 50 000 000 + 300 000 000)
  uint256 constant  _wallet4EndOfIcoSupply       = 112500000           * (10 ** uint256(_decimals));
  uint256 constant  _wallet5EndOfIcoSupply       = 200000000           * (10 ** uint256(_decimals));
  uint256 constant  _wallet6EndOfIcoSupply       = 1000000000          * (10 ** uint256(_decimals));

  uint256 constant  _maxSupply_6M                = 4250000000          * (10 ** uint256(_decimals)); // Reserve, Associates and Team cap
  uint256 constant  _maxSupply_4M                = 3000000000          * (10 ** uint256(_decimals)); // Platform, Private Sale and Marketing cap
  uint256 constant  _maxSupply_3M                = 750000000           * (10 ** uint256(_decimals)); // ICO Round 1 cap
  uint256 constant  _maxSupply_1M                = 1000000000          * (10 ** uint256(_decimals)); // ICO Round 2 cap

  uint256 constant  _maxSupply                   = 10000000000         * (10 ** uint256(_decimals)); // 10 MD

  address private immutable _wallet1;
  address private immutable _wallet2;
  address private immutable _wallet3;
  address private immutable _wallet4;
  address private immutable _wallet5;
  address private immutable _wallet6;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint256 private _totalSupply_6M;
  uint256 private _totalSupply_4M;
  uint256 private _totalSupply_3M;
  uint256 private _totalSupply_1M;

  uint256 private _startTime_1M;
  uint256 private _startTime_3M;
  uint256 private _startTime_4M;
  uint256 private _startTime_6M;

  uint256 private _endOfICO;


  constructor(address wallet1, address wallet2, address wallet3, address wallet4, address wallet5, address wallet6)  {
    require(wallet1 != address(0), "BEP20: wallet1 is the zero address");
    require(wallet2 != address(0), "BEP20: wallet2 is the zero address");
    require(wallet3 != address(0), "BEP20: wallet3 is the zero address");
    require(wallet4 != address(0), "BEP20: wallet4 is the zero address");
    require(wallet5 != address(0), "BEP20: wallet5 is the zero address");
    require(wallet6 != address(0), "BEP20: wallet6 is the zero address");
    
    _balances[msg.sender] = 0;

    _endOfICO             = block.timestamp;
    _startTime_1M         = _endOfICO + (thirtyDays * 1); // 1 month after
    _startTime_3M         = _endOfICO + (thirtyDays * 3); // 3 month after
    _startTime_4M         = _endOfICO + (thirtyDays * 4); // 4 month after
    _startTime_6M         = _endOfICO + (thirtyDays * 6); // 6 month after

    _wallet1        = wallet1; // Reserve address
    _wallet2        = wallet2; // Associates and Team address
    _wallet3        = wallet3; // Platform, Private Sale and Marketing Address
    _wallet4        = wallet4; // Round 1 Address
    _wallet5        = wallet5; // Round 2 Address
    _wallet6        = wallet6; // Round 3 Address

    _mint(wallet1, _wallet1EndOfIcoSupply);
    _mint(wallet2, _wallet2EndOfIcoSupply);
    _mint(wallet3, _wallet3EndOfIcoSupply);
    _mint(wallet4, _wallet4EndOfIcoSupply);
    _mint(wallet5, _wallet5EndOfIcoSupply);
    _mint(wallet6, _wallet6EndOfIcoSupply);
    _totalSupply_1M   = _totalSupply_1M.add(_wallet5EndOfIcoSupply);
    _totalSupply_3M   = _totalSupply_3M.add(_wallet4EndOfIcoSupply);
    _totalSupply_4M   = _totalSupply_4M.add(_wallet3EndOfIcoSupply);
    _totalSupply_6M   = _totalSupply_6M.add(_wallet1EndOfIcoSupply).add(_wallet2EndOfIcoSupply);
  }

  /**
   * @dev Returns the bep token owner.
   */
  function getOwner() external view override returns (address) {
    return owner();
  }
  /**
   * @dev Returns  Round 3 address.
   */
  function getRound3Add() external view returns (address) {
    return _wallet6;
  }

  /**
   * @dev Returns  Round 2 address.
   */
  function getRound2Add() external view returns (address) {
    return _wallet5;
  }

  /**
   * @dev Returns  Round 1 address.
   */
  function getRound1Add() external view returns (address) {
    return _wallet4;
  }

  /**
   * @dev Returns  Private Sale address.
   */
  function getPrivateSaleAdd() external view returns (address) {
    return _wallet3;
  }

  /**
   * @dev Returns  Associates and Team address.
   */
  function getTeamAdd() external view returns (address) {
    return _wallet2;
  }

  /**
   * @dev Returns  Reserve address.
   */
  function getReserveAdd() external view returns (address) {
    return _wallet1;
  }

  /**
   * @dev Returns the token decimals.
   */
  function decimals() external pure override returns (uint8) {
    return _decimals;
  }

  /**
   * @dev Returns the token symbol.
   */
  function symbol() external pure override returns (string memory) {
    return _symbol;
  }

  /**
  * @dev Returns the token name.
  */
  function name() external pure override returns (string memory) {
    return _name;
  }

  /**
   * @dev See {BEP20-totalSupply}.
   */
  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev See {BEP20-balanceOf}.
   */
  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  /**
   * @dev Returns the cap on the token's total supply.
   */
  function maxSupply() public pure returns (uint256) {
    return _maxSupply;
  }

  /**
   * @dev Returns the end of ico .
   */
  function getEndOfICO() external view returns (uint256) {
    return _endOfICO;
  }

  /**
   * @dev See {BEP20-startTime}.
   */
  function startTime() external view returns (uint256) {
    return _endOfICO;
  }

  /**
   * @dev See {BEP20-transfer}.
   *
   * Requirements:
   *
   * - `recipient` cannot be the zero address.
   * - the caller must have a balance of at least `amount`.
   */
  function transfer(address recipient, uint256 amount) external virtual override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    return true;
  }

  /**
   * @dev See {BEP20-allowance}.
   */
  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  /**
   * @dev See {BEP20-approve}.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function approve(address spender, uint256 amount) external virtual override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  /**
   * @dev See {BEP20-transferFrom}.
   *
   * Emits an {Approval} event indicating the updated allowance. This is not
   * required by the EIP. See the note at the beginning of {BEP20};
   *
   * Requirements:
   * - `sender` and `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   * - the caller must have allowance for `sender`'s tokens of at least
   * `amount`.
   */
  function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }

  /**
   * @dev Atomically increases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   */
  function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  /**
   * @dev Atomically decreases the allowance granted to `spender` by the caller.
   *
   * This is an alternative to {approve} that can be used as a mitigation for
   * problems described in {BEP20-approve}.
   *
   * Emits an {Approval} event indicating the updated allowance.
   *
   * Requirements:
   *
   * - `spender` cannot be the zero address.
   * - `spender` must have allowance for the caller of at least
   * `subtractedValue`.
   */
  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  /** @dev Creates `amount` tokens and assigns them to the right
	 * adresses (associatesAdd, teamAdd, seedAdd, privSaleAdd,
	 * marketingAdd, icoRound1Add , icoRound2Add, icoRound3Add,
	 * reserveAdd), increasing _totalSupply_XM sub-supplies and
	 * the total supply
  */
  function mint(uint256 mintValue) external onlyOwner returns (bool) {
    require(( mintValue == cliffSixM) ||  (mintValue == cliffFourM) || (mintValue == cliffThreeM) || (mintValue == cliffOneM), "BEP20: mint value not authorized");
    
    if (mintValue == cliffSixM){
      require(block.timestamp >= _startTime_6M , "BEP20: too early for minting request");
      require(_totalSupply_6M.add(_wallet1MonthlySupply).add(_wallet2MonthlySupply) <= _maxSupply_6M, "BEP20: Reserve, Associates and Team cap exceeded");
      require(_totalSupply.add(_wallet1MonthlySupply).add(_wallet2MonthlySupply) <= maxSupply(), "BEP20: cap exceeded");
      _mint(_wallet1, _wallet1MonthlySupply);
      _mint(_wallet2, _wallet2MonthlySupply);
      _totalSupply_6M   = _totalSupply_6M.add(_wallet1MonthlySupply).add(_wallet2MonthlySupply);
      _startTime_6M     = _startTime_6M.add(thirtyDays);
    }
    else if (mintValue == cliffFourM){
      require(block.timestamp >= _startTime_4M , "BEP20: too early for minting request");
      require(_totalSupply_4M.add(_wallet3MonthlySupply) <= _maxSupply_4M, "BEP20: Platform, Private Sale and Marketing cap exceeded");
      require(_totalSupply.add(_wallet3MonthlySupply) <= maxSupply(), "BEP20: cap exceeded");
      _mint(_wallet3, _wallet3MonthlySupply);
      _totalSupply_4M   = _totalSupply_4M.add(_wallet3MonthlySupply);
      _startTime_4M     = _startTime_4M.add(thirtyDays);  
    }
    else if (mintValue == cliffThreeM){
      require(block.timestamp >= _startTime_3M, "BEP20: too early for minting request");
      require(_totalSupply_3M.add(_wallet4MonthlySupply) <= _maxSupply_3M, "BEP20: ICO Round 1 cap exceeded");
      require(_totalSupply.add(_wallet4MonthlySupply) <= maxSupply(), "BEP20: cap exceeded");
      _mint(_wallet4, _wallet4MonthlySupply);
      _totalSupply_3M   = _totalSupply_3M.add(_wallet4MonthlySupply);
      _startTime_3M     = _startTime_3M.add(thirtyDays);
    }
    else if (mintValue == cliffOneM){
      require(block.timestamp >= _startTime_1M, "BEP20: too early for minting request");
      require(_totalSupply_1M.add(_wallet5MonthlySupply) <= _maxSupply_1M, "BEP20: ICO Round 2 cap exceeded");
      require(_totalSupply.add(_wallet5MonthlySupply) <= maxSupply(), "BEP20: cap exceeded");
      _mint(_wallet5, _wallet5MonthlySupply);
      _totalSupply_1M   = _totalSupply_1M.add(_wallet5MonthlySupply);
      _startTime_1M     = _startTime_1M.add(thirtyDays);
    }
    return true;
  }


  /**
    * @dev Destroys `amount` tokens from the caller.
    *
    * See {ERC20-_burn}.
    */
  function burn(uint256 amount) external returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  /**
    * @dev Destroys `amount` tokens from `account`, deducting from the caller's
    * allowance.
    *
    * See {ERC20-_burn} and {ERC20-allowance}.
    *
    * Requirements:
    *
    * - the caller must have allowance for ``accounts``'s tokens of at least
    * `amount`.
    */
  function burnFrom(address account, uint256 amount) external returns (bool) {
    _burnFrom(account, amount);
    return true;
  }

  /**
   * @dev Moves tokens `amount` from `sender` to `recipient`.
   *
   * This is internal function is equivalent to {transfer}, and can be used to
   * e.g. implement automatic token fees, slashing mechanisms, etc.
   *
   * Emits a {Transfer} event.
   *
   * Requirements:
   *
   * - `sender` cannot be the zero address.
   * - `recipient` cannot be the zero address.
   * - `sender` must have a balance of at least `amount`.
   */
  function _transfer(address sender, address recipient, uint256 amount) internal virtual {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  /** @dev Creates `amount` tokens and assigns them to `account`, increasing
   * the total supply.
   *
   * Emits a {Transfer} event with `from` set to the zero address.
   *
   * Requirements
   *
   * - `to` cannot be the zero address.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`, reducing the
   * total supply.
   *
   * Emits a {Transfer} event with `to` set to the zero address.
   *
   * Requirements
   *
   * - `account` cannot be the zero address.
   * - `account` must have at least `amount` tokens.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
   *
   * This is internal function is equivalent to `approve`, and can be used to
   * e.g. set automatic allowances for certain subsystems, etc.
   *
   * Emits an {Approval} event.
   *
   * Requirements:
   *
   * - `owner` cannot be the zero address.
   * - `spender` cannot be the zero address.
   */
  function _approve(address owner, address spender, uint256 amount) internal virtual {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  /**
   * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
   * from the caller's allowance.
   *
   * See {_burn} and {_approve}.
   */
  function _burnFrom(address account, uint256 amount) internal {
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
    _burn(account, amount);
  }
}
