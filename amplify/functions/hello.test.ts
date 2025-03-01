import { describe, it, expect } from 'vitest';
import { handler } from './hello';

describe('hello function', () => {
    it('returns a 200 status code', async () => {
        const result = await handler({});
        expect(result.statusCode).toBe(200);
    });

    it('returns a JSON response with message and timestamp', async () => {
        const result = await handler({});
        const body = JSON.parse(result.body);
        
        expect(body).toHaveProperty('message');
        expect(body).toHaveProperty('timestamp');
        expect(body.message).toBe('Hello from GameNight!');
        expect(new Date(body.timestamp)).toBeInstanceOf(Date);
    });

    it('includes correct Content-Type header', async () => {
        const result = await handler({});
        expect(result.headers['Content-Type']).toBe('application/json');
    });
});