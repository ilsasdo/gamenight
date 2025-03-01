const { handler } = require('./index');

async function test() {
    try {
        const response = await handler({});
        console.log('[DEBUG_LOG] Response:', response);
        
        if (response.statusCode !== 200) {
            console.log('[DEBUG_LOG] Error: Expected status code 200 but got', response.statusCode);
            return;
        }

        const body = JSON.parse(response.body);
        if (body.message !== "hello") {
            console.log('[DEBUG_LOG] Error: Expected message "hello" but got', body.message);
            return;
        }

        console.log('[DEBUG_LOG] Test passed successfully!');
    } catch (error) {
        console.log('[DEBUG_LOG] Test failed with error:', error);
    }
}

test();