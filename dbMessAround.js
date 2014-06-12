var mongojs = require('mongojs')
ObjectId = mongojs.ObjectId;

var db = mongojs('beerandfooddb', ['nodes']);

var setLinks = function(toSet, links){
db.nodes.findAndModify({
query:{_id:toSet},
update:{$set:{links:links}}
}, function(err, doc, lastErrorObject){
console.log(err);
console.log(doc);
});
}

var findByName = function(name){
db.nodes.findOne({
name:name
}, function(err, doc){
console.log(err);
console.log(doc);
})
}