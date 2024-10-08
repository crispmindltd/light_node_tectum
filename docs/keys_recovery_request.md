
## Purpose
Recover the public and private keys using a provided seed phrase.

### Request Description
- **Method**: POST  
- **URL**: `/keys/recover`

### Request Parameters

| Parameter    | Required | Location | Data Type | Constraints      | Description                     |
| ------------ | -------- | -------- | --------- | ---------------- | ------------------------------- |
| seed_phrase  | Yes      | Body     | String    | 12-24 words      | The user's seed phrase          |

#### Example Request in JSON Format
```json
{
  "seed_phrase": "order viable diary vibrant satoshi sand blouse dry throw boil plate slender"
}
```

### Response Parameters

#### Successful Response
- **HTTP Status Code**: 200 OK

| Parameter    | Required | Data Type | Description                   |
| ------------ | -------- | --------- | ----------------------------- |
| private_key  | Yes      | String    | The recovered private key     |
| public_key   | Yes      | String    | The recovered public key      |

#### Example Successful Response
```json
{
  "private_key": "4c547e137bb4ae7b8bb81171359583054b2db19c82bd7beba803c6ae5f840165",
  "public_key": "04e8ec7f7aff597b56b1f0c23a6642e393d32a015bd15e369b1d0234948322940613a49ecee827983d7e5b38c5535af33106dcdf40b68348fe227f7bee1347cae6"
}
```

### Error Response
#### Common Error Response Structure

| Parameter | Required | Data Type | Description          |
| --------- | -------- | --------- | -------------------- |
| error     | Yes      | String    | Error code           |
| message   | Yes      | String    | Error description    |

### Error Codes

| Error Code              | HTTP Status Code  | Error Description                  |
| ----------------------- | ----------------- | ---------------------------------- |
| VALIDATION_FAILED       | 400 Bad Request   | Incorrect seed phrase              |

#### Example Error Response
```json
{
  "error": "VALIDATION_FAILED",
  "message": "incorrect seed phrase"
}
```

### Workflow
1. The user submits a seed phrase.
2. If valid, the server returns the corresponding public and private keys.
3. If the seed phrase is invalid, the server returns an error.
