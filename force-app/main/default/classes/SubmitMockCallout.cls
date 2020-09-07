/*
 * Created by: Mathew
 * Description : Apex class which implements HttpCalloutMock and the respond method.
 * This method will help generate mock responses in the context of unit testing.            
 */

global class SubmitMockCallout implements HttpCalloutMock {
    private String body;
    public SubmitMockCallout(String body){
        this.body = body;
    }
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setBody(this.body);
        if(this.body.contains('error')){
            response.setStatus('KO');
            response.setStatusCode(500);
        }else{
            response.setStatus('OK');
            response.setStatusCode(200);            
        }
        return response;
    }
}