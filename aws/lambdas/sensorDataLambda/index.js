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
