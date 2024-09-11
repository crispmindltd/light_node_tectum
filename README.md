# Welcome to Tectum Light Node v0.9! #

## Description ##

The Light Node is a component of the Tectum blockchain, designed to provide simplified access to the functionality of the blockchain network. It is developed for user convenience, without requiring full synchronization of the entire blockchain.

Main functions of the Light Node:
1. Token management.
2. Transaction processing.
3. User key management.
4. Interaction with the main network and other system components.

## Web Server ##
The Light Node also includes a local web server that processes these requests and interacts with other system components, such as WalletAPI.
It provides explorer functionality, allowing users to view information about blocks and transactions, as well as an interface for creating new tokens, making transfers, and managing keys.

## Endpoints ##

The Light Node supports the following types of requests:

### Token operations: ###

-   GET /tokens: Retrieve a list of all tokens
-   POST /tokens: Create a new token
-   GET /tokens/fee: Retrieve fee of creating token
-   GET /tokens/ticker: Retrieve information about a specific token
-   POST /tokens/transfer: Transfer tokens
-   GET /tokens/transfer/fee: Retrieve fee of token transfer
-   GET /tokens/transfers: Retrieve token transfer history
-   <details>

<summary>GET /tokens/address/byid: Retrieve the smart contract address by ID</summary>

#### Purpose ####
Retrieve the smart contract address by its ID.

#### Request Description ####


#### Purpose ####

**Method:** `` GET ``

**URL:** `` /token/address/byid ``

#### Request Parameters ####

| Parameter | Required     | Location                | Data Type | Constraints |Description |
| :-------- | :------- | :------------------------- |:-------- | :-------- | :-------- | 
| smart_id | Yes | query | Integer| Positive value | The unique ID of the smart contract |

#### Example Request ####

```
  GET /token/address/byid?smart_id=24
```

#### Response Parameters ####

**Successful Response**

**HTTP Status Code:** ``200 OK``

| Parameter | Required     | Data Type                       | Constraints | Description |
| :-------- | :------- | :-------------------------------- | :-------- | :-------- |
| smart_address      | Yes | String | Valid address format | The smart contract's address |

#### Example Successful Response ####

```json
{
  "smart_address": "0x211865ed10ce8b42ed3ddf63302c7b3d4b7d68d2"
}
```

#### Error Response ####

**Common Error Response Structure**
| Parameter | Required | Data Type | Description |
| :-------- | :------- | :-------- | :--------   |
| error     | Yes      | String    | Error code  |
| message   | Yes    | String    | Error description  |

#### Error Codes ####

| Error Code | HTTP Status Code | Error Description |
| :--------  | :-------         | :--------        | 
| VALIDATION_FAILED | 400 Bad Request | Invalid smart contract ID | 

#### Example Error Response ####

```json
{
  "error": "VALIDATION_FAILED",
  "message": "invalid smart ID"
}

```

#### Workflow ####
1. The user sends a request with the smart contract ID.
2. The server returns the smart contract address if the ID is valid.
3. If the ID is invalid, the server returns an error with details.

</details>

-   GET /tokens/address/byticker: Retrieve the smart contract address by ticker
-   GET /tokens/balance/byaddress: Retrieve token balance by address
-   GET /tokens/balance/byticker: Retrieve token balance by ticker

### TET operations: ###

-   GET /coins/balances: Retrieve balances for multiple tokens
-   POST /coins/transfer: Transfer TET
-   GET /coins/transfers: Retrieve TET transfer history
-   GET /coins/transfers/user: Retrieve TET transfer history for user
-   GET /coins/transfers/fee: Retrieve fee for transfer

### User management: ###

-   POST /user/auth: User authentication
-   POST /user/registration: Register a new user

### Key management: ###

-   POST /keys/generate: Generate new keys
-   POST /keys/recover: Recover keys using a seed phrase
-   GET /keys/public/byuserid: Retrieve the public key by user ID
-   GET /keys/public/byskey: Retrieve the public key by session key

### Blocks: ###

-   GET /blockscount: Retrieve count of blocks

### Additional functions: ###


## Launch ##
To start testing Tectum blockchain, you need to run the Tectum Lite file Node.exe. During startup, a reaction from the antivirus / firewall is possible, this is due to the features of the software, it is necessary to ignore the warning and continue the launch. We do NOT DISTRIBUTE malware, and you can be sure of the security of the application being launched.
After launching the application, you will be asked to enter your login details or register. When using it for the first time, click the "registration" button and fill in the required fields. The account is activated instantly!
The Light Node is designed with the necessity of ensuring the security of user data, including the use of session keys and encryption of sensitive information.

## Usage of the Light node: ##
1.	__The "Node" window.__ 
This window displays blockchain events in real time.
2.	__The "Briefcase" window.__
In this window, you can perform all the basic actions with the system using TET test tokens. In the "Make transaction" section, click the "Refresh" button to get a list of tokens available for transactions. 
Upon registration, you are automatically credited with 1000 TET. Click on the token in the list in the "My tokens" window on the right side of the interface in the "Transfer" window, you will see your TET address. You can share this address with another member to have them transfer TET Test tokens to your account. You can also transfer TET from your wallet to any Test participant.
In the __"Token" section__, you can get information about the ICO of the used token by entering the ICO number from the "My tokens" window of the "Make transaction" section in the "Token ID" field.
The __"Blocks" section__ displays information about the specified range of blockchain blocks (you can set a range of no more than 10 blocks).
The __Latest block section__ displays comprehensive information about the latest block range, including transaction speed, hash rate, and other block write parameters.
The __"Report" section__ displays information about the last 10 transactions between network members.
