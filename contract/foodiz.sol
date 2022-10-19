// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
@title A restaurant App
@author  francessNewdev
@notice A smart contract to Add Meal and Purchase/Order Meal with cUsd token 
*/


/**
@dev An interface contract to interact with an ERC-20 token
*/
interface IERC20Token {

    /**
    @dev ERC-20 standard functions for a token 
    */
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

/**
The event to be emited upon successful transfers and approval to the blockchain
*/
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
@dev The foodiz contract for controllin the food app 
*/
contract Foodiz {

    event AddNewMeal(address Creator, string indexed Name, string indexed Image, uint indexed Price);
    event PurchasedMeal(address indexed buyer, uint indexed totalAmount);
    uint256 internal mealsLength;
    address internal owner;

    /// Added the token address
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;



    struct Order {
        uint256 mealId;
        uint256 count;
    }

    struct Meal {
        string name;
        string image;
        uint256 price;
        uint256 sold;
    }




    mapping(uint256 => Meal) internal meals;
    mapping(uint256 => bool) internal mealExists;

    ///Variables Created and assigned value upon deployment of conttract
    constructor() {
        owner = msg.sender;
        mealsLength = 0;
    }


    /**
    @dev A function to add meal to the meu list 
    Enusre the price of the meal is greater than 0
    @param _name The name of the meal
    @param _image the link of the image(image url)
    @param _price The amount the meal will cost
    */
    function addNewMeal(
        string memory _name,
        string memory _image,
        uint256 _price
    ) public {
        require(_price > 0, "Price must be greater than 0");
        /// This will keep total amount of sales this meal has acquired
        uint256 _sold = 0;
        meals[mealsLength] = Meal(_name, _image, _price, _sold);
        mealExists[mealsLength] = true;
        emit AddNewMeal(msg.sender,_name,_image,_price);
        /// When a meal is bought the total amount of meal is 
        mealsLength++;
    }

    /**
    @dev Function for placing orders with available meals in the menu, There are checks to make sure only food in the menu can be ordered 
    */
    function placeOrder(Order[] memory _orders) public payable {
        uint256 _totalAmount;
        for (uint256 i = 0; i < _orders.length; i++) {
            Order memory _order = _orders[i];
            Meal storage _meal = meals[_order.mealId];
            require(mealExists[_order.mealId] == true, "Meal does not exist");
            _totalAmount += _meal.price * _order.count;

            /// emit the event PurchasedMeal
            emit PurchasedMeal(msg.sender, _totalAmount);
            _meal.sold += _order.count;
        }
        require(_totalAmount == msg.value, "Invalid Amount Sent");

        /** A function like this will be required to emitted to ensure a certain amount is sent to the owner of the meal
        for now i am sending it to the cotract address
        */
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            0x267174CA118F870832Be54C29343b7bdABAD54B8,
            _totalAmount
          ),
          "Transfer failed."
        );
        // transfer amount
        (bool success, ) = payable(owner).call{value: msg.value}("");
        require(success, "Transfer of order amount failed");
    }


    /**
    @dev Get the details of the meal using its index
    @param _index the index of the meal in the map function to provide the details of a particular meal in that array
    @return meals[_index].name The name of the meal
    @return meals[_index].image The Image link of the meal
    @return meals[_index].price The cost of the meal
    @return meals[_index].sold The amount of times the has been sold
    */
    function getMeal(uint256 _index)
        public
        view
        returns (
            string memory,
            string memory,
            uint256,
            uint256
        )
    {
        return (
            meals[_index].name,
            meals[_index].image,
            meals[_index].price,
            meals[_index].sold
        );
    }


    /**
    @dev Get the total amount of meals in the menu
    @return number The total number of meals you have in the menu
    */
    function getMealslength() public view returns (uint256) {
        return (mealsLength);
    }
}
