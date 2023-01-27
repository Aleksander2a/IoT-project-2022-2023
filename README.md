# IoT-project-2022-2023

## Columns in the table to store sensor data:
| device_id      | temperature | humidity     | pressure | creation_time |
| :---           |    :----:   | :----:       |:----:    |          ---: |

## Sample MQTT message from ESP32 to topic `<device_id>/data`:
- messages to topics defined by `'+/data'` are then passed to the below lambda function that saves data
- this is done by AWS IoT Rule with Lambda action

```json
{
    "device_id": "4095064076",
    "humidity": 4,
    "pressure": 4,
    "temperature": 4,
    "creation_time": 1674582604
}
```

## Lambda Function to save data from MQTT message:
- checks if the device sending the message is acknowledged by any user
- if it is, then data is saved to DynamoDB

```js
const AWS = require('aws-sdk');
AWS.config.update({region: "eu-west-1"});

exports.handler = async (event, context) => {
    if (event.device_id == null) return {"response": "no device_id in message"};
    const dc = new AWS.DynamoDB.DocumentClient({region: "eu-west-1"});
    
    const paramsNewSensorDataObject = {
        TableName: "SensorDataNew",
        Item: {
            "temperature": event.temperature,
            "humidity": event.humidity,
            "pressure": event.pressure,
            "device_id": event.device_id,
            "creation_time": event.creation_time
        }
    }
    
    const paramsUsers = {
        TableName: "Users-4s4hbpqw45ghllspmndvdabz7u-betae",
        FilterExpression: "device_id = :device_id",
        ExpressionAttributeValues: {
            ":device_id": event.device_id
        }
    };
    
    try {
        // return users that have this device_id assigned to their profile
        // may return multpile users, like roomates connected to the same device
        var data = await dc.scan(paramsUsers).promise();
        console.log(data);
        
        // check if any users are returned (this device is used by someone)
        if (!isEmptyObject(data.Items)) {
            // if the device is used, save data to DB
            dc.put(paramsNewSensorDataObject, function(err, data) {
                if (err) {
                    console.log("Error", err);
                } else {
                    console.log("Success", data);
                }
            });
            return event
        } else {
            return "Wrong device_id"
        }
    } catch(err) {
        console.log(err);
        return err
    }
    
};

function isEmptyObject(obj) {
  return !Object.keys(obj).length;
}
```

## Lambda Function to retrieve last sensor data by `device_id` param in the URL:
- this function is exposed using API GATEWAY

```js
const AWS = require('aws-sdk');
AWS.config.update({region: "eu-west-1"});

exports.handler = async (event, context) => {
    const dc = new AWS.DynamoDB.DocumentClient({region: "eu-west-1"});
    
    const params = {
        TableName: "SensorDataNew",
        KeyConditionExpression: "device_id = :device_id",
        Limit: 1,
        ScanIndexForward: false,
        ExpressionAttributeValues: {
            ":device_id": event.device_id
        }
    };
    
    try {
        var data = await dc.query(params).promise();
        console.log(data);
        return data.Items
    } catch(err) {
        console.log(err);
        return err
    }
    
};
```
