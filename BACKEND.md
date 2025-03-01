# AWS Amplify Backend Documentation

## API Endpoint
The backend provides a simple REST API with the following endpoint:

- **Endpoint**: `/hello`
- **Method**: GET
- **Response Format**: JSON
- **Expected Response**:
```json
{
    "message": "hello"
}
```

## Implementation Details
The backend is implemented using AWS Amplify with the following components:

1. **API Gateway**
   - Service: API Gateway
   - Configuration: `amplify/backend/api/gamenight/api-params.json`
   - Endpoint path: `/hello`
   - Authentication: Open (no authentication required)

2. **Lambda Function**
   - Runtime: Node.js 18.x
   - Handler: `index.handler`
   - Location: `amplify/backend/function/gamenightFunction/src/index.js`
   - Response: Returns a JSON object with a "hello" message
   - CORS: Enabled for all origins

## Deployment
The backend is automatically deployed through AWS Amplify's build process as configured in `amplify.yml`. The process includes:
1. Backend deployment using `amplifyPush`
2. Frontend build and deployment

## Testing
A test script is provided at `amplify/backend/function/gamenightFunction/src/test.js` to verify the Lambda function's behavior locally.

## Future Enhancements
1. Add authentication
2. Implement additional endpoints for game management
3. Add database integration for persistent storage