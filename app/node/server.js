const Http = require("http");
const Url = require("url");


function serverError(response, err) {
    response.writeHeader(500, {"Content-Type": "text/plain"});
    response.write(err.toString());
    response.end();                    
}

function invalidMethod(response) {
    response.writeHeader(405);
    response.end();
}

function notFound(response, err) {
    response.writeHeader(404, {"Content-Type": "text/plain"});
    response.write(err.toString());
    response.end();
}

function badRequest(response, err) {
    response.writeHeader(400, {"Content-Type": "text/plain"});
    response.write(err.toString());
    response.end();
}

Http.createServer(function(request,response){
    console.log(request.url);
    var pathname = Url.parse(request.url).pathname;

    if (request.method == "GET") {
        if (pathname.startsWith("/tx/")) {
	    var txHash = pathname.slice(4, 70);
	    web3.eth.getTransaction(txHash, function (err, tx) {
		if (err) {
		    serverError(response, err);
		} else {
		    response.writeHeader(200, {"Content-Type": "application/json"});
		    response.write(JSON.stringify(tx));
		    response.end();
		}
	    });
        } else notFound(response);
    } else if (request.method == "POST") {
        if (false) { ; 
        } else notFound(response);
    } else notFound(response);


}).listen(8080);
