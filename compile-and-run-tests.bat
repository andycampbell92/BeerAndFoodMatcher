CALL coffee -cj server.js -o . server-source\server.coffee
CALL coffee -cj rest-server.js -o .\test server-source\test.coffee
node_modules\.bin\mocha