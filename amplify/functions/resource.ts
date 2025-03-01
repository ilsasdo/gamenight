import { defineFunction } from '@aws-amplify/backend';

export const hello = defineFunction({
    name: 'hello',
    entryPoint: 'hello.ts'
});