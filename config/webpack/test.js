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

let enzyme = require('enzyme');
let Adapter = require('enzyme-adapter-react-16');
enzyme.configure({ adapter: new Adapter() });
global.enzyme = enzyme;
