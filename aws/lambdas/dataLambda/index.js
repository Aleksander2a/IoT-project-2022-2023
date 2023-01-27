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
