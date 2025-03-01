# GameNight Amplify Backend

## Hello Function Implementation

A new hello function has been implemented with the following components:

1. **Function Implementation** (`functions/hello.ts`):
   - Simple REST API endpoint
   - Returns JSON response with message and timestamp
   - Proper TypeScript typing

2. **Test Suite** (`functions/hello.test.ts`):
   - Tests status code
   - Tests response structure
   - Tests content type headers

3. **Configuration**:
   - Function resource definition in `functions/resource.ts`
   - Backend integration in `backend.ts`
   - Test configuration in `vitest.config.ts`
   - TypeScript configuration in `tsconfig.json`

## Setup Instructions

1. Install dependencies:
   ```bash
   cd amplify
   npm install
   ```

2. Run tests:
   ```bash
   npm test
   ```

3. Deploy the function:
   ```bash
   amplify push
   ```

## Testing the Deployed Function

After deployment, you can test the function using:

```bash
curl -X GET <function-url>
```

The response should look like:
```json
{
    "message": "Hello from GameNight!",
    "timestamp": "2024-01-01T00:00:00.000Z"
}
```