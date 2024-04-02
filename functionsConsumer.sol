// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "https://github.com/smartcontractkit/functions-hardhat-starter-kit/blob/main/contracts/dev/functions/FunctionsClient.sol";
// import "@chainlink/contracts/src/v0.8/dev/functions/FunctionsClient.sol"; // Once published
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";

/**
 * @title Functions Cons contract
 * @notice This contract is a demonstration of using Functions.
 * @notice NOT FOR PRODUCTION USE
 */
contract GeometricMeanFunctions is FunctionsClient, ConfirmedOwner {
  using Functions for Functions.Request;

  bytes32 public latestRequestId;
  bytes public latestResponse;
  uint256 public latestGeometricMean;
  bytes public latestError;


  string public source = "console.log(`calculate geometric mean of ${args}`);"
                         "if (!args || args.length === 0) throw new Error(\"input not provided\");"
                         "const product = args.reduce((accumulator, currentValue) => {"
                            "const numValue = parseInt(currentValue);"
                            "if (isNaN(numValue)) throw Error(`${currentValue} is not a number`);"
                            "return accumulator * numValue;"
                            "}, 1) ;"
                         "const geometricMean = Math.pow(product, 1 / args.length);"
                         "console.log(`geometric mean is: ${geometricMean.toFixed(2)}`);"
                         "return Functions.encodeUint256(Math.round(geometricMean * 100));";
  uint64 public subscriptionId;

  event OCRRequest(bytes32 indexed requestId, string[] args);
  event OCRResponse(bytes32 indexed requestId, uint256 geometricMean, bytes result, bytes err);
  error ArgumentsNotProvided();

  /**
   * @notice Executes once when a contract is created to initialize state variables
   *
   * @param oracle - The FunctionsOracle contract
   */
  constructor(address oracle, uint64 subId) FunctionsClient(oracle) ConfirmedOwner(msg.sender) {
      subscriptionId = subId;
  }


  
  /**
   * @notice Send a simple request
   * @param args List of arguments accessible from within the source code
   */
  function executeRequest(
    string[] calldata args
  ) public onlyOwner returns (bytes32) {
    if (args.length == 0) revert ArgumentsNotProvided();
    Functions.Request memory req;
    req.initializeRequest(Functions.Location.Inline, Functions.CodeLanguage.JavaScript, source);
    req.addArgs(args);
    uint32 gasLimit = 100_000;
    bytes32 assignedReqID = sendRequest(req, subscriptionId, gasLimit);
    latestRequestId = assignedReqID;
    emit OCRRequest(latestRequestId,args);
    return assignedReqID;
  }

  /**
   * @notice Callback that is invoked once the DON has resolved the request or hit an error
   *
   * @param requestId The request ID, returned by sendRequest()
   * @param response Aggregated response from the user code
   * @param err Aggregated error from the user code or from the execution pipeline
   * Either response or error parameter will be set, but never both
   */
  function fulfillRequest(
    bytes32 requestId,
    bytes memory response,
    bytes memory err
  ) internal override {
    latestResponse = response;
    latestError = err;
    latestGeometricMean = abi.decode(response,(uint256));
    emit OCRResponse(requestId, latestGeometricMean, response, err);
  }

  function updateOracleAddress(address oracle) public onlyOwner {
    setOracle(oracle);
  }

  /**
  * @notice Update the subscription id
  * @param subId Billing ID
  *
  */
  function updateSubscriptionId(uint64 subId) public onlyOwner {
      subscriptionId = subId;
  }

  function fundSubscription(address linkTokenAddress, address functionsRegistry, uint256 amountInJuels) external onlyOwner {
      bytes memory data = abi.encode(subscriptionId);

      LinkTokenInterface(linkTokenAddress).transferFrom(msg.sender, address(this), amountInJuels);
      
      LinkTokenInterface(linkTokenAddress).transferAndCall(
          functionsRegistry,
          amountInJuels,
          data
      );
  }

  
}