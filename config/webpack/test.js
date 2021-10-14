process.env.NODE_ENV = process.env.NODE_ENV || 'development';

const environment = require('./environment');

module.exports = environment.toWebpackConfig();

const { assert, expect } = require('chai');
global.assert = assert;
global.expect = expect;

let jsdom = require('jsdom');
const { JSDOM } = jsdom;
const { document } = (new JSDOM('')).window;
global.document = document;
