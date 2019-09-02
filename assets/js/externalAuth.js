window.externalApp = {};
window.externalApp.getExternalAuth = function(options) {
    console.log("Starting external auth");
    var options = JSON.parse(options);
    if (options && options.callback) {
        var responseData = {
            access_token: "[token]",
            expires_in: 1800
        };
        console.log("Waiting for callback to be added");
        setTimeout(function(){
            console.log("Calling a callback");
            window[options.callback](true, responseData);
        }, 500);
    }
};